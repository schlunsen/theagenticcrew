#!/usr/bin/env python3
"""
Generate and master the presentation narration in Rasmus's own voice.

- Scripts: scripts/narration/presentation.json (English + Spanish, slide order)
- Voice:   voice clone of assets/voice-ref.wav via Atlas Cloud (bytedance/seed-audio-1.0)
- Auth:    ATLASCLOUD_API_KEY environment variable (never commit the key)
- Output:  website/public/presentation-audio/slide-NN.mp3 and slide-NN-es.mp3

Why chunking: the TTS model stops at a fixed maximum length (~29 s). Sending a
whole slide in one request silently truncated long narrations. We synthesise one
or two sentences at a time, verify each chunk, and join them with natural pauses.

Mastering (per slide): trim chunk silences -> join with pauses -> high-pass,
tame low-mids, add presence, de-ess, gentle compression, slight slow-down ->
gain to -16 LUFS and a true-peak limiter at -1.5 dBTP -> head/tail padding
and fades -> 44.1 kHz mono MP3.

Usage:
  python3 scripts/generate-presentation-audio.py            # all slides, both languages
  python3 scripts/generate-presentation-audio.py --lang en  # English only
  python3 scripts/generate-presentation-audio.py --slides 2,5 --force
"""

import argparse
import base64
import json
import re
import subprocess
import sys
import tempfile
import os
import time
import wave
from concurrent.futures import ThreadPoolExecutor
from difflib import SequenceMatcher
import threading
from pathlib import Path

import requests

BASE_DIR = Path(__file__).resolve().parent.parent
SCRIPTS = BASE_DIR / "scripts" / "narration" / "presentation.json"
OUTPUT_DIR = BASE_DIR / "website" / "public" / "presentation-audio"
REF_AUDIO = BASE_DIR / "assets" / "voice-ref.wav"
ATLAS = "https://api.atlascloud.ai/api/v1/model"
TTS_MODEL = "bytedance/seed-audio-1.0"
VOICE_PROMPT = "Use the voice of @audio1 and say: "
PARALLEL = 2

MAX_CHUNK_CHARS = 170        # ~10-12 s of speech, far below the model's cap
MAX_CHUNK_SECONDS = 26.0     # anything near the cap is treated as truncated
PAUSE_BETWEEN_CHUNKS = 0.34  # seconds
SAMPLE_RATE = 24000          # TTS native rate; we resample everything to this
TEMPO = 0.95                 # slightly slower, unhurried narration
TARGET_LUFS = -16.0
TARGET_TP = -1.5
TARGET_LRA = 7.0
HEAD_PAD, TAIL_PAD = 0.35, 0.7

MASTER_CHAIN = ",".join([
    "highpass=f=80",
    "equalizer=f=250:t=q:w=1.2:g=-2",   # reduce boxiness
    "equalizer=f=3200:t=q:w=1.0:g=1.5", # presence
    "deesser=i=0.35",
    "acompressor=threshold=-21dB:ratio=2.5:attack=8:release=140:makeup=1.5",
    f"atempo={TEMPO}",
    "alimiter=limit=0.6:attack=4:release=60:level=false",  # peak control so loudnorm can reach target
])


def run(cmd, **kw):
    return subprocess.run(cmd, check=True, capture_output=True, text=True, **kw)


def split_chunks(text, limit=MAX_CHUNK_CHARS):
    sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", text) if s.strip()]
    chunks, cur = [], ""
    for s in sentences:
        # very long sentence: split on commas/colons
        parts = [s] if len(s) <= limit else [p.strip() for p in re.split(r"(?<=[,:;])\s+", s)]
        for p in parts:
            if cur and len(cur) + 1 + len(p) > limit:
                chunks.append(cur)
                cur = p
            else:
                cur = f"{cur} {p}".strip()
    if cur:
        chunks.append(cur)
    return chunks


def _headers():
    key = os.environ.get("ATLASCLOUD_API_KEY")
    if not key:
        sys.exit("Set ATLASCLOUD_API_KEY in the environment.")
    return {"Authorization": f"Bearer {key}"}


def prepare_reference(tmpdir):
    """Upload a light mono copy of the voice reference (must be <= 30 s) and return its URL."""
    ref = Path(tmpdir) / "ref.mp3"
    run(["ffmpeg", "-y", "-i", str(REF_AUDIO), "-t", "29", "-ac", "1", "-ar", "24000", "-b:a", "96k", str(ref)])
    with open(ref, "rb") as f:
        r = requests.post(f"{ATLAS}/uploadMedia", headers=_headers(), files={"file": ("ref.mp3", f, "audio/mpeg")}, timeout=120)
    r.raise_for_status()
    return r.json()["data"]["download_url"]


def tts(text, ref_url, retries=5):
    """Submit a voice-cloned TTS job to Atlas Cloud, poll it, and return WAV bytes."""
    h = {**_headers(), "Content-Type": "application/json"}
    body = {"model": TTS_MODEL, "text": VOICE_PROMPT + text, "references": [{"audio_url": ref_url}],
            "format": "wav", "sample_rate": SAMPLE_RATE}
    backoff = 8
    for attempt in range(1, retries + 1):
        try:
            r = requests.post(f"{ATLAS}/generateAudio", headers=h, json=body, timeout=120)
            r.raise_for_status()
            pid = r.json()["data"]["id"]
            for _ in range(120):
                time.sleep(2.5)
                g = requests.get(f"{ATLAS}/prediction/{pid}", headers=h, timeout=60).json()
                d = g.get("data") or {}
                status = d.get("status")
                if status in ("completed", "succeeded", "success"):
                    return requests.get(d["outputs"][0], timeout=120).content
                if status in ("failed", "error") or g.get("code") != 200:
                    raise RuntimeError((g.get("message") or d.get("error") or "failed")[:160])
            raise RuntimeError("timed out waiting for job")
        except Exception as e:  # noqa: BLE001
            if attempt == retries:
                raise
            print(f"      retry {attempt}/{retries - 1}: {str(e)[:120]}", flush=True)
            time.sleep(backoff)
            backoff = min(backoff * 2, 60)


_whisper = None
_whisper_lock = threading.Lock()


def words(t):
    return re.findall(r"[a-záéíóúñü0-9']+", t.lower())


def check_speech(path, text, lang):
    """Transcribe a chunk and confirm the whole text was spoken (nothing dropped or cut)."""
    global _whisper
    try:
        from faster_whisper import WhisperModel
    except ImportError:
        return 1.0, True  # verification unavailable; accept
    with _whisper_lock:
        if _whisper is None:
            _whisper = WhisperModel("small", device="cpu", compute_type="int8")
        segs, _ = _whisper.transcribe(str(path), language=lang)
        heard = words(" ".join(x.text for x in segs))
    ref = words(text)
    cover = SequenceMatcher(None, ref, heard).ratio()
    tail_ok = SequenceMatcher(None, ref[-3:], heard[-3:]).ratio() >= 0.6
    return cover, tail_ok


def duration(path):
    out = run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)]).stdout
    return float(out.strip())


def normalise_chunk(raw_wav, out_wav):
    """Resample to mono 24 kHz and trim leading/trailing silence."""
    trim = ("silenceremove=start_periods=1:start_threshold=-48dB:start_silence=0.04,"
            "areverse,silenceremove=start_periods=1:start_threshold=-48dB:start_silence=0.08,areverse")
    run(["ffmpeg", "-y", "-i", str(raw_wav), "-ac", "1", "-ar", str(SAMPLE_RATE), "-af", trim,
         "-sample_fmt", "s16", str(out_wav)])


def join_wavs(paths, out_path, pause=PAUSE_BETWEEN_CHUNKS):
    silence = b"\x00\x00" * int(SAMPLE_RATE * pause)
    with wave.open(str(out_path), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(SAMPLE_RATE)
        for i, p in enumerate(paths):
            with wave.open(str(p), "rb") as w:
                out.writeframes(w.readframes(w.getnframes()))
            if i < len(paths) - 1:
                out.writeframes(silence)


def integrated_loudness(path):
    err = run(["ffmpeg", "-hide_banner", "-i", str(path), "-af", "loudnorm=print_format=json", "-f", "null", "-"]).stderr
    return float(json.loads(err[err.rindex("{"):err.rindex("}") + 1])["input_i"])


def master(in_wav, out_mp3):
    """Voice processing -> exact gain to target LUFS -> true-peak limit -> padding/fades -> MP3."""
    ceiling = 10 ** ((TARGET_TP - 0.3) / 20)  # a little headroom for MP3 encoding
    with tempfile.TemporaryDirectory() as td:
        processed = Path(td) / "p.wav"
        run(["ffmpeg", "-y", "-i", str(in_wav), "-af", MASTER_CHAIN, "-ar", "44100", "-ac", "1", str(processed)])
        mastered = Path(td) / "m.wav"
        target = TARGET_LUFS + 0.7  # compensates the small drop from padding + MP3 encoding
        gain = target - integrated_loudness(processed)
        for _ in range(4):  # the limiter shaves a little loudness; nudge the gain until on target
            run(["ffmpeg", "-y", "-i", str(processed), "-af",
                 f"volume={gain:.2f}dB,alimiter=limit={ceiling:.4f}:attack=5:release=80:level=false",
                 "-ar", "44100", "-ac", "1", str(mastered)])
            miss = target - integrated_loudness(mastered)
            if abs(miss) <= 0.3:
                break
            gain += miss
        d = duration(mastered) + HEAD_PAD + TAIL_PAD
        finish = (f"adelay={int(HEAD_PAD * 1000)},apad=pad_dur={TAIL_PAD},"
                  f"afade=t=in:d=0.03,afade=t=out:st={d - 0.25:.3f}:d=0.25")
        run(["ffmpeg", "-y", "-i", str(mastered), "-af", finish, "-ar", "44100", "-ac", "1",
             "-codec:a", "libmp3lame", "-b:a", "128k", str(out_mp3)])


def build_slide(n, text, suffix, ref_path, force, lang="en"):
    out = OUTPUT_DIR / f"slide-{n:02d}{suffix}.mp3"
    if out.exists() and not force:
        print(f"  slide {n:02d}{suffix}: exists, skipping (use --force)")
        return
    chunks = split_chunks(text)
    print(f"  slide {n:02d}{suffix}: {len(chunks)} chunks", flush=True)
    with tempfile.TemporaryDirectory() as td:
        def make(i_chunk):
            i, chunk = i_chunk
            best = None
            for attempt in range(4):
                raw = Path(td) / f"raw{i}-{attempt}.wav"
                raw.write_bytes(tts(chunk, ref_path))
                d = duration(raw)
                cover, tail_ok = check_speech(raw, chunk, lang)
                score = cover + (0.5 if tail_ok else 0)
                if best is None or score > best[0]:
                    best = (score, raw)
                if d < MAX_CHUNK_SECONDS and cover >= 0.8 and tail_ok:
                    break
                print(f"      chunk {i}: match {cover:.2f}, ending {'ok' if tail_ok else 'missing'}, {d:.1f}s -> regenerating", flush=True)
            clean = Path(td) / f"c{i}.wav"
            normalise_chunk(best[1], clean)
            return clean

        with ThreadPoolExecutor(max_workers=PARALLEL) as pool:
            parts = list(pool.map(make, enumerate(chunks)))
        joined = Path(td) / "joined.wav"
        join_wavs(parts, joined)
        master(joined, out)
    print(f"    -> {out.name} ({duration(out):.1f}s)", flush=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lang", choices=["en", "es", "both"], default="both")
    ap.add_argument("--slides", help="comma-separated slide numbers")
    ap.add_argument("--force", action="store_true", help="overwrite existing files")
    args = ap.parse_args()

    data = json.loads(SCRIPTS.read_text())
    wanted = {int(x) for x in args.slides.split(",")} if args.slides else None
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        ref = prepare_reference(td)
        for s in data["slides"]:
            if wanted and s["n"] not in wanted:
                continue
            if args.lang in ("en", "both"):
                build_slide(s["n"], s["en"], "", ref, args.force, "en")
            if args.lang in ("es", "both"):
                build_slide(s["n"], s["es"], "-es", ref, args.force, "es")
    print("Done.")


if __name__ == "__main__":
    sys.exit(main())

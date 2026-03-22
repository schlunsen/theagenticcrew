#!/usr/bin/env python3
"""
Audiobook generation pipeline for "The Agentic Crew: Crew Member's Guide".

Uses Qwen3-TTS via HuggingFace to generate speech from Typst chapter files,
then concatenates chunks into chapter and full-book MP3s.

Supports both English and Catalan editions, with female voice (crew voice ref).

Usage:
  python scripts/generate-crew-audiobook.py --book crew --chapter 01
  python scripts/generate-crew-audiobook.py --book crew-ca --chapter 05
  python scripts/generate-crew-audiobook.py --book all
  python scripts/generate-crew-audiobook.py --book crew --concat-only
"""

import argparse
import base64
import json
import os
import re
import subprocess
import sys
import time
import tempfile
import shutil
from pathlib import Path
from typing import List, Optional

import requests
import numpy as np

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent
CREW_EN_DIR = BASE_DIR / "chapters" / "crew"
CREW_CA_DIR = BASE_DIR / "chapters" / "crew-ca"
OUTPUT_DIR = BASE_DIR / "website" / "public" / "audiobook"

HF_API_KEY = os.environ.get("HF_API_KEY", "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")

# Primary: faster mirror (FastAPI, more reliable)
FASTAPI_BASE = "https://huggingfacem4-faster-qwen3-tts-demo.hf.space"

# API backend
TTS_BACKEND = os.environ.get("TTS_BACKEND", "fastapi")

# Voice references
CREW_VOICE_REF = BASE_DIR / "assets" / "voice-ref-crew.wav"
KITT_VOICE_REF = BASE_DIR / "assets" / "kitt-voice-ref.wav"
AUTHOR_VOICE_REF = BASE_DIR / "assets" / "voice-ref.wav"

# Voice configs — Qwen3-TTS voices (voice cloning)
VOICES = {
    "female": {
        "backend": "qwen",
        "ref_audio": str(CREW_VOICE_REF),
        "ref_text": "La Balenguera fila, fila, la Balenguera filarà. Qui sap quan acabarà, de filar la seva tela.",
        "ref_preset": "ref_audio_2",
    },
    "kitt": {
        "backend": "qwen",
        "ref_audio": str(KITT_VOICE_REF),
        "ref_text": (
            "I am the Knight Industries Two Thousand. You may call me KITT. "
            "I am designed to assist and protect human life."
        ),
        "ref_preset": "ref_audio_3",
    },
    "male": {
        "backend": "qwen",
        "ref_audio": str(AUTHOR_VOICE_REF),
        "ref_text": (
            "The best software is built by people who care deeply about the problem "
            "they are solving. It's not about the tools you use or the frameworks you "
            "pick. It's about understanding what matters, making smart trade-offs and "
            "shipping something that actually works in the real world."
        ),
        "ref_preset": "ref_audio_3",
    },
    "sky": {
        "backend": "kokoro",
        "kokoro_voice": "af_sky",
        "kokoro_speed": 1.0,
        "kokoro_lang": "a",  # American English
    },
}

# Lazy-loaded Kokoro pipeline (initialized on first use)
_kokoro_pipeline = None

def get_kokoro_pipeline(lang_code: str = "a"):
    """Lazily initialize and return the Kokoro TTS pipeline."""
    global _kokoro_pipeline
    if _kokoro_pipeline is None:
        from kokoro import KPipeline
        print("  [kokoro] Initializing Kokoro pipeline ...")
        _kokoro_pipeline = KPipeline(lang_code=lang_code)
    return _kokoro_pipeline

# Background music
BGM_VOICE_VOLUME = 8.0  # Default for Qwen voices (their output is quiet)
BGM_MUSIC_VOLUME = 0.08
# Per-backend voice volume overrides (Kokoro output is already loud)
VOICE_VOLUME_OVERRIDES = {
    "kokoro": 1.5,
}
DEFAULT_BGM = "bgm-hazelwood.mp3"
CHAPTER_BGM = {
    "01": "bgm-hazelwood.mp3",
    "02": "bgm-lighthouse.mp3",
}

TITLE_PAUSE_SECONDS = 3

# Chapter titles — English
CREW_TITLES_EN = {
    "01": "Chapter One. Welcome to the Crew.",
    "02": "Chapter Two. The Ground Is Shifting.",
    "03": "Chapter Three. What's Under the Hood.",
    "04": "Chapter Four. What Is an Agent, Really?",
    "05": "Chapter Five. How to Give Good Instructions.",
    "06": "Chapter Six. What the Agent Can See.",
    "07": "Chapter Seven. The Trust Gradient.",
    "08": "Chapter Eight. Extending the Crew's Reach.",
    "09": "Chapter Nine. The Padlock.",
    "10": "Chapter Ten. Reading the Output Like a Pro.",
    "11": "Chapter Eleven. Building Something Real.",
    "12": "Chapter Twelve. When Things Go Wrong.",
    "13": "Chapter Thirteen. When to Do It Yourself.",
    "14": "Chapter Fourteen. Being the Human in the Loop.",
    "15": "Chapter Fifteen. Talking to Your Tech Team.",
    "16": "Chapter Sixteen. Keeping Your Finger on the Pulse.",
    "17": "Chapter Seventeen. Final Words.",
}

# Chapter titles — Catalan
CREW_TITLES_CA = {
    "01": "Capítol Un. Benvingut a la tripulació.",
    "02": "Capítol Dos. El terra s'està movent.",
    "03": "Capítol Tres. Què hi ha sota el capó.",
    "04": "Capítol Quatre. Què és un agent, realment?",
    "05": "Capítol Cinc. Com donar bones instruccions.",
    "06": "Capítol Sis. Què pot veure l'agent.",
    "07": "Capítol Set. El Gradient de Confiança.",
    "08": "Capítol Vuit. Ampliant l'Abast de la Tripulació.",
    "09": "Capítol Nou. El Cadenat.",
    "10": "Capítol Deu. Llegir la Sortida com un Professional.",
    "11": "Capítol Onze. Construir Alguna Cosa Real.",
    "12": "Capítol Dotze. Quan les coses surten malament.",
    "13": "Capítol Tretze. Quan fer-ho tu mateix.",
    "14": "Capítol Catorze. Ser l'humà en el procés.",
    "15": "Capítol Quinze. Parlant amb el Teu Equip Tècnic.",
    "16": "Capítol Setze. Mantenir el Pols.",
    "17": "Capítol Disset. Paraules Finals.",
}

# Front matter text for narration
FRONT_MATTER_EN = """A Note Before We Start.

This book is a companion to The Agentic Crew: Engineering in the Age of AI Agents. That book was written for software engineers — people who write code for a living. This one is for everyone else who's good with computers.

You might be a project manager, a designer, a sysadmin, a data analyst, a small business owner, or just the person in your family who fixes the Wi-Fi. You live in spreadsheets, manage inboxes like a general, and have forty-seven browser tabs open right now. But you've never written a line of code — and you don't need to.

AI agents are changing how software gets built. That affects you, whether you're working alongside developers, running a business that depends on software, or just trying to understand what's happening to the world around you. The ideas in this book are real. We've simplified the technical details, but we haven't watered them down.

By the end, you'll understand what agents actually are, how modern software works under the hood, and — most importantly — how to direct an agent to build something real. No programming required.

Rasmus Bornhoft Schlunsen. March 2026."""

FRONT_MATTER_CA = """Una nota abans de començar.

Aquest llibre és un company de La Tripulació Agèntica: Enginyeria en l'era dels agents d'IA. Aquell llibre va ser escrit per a enginyers de programari — persones que escriuen codi per guanyar-se la vida. Aquest és per a tots els altres que se'n surten bé amb els ordinadors.

Potser ets un gestor de projectes, un dissenyador, un administrador de sistemes, un analista de dades, un petit empresari, o simplement la persona de la teva família que arregla el Wi-Fi. Vius entre fulls de càlcul, gestiones bústies de correu com un general i ara mateix tens quaranta-set pestanyes del navegador obertes. Però no has escrit mai una línia de codi — i no cal que ho facis.

Els agents d'IA estan canviant com es construeix el programari. Això t'afecta, tant si treballes al costat de desenvolupadors, com si gestiones un negoci que depèn del programari, o simplement intentes entendre què passa al món que t'envolta. Les idees d'aquest llibre són reals. Hem simplificat els detalls tècnics, però no els hem aigualit.

Quan acabis, entendràs què són realment els agents, com funciona el programari modern per dins i — el més important — com dirigir un agent perquè construeixi alguna cosa real. No cal saber programar.

Rasmus Bornhoft Schlunsen. Març 2026."""

DEDICATION_EN = "To everyone who was told: you're not technical enough. You are. You always were. Now the tools agree."
DEDICATION_CA = "A tots els qui els van dir: no ets prou tècnic. Ho ets. Sempre ho has estat. Ara les eines hi estan d'acord."

MAX_CHUNK_CHARS = 500
MAX_RETRIES = 5
INITIAL_BACKOFF = 10
HAS_FFMPEG = shutil.which("ffmpeg") is not None

# ---------------------------------------------------------------------------
# Text extraction – strip Typst markup
# ---------------------------------------------------------------------------

def strip_typst(text: str) -> str:
    """Remove Typst markup and return plain text.

    Code blocks and figure captions are preserved so the audiobook
    matches the PDF book content.
    """

    # Convert code blocks to narrated content instead of removing them
    def _narrate_code_block(m):
        code = m.group(0)
        code = re.sub(r"^```\w*\n?", "", code)
        code = re.sub(r"\n?```$", "", code)
        code = code.strip()
        if not code:
            return ""
        return f"\n\n{code}\n\n"

    text = re.sub(r"```[\s\S]*?```", _narrate_code_block, text)

    # Extract figure captions before removing figure commands
    def _extract_figure_caption(t):
        pattern = r"#figure\("
        while True:
            m = re.search(pattern, t)
            if not m:
                break
            start = m.start()
            depth = 0
            i = m.end() - 1
            while i < len(t):
                if t[i] == "(":
                    depth += 1
                elif t[i] == ")":
                    depth -= 1
                    if depth == 0:
                        break
                i += 1
            figure_text = t[start:i + 1]
            cap_match = re.search(r"caption:\s*\[([^\]]*)\]", figure_text)
            replacement = ""
            if cap_match:
                replacement = f"\n\n{cap_match.group(1).strip()}\n\n"
            t = t[:start] + replacement + t[i + 1:]
        return t

    text = _extract_figure_caption(text)

    # Remove commands with balanced parens
    def remove_command(t, cmd):
        pattern = r"#" + cmd + r"\("
        while True:
            m = re.search(pattern, t)
            if not m:
                break
            start = m.start()
            depth = 0
            i = m.end() - 1
            while i < len(t):
                if t[i] == "(":
                    depth += 1
                elif t[i] == ")":
                    depth -= 1
                    if depth == 0:
                        break
                i += 1
            t = t[:start] + t[i + 1:]
        return t

    for cmd in ["image", "figure", "v", "pagebreak", "colbreak", "align", "box",
                 "place", "set", "show", "import", "include", "metadata", "counter",
                 "numbering", "heading", "text", "block", "grid", "table", "rect",
                 "circle", "line", "columns", "par", "stack"]:
        text = remove_command(text, cmd)

    text = remove_command(text, "quote")
    text = re.sub(r"#emph\[([^\]]*)\]", r"\1", text)
    text = re.sub(r"#strong\[([^\]]*)\]", r"\1", text)
    text = re.sub(r"_([^_]+)_", r"\1", text)
    text = re.sub(r"\*([^*]+)\*", r"\1", text)
    text = re.sub(r"^=+\s*(.+)$", r"\n[SECTION]\1", text, flags=re.MULTILINE)
    text = re.sub(r"#\w+\[([^\]]*)\]", r"\1", text)
    text = re.sub(r"<[a-zA-Z0-9_-]+>", "", text)
    text = re.sub(r"@[\w-]+", "", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    lines = [l.strip() for l in text.split("\n")]
    text = "\n".join(lines)
    return text.strip()


# ---------------------------------------------------------------------------
# Chunking
# ---------------------------------------------------------------------------

def chunk_text(text: str, max_chars: int = MAX_CHUNK_CHARS) -> List[str]:
    """Split text into chunks respecting sentence and section boundaries."""
    paragraphs = re.split(r"\n\n+", text)
    chunks = []
    current = ""

    for para in paragraphs:
        para = para.strip()
        if not para:
            continue

        if para.startswith("[SECTION]"):
            if current:
                chunks.append(current)
                current = ""
            chunks.append(para)
            continue

        if len(current) + len(para) + 2 <= max_chars:
            current = (current + "\n\n" + para).strip()
        else:
            if current:
                chunks.append(current)
                current = ""
            if len(para) <= max_chars:
                current = para
            else:
                sentences = re.split(r"(?<=[.!?])\s+", para)
                for sent in sentences:
                    if len(current) + len(sent) + 1 <= max_chars:
                        current = (current + " " + sent).strip()
                    else:
                        if current:
                            chunks.append(current)
                        current = sent

    if current:
        chunks.append(current)
    return chunks


# ---------------------------------------------------------------------------
# TTS API
# ---------------------------------------------------------------------------

def tts_generate_kokoro(text: str, voice: dict) -> bytes:
    """Generate speech using Kokoro TTS (local model). Returns WAV bytes."""
    import soundfile as sf
    import io

    pipeline = get_kokoro_pipeline(voice.get("kokoro_lang", "a"))
    kokoro_voice = voice.get("kokoro_voice", "af_sky")
    speed = voice.get("kokoro_speed", 1.0)

    # Generate all audio chunks and concatenate
    all_audio = []
    for gs, ps, audio in pipeline(text, voice=kokoro_voice, speed=speed):
        all_audio.append(audio)

    if not all_audio:
        raise RuntimeError("Kokoro generated no audio")

    # Concatenate all chunks
    combined = np.concatenate(all_audio) if len(all_audio) > 1 else all_audio[0]

    # Write to WAV bytes
    buf = io.BytesIO()
    sf.write(buf, combined, 24000, format="WAV")
    return buf.getvalue()


def tts_generate_qwen(text: str, voice: dict) -> bytes:
    """Call faster-qwen3-tts FastAPI and return WAV audio bytes."""
    form_data = {
        "text": text,
        "ref_text": voice["ref_text"],
    }

    ref_audio_path = voice.get("ref_audio")
    use_custom_ref = ref_audio_path and Path(ref_audio_path).exists()

    if not use_custom_ref:
        form_data["ref_preset"] = voice["ref_preset"]

    backoff = INITIAL_BACKOFF
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            files = None
            if use_custom_ref:
                files = {"ref_audio": ("ref.wav", open(ref_audio_path, "rb"), "audio/wav")}

            resp = requests.post(
                f"{FASTAPI_BASE}/generate",
                data=form_data,
                files=files,
                timeout=300,
            )
            if resp.status_code == 429 or resp.status_code >= 500:
                raise RuntimeError(f"HTTP {resp.status_code}: {resp.text[:200]}")
            resp.raise_for_status()

            result = resp.json()
            if "audio_b64" in result:
                return base64.b64decode(result["audio_b64"])
            else:
                raise RuntimeError(f"No audio_b64 in response: {list(result.keys())}")

        except Exception as e:
            print(f"  [attempt {attempt}/{MAX_RETRIES}] Error: {e}")
            if attempt < MAX_RETRIES:
                print(f"  Retrying in {backoff}s ...")
                time.sleep(backoff)
                backoff = min(backoff * 2, 120)
            else:
                raise RuntimeError(f"Failed after {MAX_RETRIES} attempts: {e}")


def tts_generate(text: str, voice: dict) -> bytes:
    """Generate TTS audio using the appropriate backend for this voice."""
    backend = voice.get("backend", "qwen")
    if backend == "kokoro":
        return tts_generate_kokoro(text, voice)
    else:
        return tts_generate_qwen(text, voice)


# ---------------------------------------------------------------------------
# Audio utilities
# ---------------------------------------------------------------------------

def wav_to_mp3(wav_path: Path, mp3_path: Path):
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(wav_path), "-codec:a", "libmp3lame", "-qscale:a", "2", str(mp3_path)],
        check=True, capture_output=True,
    )

def concatenate_audio_files(input_paths: List[Path], output_path: Path):
    if not input_paths:
        return
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
        for p in input_paths:
            f.write(f"file '{p}'\n")
        list_file = f.name
    try:
        ext = output_path.suffix.lower()
        cmd = ["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", list_file]
        if ext == ".mp3":
            cmd += ["-codec:a", "libmp3lame", "-qscale:a", "2"]
        else:
            cmd += ["-c", "copy"]
        cmd.append(str(output_path))
        subprocess.run(cmd, check=True, capture_output=True)
    finally:
        os.unlink(list_file)

def get_audio_duration(path: Path) -> float:
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "quiet", "-show_entries", "format=duration",
             "-of", "default=noprint_wrappers=1:nokey=1", str(path)],
            capture_output=True, text=True, check=True,
        )
        return float(result.stdout.strip())
    except Exception:
        return 0.0

def generate_silence(duration_s: float, output_path: Path):
    subprocess.run(
        ["ffmpeg", "-y", "-f", "lavfi", "-i", f"anullsrc=r=24000:cl=mono",
         "-t", str(duration_s), "-codec:a", "libmp3lame", "-qscale:a", "2",
         str(output_path)],
        check=True, capture_output=True,
    )

def slow_down_audio(input_path: Path, output_path: Path, speed: float = 0.92):
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(input_path),
         "-af", f"atempo={speed}",
         "-codec:a", "libmp3lame", "-qscale:a", "2",
         str(output_path)],
        check=True, capture_output=True,
    )

def get_bgm_path(chapter_stem: str) -> Optional[Path]:
    m = re.match(r"^(\d+[a-z]?)", chapter_stem)
    chapter_num = m.group(1) if m else None
    bgm_name = CHAPTER_BGM.get(chapter_num, DEFAULT_BGM) if chapter_num else DEFAULT_BGM
    bgm_path = BASE_DIR / "assets" / bgm_name
    if bgm_path.exists():
        return bgm_path
    print(f"  [warn] BGM not found at {bgm_path}")
    return None

def mix_with_bgm(narration_path: Path, output_path: Path, chapter_stem: str = "", voice_config: dict = None):
    bgm_path = get_bgm_path(chapter_stem)
    if not bgm_path:
        shutil.copy2(narration_path, output_path)
        return
    # Use voice-specific volume if available (Kokoro is louder than Qwen)
    backend = (voice_config or {}).get("backend", "qwen")
    voice_vol = VOICE_VOLUME_OVERRIDES.get(backend, BGM_VOICE_VOLUME)
    print(f"  Using BGM: {bgm_path.name}")
    subprocess.run(
        ["ffmpeg", "-y",
         "-i", str(narration_path),
         "-stream_loop", "-1", "-i", str(bgm_path),
         "-filter_complex",
         f"[0:a]volume={voice_vol}[voice];"
         f"[1:a]volume={BGM_MUSIC_VOLUME}[bgm];"
         f"[voice][bgm]amix=inputs=2:duration=first:dropout_transition=3[out]",
         "-map", "[out]",
         "-codec:a", "libmp3lame", "-qscale:a", "2",
         str(output_path)],
        check=True, capture_output=True,
    )


# ---------------------------------------------------------------------------
# Chapter processing
# ---------------------------------------------------------------------------

def get_chapter_title(stem: str, lang: str = "en") -> Optional[str]:
    titles = CREW_TITLES_CA if lang == "ca" else CREW_TITLES_EN
    m = re.match(r"^(\d+)", stem)
    if m:
        return titles.get(m.group(1))
    return None

def process_chapter(
    chapter_path: Path,
    voice_name: str,
    output_dir: Path,
    skip_existing: bool = True,
    speed: float = 0.92,
    add_bgm: bool = True,
    lang: str = "en",
) -> Optional[Path]:
    """Generate audio for a single chapter. Returns path to final MP3."""
    voice = VOICES[voice_name]
    stem = chapter_path.stem
    ext = ".mp3" if HAS_FFMPEG else ".wav"
    final_path = output_dir / f"{stem}{ext}"

    if skip_existing and final_path.exists():
        print(f"  [skip] {final_path.name} already exists")
        return final_path

    raw = chapter_path.read_text(encoding="utf-8")
    text = strip_typst(raw)

    if not text.strip():
        print(f"  [skip] {chapter_path.name} has no text content")
        return None

    chunks = chunk_text(text)
    print(f"  {chapter_path.name}: {len(text)} chars -> {len(chunks)} chunks")

    output_dir.mkdir(parents=True, exist_ok=True)
    chunk_dir = output_dir / f".chunks-{stem}"
    chunk_dir.mkdir(parents=True, exist_ok=True)

    # Silence files
    silence_3s = chunk_dir / "silence-3s.mp3"
    silence_2s = chunk_dir / "silence-2s.mp3"
    if not silence_3s.exists():
        generate_silence(TITLE_PAUSE_SECONDS, silence_3s)
    if not silence_2s.exists():
        generate_silence(2, silence_2s)

    # Chapter title audio
    chapter_title = get_chapter_title(stem, lang)
    title_path = chunk_dir / "title.mp3"
    if chapter_title and not (skip_existing and title_path.exists() and title_path.stat().st_size > 0):
        print(f"    title: generating '{chapter_title}' ...")
        title_wav = chunk_dir / "title.wav"
        audio_bytes = tts_generate(chapter_title, voice)
        title_wav.write_bytes(audio_bytes)
        if HAS_FFMPEG:
            wav_to_mp3(title_wav, title_path)
            title_wav.unlink()

    # Build ordered list of audio parts
    part_paths = []
    if chapter_title and title_path.exists():
        part_paths.append(title_path)
        part_paths.append(silence_3s)

    skip_first_section = True
    chunk_idx = 0
    for chunk in chunks:
        if chunk.startswith("[SECTION]"):
            section_text = chunk[len("[SECTION]"):].strip()
            if skip_first_section:
                skip_first_section = False
                continue
            if section_text:
                section_mp3 = chunk_dir / f"section-{chunk_idx:04d}.mp3"
                if not (skip_existing and section_mp3.exists() and section_mp3.stat().st_size > 0):
                    print(f"    section: generating '{section_text}' ...")
                    section_wav = chunk_dir / f"section-{chunk_idx:04d}.wav"
                    audio_bytes = tts_generate(section_text, voice)
                    section_wav.write_bytes(audio_bytes)
                    if HAS_FFMPEG:
                        wav_to_mp3(section_wav, section_mp3)
                        section_wav.unlink()
                part_paths.append(silence_2s)
                if section_mp3.exists():
                    part_paths.append(section_mp3)
                part_paths.append(silence_2s)
            chunk_idx += 1
            continue

        # Regular text chunk
        chunk_wav = chunk_dir / f"chunk-{chunk_idx:04d}.wav"
        chunk_mp3 = chunk_dir / f"chunk-{chunk_idx:04d}.mp3"
        target = chunk_mp3 if HAS_FFMPEG else chunk_wav

        if skip_existing and target.exists() and target.stat().st_size > 0:
            print(f"    chunk {chunk_idx+1}: cached")
            part_paths.append(target)
        else:
            print(f"    chunk {chunk_idx+1}: generating ({len(chunk)} chars) ...")
            audio_bytes = tts_generate(chunk, voice)
            chunk_wav.write_bytes(audio_bytes)
            if HAS_FFMPEG:
                wav_to_mp3(chunk_wav, chunk_mp3)
                chunk_wav.unlink()
                part_paths.append(chunk_mp3)
            else:
                part_paths.append(chunk_wav)

        chunk_idx += 1

    # Concatenate all parts
    raw_narration = chunk_dir / f"raw-narration{ext}"
    if part_paths:
        print(f"  Concatenating {len(part_paths)} parts -> raw narration")
        concatenate_audio_files(part_paths, raw_narration)

    # Slow down
    slowed_narration = chunk_dir / f"slowed-narration{ext}"
    if speed < 1.0 and raw_narration.exists():
        print(f"  Slowing down to {speed}x speed ...")
        slow_down_audio(raw_narration, slowed_narration, speed)
    else:
        slowed_narration = raw_narration

    # Mix with BGM
    if add_bgm and slowed_narration.exists():
        print(f"  Mixing with background music ...")
        mix_with_bgm(slowed_narration, final_path, stem, voice_config=voice)
    elif slowed_narration.exists():
        shutil.copy2(slowed_narration, final_path)

    # Clean up chunk dir
    if final_path.exists():
        dur = get_audio_duration(final_path)
        size_mb = final_path.stat().st_size / (1024 * 1024)
        print(f"  Done: {final_path.name} ({dur:.1f}s / {dur/60:.1f}min, {size_mb:.1f}MB)")
        shutil.rmtree(chunk_dir, ignore_errors=True)

    return final_path


def process_special_section(
    text: str,
    name: str,
    voice_name: str,
    output_dir: Path,
    skip_existing: bool = True,
    speed: float = 0.92,
    add_bgm: bool = True,
) -> Optional[Path]:
    """Generate audio for front matter or dedication."""
    voice = VOICES[voice_name]
    ext = ".mp3" if HAS_FFMPEG else ".wav"
    final_path = output_dir / f"{name}{ext}"

    if skip_existing and final_path.exists():
        print(f"  [skip] {final_path.name} already exists")
        return final_path

    chunks = chunk_text(text)
    print(f"  {name}: {len(text)} chars -> {len(chunks)} chunks")

    output_dir.mkdir(parents=True, exist_ok=True)
    chunk_dir = output_dir / f".chunks-{name}"
    chunk_dir.mkdir(parents=True, exist_ok=True)

    part_paths = []
    for idx, chunk in enumerate(chunks):
        chunk_wav = chunk_dir / f"chunk-{idx:04d}.wav"
        chunk_mp3 = chunk_dir / f"chunk-{idx:04d}.mp3"
        target = chunk_mp3 if HAS_FFMPEG else chunk_wav

        if skip_existing and target.exists() and target.stat().st_size > 0:
            print(f"    chunk {idx+1}: cached")
            part_paths.append(target)
        else:
            print(f"    chunk {idx+1}: generating ({len(chunk)} chars) ...")
            audio_bytes = tts_generate(chunk, voice)
            chunk_wav.write_bytes(audio_bytes)
            if HAS_FFMPEG:
                wav_to_mp3(chunk_wav, chunk_mp3)
                chunk_wav.unlink()
                part_paths.append(chunk_mp3)
            else:
                part_paths.append(chunk_wav)

    raw_narration = chunk_dir / f"raw-narration{ext}"
    if part_paths:
        concatenate_audio_files(part_paths, raw_narration)

    slowed = chunk_dir / f"slowed{ext}"
    if speed < 1.0 and raw_narration.exists():
        slow_down_audio(raw_narration, slowed, speed)
    else:
        slowed = raw_narration

    if add_bgm and slowed.exists():
        mix_with_bgm(slowed, final_path, name, voice_config=voice)
    elif slowed.exists():
        shutil.copy2(slowed, final_path)

    if final_path.exists():
        dur = get_audio_duration(final_path)
        size_mb = final_path.stat().st_size / (1024 * 1024)
        print(f"  Done: {final_path.name} ({dur:.1f}s / {dur/60:.1f}min, {size_mb:.1f}MB)")
        shutil.rmtree(chunk_dir, ignore_errors=True)

    return final_path


def concat_full_book(output_dir: Path):
    """Concatenate all chapter MP3s in order into a full book."""
    ext = ".mp3" if HAS_FFMPEG else ".wav"

    # Collect in order: front-matter, chapters 01-17, dedication
    parts = []
    front = output_dir / f"00-front-matter{ext}"
    if front.exists():
        parts.append(front)

    for i in range(1, 18):
        pattern = f"{i:02d}-*{ext}"
        matches = sorted(output_dir.glob(pattern))
        parts.extend(matches)

    ded = output_dir / f"99-dedication{ext}"
    if ded.exists():
        parts.append(ded)

    if len(parts) < 2:
        print(f"  Only {len(parts)} parts found, skipping full book concat")
        return

    full_path = output_dir / f"full-book{ext}"
    print(f"\nConcatenating {len(parts)} files -> {full_path.name}")
    for p in parts:
        print(f"  + {p.name}")
    concatenate_audio_files(parts, full_path)

    dur = get_audio_duration(full_path)
    size_mb = full_path.stat().st_size / (1024 * 1024)
    print(f"Full book: {dur:.1f}s ({dur/60:.1f}min), {size_mb:.1f} MB")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Generate audiobook for Crew Member's Guide")
    parser.add_argument("--book", choices=["crew", "crew-ca", "all"], default="all",
                        help="Which edition to process")
    parser.add_argument("--voice", choices=["male", "female", "kitt", "sky", "both"], default="female",
                        help="Which voice to use (default: female). 'sky' uses Kokoro TTS af_sky.")
    parser.add_argument("--chapter", type=str, default=None,
                        help="Filter: only process chapters containing this string (e.g. '01', '09-the-padlock')")
    parser.add_argument("--no-skip", action="store_true",
                        help="Regenerate even if files exist")
    parser.add_argument("--speed", type=float, default=0.92,
                        help="Playback speed (default 0.92)")
    parser.add_argument("--no-bgm", action="store_true",
                        help="Skip background music")
    parser.add_argument("--concat-only", action="store_true",
                        help="Only concatenate existing chapter files into full book")
    parser.add_argument("--no-front-matter", action="store_true",
                        help="Skip front matter and dedication")
    args = parser.parse_args()

    skip_existing = not args.no_skip
    add_bgm = not args.no_bgm
    voices = ["male", "female"] if args.voice == "both" else [args.voice]

    books = []
    if args.book in ("crew", "all"):
        books.append(("crew", CREW_EN_DIR, "en"))
    if args.book in ("crew-ca", "all"):
        books.append(("crew-ca", CREW_CA_DIR, "ca"))

    print(f"Crew Audiobook Generation")
    print(f"  Books: {[b[0] for b in books]}")
    print(f"  Voices: {voices}")
    print(f"  Chapter filter: {args.chapter or '(all)'}")
    print(f"  ffmpeg: {'available' if HAS_FFMPEG else 'NOT available'}")
    print()

    for book_type, chapters_dir, lang in books:
        for voice_name in voices:
            out_dir = OUTPUT_DIR / book_type / voice_name
            out_dir.mkdir(parents=True, exist_ok=True)

            print(f"\n{'='*60}")
            print(f"Processing: {book_type} / {voice_name}")
            print(f"{'='*60}")

            if args.concat_only:
                concat_full_book(out_dir)
                continue

            # Front matter
            if not args.chapter and not args.no_front_matter:
                print(f"\n--- {book_type}/{voice_name}: front matter ---")
                fm_text = FRONT_MATTER_CA if lang == "ca" else FRONT_MATTER_EN
                process_special_section(fm_text, "00-front-matter", voice_name, out_dir,
                                       skip_existing, args.speed, add_bgm)

            # Chapters
            chapter_files = sorted(chapters_dir.glob("*.typ"))
            if args.chapter:
                chapter_files = [f for f in chapter_files if args.chapter in f.name]

            for ch in chapter_files:
                print(f"\n--- {book_type}/{voice_name}: {ch.name} ---")
                process_chapter(ch, voice_name, out_dir, skip_existing, args.speed, add_bgm, lang)

            # Dedication
            if not args.chapter and not args.no_front_matter:
                print(f"\n--- {book_type}/{voice_name}: dedication ---")
                ded_text = DEDICATION_CA if lang == "ca" else DEDICATION_EN
                process_special_section(ded_text, "99-dedication", voice_name, out_dir,
                                       skip_existing, args.speed, add_bgm)

            # Full book concat (only if processing all chapters)
            if not args.chapter:
                concat_full_book(out_dir)

    # Summary
    print(f"\n{'='*60}")
    print("SUMMARY")
    print(f"{'='*60}")
    for book_type, _, _ in books:
        for voice_name in voices:
            out_dir = OUTPUT_DIR / book_type / voice_name
            if not out_dir.exists():
                continue
            ext = ".mp3" if HAS_FFMPEG else ".wav"
            files = sorted(out_dir.glob(f"*{ext}"))
            for f in files:
                dur = get_audio_duration(f)
                size_mb = f.stat().st_size / (1024 * 1024)
                print(f"  {book_type}/{voice_name}/{f.name}: {dur:.1f}s ({dur/60:.1f}min), {size_mb:.1f}MB")


if __name__ == "__main__":
    main()

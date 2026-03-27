#!/usr/bin/env python3
"""Generate audiobook chapters using Qwen3-TTS (via FastAPI mirror).

Uses the Q-from-Bond voice reference for a young, sharp, intellectual
British male narrator.
"""

import base64
import re
import os
import sys
import glob
import json
import subprocess
import time
import tempfile

import requests

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_DIR = os.path.join(os.path.dirname(__file__), "..")
CHAPTERS_DIR = os.path.join(BASE_DIR, "chapters")
OUTPUT_DIR = os.path.join(BASE_DIR, "website", "public", "audiobook")

# FastAPI mirror (most reliable)
FASTAPI_BASE = "https://huggingfacem4-faster-qwen3-tts-demo.hf.space"

# Voice reference: Q-from-Bond style
REF_AUDIO = os.path.join(BASE_DIR, "assets", "voice-ref-q.wav")
REF_TEXT = (
    "Now pay attention, double-oh seven. I've designed this system to be "
    "quite elegant. Every component serves a purpose. The encryption protocol "
    "is unbreakable, the interface is intuitive, and the entire architecture "
    "can be deployed in under thirty seconds. Please do bring it back in one piece."
)

# Retry config
MAX_RETRIES = 5
INITIAL_BACKOFF = 10

# Maximum chars per TTS chunk (Gradio spaces have limits)
MAX_CHUNK_CHARS = 500

# Title pause duration in seconds
TITLE_PAUSE_SECONDS = 3


def strip_typst(text):
    """Strip Typst markup from text, leaving readable prose."""
    def _extract_figure_caption(m):
        figure_text = m.group(0)
        cap_match = re.search(r'caption:\s*\[([^\]]*)\]', figure_text)
        if cap_match:
            return '\n\n' + cap_match.group(1).strip() + '\n\n'
        return ''
    text = re.sub(r'#figure\([\s\S]*?\n\)', _extract_figure_caption, text)
    text = re.sub(r'image\(".*?"[^)]*\)', '', text, flags=re.DOTALL)
    text = re.sub(r'^#(import|show|set|let|pagebreak|v|align|table|grid|columns|colbreak|place|box|rect|block|circle|stack|counter|context|include).*$', '', text, flags=re.MULTILINE)
    text = re.sub(r'#emoji\.\w+', '', text)
    def _narrate_code_block(m):
        code = m.group(0)
        code = re.sub(r'^```\w*\n?', '', code)
        code = re.sub(r'\n?```$', '', code)
        code = code.strip()
        if not code:
            return ''
        return '\n\n' + code + '\n\n'
    text = re.sub(r'```[\s\S]*?```', _narrate_code_block, text)
    text = re.sub(r'\*([^*]+)\*', r'\1', text)
    text = re.sub(r'_([^_]+)_', r'\1', text)
    text = re.sub(r'#link\(".*?"\)\[([^\]]*)\]', r'\1', text)
    text = re.sub(r'@\w+', '', text)
    text = re.sub(r'<[^>]+>', '', text)
    text = re.sub(r'#\w+\([^)]*\)', '', text)
    text = re.sub(r'//.*$', '', text, flags=re.MULTILINE)
    text = re.sub(r'^(=+)\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'^[-*]\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'^\+\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r'\[\s*\]', '', text)
    text = re.sub(r'\(\s*\)', '', text)
    text = re.sub(r',\s*\)', ')', text)
    text = text.strip()
    return text


def get_chapter_title(text, filename):
    """Extract chapter title from Typst content."""
    match = re.search(r'^=\s+(.+)$', text, re.MULTILINE)
    if match:
        return match.group(1).strip()
    name = os.path.basename(filename).replace('.typ', '')
    return name.replace('-', ' ').title()


def split_into_chunks(text, max_chars=MAX_CHUNK_CHARS):
    """Split text into chunks at sentence boundaries."""
    sentences = re.split(r'(?<=[.!?])\s+', text)
    chunks = []
    current = ""
    for sentence in sentences:
        if len(current) + len(sentence) + 1 > max_chars and current:
            chunks.append(current.strip())
            current = sentence
        else:
            current = current + " " + sentence if current else sentence
    if current.strip():
        chunks.append(current.strip())
    return chunks


def tts_generate(text):
    """Call Qwen3-TTS FastAPI mirror with Q-voice reference and return WAV bytes."""
    backoff = INITIAL_BACKOFF
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            files = {"ref_audio": open(REF_AUDIO, "rb")} if os.path.exists(REF_AUDIO) else {}
            data = {
                "text": text,
                "ref_text": REF_TEXT,
            }
            if not files:
                data["ref_preset"] = "ref_audio_3"

            resp = requests.post(
                f"{FASTAPI_BASE}/generate",
                data=data,
                files=files,
                timeout=120,
            )
            if resp.status_code == 429 or resp.status_code >= 500:
                raise RuntimeError(f"HTTP {resp.status_code}: {resp.text[:200]}")
            resp.raise_for_status()

            result = resp.json()
            if "audio_b64" not in result:
                raise RuntimeError(f"No audio_b64 in response: {list(result.keys())}")

            return base64.b64decode(result["audio_b64"])

        except Exception as e:
            print(f"  [attempt {attempt}/{MAX_RETRIES}] {e}")
            if attempt < MAX_RETRIES:
                print(f"  Retrying in {backoff}s ...")
                time.sleep(backoff)
                backoff = min(backoff * 2, 120)
            else:
                raise RuntimeError(f"Failed after {MAX_RETRIES} attempts: {e}")


def wav_to_mp3(wav_path, mp3_path):
    """Convert WAV to MP3 using ffmpeg."""
    subprocess.run([
        "ffmpeg", "-y", "-i", wav_path,
        "-codec:a", "libmp3lame", "-qscale:a", "2",
        mp3_path
    ], capture_output=True)
    return os.path.exists(mp3_path)


def generate_silence(duration_s, output_path):
    """Generate a silent WAV file of given duration."""
    subprocess.run([
        "ffmpeg", "-y", "-f", "lavfi",
        "-i", f"anullsrc=r=24000:cl=mono",
        "-t", str(duration_s),
        output_path
    ], capture_output=True)


def concatenate_wavs(wav_files, output_path):
    """Concatenate multiple WAV files into one using ffmpeg."""
    list_path = output_path + ".txt"
    with open(list_path, 'w') as f:
        for wav in wav_files:
            f.write(f"file '{wav}'\n")
    subprocess.run([
        "ffmpeg", "-y", "-f", "concat", "-safe", "0",
        "-i", list_path, "-c", "copy", output_path
    ], capture_output=True)
    os.unlink(list_path)


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    chapters = sorted(glob.glob(os.path.join(CHAPTERS_DIR, "*.typ")))

    # Optional filter
    if len(sys.argv) > 1:
        filter_str = sys.argv[1]
        chapters = [c for c in chapters if filter_str in c]

    print("Audiobook Generator (Qwen3-TTS / Ethan voice)")
    print(f"Found {len(chapters)} chapters")
    print(f"Output: {OUTPUT_DIR}")
    print(f"Voice: Q-from-Bond (FastAPI + voice clone)")
    print()

    chapter_mp3s = []

    for chapter_path in chapters:
        basename = os.path.basename(chapter_path).replace('.typ', '')
        mp3_path = os.path.join(OUTPUT_DIR, f"{basename}.mp3")

        if os.path.exists(mp3_path) and os.path.getsize(mp3_path) > 1000:
            print(f"  {basename}: already exists, skipping")
            chapter_mp3s.append(mp3_path)
            continue

        with open(chapter_path, 'r') as f:
            raw = f.read()

        title = get_chapter_title(raw, chapter_path)
        text = strip_typst(raw)

        if len(text.strip()) < 50:
            print(f"  {basename}: too short, skipping")
            continue

        # Split into chunks
        chunks = split_into_chunks(text)
        print(f"\n--- {basename}: {title} ---")
        print(f"  {len(text)} chars -> {len(chunks)} chunks")

        with tempfile.TemporaryDirectory() as tmpdir:
            chunk_wavs = []

            # Generate title
            title_text = f"Chapter. {title}."
            print(f"  title: generating '{title_text}' ...", end=" ", flush=True)
            try:
                audio = tts_generate(title_text)
                title_wav = os.path.join(tmpdir, "title.wav")
                with open(title_wav, 'wb') as f:
                    f.write(audio)
                chunk_wavs.append(title_wav)

                # Add pause after title
                silence_wav = os.path.join(tmpdir, "silence.wav")
                generate_silence(TITLE_PAUSE_SECONDS, silence_wav)
                chunk_wavs.append(silence_wav)
                print("OK")
            except Exception as e:
                print(f"FAILED: {e}")
                continue

            # Generate each chunk
            for i, chunk in enumerate(chunks, 1):
                print(f"  chunk {i}/{len(chunks)}: generating ({len(chunk)} chars) ...", end=" ", flush=True)
                try:
                    audio = tts_generate(chunk)
                    chunk_wav = os.path.join(tmpdir, f"chunk_{i:04d}.wav")
                    with open(chunk_wav, 'wb') as f:
                        f.write(audio)
                    chunk_wavs.append(chunk_wav)
                    size_kb = len(audio) // 1024
                    print(f"OK ({size_kb} KB)")
                except Exception as e:
                    print(f"FAILED: {e}")
                    continue

            # Concatenate all chunks into chapter WAV
            if chunk_wavs:
                chapter_wav = os.path.join(tmpdir, "chapter.wav")
                concatenate_wavs(chunk_wavs, chapter_wav)

                # Convert to MP3
                if wav_to_mp3(chapter_wav, mp3_path):
                    mp3_mb = os.path.getsize(mp3_path) / 1024 / 1024
                    print(f"  -> {basename}.mp3 ({mp3_mb:.1f} MB)")
                    chapter_mp3s.append(mp3_path)
                else:
                    print(f"  MP3 conversion failed for {basename}")

    # Create full book by concatenating all chapter MP3s
    if chapter_mp3s:
        full_mp3 = os.path.join(OUTPUT_DIR, "the-agentic-crew-full.mp3")
        list_path = os.path.join(OUTPUT_DIR, "_concat.txt")
        with open(list_path, 'w') as f:
            for mp3 in chapter_mp3s:
                f.write(f"file '{mp3}'\n")
        subprocess.run([
            "ffmpeg", "-y", "-f", "concat", "-safe", "0",
            "-i", list_path, "-c", "copy", full_mp3
        ], capture_output=True)
        os.unlink(list_path)

        if os.path.exists(full_mp3):
            full_mb = os.path.getsize(full_mp3) / 1024 / 1024
            print(f"\nFull book: {full_mp3} ({full_mb:.1f} MB)")

    print("\nDone!")


if __name__ == "__main__":
    main()

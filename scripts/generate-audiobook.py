#!/usr/bin/env python3
"""
Audiobook generation pipeline for "The Agentic Crew".

Uses Qwen3-TTS via HuggingFace Gradio Space API to generate speech from
Typst chapter files, then concatenates chunks into chapter and full-book MP3s.
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

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent
ADULT_CHAPTERS_DIR = BASE_DIR / "chapters"
ADULT_CA_CHAPTERS_DIR = BASE_DIR / "chapters" / "ca"
ADULT_ES_CHAPTERS_DIR = BASE_DIR / "chapters" / "es"
ADULT_DA_CHAPTERS_DIR = BASE_DIR / "chapters" / "da"
KIDS_CHAPTERS_DIR = BASE_DIR / "chapters" / "kids"
OUTPUT_DIR = BASE_DIR / "website" / "public" / "audiobook"

HF_API_KEY = os.environ.get("HF_API_KEY", "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")

# Primary: faster mirror (FastAPI, more reliable)
FASTAPI_BASE = "https://huggingfacem4-faster-qwen3-tts-demo.hf.space"
# Fallback: official Gradio Space
GRADIO_BASE = "https://qwen-qwen3-tts.hf.space/gradio_api/call/generate_custom_voice"

# API backend: "fastapi" or "gradio"
TTS_BACKEND = os.environ.get("TTS_BACKEND", "fastapi")

# Custom voice clone reference audio (recorded by the author)
CUSTOM_REF_AUDIO = BASE_DIR / "assets" / "voice-ref.wav"
CUSTOM_REF_TEXT = (
    "The best software is built by people who care deeply about the problem "
    "they are solving. It's not about the tools you use or the frameworks you "
    "pick. It's about understanding what matters, making smart trade-offs and "
    "shipping something that actually works in the real world."
)

# Background music config
BGM_VOICE_VOLUME = 8.0
BGM_MUSIC_VOLUME = 0.08

# Per-chapter BGM mapping: chapter stem prefix -> BGM source file in assets/
# Chapters not listed here fall back to the default BGM.
CHAPTER_BGM = {
    "01": "bgm-hazelwood.mp3",    # Hazelwood - Coming Of Age
    "02": "bgm-lighthouse.mp3",   # Zambolino - Lighthouse
}
DEFAULT_BGM = "bgm-hazelwood.mp3"

# Title pause duration in seconds
TITLE_PAUSE_SECONDS = 3

VOICES = {
    "male": {
        # FastAPI backend: custom voice clone from author's recording
        "ref_audio": str(CUSTOM_REF_AUDIO),
        "ref_text": CUSTOM_REF_TEXT,
        # Preset fallback (if no custom ref audio)
        "ref_preset": "ref_audio_3",
        # Gradio backend (fallback)
        "speaker": "Aiden",
        "style": "Read in a deep, rich baritone with gravitas and authority, like a seasoned documentary narrator delivering an epic story. Pace is measured and deliberate, with dramatic pauses for emphasis.",
    },
    "female": {
        # FastAPI backend: voice clone with preset
        "ref_preset": "ref_audio_2",
        "ref_text": "when to leave and where to go. It's not Shakespeare. It does not speak in memorable lines. My inner voice always gives it to me straight,",
        # Gradio backend (fallback)
        "speaker": "Serena",
        "style": "Read in a warm, clear storytelling tone, like a professional audiobook narrator",
    },
}

# Chapter number to spoken title mapping
CHAPTER_TITLES = {
    "01": "Chapter One. Introduction.",
    "02": "Chapter Two. Context.",
    "03": "Chapter Three. What is an Agent?",
    "04": "Chapter Four. Claude Code in the Terminal.",
    "05": "Chapter Five. Guardrails.",
    "06": "Chapter Six. Git.",
    "07": "Chapter Seven. Sandboxes.",
    "08": "Chapter Eight. Testing as the Feedback Loop.",
    "09": "Chapter Nine. Convention over Configuration.",
    "09b": "Chapter Nine B. Tool Integrations.",
    "10": "Chapter Ten. Local versus Commercial LLMs.",
    "11": "Chapter Eleven. Prompting as Engineering.",
    "12": "Chapter Twelve. Multi-Agent Orchestration.",
    "12b": "Chapter Twelve B. CI CD and Agents.",
    "13": "Chapter Thirteen. War Stories.",
    "14": "Chapter Fourteen. When Not to Use Agents.",
    "15": "Chapter Fifteen. Agentic Teams.",
    "16": "Chapter Sixteen. Final Words.",
}

CHAPTER_TITLES_CA = {
    "01": "Capítol Un. Introducció.",
    "02": "Capítol Dos. Context.",
    "03": "Capítol Tres. Què és un Agent?",
    "04": "Capítol Quatre. Claude Code al Terminal.",
    "05": "Capítol Cinc. Baranes de Seguretat.",
    "06": "Capítol Sis. Git.",
    "07": "Capítol Set. Sandboxes.",
    "08": "Capítol Vuit. Els Tests com a Bucle de Retroalimentació.",
    "09": "Capítol Nou. Convenció sobre Configuració.",
    "09b": "Capítol Nou B. Integracions d'Eines.",
    "10": "Capítol Deu. LLMs Locals versus Comercials.",
    "11": "Capítol Onze. El Prompting com a Enginyeria.",
    "12": "Capítol Dotze. Orquestració Multi-Agent.",
    "12b": "Capítol Dotze B. CI CD i Agents.",
    "13": "Capítol Tretze. Històries de Guerra.",
    "14": "Capítol Catorze. Quan No Utilitzar Agents.",
    "15": "Capítol Quinze. Equips Agèntics.",
    "16": "Capítol Setze. Paraules Finals.",
}

CHAPTER_TITLES_ES = {
    "01": "Capítulo Uno. Introducción.",
    "02": "Capítulo Dos. Contexto.",
    "03": "Capítulo Tres. Qué es un Agente.",
    "04": "Capítulo Cuatro. Claude Code en el Terminal.",
    "05": "Capítulo Cinco. Barandillas.",
    "06": "Capítulo Seis. Git.",
    "07": "Capítulo Siete. Sandboxes.",
    "08": "Capítulo Ocho. Testing como Bucle de Retroalimentación.",
    "09": "Capítulo Nueve. Convención sobre Configuración.",
    "09b": "Capítulo Nueve B. Integraciones de Herramientas.",
    "10": "Capítulo Diez. LLMs Locales versus Comerciales.",
    "11": "Capítulo Once. Prompting como Ingeniería.",
    "12": "Capítulo Doce. Orquestación Multi-Agente.",
    "12b": "Capítulo Doce B. CI CD y Agentes.",
    "13": "Capítulo Trece. Historias de Guerra.",
    "14": "Capítulo Catorce. Cuándo No Usar Agentes.",
    "15": "Capítulo Quince. Equipos Agénticos.",
    "16": "Capítulo Dieciséis. Palabras Finales.",
}

CHAPTER_TITLES_DA = {
    "01": "Kapitel Et. Introduktion.",
    "02": "Kapitel To. Kontekst.",
    "03": "Kapitel Tre. Hvad er en Agent?",
    "04": "Kapitel Fire. Claude Code i Terminalen.",
    "05": "Kapitel Fem. Sikkerhedsværn.",
    "06": "Kapitel Seks. Git.",
    "07": "Kapitel Syv. Sandboxes.",
    "08": "Kapitel Otte. Test som Feedback-Loop.",
    "09": "Kapitel Ni. Konvention over Konfiguration.",
    "09b": "Kapitel Ni B. Værktøjsintegrationer.",
    "10": "Kapitel Ti. Lokale versus Kommercielle LLMs.",
    "11": "Kapitel Elleve. Prompting som Ingeniørarbejde.",
    "12": "Kapitel Tolv. Multi-Agent Orkestrering.",
    "12b": "Kapitel Tolv B. CI CD og Agenter.",
    "13": "Kapitel Tretten. Krigshistorier.",
    "14": "Kapitel Fjorten. Hvornår Man Ikke Skal Bruge Agenter.",
    "15": "Kapitel Femten. Agentiske Teams.",
    "16": "Kapitel Seksten. Sidste Ord.",
}

MAX_CHUNK_CHARS = 500
MAX_RETRIES = 5
INITIAL_BACKOFF = 10  # seconds
HAS_FFMPEG = shutil.which("ffmpeg") is not None

# ---------------------------------------------------------------------------
# Text extraction – strip Typst markup
# ---------------------------------------------------------------------------

def strip_typst(text: str) -> str:
    """Remove Typst markup and return plain text.

    Code blocks and figure captions are preserved as narrated content
    so the audiobook matches the PDF book.
    """

    # Convert code blocks to narrated content instead of removing them
    def _narrate_code_block(m):
        code = m.group(0)
        # Strip the ``` delimiters and optional language tag
        code = re.sub(r"^```\w*\n?", "", code)
        code = re.sub(r"\n?```$", "", code)
        code = code.strip()
        if not code:
            return ""
        # Read the code content as-is so listeners hear exactly what's in the book
        return f"\n\n{code}\n\n"

    text = re.sub(r"```[\s\S]*?```", _narrate_code_block, text)

    # Extract figure captions before removing figure commands
    # Matches #figure(..., caption: [...]) and keeps the caption text
    def _extract_figure_caption(t):
        pattern = r"#figure\("
        while True:
            m = re.search(pattern, t)
            if not m:
                break
            start = m.start()
            depth = 0
            i = m.end() - 1  # position of opening paren
            while i < len(t):
                if t[i] == "(":
                    depth += 1
                elif t[i] == ")":
                    depth -= 1
                    if depth == 0:
                        break
                i += 1
            figure_text = t[start:i + 1]
            # Try to extract caption content from caption: [...]
            cap_match = re.search(r"caption:\s*\[([^\]]*)\]", figure_text)
            replacement = ""
            if cap_match:
                replacement = f"\n\n{cap_match.group(1).strip()}\n\n"
            t = t[:start] + replacement + t[i + 1:]
        return t

    text = _extract_figure_caption(text)

    # Remove #image(...), #v(...), #pagebreak() and similar commands
    # These can span multiple lines with nested parens
    def remove_command(t, cmd):
        pattern = r"#" + cmd + r"\("
        while True:
            m = re.search(pattern, t)
            if not m:
                break
            start = m.start()
            depth = 0
            i = m.end() - 1  # position of opening paren
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

    # Remove #quote blocks – keep the inner content
    # #quote[...] or #quote(attribution: ...)[...]
    text = remove_command(text, "quote")

    # Remove #emph[...] and #strong[...] but keep inner text
    text = re.sub(r"#emph\[([^\]]*)\]", r"\1", text)
    text = re.sub(r"#strong\[([^\]]*)\]", r"\1", text)

    # Remove _emphasis_ markers
    text = re.sub(r"_([^_]+)_", r"\1", text)

    # Remove *bold* markers
    text = re.sub(r"\*([^*]+)\*", r"\1", text)

    # Convert heading markers (= , == , === ) to [SECTION] markers for pause insertion
    text = re.sub(r"^=+\s*(.+)$", r"\n[SECTION]\1", text, flags=re.MULTILINE)

    # Remove remaining # directives that are single-line
    text = re.sub(r"#\w+\[([^\]]*)\]", r"\1", text)

    # Remove label markers <...>
    text = re.sub(r"<[a-zA-Z0-9_-]+>", "", text)

    # Remove @ref references – keep just the ref name cleaned up
    text = re.sub(r"@[\w-]+", "", text)

    # Clean up multiple blank lines
    text = re.sub(r"\n{3,}", "\n\n", text)

    # Clean up leading/trailing whitespace per line
    lines = [l.strip() for l in text.split("\n")]
    text = "\n".join(lines)

    return text.strip()


# ---------------------------------------------------------------------------
# Chunking – split text into TTS-friendly pieces
# ---------------------------------------------------------------------------

def chunk_text(text: str, max_chars: int = MAX_CHUNK_CHARS) -> List[str]:
    """Split text into chunks that respect sentence and section boundaries.

    Section headings marked with [SECTION] are emitted as separate chunks
    prefixed with [SECTION] so the caller can insert pauses after them.
    """
    paragraphs = re.split(r"\n\n+", text)
    chunks = []
    current = ""

    for para in paragraphs:
        para = para.strip()
        if not para:
            continue

        # If this is a section heading, flush current and emit it separately
        if para.startswith("[SECTION]"):
            if current:
                chunks.append(current)
                current = ""
            chunks.append(para)  # Keep [SECTION] prefix for the caller
            continue

        # If paragraph itself is within limit, try to append to current chunk
        if len(current) + len(para) + 2 <= max_chars:
            current = (current + "\n\n" + para).strip()
        else:
            # Flush current if non-empty
            if current:
                chunks.append(current)
                current = ""

            # If paragraph fits in one chunk
            if len(para) <= max_chars:
                current = para
            else:
                # Split paragraph by sentences
                sentences = re.split(r"(?<=[.!?])\s+", para)
                for sent in sentences:
                    if len(current) + len(sent) + 1 <= max_chars:
                        current = (current + " " + sent).strip()
                    else:
                        if current:
                            chunks.append(current)
                        # If single sentence exceeds max, just take it as-is
                        current = sent

    if current:
        chunks.append(current)

    return chunks


# ---------------------------------------------------------------------------
# TTS API calls with retry
# ---------------------------------------------------------------------------

def tts_generate_fastapi(text: str, voice: dict) -> bytes:
    """Call the faster-qwen3-tts FastAPI mirror and return WAV audio bytes."""
    form_data = {
        "text": text,
        "ref_text": voice["ref_text"],
    }

    # Use custom ref audio file if available, otherwise fall back to preset
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


def tts_generate_gradio(text: str, voice: dict) -> bytes:
    """Call Qwen3-TTS official Gradio Space and return WAV audio bytes."""
    submit_headers = {"Content-Type": "application/json"}
    payload = {
        "data": [text, "English", voice["speaker"], voice["style"], "1.7B"],
    }

    backoff = INITIAL_BACKOFF
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            # Step 1: Submit
            resp = requests.post(GRADIO_BASE, headers=submit_headers, json=payload, timeout=60)
            if resp.status_code == 429 or resp.status_code >= 500:
                raise RuntimeError(f"HTTP {resp.status_code}: {resp.text[:200]}")
            resp.raise_for_status()
            event_id = resp.json()["event_id"]

            # Step 2: Get SSE result
            sse_url = f"{GRADIO_BASE}/{event_id}"
            sse_resp = requests.get(sse_url, stream=True, timeout=300)
            sse_resp.raise_for_status()

            audio_url = None
            event_type = None
            for line in sse_resp.iter_lines(decode_unicode=True):
                if not line:
                    continue
                if line.startswith("event:"):
                    event_type = line[len("event:"):].strip()
                    continue
                if line.startswith("data:"):
                    data_str = line[len("data:"):].strip()
                    if event_type == "error":
                        raise RuntimeError(f"Gradio returned error event: {data_str}")
                    try:
                        data = json.loads(data_str)
                        if isinstance(data, list):
                            for item in data:
                                if isinstance(item, dict) and "url" in item:
                                    audio_url = item["url"]
                                    break
                        elif isinstance(data, dict) and "url" in data:
                            audio_url = data["url"]
                    except json.JSONDecodeError:
                        pass
                if audio_url:
                    break

            if not audio_url:
                raise RuntimeError("No audio URL found in SSE response")

            # Step 3: Download WAV
            dl_resp = requests.get(audio_url, timeout=120)
            dl_resp.raise_for_status()
            return dl_resp.content

        except Exception as e:
            print(f"  [attempt {attempt}/{MAX_RETRIES}] Error: {e}")
            if attempt < MAX_RETRIES:
                print(f"  Retrying in {backoff}s ...")
                time.sleep(backoff)
                backoff = min(backoff * 2, 120)
            else:
                raise RuntimeError(f"Failed after {MAX_RETRIES} attempts: {e}")


def tts_generate(text: str, voice: dict) -> bytes:
    """Generate TTS audio using the configured backend."""
    if TTS_BACKEND == "fastapi":
        return tts_generate_fastapi(text, voice)
    else:
        return tts_generate_gradio(text, voice)


# ---------------------------------------------------------------------------
# Audio utilities
# ---------------------------------------------------------------------------

def wav_to_mp3(wav_path: Path, mp3_path: Path):
    """Convert WAV to MP3 using ffmpeg."""
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(wav_path), "-codec:a", "libmp3lame", "-qscale:a", "2", str(mp3_path)],
        check=True,
        capture_output=True,
    )


def concatenate_audio_files(input_paths: List[Path], output_path: Path):
    """Concatenate multiple audio files into one using ffmpeg."""
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
    """Return audio duration in seconds using ffprobe."""
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "quiet", "-show_entries", "format=duration",
             "-of", "default=noprint_wrappers=1:nokey=1", str(path)],
            capture_output=True, text=True, check=True,
        )
        return float(result.stdout.strip())
    except Exception:
        return 0.0


# ---------------------------------------------------------------------------
# Chapter processing
# ---------------------------------------------------------------------------

def generate_silence(duration_s: float, output_path: Path):
    """Generate a silent audio file of the given duration."""
    subprocess.run(
        ["ffmpeg", "-y", "-f", "lavfi", "-i", f"anullsrc=r=24000:cl=mono",
         "-t", str(duration_s), "-codec:a", "libmp3lame", "-qscale:a", "2",
         str(output_path)],
        check=True, capture_output=True,
    )


def slow_down_audio(input_path: Path, output_path: Path, speed: float = 0.92):
    """Slow down audio using atempo filter. speed < 1.0 = slower."""
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(input_path),
         "-af", f"atempo={speed}",
         "-codec:a", "libmp3lame", "-qscale:a", "2",
         str(output_path)],
        check=True, capture_output=True,
    )


def get_bgm_path(chapter_stem: str) -> Optional[Path]:
    """Return the BGM source file for a given chapter, or None if not found."""
    # Extract chapter number prefix (e.g. "01", "09b", "12b")
    m = re.match(r"^(\d+[a-z]?)", chapter_stem)
    chapter_num = m.group(1) if m else None
    bgm_name = CHAPTER_BGM.get(chapter_num, DEFAULT_BGM) if chapter_num else DEFAULT_BGM
    bgm_path = BASE_DIR / "assets" / bgm_name
    if bgm_path.exists():
        return bgm_path
    print(f"  [warn] BGM not found at {bgm_path}")
    return None


def mix_with_bgm(narration_path: Path, output_path: Path, chapter_stem: str = ""):
    """Mix narration with looping BGM at configured volumes."""
    bgm_path = get_bgm_path(chapter_stem)
    if not bgm_path:
        shutil.copy2(narration_path, output_path)
        return

    print(f"  Using BGM: {bgm_path.name}")
    subprocess.run(
        ["ffmpeg", "-y",
         "-i", str(narration_path),
         "-stream_loop", "-1", "-i", str(bgm_path),
         "-filter_complex",
         f"[0:a]volume={BGM_VOICE_VOLUME}[voice];"
         f"[1:a]volume={BGM_MUSIC_VOLUME}[bgm];"
         f"[voice][bgm]amix=inputs=2:duration=first:dropout_transition=3[out]",
         "-map", "[out]",
         "-codec:a", "libmp3lame", "-qscale:a", "2",
         str(output_path)],
        check=True, capture_output=True,
    )


def get_chapter_files(chapters_dir: Path) -> List[Path]:
    """Return sorted list of .typ chapter files."""
    files = sorted(chapters_dir.glob("*.typ"))
    return files


def get_chapter_title(stem: str, lang: str = "en") -> Optional[str]:
    """Get the spoken chapter title from the stem (e.g. '01-introduction' -> 'Chapter One...')."""
    titles_map = {"ca": CHAPTER_TITLES_CA, "es": CHAPTER_TITLES_ES, "da": CHAPTER_TITLES_DA}
    titles = titles_map.get(lang, CHAPTER_TITLES)
    m = re.match(r"^(\d+[a-z]?)", stem)
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
    """Generate audio for a single chapter. Returns path to final MP3/WAV.

    Features:
    - Separates chapter title with a pause after it
    - Inserts pauses after section headings
    - Slows down audio slightly for natural narration pace
    - Mixes with background music loop
    """
    voice = VOICES[voice_name]
    stem = chapter_path.stem  # e.g. "01-introduction"
    ext = ".mp3" if HAS_FFMPEG else ".wav"
    final_path = output_dir / f"{stem}{ext}"

    if skip_existing and final_path.exists():
        print(f"  [skip] {final_path.name} already exists")
        return final_path

    # Read and strip Typst
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

    # Generate silence files for pauses
    silence_3s = chunk_dir / "silence-3s.mp3"
    silence_2s = chunk_dir / "silence-2s.mp3"
    if not silence_3s.exists():
        generate_silence(TITLE_PAUSE_SECONDS, silence_3s)
    if not silence_2s.exists():
        generate_silence(2, silence_2s)

    # Generate chapter title audio
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

    # Build ordered list of audio parts: title + pause + chunks (with section pauses)
    part_paths = []

    # Add title + pause if we have one
    if chapter_title and title_path.exists():
        part_paths.append(title_path)
        part_paths.append(silence_3s)

    # Skip the first [SECTION] chunk if it matches the chapter title (avoid duplication)
    skip_first_section = True

    chunk_idx = 0
    for chunk in chunks:
        # Handle section headings: generate the heading text + add a pause
        if chunk.startswith("[SECTION]"):
            section_text = chunk[len("[SECTION]"):].strip()

            # Skip the very first section if it's the chapter's own title
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
                part_paths.append(silence_2s)  # Pause before section
                if section_mp3.exists():
                    part_paths.append(section_mp3)
                part_paths.append(silence_2s)  # Pause after section
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

    # Concatenate all parts into raw narration
    raw_narration = chunk_dir / f"raw-narration{ext}"
    if part_paths:
        print(f"  Concatenating {len(part_paths)} parts -> raw narration")
        concatenate_audio_files(part_paths, raw_narration)

    # Slow down for natural narration pace
    slowed_narration = chunk_dir / f"slowed-narration{ext}"
    if speed < 1.0 and raw_narration.exists():
        print(f"  Slowing down to {speed}x speed ...")
        slow_down_audio(raw_narration, slowed_narration, speed)
    else:
        slowed_narration = raw_narration

    # Mix with background music
    if add_bgm and slowed_narration.exists():
        print(f"  Mixing with background music ...")
        mix_with_bgm(slowed_narration, final_path, stem)
    elif slowed_narration.exists():
        shutil.copy2(slowed_narration, final_path)

    # Clean up chunk dir
    if final_path.exists():
        shutil.rmtree(chunk_dir, ignore_errors=True)

    return final_path


def process_book(
    book_type: str,  # "adult", "adult-ca", or "kids"
    voice_name: str,
    chapters_dir: Path,
    output_base: Path,
    chapter_filter: Optional[str] = None,
    skip_existing: bool = True,
    speed: float = 0.92,
    add_bgm: bool = True,
    lang: str = "en",
):
    """Process all (or filtered) chapters for a book+voice combination."""
    out_dir = output_base / book_type / voice_name
    out_dir.mkdir(parents=True, exist_ok=True)

    # BGM is now resolved per-chapter via get_bgm_path()

    chapter_files = get_chapter_files(chapters_dir)
    if chapter_filter:
        chapter_files = [f for f in chapter_files if chapter_filter in f.name]

    if not chapter_files:
        print(f"No chapters matched filter '{chapter_filter}' in {chapters_dir}")
        return

    ext = ".mp3" if HAS_FFMPEG else ".wav"
    chapter_outputs = []

    for ch in chapter_files:
        print(f"\n--- {book_type}/{voice_name}: {ch.name} ---")
        result = process_chapter(ch, voice_name, out_dir, skip_existing, speed, add_bgm, lang)
        if result and result.exists():
            chapter_outputs.append(result)

    # Concatenate into full book (only if no filter / all chapters processed)
    if not chapter_filter and len(chapter_outputs) > 1:
        full_path = out_dir / f"full-book{ext}"
        print(f"\nConcatenating full book -> {full_path.name}")
        concatenate_audio_files(chapter_outputs, full_path)
        dur = get_audio_duration(full_path)
        size_mb = full_path.stat().st_size / (1024 * 1024)
        print(f"Full book: {dur:.1f}s ({dur/60:.1f}min), {size_mb:.1f} MB")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Generate audiobook for The Agentic Crew")
    parser.add_argument("--book", choices=["adult", "adult-ca", "adult-es", "adult-da", "kids", "all"], default="all",
                        help="Which book to process")
    parser.add_argument("--voice", choices=["male", "female", "both"], default="both",
                        help="Which voice(s) to use")
    parser.add_argument("--chapter", type=str, default=None,
                        help="Filter: only process chapters whose filename contains this string")
    parser.add_argument("--no-skip", action="store_true",
                        help="Regenerate files even if they already exist")
    parser.add_argument("--output", type=str, default=None,
                        help="Override output directory")
    parser.add_argument("--speed", type=float, default=0.92,
                        help="Playback speed (default 0.92, lower = slower)")
    parser.add_argument("--no-bgm", action="store_true",
                        help="Skip background music mixing")
    args = parser.parse_args()

    output_base = Path(args.output) if args.output else OUTPUT_DIR
    skip_existing = not args.no_skip

    voices = ["male", "female"] if args.voice == "both" else [args.voice]
    books = []  # list of (book_type, chapters_dir, lang)
    if args.book in ("adult", "all"):
        books.append(("adult", ADULT_CHAPTERS_DIR, "en"))
    if args.book in ("adult-ca", "all"):
        books.append(("adult-ca", ADULT_CA_CHAPTERS_DIR, "ca"))
    if args.book in ("adult-es", "all"):
        books.append(("adult-es", ADULT_ES_CHAPTERS_DIR, "es"))
    if args.book in ("adult-da", "all"):
        books.append(("adult-da", ADULT_DA_CHAPTERS_DIR, "da"))
    if args.book in ("kids", "all"):
        books.append(("kids", KIDS_CHAPTERS_DIR, "en"))

    print(f"Audiobook generation pipeline")
    print(f"  Books: {[b[0] for b in books]}")
    print(f"  Voices: {voices}")
    print(f"  Chapter filter: {args.chapter or '(all)'}")
    print(f"  Output: {output_base}")
    print(f"  ffmpeg: {'available' if HAS_FFMPEG else 'NOT available (will keep WAV)'}")
    print()

    for book_type, chapters_dir, lang in books:
        for voice_name in voices:
            print(f"\n{'='*60}")
            print(f"Processing: {book_type} / {voice_name}")
            print(f"{'='*60}")
            process_book(
                book_type, voice_name, chapters_dir, output_base,
                chapter_filter=args.chapter,
                skip_existing=skip_existing,
                speed=args.speed,
                add_bgm=not args.no_bgm,
                lang=lang,
            )

    # Summary
    print(f"\n{'='*60}")
    print("SUMMARY")
    print(f"{'='*60}")
    for book_type, _, _ in books:
        for voice_name in voices:
            out_dir = output_base / book_type / voice_name
            if not out_dir.exists():
                continue
            ext = ".mp3" if HAS_FFMPEG else ".wav"
            files = sorted(out_dir.glob(f"*{ext}"))
            for f in files:
                dur = get_audio_duration(f)
                size_mb = f.stat().st_size / (1024 * 1024)
                print(f"  {book_type}/{voice_name}/{f.name}: {dur:.1f}s ({dur/60:.1f}min), {size_mb:.1f} MB")


if __name__ == "__main__":
    main()

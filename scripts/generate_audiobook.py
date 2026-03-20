#!/usr/bin/env python3
"""Generate audiobook chapters using Piper TTS (local, high quality)."""

import re
import os
import sys
import glob
import subprocess

PIPER = "/Users/schlunsen/Library/Python/3.9/bin/piper"
VOICES_DIR = os.path.join(os.path.dirname(__file__), "..", "build", "voices")
CHAPTERS_DIR = os.path.join(os.path.dirname(__file__), "..", "chapters")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "build", "audiobook")

VOICES = [
    ("lessac", os.path.join(VOICES_DIR, "en_US-lessac-high.onnx"), "male"),
    ("amy", os.path.join(VOICES_DIR, "en_US-amy-medium.onnx"), "female"),
]


def strip_typst(text):
    """Strip Typst markup from text, leaving readable prose.

    Code blocks and figure captions are preserved so the audiobook
    matches the PDF book content.
    """
    # Extract figure captions before removing figure commands
    def _extract_figure_caption(m):
        figure_text = m.group(0)
        cap_match = re.search(r'caption:\s*\[([^\]]*)\]', figure_text)
        if cap_match:
            return '\n\n' + cap_match.group(1).strip() + '\n\n'
        return ''
    text = re.sub(r'#figure\([\s\S]*?\n\)', _extract_figure_caption, text)
    # Remove image references
    text = re.sub(r'image\(".*?"[^)]*\)', '', text, flags=re.DOTALL)
    # Remove #import, #show, #set, #let, #pagebreak and similar directives
    text = re.sub(r'^#(import|show|set|let|pagebreak|v|align|table|grid|columns|colbreak|place|box|rect|block|circle|stack|counter|context|include).*$', '', text, flags=re.MULTILINE)
    # Remove #emoji references
    text = re.sub(r'#emoji\.\w+', '', text)
    # Convert code blocks to narrated content instead of removing them
    def _narrate_code_block(m):
        code = m.group(0)
        code = re.sub(r'^```\w*\n?', '', code)
        code = re.sub(r'\n?```$', '', code)
        code = code.strip()
        if not code:
            return ''
        return '\n\n' + code + '\n\n'
    text = re.sub(r'```[\s\S]*?```', _narrate_code_block, text)
    # Remove bold/italic markers
    text = re.sub(r'\*([^*]+)\*', r'\1', text)
    text = re.sub(r'_([^_]+)_', r'\1', text)
    # Remove links
    text = re.sub(r'#link\(".*?"\)\[([^\]]*)\]', r'\1', text)
    # Remove label refs
    text = re.sub(r'@\w+', '', text)
    text = re.sub(r'<[^>]+>', '', text)
    # Remove remaining # function calls
    text = re.sub(r'#\w+\([^)]*\)', '', text)
    # Remove Typst comments
    text = re.sub(r'//.*$', '', text, flags=re.MULTILINE)
    # Remove heading markers (= == ===)
    text = re.sub(r'^(=+)\s+', '', text, flags=re.MULTILINE)
    # Remove list markers
    text = re.sub(r'^[-*]\s+', '', text, flags=re.MULTILINE)
    text = re.sub(r'^\+\s+', '', text, flags=re.MULTILINE)
    # Clean up multiple blank lines
    text = re.sub(r'\n{3,}', '\n\n', text)
    # Clean up stray punctuation/brackets
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


def generate_wav(text, voice_model, output_path):
    """Generate WAV using piper TTS."""
    proc = subprocess.run(
        [PIPER, "--model", voice_model, "--output_file", output_path],
        input=text.encode(),
        capture_output=True,
        timeout=600
    )
    if proc.returncode != 0:
        print(f"  ERROR: {proc.stderr.decode()[:200]}")
        return False
    return os.path.exists(output_path) and os.path.getsize(output_path) > 100


def wav_to_mp3(wav_path, mp3_path):
    """Convert WAV to MP3 using ffmpeg."""
    subprocess.run([
        "ffmpeg", "-y", "-i", wav_path,
        "-codec:a", "libmp3lame", "-qscale:a", "2",
        mp3_path
    ], capture_output=True)
    return os.path.exists(mp3_path)


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    chapters = sorted(glob.glob(os.path.join(CHAPTERS_DIR, "*.typ")))

    # Optional filter
    if len(sys.argv) > 1:
        filter_str = sys.argv[1]
        chapters = [c for c in chapters if filter_str in c]

    print("Audiobook Generator (Piper TTS)")
    print(f"Found {len(chapters)} chapters")
    print(f"Output: {OUTPUT_DIR}")

    for voice_name, voice_model, gender in VOICES:
        print(f"\n{'='*60}")
        print(f"Voice: {voice_name} ({gender})")
        print(f"{'='*60}")

        chapter_wavs = []

        for chapter_path in chapters:
            basename = os.path.basename(chapter_path).replace('.typ', '')
            wav_path = os.path.join(OUTPUT_DIR, f"{basename}_{gender}.wav")
            mp3_path = os.path.join(OUTPUT_DIR, f"{basename}_{gender}.mp3")

            if os.path.exists(mp3_path) and os.path.getsize(mp3_path) > 1000:
                print(f"  {basename}: already exists, skipping")
                chapter_wavs.append(wav_path if os.path.exists(wav_path) else mp3_path)
                continue

            with open(chapter_path, 'r') as f:
                raw = f.read()

            title = get_chapter_title(raw, chapter_path)
            text = strip_typst(raw)

            if len(text.strip()) < 50:
                print(f"  {basename}: too short, skipping")
                continue

            # Add chapter intro
            full_text = f"Chapter: {title}.\n\n{text}"
            print(f"  {basename}: {len(full_text)} chars...", end=" ", flush=True)

            if generate_wav(full_text, voice_model, wav_path):
                size_mb = os.path.getsize(wav_path) / 1024 / 1024
                print(f"WAV OK ({size_mb:.1f}MB)", end=" ", flush=True)

                # Convert to MP3
                if wav_to_mp3(wav_path, mp3_path):
                    mp3_mb = os.path.getsize(mp3_path) / 1024 / 1024
                    print(f"-> MP3 ({mp3_mb:.1f}MB)")
                    chapter_wavs.append(wav_path)
                else:
                    print("MP3 conversion failed")
                    chapter_wavs.append(wav_path)
            else:
                print("FAILED")

        # Create full book by concatenating all chapter MP3s
        if chapter_wavs:
            full_mp3 = os.path.join(OUTPUT_DIR, f"the-agentic-crew-full_{gender}.mp3")
            mp3_files = [os.path.join(OUTPUT_DIR, f"{os.path.basename(w).replace('.wav', '.mp3')}")
                        for w in chapter_wavs if w.endswith('.wav')]
            mp3_files = [f for f in mp3_files if os.path.exists(f)]

            if mp3_files:
                list_path = os.path.join(OUTPUT_DIR, f"_concat_{gender}.txt")
                with open(list_path, 'w') as f:
                    for mp3 in mp3_files:
                        f.write(f"file '{mp3}'\n")
                subprocess.run([
                    "ffmpeg", "-y", "-f", "concat", "-safe", "0",
                    "-i", list_path, "-c", "copy", full_mp3
                ], capture_output=True)
                os.unlink(list_path)

                if os.path.exists(full_mp3):
                    full_mb = os.path.getsize(full_mp3) / 1024 / 1024
                    print(f"\n  Full book: {full_mp3} ({full_mb:.1f}MB)")

    # Clean up WAV files (keep only MP3s)
    print("\nCleaning up WAV files...")
    for wav in glob.glob(os.path.join(OUTPUT_DIR, "*.wav")):
        mp3 = wav.replace('.wav', '.mp3')
        if os.path.exists(mp3):
            os.unlink(wav)
            print(f"  Removed {os.path.basename(wav)}")

    print("\nDone!")


if __name__ == "__main__":
    main()

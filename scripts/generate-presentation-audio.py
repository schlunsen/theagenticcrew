#!/usr/bin/env python3
"""
Generate narration audio for the slide presentation using Qwen3-TTS.

Uses the author's voice reference (assets/voice-ref.wav) to clone the voice
via the HuggingFace faster-qwen3-tts FastAPI mirror.

Output: website/public/presentation-audio/slide-{01..13}.mp3
"""

import base64
import os
import shutil
import subprocess
import tempfile
import time
from pathlib import Path

import requests

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = BASE_DIR / "website" / "public" / "presentation-audio"
CUSTOM_REF_AUDIO = BASE_DIR / "assets" / "voice-ref.wav"
CUSTOM_REF_TEXT = (
    "The best software is built by people who care deeply about the problem "
    "they are solving. It's not about the tools you use or the frameworks you "
    "pick. It's about understanding what matters, making smart trade-offs and "
    "shipping something that actually works in the real world."
)

FASTAPI_BASE = "https://huggingfacem4-faster-qwen3-tts-demo.hf.space"
MAX_RETRIES = 5
INITIAL_BACKOFF = 10
SPEED = 0.92  # Slow down slightly for natural narration pace

HAS_FFMPEG = shutil.which("ffmpeg") is not None

# ---------------------------------------------------------------------------
# Slide narration scripts — what "Rasmus" says on each slide
# ---------------------------------------------------------------------------

SLIDE_NARRATIONS = {
    1: (
        "Welcome, everyone. I'm Rasmus, and this is The Agentic Crew. "
        "A field guide to engineering in the age of AI agents. "
        "Let me take you through the key ideas from the book."
    ),
    2: (
        "For twenty years, being a software engineer meant one thing. "
        "You open an editor, you write code, you ship it. "
        "That loop is breaking. And the numbers tell the story. "
        "Seventy-two percent of developers used AI coding tools in twenty twenty-five. "
        "At leading firms, agents now write over thirty percent of shipped code. "
        "The old loop was write, run, ship. The new loop is instruct, review, steer. "
        "AI agents don't just autocomplete. They read your codebase, reason about architecture, "
        "make changes across dozens of files, run your tests, and iterate on failures. "
        "All without you touching the keyboard."
    ),
    3: (
        "The craft isn't dying. It's molting. "
        "The keystrokes, the syntax, the boilerplate, that part is falling away. "
        "But the judgment and taste underneath? More alive than ever. "
        "This book covers eighteen chapters of what comes next. "
        "Guardrails and sandboxes. Prompt engineering. Multi-agent orchestration. "
        "Agents in CI CD pipelines. Testing as the feedback loop. "
        "And knowing when not to use agents at all. "
        "It's a practical guide, not a manifesto."
    ),
    4: (
        "So what actually is an agent? Let's get precise. "
        "At one end, autocomplete suggests the next few tokens. Reactive, no thinking. "
        "A copilot sees more context but is still passive. You ask, it responds. "
        "Then comes tool-using agents. They don't just generate text, they act. "
        "They read files, write files, run commands, inspect results, and do it in a loop. "
        "Try, observe, adjust, try again. "
        "Most practical agentic engineering today happens right here, in that tool-using zone."
    ),
    5: (
        "The best analogy I've found is Rain Man. "
        "You're Tom Cruise. The agent is Dustin Hoffman. "
        "Raymond can count cards like no human alive. "
        "He sees patterns in mountains of data, processes them instantly, never gets tired. "
        "But he can't navigate a casino floor. He doesn't know why they're counting cards. "
        "Charlie is the one with the plan. He knows which casino to hit, when to bet big, when to cash out. "
        "That's agentic engineering. You provide direction, judgment, and taste. "
        "The agent provides speed and breadth. The combination is more powerful than either alone."
    ),
    6: (
        "Three capabilities separate an agent from a fancy chatbot. "
        "First, planning. An agent breaks a goal into steps. "
        "Add authentication to this app becomes a series of actions. "
        "Second, tool use. An agent interacts with the world, reads your files, runs your tests. "
        "The tools you give an agent define what kind of agent it is. "
        "And third, iteration. An agent can try, fail, and try again. "
        "Write a function, run the tests, see a failure, read the error, adjust, rerun. "
        "That cycle is the magic."
    ),
    7: (
        "Agents will fail. Understanding how they fail helps you build better workflows. "
        "Scope creep: you ask for a bug fix, and the agent refactors three files and updates the build system. "
        "Hallucinated APIs: the agent calls functions or libraries that don't exist. "
        "Overconfidence: the agent says it's done, and it looks done, but there's a subtle bug. "
        "Context loss: on long tasks, the agent loses track of earlier decisions. "
        "Every failure mode has a mitigation, and those mitigations are the chapters of this book."
    ),
    8: (
        "Five practices form the engineering toolkit for working with agents. "
        "Guardrails keep agents on track through linters, type checkers, and approval gates. "
        "Git gives you version control as a safety net, with branches for isolation and diffs for review. "
        "Sandboxes provide isolated environments where agents can safely experiment. "
        "Testing is the feedback loop that makes agents reliable, not just fast. "
        "And conventions, naming patterns and structure that agents can follow without being told. "
        "These five reinforce each other. Together, they're the ship that makes any crew productive."
    ),
    9: (
        "Multi-agent orchestration sounds abstract until you build it. "
        "Wee is a self-hosted control plane for running multiple AI agent sessions from your browser. "
        "Built in Go, single fifteen megabyte binary, no dependencies. "
        "But the interesting part isn't the features. "
        "It's what building it taught me about orchestration in practice. "
        "Running multiple sessions is multi-agent orchestration from chapter twelve. "
        "Granular permissions are guardrails in code, from chapter four. "
        "And pipeline integration is agents in CI CD, from chapter thirteen. "
        "The best way to learn agentic engineering is to build agentic tooling."
    ),
    10: (
        "Everything in this book converges in one of the most compelling applications "
        "of agentic engineering: automated penetration testing. "
        "Donna is an open-source pentesting platform built on the Claude Agent SDK and Temporal. "
        "It runs thirteen specialised agents across five phases: reconnaissance, "
        "vulnerability analysis with five agents in parallel, "
        "exploitation with another five in parallel, and reporting. "
        "The exploitation agents don't just flag potential issues. "
        "They execute real attacks to confirm vulnerabilities, capturing evidence along the way. "
        "Every principle from the book, guardrails, sandboxes, orchestration, testing, converges here. "
        "If you can safely let agents attack your software, you've mastered agentic engineering."
    ),
    11: (
        "Here's the irony of pentesting agents. "
        "The same guardrails that protect you from rogue agents in normal development "
        "now need to protect the world from your intentionally hostile agents. "
        "Two rules are non-negotiable. "
        "First, isolate and authorize. Sandbox your pentesting agents. Get written permission. "
        "A SQL injection test against your production database is not a test, it's an incident. "
        "Second, verify everything. Agents hallucinate vulnerabilities just as readily as they "
        "hallucinate library names. Every finding needs human eyes before it becomes an action item. "
        "If your guardrail configuration can handle an agent that's trying to break things, "
        "it can handle anything."
    ),
    12: (
        "This is the central metaphor of the book. "
        "You're the captain. The agents are your crew. The codebase is the ship. "
        "Most days, I spin up an agent, give it a job, take the output, and throw it overboard. "
        "Then I spin up another one. They don't remember the last session. "
        "The crew is disposable. The ship is not. "
        "Your conventions, your test suites, your project rules, those are the ship. "
        "And if you've built the ship well, any new crew member will be productive in minutes."
    ),
    13: (
        "Here's what I want you to do. "
        "Tonight, not tomorrow, not next week, tonight, open your terminal. "
        "Pick a bug you've been avoiding. Point an agent at it. Give it context. Set a guardrail. "
        "Watch what happens. "
        "The engineers who will define this era are not waiting for permission. "
        "They are shipping, breaking things, learning, and shipping again, "
        "with a crew at their side that gets a little better every day. "
        "Thank you."
    ),
}


# ---------------------------------------------------------------------------
# TTS generation (reuses the audiobook pipeline's approach)
# ---------------------------------------------------------------------------

def tts_generate(text: str) -> bytes:
    """Call the faster-qwen3-tts FastAPI mirror with voice cloning and return WAV bytes."""
    form_data = {
        "text": text,
        "ref_text": CUSTOM_REF_TEXT,
    }

    use_custom_ref = CUSTOM_REF_AUDIO.exists()

    if not use_custom_ref:
        form_data["ref_preset"] = "ref_audio_3"

    backoff = INITIAL_BACKOFF
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            files = None
            if use_custom_ref:
                files = {"ref_audio": ("ref.wav", open(CUSTOM_REF_AUDIO, "rb"), "audio/wav")}

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


def wav_to_mp3(wav_path: Path, mp3_path: Path):
    """Convert WAV to MP3 using ffmpeg."""
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(wav_path), "-codec:a", "libmp3lame", "-qscale:a", "2", str(mp3_path)],
        check=True, capture_output=True,
    )


def slow_down_audio(input_path: Path, output_path: Path, speed: float = SPEED):
    """Slow down audio using atempo filter."""
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(input_path),
         "-af", f"atempo={speed}",
         "-codec:a", "libmp3lame", "-qscale:a", "2",
         str(output_path)],
        check=True, capture_output=True,
    )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("Presentation Audio Generator")
    print(f"  Voice ref: {CUSTOM_REF_AUDIO} ({'exists' if CUSTOM_REF_AUDIO.exists() else 'MISSING'})")
    print(f"  Output:    {OUTPUT_DIR}")
    print(f"  Slides:    {len(SLIDE_NARRATIONS)}")
    print(f"  ffmpeg:    {'available' if HAS_FFMPEG else 'NOT available'}")
    print(f"  Speed:     {SPEED}x")
    print()

    for slide_num in sorted(SLIDE_NARRATIONS.keys()):
        text = SLIDE_NARRATIONS[slide_num]
        mp3_path = OUTPUT_DIR / f"slide-{slide_num:02d}.mp3"

        if mp3_path.exists() and mp3_path.stat().st_size > 1000:
            print(f"  Slide {slide_num:2d}: already exists ({mp3_path.stat().st_size / 1024:.0f} KB), skipping")
            continue

        print(f"  Slide {slide_num:2d}: generating ({len(text)} chars) ...", end=" ", flush=True)

        try:
            wav_bytes = tts_generate(text)

            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                tmp.write(wav_bytes)
                tmp_wav = Path(tmp.name)

            if HAS_FFMPEG:
                # Convert to MP3
                tmp_mp3 = tmp_wav.with_suffix(".mp3")
                wav_to_mp3(tmp_wav, tmp_mp3)
                tmp_wav.unlink()

                # Slow down for natural pace
                slow_down_audio(tmp_mp3, mp3_path, SPEED)
                tmp_mp3.unlink()

                size_kb = mp3_path.stat().st_size / 1024
                print(f"OK ({size_kb:.0f} KB)")
            else:
                # No ffmpeg — save as WAV
                wav_path = OUTPUT_DIR / f"slide-{slide_num:02d}.wav"
                shutil.move(str(tmp_wav), str(wav_path))
                print(f"OK (WAV, no ffmpeg)")

        except Exception as e:
            print(f"FAILED: {e}")

    print("\nDone! Audio files are in:", OUTPUT_DIR)


if __name__ == "__main__":
    main()

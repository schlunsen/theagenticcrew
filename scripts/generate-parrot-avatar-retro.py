#!/usr/bin/env python3
"""
Generate a 70's retro style parrot avatar using Stable Diffusion XL
via the HuggingFace Inference API.

Usage:
    python scripts/generate-parrot-avatar-retro.py
    python scripts/generate-parrot-avatar-retro.py --output my-parrot.png
"""

import argparse
import os
import sys
import time
from pathlib import Path

import requests

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent

HF_API_KEY = (
    os.environ.get("HF_API_KEY")
    or os.environ.get("HF_TOKEN")
    or "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"
)
API_URL = "https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0"

HEADERS = {
    "Authorization": f"Bearer {HF_API_KEY}",
    "Content-Type": "application/json",
}

# ---------------------------------------------------------------------------
# Prompt — 70's retro parrot illustration
# ---------------------------------------------------------------------------

PROMPT = (
    "a vibrant parrot portrait, 1970s retro graphic illustration style, "
    "psychedelic poster art, groovy flat graphic design, "
    "warm earthy palette — burnt orange, avocado green, mustard yellow, dusty rose, sienna brown, "
    "bold graphic shapes with thick outlines, "
    "retro airbrush shading, sunburst halo behind the parrot, "
    "album cover aesthetic, circular badge composition, "
    "macrame flower border, peace-and-love era vibes, "
    "lush tropical feathers in retro muted tones, "
    "centered subject, clean minimal background, "
    "high quality, sharp illustration, no text, no words, no letters"
)

NEGATIVE_PROMPT = (
    "photorealistic, photograph, 3d render, anime, modern, "
    "text, words, letters, watermark, signature, "
    "blurry, low quality, deformed, ugly, noisy, "
    "cold colors, neon, cyberpunk, sci-fi, futuristic"
)

# ---------------------------------------------------------------------------
# Generation
# ---------------------------------------------------------------------------

def generate(output_path: Path, max_retries: int = 3) -> bool:
    payload = {
        "inputs": PROMPT,
        "parameters": {
            "negative_prompt": NEGATIVE_PROMPT,
            "width": 1024,
            "height": 1024,
            "num_inference_steps": 50,
            "guidance_scale": 7.5,
        },
    }

    for attempt in range(1, max_retries + 1):
        print(f"🎨  Generating retro parrot avatar (attempt {attempt}/{max_retries})…")
        try:
            response = requests.post(API_URL, headers=HEADERS, json=payload, timeout=120)
        except requests.exceptions.Timeout:
            print("   ⚠  Request timed out — retrying in 10s")
            time.sleep(10)
            continue

        if response.status_code == 503:
            wait = 20
            print(f"   ⏳  Model loading (503) — waiting {wait}s…")
            time.sleep(wait)
            continue

        if response.status_code != 200:
            print(f"   ✗  HTTP {response.status_code}: {response.text[:200]}")
            if attempt < max_retries:
                time.sleep(5)
            continue

        # Success — response body is raw PNG bytes
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_bytes(response.content)
        print(f"   ✓  Saved → {output_path}")
        return True

    print("✗  All attempts failed.")
    return False


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Generate 70's retro parrot avatar via HuggingFace SDXL")
    parser.add_argument(
        "--output",
        type=Path,
        default=BASE_DIR / "parrot-avatar-retro70s.png",
        help="Output file path (default: parrot-avatar-retro70s.png in project root)",
    )
    parser.add_argument(
        "--copy-to-public",
        action="store_true",
        help="Also copy the result to website/public/parrot-avatar.png",
    )
    args = parser.parse_args()

    ok = generate(args.output)

    if ok and args.copy_to_public:
        import shutil
        dest = BASE_DIR / "website" / "public" / "parrot-avatar.png"
        shutil.copy2(args.output, dest)
        print(f"   📋  Copied to {dest}")

    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()

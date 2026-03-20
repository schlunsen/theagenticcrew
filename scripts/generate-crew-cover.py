#!/usr/bin/env python3
"""
Generate a cover illustration for "The Agentic Crew — Crew Member's Guide".

Uses Stable Diffusion XL via HuggingFace Inference API to generate
a compass rose illustration that complements the main book's ship's wheel.

Usage:
    python scripts/generate-crew-cover.py
"""

import os
import sys
import time
from pathlib import Path

import requests

BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_DIR = BASE_DIR / "assets" / "illustrations" / "crew"

HF_API_KEY = os.environ.get("HF_API_KEY", "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")
API_URL = "https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0"

HEADERS = {
    "Authorization": f"Bearer {HF_API_KEY}",
    "Content-Type": "application/json",
}

# A compass rose — complementary to the main book's ship's wheel
PROMPT = (
    "A detailed ornate compass rose with cardinal directions, "
    "golden metallic finish on dark navy background, "
    "elegant thin line art style, nautical navigation theme, "
    "geometric precision, art deco influences, "
    "single centered object, symmetric design, "
    "gold and amber tones on deep dark blue, "
    "no text, no words, no letters, no labels, no numbers"
)

NEGATIVE_PROMPT = (
    "photorealistic, 3d render, anime, cartoon, childish, cluttered, "
    "text, words, letters, watermark, signature, border, frame, "
    "blurry, low quality, deformed, human figures, hands, fingers, "
    "N S E W, north south east west"
)


def generate_image(prompt: str, output_path: Path, retries: int = 3) -> bool:
    payload = {
        "inputs": prompt,
        "parameters": {
            "negative_prompt": NEGATIVE_PROMPT,
            "width": 768,
            "height": 768,
            "guidance_scale": 8.0,
            "num_inference_steps": 45,
        },
    }

    for attempt in range(retries):
        try:
            print(f"  Generating (attempt {attempt + 1}/{retries})...")
            response = requests.post(API_URL, headers=HEADERS, json=payload, timeout=120)

            if response.status_code == 503:
                wait = response.json().get("estimated_time", 30)
                print(f"  Model loading, waiting {wait:.0f}s...")
                time.sleep(wait)
                continue

            if response.status_code == 200:
                output_path.parent.mkdir(parents=True, exist_ok=True)
                output_path.write_bytes(response.content)
                print(f"  Saved: {output_path}")
                return True

            print(f"  Error {response.status_code}: {response.text[:200]}")

        except requests.exceptions.Timeout:
            print("  Timeout, retrying...")
        except Exception as e:
            print(f"  Error: {e}")

        if attempt < retries - 1:
            time.sleep(5)

    return False


def main():
    output_path = OUTPUT_DIR / "cover-compass.jpg"
    print(f"Generating crew cover illustration...")
    print(f"Output: {output_path}\n")

    if generate_image(PROMPT, output_path):
        print("\nDone! Cover illustration generated successfully.")
    else:
        print("\nFailed to generate cover illustration.")
        sys.exit(1)


if __name__ == "__main__":
    main()

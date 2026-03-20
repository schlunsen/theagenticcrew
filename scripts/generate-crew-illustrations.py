#!/usr/bin/env python3
"""
Illustration generation for "The Agentic Crew — Crew Member's Guide".

Uses Stable Diffusion XL via the HuggingFace Inference API to generate
chapter illustrations with a modern, hip ink-and-watercolour style —
distinct from the main book's hand-drawn ink sketches.

Usage:
    python scripts/generate-crew-illustrations.py              # Generate all
    python scripts/generate-crew-illustrations.py --chapter 3   # Single chapter
    python scripts/generate-crew-illustrations.py --list        # Show prompts
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
OUTPUT_DIR = BASE_DIR / "assets" / "illustrations" / "crew"

HF_API_KEY = os.environ.get("HF_API_KEY", "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")
API_URL = "https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0"

HEADERS = {
    "Authorization": f"Bearer {HF_API_KEY}",
    "Content-Type": "application/json",
}

# Style prefix applied to every prompt — modern, hip, slightly editorial
STYLE = (
    "minimal modern editorial illustration, ink and watercolour wash, "
    "loose confident brushstrokes, muted teal and warm ochre palette, "
    "white paper background, subtle halftone texture, contemporary graphic novel style, "
    "clean composition with generous white space, "
    "no text, no words, no letters, no labels"
)

NEGATIVE_PROMPT = (
    "photorealistic, 3d render, anime, cartoon, childish, cluttered, "
    "text, words, letters, watermark, signature, border, frame, "
    "blurry, low quality, deformed hands, extra fingers"
)

# ---------------------------------------------------------------------------
# Chapter illustration prompts
# ---------------------------------------------------------------------------

ILLUSTRATIONS = {
    "ch01-welcome": {
        "file": "ch01-welcome.jpg",
        "prompt": (
            "A person standing at a ship's railing looking out at a vast ocean horizon, "
            "dawn light breaking through clouds, a modern tablet in their hand, "
            "nautical ropes and rigging in the foreground"
        ),
    },
    "ch02-ground-shifting": {
        "file": "ch02-ground-shifting.jpg",
        "prompt": (
            "A tectonic crack in the ground with light pouring through from below, "
            "one side shows old-fashioned paper documents and filing cabinets, "
            "the other side shows luminous digital screens and floating data, "
            "a person stepping confidently across the gap"
        ),
    },
    "ch03-under-the-hood": {
        "file": "ch03-under-the-hood.jpg",
        "prompt": (
            "Cross-section view of a bustling restaurant kitchen, front-of-house dining room, "
            "a pantry, and a prep station, all connected by service windows and doors, "
            "tiny figures working at each station, warm ambient lighting, "
            "architectural cutaway style"
        ),
    },
    "ch03-git-branches": {
        "file": "ch03-git-branches.jpg",
        "prompt": (
            "Tracing paper layered over a blueprint on a drafting table, "
            "multiple transparent overlays each showing different design variations, "
            "an architect's hand peeling one layer back, "
            "pencils and drafting tools scattered nearby"
        ),
    },
    "ch03-dns-phonebook": {
        "file": "ch03-dns-phonebook.jpg",
        "prompt": (
            "A massive old-fashioned telephone switchboard with glowing connections, "
            "names on one side and numbers on the other connected by luminous wires, "
            "an operator figure connecting a cable, "
            "warm vintage lighting with modern digital glow"
        ),
    },
    "ch04-agent-loop": {
        "file": "ch04-agent-loop.jpg",
        "prompt": (
            "A circular diagram rendered as a ship's compass rose, "
            "four points labelled with icons: an eye (observe), a map (plan), "
            "a hand pulling a lever (act), a magnifying glass (check), "
            "arrows flowing clockwise between them, nautical styling"
        ),
    },
    "ch05-two-captains": {
        "file": "ch05-two-captains.jpg",
        "prompt": (
            "Split composition: on the left, a person gesturing vaguely at a confused crew "
            "who are painting the wrong wall, on the right a person holding a detailed plan "
            "with the crew working precisely on the correct target, "
            "both scenes on the same ship deck"
        ),
    },
    "ch06-workbench": {
        "file": "ch06-workbench.jpg",
        "prompt": (
            "A craftsperson's workbench seen from above, neatly arranged with only "
            "the essential tools for the current job, a few documents pinned to a board, "
            "a focused pool of light on the work area, "
            "the rest of the workshop fading into shadow"
        ),
    },
    "ch07-trust-gradient": {
        "file": "ch07-trust-gradient.jpg",
        "prompt": (
            "A mixing board with sliding faders, each labelled with a small icon, "
            "some sliders pushed high and others kept low, "
            "a person's hand adjusting one fader thoughtfully, "
            "warm studio lighting, professional audio engineering atmosphere"
        ),
    },
    "ch08-extending-reach": {
        "file": "ch08-extending-reach.jpg",
        "prompt": (
            "A robotic arm extending from a central hub, its fingers delicately connecting "
            "puzzle pieces to a calendar, an envelope, a spreadsheet, and a database cylinder, "
            "luminous connection lines between each tool, "
            "clean minimalist composition"
        ),
    },
    "ch09-the-padlock": {
        "file": "ch09-the-padlock.jpg",
        "prompt": (
            "A giant ornate padlock floating above an ocean of flowing data streams, "
            "one side showing a postcard being read by shadowy figures, "
            "the other side showing a sealed glowing envelope safe from prying eyes, "
            "a keyhole emitting warm golden light, nautical chain links connecting to a ship's anchor"
        ),
    },
    "ch10-reading-output": {
        "file": "ch10-reading-output.jpg",
        "prompt": (
            "A person holding a document up to a light source, examining it closely, "
            "some lines on the document glow green (verified) while others glow amber (suspect), "
            "a magnifying glass in the other hand, "
            "detective-like atmosphere with warm directional lighting"
        ),
    },
    "ch11-building-real": {
        "file": "ch11-building-real.jpg",
        "prompt": (
            "A window installer on a job site holding a tablet showing a 3D wireframe "
            "of a window in a wall, the real wall visible behind the tablet, "
            "tools and window frames leaning against the wall, "
            "morning sunlight streaming through the unfinished window opening"
        ),
    },
    "ch12-when-wrong": {
        "file": "ch12-when-wrong.jpg",
        "prompt": (
            "A ship in a mild storm, the crew scrambling but organised, "
            "one person at the helm making a course correction, "
            "dark dramatic clouds but a break of clear sky visible ahead, "
            "waves splashing against the bow"
        ),
    },
    "ch13-do-it-yourself": {
        "file": "ch13-do-it-yourself.jpg",
        "prompt": (
            "A person putting down a power tool and picking up a fine hand tool instead, "
            "a delicate bonsai tree on the workbench in front of them, "
            "the power tool still spinning down beside them, "
            "a moment of deliberate choice"
        ),
    },
    "ch14-human-in-loop": {
        "file": "ch14-human-in-loop.jpg",
        "prompt": (
            "A person sitting at the centre of a circular workflow, "
            "robotic arms passing documents and screens around them in a loop, "
            "the person reviewing each item with a stamp of approval or a red mark, "
            "calm, in-control posture, warm lighting"
        ),
    },
    "ch15-talking-tech-team": {
        "file": "ch15-talking-tech-team.jpg",
        "prompt": (
            "Two people standing on opposite sides of a bridge, one wearing work boots "
            "and a hard hat, the other in a hoodie with a laptop, "
            "they're meeting in the middle of the bridge shaking hands, "
            "the bridge is made of words and code symbols"
        ),
    },
    "ch16-pulse": {
        "file": "ch16-pulse.jpg",
        "prompt": (
            "A person at a cozy desk with a coffee mug, morning light coming through a window, "
            "three glowing screens showing different feeds: news headlines, trending charts, "
            "and community discussions, relaxed casual atmosphere, "
            "only ten minutes of reading"
        ),
    },
    "ch17-final-words": {
        "file": "ch17-final-words.jpg",
        "prompt": (
            "A ship sailing toward a bright horizon, the crew on deck in various roles, "
            "one person at the bow pointing forward, others working the sails and reading maps, "
            "golden hour lighting, a sense of optimism and purpose, "
            "the open ocean ahead"
        ),
    },
}


# ---------------------------------------------------------------------------
# Generation
# ---------------------------------------------------------------------------


def generate_image(prompt: str, output_path: Path, retries: int = 3) -> bool:
    """Generate a single illustration via HF Inference API."""
    full_prompt = f"{STYLE}, {prompt}"

    payload = {
        "inputs": full_prompt,
        "parameters": {
            "negative_prompt": NEGATIVE_PROMPT,
            "width": 1024,
            "height": 768,
            "guidance_scale": 7.5,
            "num_inference_steps": 40,
        },
    }

    for attempt in range(retries):
        try:
            print(f"  Generating (attempt {attempt + 1}/{retries})...")
            response = requests.post(API_URL, headers=HEADERS, json=payload, timeout=120)

            if response.status_code == 503:
                # Model is loading
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
    parser = argparse.ArgumentParser(description="Generate Crew Member's Guide illustrations")
    parser.add_argument("--chapter", type=int, help="Generate for a specific chapter number only")
    parser.add_argument("--list", action="store_true", help="List all prompts without generating")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be generated")
    args = parser.parse_args()

    if args.list:
        for key, spec in ILLUSTRATIONS.items():
            print(f"\n{key}:")
            print(f"  File:   {spec['file']}")
            print(f"  Prompt: {spec['prompt']}")
        return

    # Filter to specific chapter if requested
    items = ILLUSTRATIONS.items()
    if args.chapter is not None:
        ch_prefix = f"ch{args.chapter:02d}"
        items = [(k, v) for k, v in items if k.startswith(ch_prefix)]
        if not items:
            print(f"No illustrations defined for chapter {args.chapter}")
            sys.exit(1)

    print(f"Generating {len(list(items))} illustration(s)...")
    print(f"Output directory: {OUTPUT_DIR}\n")

    success = 0
    failed = 0

    for key, spec in items:
        output_path = OUTPUT_DIR / spec["file"]

        if output_path.exists() and not args.dry_run:
            print(f"[SKIP] {key} — already exists at {output_path}")
            success += 1
            continue

        print(f"[GEN] {key}: {spec['file']}")
        if args.dry_run:
            print(f"  Prompt: {STYLE}, {spec['prompt']}")
            success += 1
            continue

        if generate_image(spec["prompt"], output_path):
            success += 1
        else:
            failed += 1
            print(f"  FAILED: {key}")

        # Small delay between requests to be polite
        time.sleep(2)

    print(f"\nDone: {success} succeeded, {failed} failed")


if __name__ == "__main__":
    main()

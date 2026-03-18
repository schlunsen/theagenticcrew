#!/usr/bin/env python3
"""Apply oval vignette to illustrations, fading edges to white with a soft elliptical mask."""

import sys
import os
from PIL import Image, ImageFilter, ImageDraw
import numpy as np


def apply_oval_vignette(input_path, output_path=None):
    """Apply a soft oval vignette that fades to white, matching the adult book style."""
    if output_path is None:
        output_path = input_path

    img = Image.open(input_path).convert("RGB")
    w, h = img.size

    # Create elliptical mask - white in center, black at edges
    mask = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(mask)

    # Tight ellipse well inside the image — creates a clearly oval shape
    margin_x = int(w * 0.15)
    margin_y = int(h * 0.12)
    draw.ellipse([margin_x, margin_y, w - margin_x, h - margin_y], fill=255)

    # Strong Gaussian blur for a smooth, wide fade from image to white
    mask = mask.filter(ImageFilter.GaussianBlur(radius=min(w, h) * 0.12))

    # Create white background
    white = Image.new("RGB", (w, h), (255, 255, 255))

    # Composite: where mask is white, show original; where black, show white
    result = Image.composite(img, white, mask)

    result.save(output_path, "JPEG", quality=92)
    print(f"  ✓ {os.path.basename(input_path)}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: apply-oval-vignette.py <image_or_directory> [...]")
        sys.exit(1)

    paths = sys.argv[1:]
    for path in paths:
        if os.path.isdir(path):
            for f in sorted(os.listdir(path)):
                if f.lower().endswith((".jpg", ".jpeg", ".png")):
                    full = os.path.join(path, f)
                    apply_oval_vignette(full)
        elif os.path.isfile(path):
            apply_oval_vignette(path)
        else:
            print(f"  ✗ Not found: {path}")

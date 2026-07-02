#!/usr/bin/env python3
# © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
#
# Logo → brand seed colours. Rasterizes PDFs (sips), then finds the two most
# saturated, sufficiently-distinct dominant colours in the image — the primary
# mark colour and an accent — which the Node generator turns into OKLCH seeds.
#
# Usage: python3 extract_colors.py <logo.pdf|png|jpg> [--out logo.png]
# Prints JSON: {"primary": "#RRGGBB", "accent": "#RRGGBB", "logoPng": "path"}

import json
import subprocess
import sys
from collections import Counter
from pathlib import Path

from PIL import Image


def rasterize_if_pdf(src: Path, out_dir: Path) -> Path:
    if src.suffix.lower() != ".pdf":
        return src
    out = out_dir / (src.stem + "_raster.png")
    subprocess.run(
        ["sips", "-s", "format", "png", "-Z", "2200", str(src), "--out", str(out)],
        check=True,
        capture_output=True,
    )
    return out


def dominant_colors(img: Image.Image, k: int = 6):
    im = img.convert("RGBA")
    im.thumbnail((400, 400))
    pixels = im.getdata()
    buckets = Counter()
    for r, g, b, a in pixels:
        if a < 128:
            continue
        # Skip near-white/near-black/near-gray backgrounds.
        mx, mn = max(r, g, b), min(r, g, b)
        sat = 0 if mx == 0 else (mx - mn) / mx
        if sat < 0.18 or mx > 250 and mn > 235:
            continue
        buckets[(r // 8 * 8, g // 8 * 8, b // 8 * 8)] += 1
    return buckets.most_common(k)


def saturation(rgb):
    r, g, b = rgb
    mx, mn = max(r, g, b), min(r, g, b)
    return 0 if mx == 0 else (mx - mn) / mx


def dist(a, b):
    return sum((x - y) ** 2 for x, y in zip(a, b)) ** 0.5


def main():
    if len(sys.argv) < 2:
        print("usage: extract_colors.py <logo> [--out path]", file=sys.stderr)
        return 1
    src = Path(sys.argv[1])
    out_arg = None
    if "--out" in sys.argv:
        out_arg = Path(sys.argv[sys.argv.index("--out") + 1])

    work_dir = src.parent
    raster = rasterize_if_pdf(src, work_dir)
    img = Image.open(raster)

    colors = dominant_colors(img)
    if not colors:
        print(json.dumps({"error": "no saturated colours found"}))
        return 1

    # Primary: most frequent saturated colour. Accent: the most-frequent
    # colour that's both reasonably saturated and visually distinct from it.
    colors_sorted = sorted(colors, key=lambda c: -c[1])
    primary_rgb = colors_sorted[0][0]
    accent_rgb = primary_rgb
    for rgb, _count in colors_sorted[1:]:
        if dist(rgb, primary_rgb) > 60 and saturation(rgb) > 0.25:
            accent_rgb = rgb
            break

    def hexs(rgb):
        return "#%02X%02X%02X" % rgb

    logo_out = out_arg or (work_dir / (src.stem + "_logo.png"))
    if str(raster) != str(logo_out):
        img.convert("RGBA").save(logo_out)

    print(json.dumps({
        "primary": hexs(primary_rgb),
        "accent": hexs(accent_rgb),
        "logoPng": str(logo_out),
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
# © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
#
# Blank-region detector (ODYSSEY_RULEBOOK R2/§5): a layout exception renders as
# a silently blank region, not a red screen. The failure signature is a LARGE
# CONTIGUOUS uniform band (the 2.5.2 toolbar bug blanked ~70% of the viewport
# while the header and dock still rendered). Fail when the longest run of
# flat, colour-continuous rows exceeds MAX_RUN of the image height.
#
# Usage: python3 tools/blank_check.py <dir-of-pngs> [--max-run 0.55]

import sys
from pathlib import Path

from PIL import Image  # pip install pillow

BAND = 6        # per-channel closeness
ROW_FLAT = 0.985  # fraction of row pixels within BAND of the row median
ROW_STEP = 4
COL_STEP = 6
MAX_RUN = 0.55  # longest flat run allowed, as a fraction of height


def longest_flat_run(path: Path) -> float:
    img = Image.open(path).convert("RGB")
    w, h = img.size
    px = img.load()

    def row_profile(y):
        cols = [px[x, y] for x in range(0, w, COL_STEP)]
        med = tuple(sorted(c[i] for c in cols)[len(cols) // 2] for i in range(3))
        flat = sum(
            1 for c in cols if all(abs(c[i] - med[i]) <= BAND for i in range(3))
        ) / len(cols)
        return med, flat >= ROW_FLAT

    best = cur = 0
    prev_med = None
    for y in range(0, h, ROW_STEP):
        med, is_flat = row_profile(y)
        cont = prev_med is not None and all(
            abs(med[i] - prev_med[i]) <= BAND for i in range(3)
        )
        if is_flat and (cur == 0 or cont):
            cur += 1
            best = max(best, cur)
        else:
            cur = 1 if is_flat else 0
        prev_med = med
    return best * ROW_STEP / h


def main() -> int:
    root = Path(sys.argv[1])
    max_run = MAX_RUN
    if "--max-run" in sys.argv:
        max_run = float(sys.argv[sys.argv.index("--max-run") + 1])
    pngs = sorted(root.glob("*.png"))
    if not pngs:
        print(f"no PNGs found in {root}", file=sys.stderr)
        return 1
    bad = 0
    for p in pngs:
        run = longest_flat_run(p)
        if run > max_run:
            bad += 1
            print(f"BLANK {p.name}: flat band spans {run:.0%} of height", file=sys.stderr)
    if bad:
        print(f"\n{bad}/{len(pngs)} shots have blank bands — broken layout.", file=sys.stderr)
        return 1
    print(f"blank check: {len(pngs)} shots OK ✓")
    return 0


if __name__ == "__main__":
    sys.exit(main())

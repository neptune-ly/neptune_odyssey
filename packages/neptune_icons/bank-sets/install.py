#!/usr/bin/env python3
"""Build the three banks' icon sets into the Flutter app's asset roots.

Per-bank difference is ENTIRELY in `emit.PROFILES` and `library_map.json` —
a different professionally drawn family per bank, selected per concept. Nothing
below reads a bank name.
"""
import json, os, re, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import emit as E

APP = sys.argv[1]
ROSTER = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "roster.json")))
ROOTS = {"andalus": "assets/icons", "nuran": "assets/nuran/icons", "fglb": "assets/fglb/icons"}
SRC_MARKS = os.path.join(APP, "assets/icons")   # marks already live at their bank's own root

DART_ROSTER = "lib/core/presentation/components/brand_marks.g.dart"

def write_brand_mark_roster():
    """Carry the roster's `isBrandMark` declaration into the running app.

    The app cannot read roster.json — `tools/` is not bundled, and bundling it
    would ship all three banks' declarations inside each bank's build. So the
    one declaration is compiled instead, from the same source that writes the
    assets, by the same run. `brand_mark_roster_test.dart` fails if this file
    and the roster ever disagree.
    """
    marks = sorted((n, s["artwork"]) for n, s in ROSTER.items()
                   if s.get("isBrandMark"))
    body = "".join(f'  "{n}": BrandMarkArtwork.{a},\n' for n, a in marks)
    open(os.path.join(APP, DART_ROSTER), "w", encoding="utf8").write(
        "// GENERATED from tools/icons/roster.json by tools/icons/install.py.\n"
        "// Do not hand-edit: declare the mark in the roster instead.\n"
        "\n"
        "/// What artwork the owner of a brand mark actually supplies.\n"
        "enum BrandMarkArtwork {\n"
        "  /// The file carries the mark's own inks. Nothing may repaint it.\n"
        "  colour,\n"
        "\n"
        "  /// The owner's single-ink variant: there are no colours in the file\n"
        "  /// to preserve, so it takes the surface's own ink and never an accent\n"
        "  /// or a selected-state colour — painting WhatsApp's glyph in a bank's\n"
        "  /// blue is as much a restyle as flattening OnePay's gradients.\n"
        "  mono,\n"
        "}\n"
        "\n"
        "/// Every glyph the roster declares `isBrandMark`, with the artwork it\n"
        "/// carries — a third-party or institution trademark either way.\n"
        "///\n"
        "/// Keyed by file name, which is the same under all three banks' roots: a\n"
        "/// mark is the partner's artwork and not the bank's, so which banks CARRY\n"
        "/// one is per-bank data in the roster and how it is PAINTED is not.\n"
        f"const brandMarkArtwork = <String, BrandMarkArtwork>{{\n{body}}};\n")

def main():
    report = {b: {"generated": [], "mark": [], "removed": []} for b in ROOTS}
    for bank, rel in ROOTS.items():
        root = os.path.join(APP, rel)
        os.makedirs(root, exist_ok=True)
        want = set()
        for name, spec in ROSTER.items():
            cls = spec["class"]
            if cls == "mark":
                if bank not in spec["banks"]:
                    continue
                want.add(name + ".svg")
                src = os.path.join(root, name + ".svg")
                if not os.path.exists(src):
                    src = os.path.join(SRC_MARKS, name + ".svg")
                if os.path.abspath(src) != os.path.abspath(os.path.join(root, name + ".svg")):
                    shutil.copyfile(src, os.path.join(root, name + ".svg"))
                report[bank]["mark"].append(name)
                continue
            want.add(name + ".svg")
            out = os.path.join(root, name + ".svg")
            # There is no "keep the bank's own drawing" path any more. A bank's
            # identity is now the FAMILY it draws from, so a surviving hand-cut
            # glyph would be the one icon on the screen that belongs to no family
            # — which is the inconsistency this whole change exists to remove.
            svg = E.emit(bank, name, spec, ROSTER)
            report[bank]["generated"].append(name)
            open(out, "w", encoding="utf8").write(svg)
        for f in sorted(os.listdir(root)):
            # A raster in a vector icon set is the same defect as a filled glyph
            # in an outline set: nothing references these and they cannot follow
            # the profile. The roster is SVG-only, so a .png here is always stale.
            if f.endswith(".png") or (f.endswith(".svg") and f not in want):
                os.remove(os.path.join(root, f))
                report[bank]["removed"].append(f)
    write_brand_mark_roster()
    os.makedirs("/tmp/gen", exist_ok=True)
    json.dump(report, open("/tmp/gen/install_report.json", "w"), indent=1)
    for b, r in report.items():
        print(f"{b:8} generated={len(r['generated']):3} "
              f"marks={len(r['mark']):2} removed={len(r['removed']):2}")

if __name__ == "__main__":
    main()

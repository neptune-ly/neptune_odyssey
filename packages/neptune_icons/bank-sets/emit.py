#!/usr/bin/env python3
"""Emit per-bank Odyssey icon sets from the shared roster.

One roster, three profiles. The per-bank difference is entirely in PROFILES —
there is no per-bank branch anywhere below this line.
"""
import json, os, re, sys, math

LUCIDE = "/tmp/iconlibs/lucide/icons/%s.svg"
TABLER_F = "/tmp/iconlibs/tabler/icons/filled/%s.svg"

PROFILES = {
    # stroke: weight in viewBox units at the canonical 24 grid
    # cap/join/miter: terminal treatment
    # scale: optical size — how much of the 24 box the glyph claims
    # rx: multiplier on every source corner radius
    # quant: coordinate snap, in viewBox units (0 = keep the drawn curve)
    # filledActive: does this bank's selected state use a filled glyph?
    # keepOwnDrawings: does this bank already own a designed set worth re-cutting?
    "andalus": dict(stroke=1.25, cap="round",  join="round", miter=4, scale=1.00, rx=1.40, quant=0.0,  filledActive=True,  keepOwnDrawings=True),
    "nuran":   dict(stroke=1.00, cap="butt",   join="miter", miter=2, scale=0.88, rx=0.00, quant=0.25, filledActive=False, keepOwnDrawings=False),
    "fglb":    dict(stroke=1.60, cap="square", join="miter", miter=2, scale=1.00, rx=0.65, quant=0.0,  filledActive=False, keepOwnDrawings=False),
}

NUM = re.compile(r'-?\d*\.?\d+(?:[eE][-+]?\d+)?')
# per SVG path command: which argument slots are coordinates (quantisable)
ARC_FLAGS = {3, 4}  # large-arc-flag, sweep-flag within each 7-tuple of A/a

def quantise_path(d, q):
    if not q:
        return d
    out, i, n = [], 0, len(d)
    cmd = None
    while i < n:
        ch = d[i]
        if ch.isalpha():
            cmd = ch
            out.append(ch)
            i += 1
            arg = 0
            continue
        if ch in ", \t\n":
            out.append(ch); i += 1; continue
        m = NUM.match(d, i)
        if not m:
            out.append(ch); i += 1; continue
        val = float(m.group())
        # never round arc flags
        if cmd in "Aa":
            # count which slot we are in by re-scanning this command's numbers
            pass
        out.append(m.group())
        i = m.end()
    # A proper slot-aware pass, done separately below.
    return _quantise_tokens(d, q)

def _tokens(d):
    """Command/number tokens, ARC-FLAG AWARE.

    `a5 5 0 014-2` is legal SVG: inside an arc, the large-arc and sweep flags
    are single characters and may be written with no separator at all. Read
    naively that is one number, 14, and the command silently loses two of its
    seven arguments — which is how a book-open-check turned into a path the
    renderer refuses. Slots 3 and 4 of every 7-tuple are therefore consumed one
    character at a time.
    """
    i, n = 0, len(d)
    cmd, slot = None, 0
    while i < n:
        ch = d[i]
        if ch.isalpha():
            cmd, slot = ch, 0
            yield ("cmd", ch)
            i += 1
            continue
        if ch in ", \t\r\n":
            i += 1
            continue
        if cmd in "Aa" and (slot % 7) in ARC_FLAGS:
            yield ("flag", ch)
            i += 1
            slot += 1
            continue
        m = NUM.match(d, i)
        if not m:
            i += 1
            continue
        yield ("num", m.group())
        i = m.end()
        slot += 1

def _quantise_tokens(d, q):
    def snap(v):
        return round(round(v / q) * q, 3)
    out, cmd, slot = [], None, 0
    for kind, tok in _tokens(d):
        if kind == "cmd":
            cmd, slot = tok, 0
            out.append(("cmd", tok))
            continue
        if kind == "flag":
            out.append(("flag", tok))
            slot += 1
            continue
        v = float(tok)
        # an arc's radii are grid coordinates; its x-axis rotation is not
        keep = cmd in "Aa" and (slot % 7) == 2
        out.append(("num", tok if keep else _fmt(snap(v))))
        slot += 1
    s = ""
    for kind, t in out:
        if not s:
            s = t
        elif kind == "cmd" or s[-1].isalpha():
            s += t
        elif kind == "flag":
            s += " " + t
        else:
            s += ("" if t.startswith("-") else " ") + t
    return s

def _fmt(v):
    s = f"{v:.3f}".rstrip("0").rstrip(".")
    return s if s not in ("", "-0") else "0"

TAG = re.compile(r'<(path|circle|rect|line|polyline|polygon|ellipse)\b([^>]*?)/?>', re.S)
ATTR = re.compile(r'([a-zA-Z][a-zA-Z0-9-]*)\s*=\s*"([^"]*)"')

def load_inner(path, drop_guard=True):
    s = open(path, encoding="utf8").read()
    els = []
    for m in TAG.finditer(s):
        tag, raw = m.group(1), m.group(2)
        a = dict(ATTR.findall(raw))
        if drop_guard and a.get("fill") == "none" and a.get("stroke") == "none":
            continue  # tabler's transparent 24×24 guard rect
        els.append((tag, a))
    return els

COORD_ATTRS = {"cx","cy","r","rx","ry","x","y","x1","y1","x2","y2","width","height"}

# Lucide/Tabler draw a dot as a zero-length subpath and rely on a ROUND cap to
# render it. A bank with butt terminals draws nothing at all there — the `!`
# inside a warning triangle simply vanishes. So the idiom is rewritten into an
# explicit filled circle for every bank, before any profile is applied.
DOT = re.compile(r'^M\s*(-?[\d.]+)[ ,]+(-?[\d.]+)\s*[hv]\s*(-?[\d.]+)$')

def dot_circle(d, p):
    m = DOT.match(d.strip())
    if not m or abs(float(m.group(3))) > 0.05:
        return None
    r = p["stroke"] / (2 * p["scale"])
    return (f'<circle cx="{_fmt(float(m.group(1)))}" cy="{_fmt(float(m.group(2)))}" '
            f'r="{_fmt(r)}" fill="currentColor" stroke="none"/>')

def transform_el(tag, a, p, filled):
    a = dict(a)
    if tag == "path" and not filled and "d" in a:
        c = dot_circle(a["d"], p)
        if c:
            return c
    for junk in ("class","stroke-width","stroke-linecap","stroke-linejoin","fill","stroke","xmlns","width","height","viewBox"):
        if tag != "rect" or junk not in ("width","height"):
            a.pop(junk, None)
    if tag == "rect":
        for k in ("rx","ry"):
            if k in a:
                a[k] = _fmt(max(0.0, float(a[k]) * p["rx"]))
        if "rx" not in a and p["rx"] < 1.0:
            pass
    q = p["quant"]
    if q and not filled:
        for k, v in list(a.items()):
            if k == "d":
                a[k] = _quantise_tokens(v, q)
            elif k in ("points",):
                a[k] = " ".join(_fmt(round(float(x)/q)*q) for x in re.findall(NUM, v))
            elif k in COORD_ATTRS and k not in ("rx","ry"):
                try:
                    a[k] = _fmt(round(float(v)/q)*q)
                except ValueError:
                    pass
    order = ["d","points","cx","cy","r","rx","ry","x","y","x1","y1","x2","y2","width","height"]
    parts = [f'{k}="{a[k]}"' for k in order if k in a]
    parts += [f'{k}="{v}"' for k, v in a.items() if k not in order]
    return f'<{tag} {" ".join(parts)}/>'

SLASH = '<path d="M4.6 19.4 19.4 4.6"/>'
RENEW = ('<g transform="translate(0.6,0.6) scale(0.8)">%s</g>'
         '<path d="M20.6 16.4a3 3 0 1 1-.9-2.1"/><path d="M20.9 12.4v2.3h-2.3"/>')

def emit(bank, name, spec, roster):
    p = PROFILES[bank]
    cls = spec["class"]
    if cls in ("mark",):
        return None  # brand marks are never restyled
    filled = False
    src = spec.get("src")
    if cls == "alias":
        base = roster[spec["of"]]
        if p["filledActive"] and base.get("sel"):
            src, filled = base["sel"], True
        else:
            src = base["src"]
    lib, ident = src.split(":", 1)
    path = {"lucide": LUCIDE, "tabler-filled": TABLER_F}[lib] % ident
    els = load_inner(path)
    inner = "".join(transform_el(t, a, p, filled) for t, a in els)
    ov = spec.get("overlay")
    if ov == "slash":
        inner += SLASH
    elif ov == "renew":
        inner = RENEW % inner
    s = p["scale"]
    g_open = f'<g transform="translate(12 12) scale({_fmt(s)}) translate(-12 -12)">'
    if filled:
        paint = f'fill="currentColor" stroke="none"'
    else:
        paint = (f'fill="none" stroke="currentColor" stroke-width="{_fmt(p["stroke"]/s)}" '
                 f'stroke-linecap="{p["cap"]}" stroke-linejoin="{p["join"]}" '
                 f'stroke-miterlimit="{p["miter"]}"')
    header = (f"<!-- Neptune Odyssey icon · bank={bank} · glyph={name}\n"
              f"     source={src} · profile stroke={p['stroke']} cap={p['cap']} "
              f"join={p['join']} scale={p['scale']} rx={p['rx']} quant={p['quant']}\n"
              f"     GENERATED by packages/neptune_icons/scripts/emit_bank_icons.py — do not hand-edit.\n"
              f"     Licences: see assets/ICON_LICENSES.md -->\n")
    return (f'{header}<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
            f'width="24" height="24" {paint}>{g_open}{inner}</g></svg>\n')

def main():
    roster = json.load(open(sys.argv[1]))
    outroots = json.loads(sys.argv[2])
    counts = {}
    for bank, root in outroots.items():
        os.makedirs(root, exist_ok=True)
        n = 0
        for name, spec in roster.items():
            svg = emit(bank, name, spec, roster)
            if svg is None:
                continue
            open(os.path.join(root, name + ".svg"), "w", encoding="utf8").write(svg)
            n += 1
        counts[bank] = n
    print(json.dumps(counts))

if __name__ == "__main__":
    main()

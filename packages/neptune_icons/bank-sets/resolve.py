# -*- coding: utf-8 -*-
"""Propose a per-bank library glyph for every roster concept.

Primary library per bank, then that bank's declared gap-filler, then Lucide as the
last resort. Nothing is ever resolved into ANOTHER BANK'S family: that is what made
Nuran and FGLB draw the identical card in the first concept pass.
"""
import os,re,glob,json,sys
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
# The libraries are not vendored -- only the glyphs we emit are -- so the root is
# wherever tools/icons/fetch_libs.sh put them. Argument first, then $ICONLIBS, then
# the default that script uses. It must NOT be a path inside one agent's worktree:
# a hard-coded one made this script unrunnable for everybody else.
R = (sys.argv[1] if len(sys.argv) > 1
     else os.environ.get("ICONLIBS", "/tmp/iconlibs"))
if not os.path.isdir(R):
    sys.exit(f"icon libraries not found at {R}. Run tools/icons/fetch_libs.sh, "
             f"or pass the root as the first argument.")
DIRS={
 "phosphor": f"{R}/x_phosphor-icons-core/package/assets/regular",
 "carbon":   f"{R}/x_carbon-icons/package/svg/32",
 "msym":     f"{R}/x_msym600/package/outlined",
 "tabler":   f"{R}/tabler/icons/outline",
 "iconoir":  f"{R}/x_iconoir/package/icons/regular",
 "lucide":   f"{R}/lucide/icons",
}
def have(lib):
    return {re.sub(r'-+','-',os.path.basename(f)[:-4].lower().replace('_','-')).strip('-'):os.path.basename(f)[:-4]
            for f in glob.glob(DIRS[lib]+"/*.svg")}
HAVE={k:have(k) for k in DIRS}
SYN=json.load(open(os.path.join(HERE,"aliases.json"),encoding="utf8"))
BANK={"andalus":["phosphor","tabler","lucide"],
      "nuran":  ["carbon","iconoir","lucide"],
      "fglb":   ["msym","lucide"]}
def cands(n):
    c=[n]+SYN.get(n,[])
    t=n.split('-')
    if len(t)>1: c.append('-'.join(reversed(t)))
    return c
def resolve(bank,concept):
    for lib in BANK[bank]:
        for c in cands(concept):
            if c in HAVE[lib]: return [lib,HAVE[lib][c]]
    return None
roster=json.load(open(os.path.join(HERE,"roster.json"),encoding="utf8"))
concepts=sorted({v["src"].split(":",1)[1] for v in roster.values() if v["class"] in ("icon","spot")})
OVR={k:v for k,v in json.load(open(os.path.join(HERE,"overrides.json"),encoding="utf8")).items() if not k.startswith("_")}
out={}
for c in concepts:
    out[c]={b:resolve(b,c) for b in BANK}
    out[c].update(OVR.get(c,{}))
json.dump(out,open(os.path.join(HERE,"library_map_proposal.json"),"w",encoding="utf8"),indent=1,sort_keys=True)
n=sum(1 for c in out for b in out[c] if out[c][b] is None)
print("concepts",len(concepts),"unresolved",n)
from collections import Counter
for b in BANK:
    print(b, Counter(out[c][b][0] for c in out if out[c][b]))

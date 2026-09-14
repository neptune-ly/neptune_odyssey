# -*- coding: utf-8 -*-
"""Propose a per-bank library glyph for every roster concept.

Primary library per bank, then that bank's declared gap-filler, then Lucide as the
last resort. Nothing is ever resolved into ANOTHER BANK'S family: that is what made
Nuran and FGLB draw the identical card in the first concept pass.
"""
import os,re,glob,json
R="/tmp/iconlibs"
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
SYN=json.load(open(R+"/syn.json"))
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
roster=json.load(open("/private/tmp/claude-501/-Volumes-MU-github-nexus-mw/e8c912e9-2ace-47fa-9a02-d87e4dc4fffd/scratchpad/iconvocab/tools/icons/roster.json"))
concepts=sorted({v["src"].split(":",1)[1] for v in roster.values() if v["class"] in ("icon","spot")})
OVR={k:v for k,v in json.load(open("overrides.json")).items() if not k.startswith("_")}
out={}
for c in concepts:
    out[c]={b:resolve(b,c) for b in BANK}
    out[c].update(OVR.get(c,{}))
json.dump(out,open("proposal.json","w"),indent=1,sort_keys=True)
n=sum(1 for c in out for b in out[c] if out[c][b] is None)
print("concepts",len(concepts),"unresolved",n)
from collections import Counter
for b in BANK:
    print(b, Counter(out[c][b][0] for c in out if out[c][b]))

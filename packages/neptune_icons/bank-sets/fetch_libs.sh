#!/usr/bin/env bash
# Fetch the six icon families the three banks draw from, at PINNED versions.
#
# The generator reads them from $ICONLIBS (default /tmp/iconlibs), which is
# volatile on purpose: the libraries are not vendored into this repo, only the
# glyphs we actually emit are. Pin the versions — an unpinned "latest" would
# silently redraw a bank's whole set on someone else's machine.
set -euo pipefail
DEST="${ICONLIBS:-/tmp/iconlibs}"
mkdir -p "$DEST"; cd "$DEST"

pull() {  # pull <npm-spec> <extract-dir>
  local spec="$1" dir="$2"
  [ -d "$dir" ] && { echo "have $dir"; return; }
  local tgz; tgz=$(npm pack "$spec" --silent)
  mkdir -p "$dir"; tar xzf "$tgz" -C "$dir"; rm -f "$tgz"
  echo "fetched $spec -> $dir"
}

pull "@phosphor-icons/core@2.1.1"        x_phosphor-icons-core   # MIT        Andalus
pull "@carbon/icons@11.88.0"             x_carbon-icons          # Apache-2.0 Nuran
pull "@material-symbols/svg-600@0.47.2"  x_msym600               # Apache-2.0 FGLB
pull "iconoir@7.12.1"                    x_iconoir               # MIT        Nuran gap-filler
pull "lucide-static@1.45.0"              .                       # ISC        last-resort filler
pull "@tabler/icons@3.46.0"              .                       # MIT        Andalus gap-filler

# lucide-static and @tabler/icons extract into package/, which the generator
# expects flattened as lucide/ and tabler/.
[ -d lucide ]  || { mkdir -p lucide  && cp -R package/icons lucide/  2>/dev/null || true; }
echo "icon libraries ready in $DEST"

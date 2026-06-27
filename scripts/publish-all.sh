#!/usr/bin/env bash
# Publish every Neptune Odyssey library — npm (7 packages) + pub.dev (Flutter).
# Run AFTER you have authenticated:  `npm login`  and  `dart pub login`.
# Usage:  bash scripts/publish-all.sh            (real publish)
#         DRY_RUN=1 bash scripts/publish-all.sh  (dry-run, no upload)
set -euo pipefail
cd "$(dirname "$0")/.."

PNPM="npx --yes pnpm@9.15.0"
DRY=${DRY_RUN:-0}

echo "▸ Building all packages…"
$PNPM -r --filter "./packages/**" run build

echo "▸ Testing…"
$PNPM -r --filter "./packages/**" run test

# ── npm ──────────────────────────────────────────────────────────────────────
if ! npm whoami >/dev/null 2>&1; then
  echo "✗ Not logged in to npm. Run:  npm login   (and create the @neptune-odyssey org first)"; exit 1
fi
echo "▸ npm user: $(npm whoami)"
if [ "$DRY" = "1" ]; then
  $PNPM -r --filter "./packages/**" publish --access public --no-git-checks --dry-run
else
  # pnpm publishes in dependency order and rewrites workspace:^ to real versions.
  NPM_CONFIG_PROVENANCE=${NPM_CONFIG_PROVENANCE:-false} \
    $PNPM -r --filter "./packages/**" publish --access public --no-git-checks
fi

# ── pub.dev (Flutter) ────────────────────────────────────────────────────────
echo "▸ Publishing neptune_flutter_ui to pub.dev…"
pushd packages/neptune_flutter_ui >/dev/null
if [ "$DRY" = "1" ]; then
  flutter pub publish --dry-run
else
  flutter pub publish --force
fi
popd >/dev/null

echo "✓ Done. npm: https://www.npmjs.com/org/neptune-odyssey  ·  pub.dev: https://pub.dev/packages/neptune_flutter_ui"

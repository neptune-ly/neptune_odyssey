#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Publish EVERY Neptune Odyssey library in one go:
#   npm     → @neptune.fintech/{tokens,web-ui,svelte-ui,vue-ui,react-ui,
#                                brand-configs,product-configs}  (7 packages)
#   pub.dev → neptune_flutter_ui
#
# Run this in YOUR OWN terminal (so the login prompts can read your password/2FA):
#
#     bash scripts/publish-all.sh
#
# It will, in order: log you in to npm if needed, verify the org/scope exists,
# build + test everything, publish all npm packages (with provenance if on CI),
# then log you in to pub.dev if needed and publish the Flutter package.
#
#   DRY_RUN=1 bash scripts/publish-all.sh   → validate everything, upload nothing
#   SCOPE=neptune-odyssey                    → npm org/scope the packages use
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

PNPM="npx --yes pnpm@9.15.0"
DRY=${DRY_RUN:-0}
SCOPE=${SCOPE:-neptune.fintech}

say() { printf '\n\033[1;36m▸ %s\033[0m\n' "$*"; }
ok()  { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
die() { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

# ── 1. npm authentication (skipped for DRY_RUN — dry publish needs no auth) ───
if [ "$DRY" != "1" ]; then
  if ! npm whoami >/dev/null 2>&1; then
    say "You're not logged in to npm — launching 'npm login' (enter your email, password, OTP)…"
    npm login
  fi
  NPM_USER=$(npm whoami)
  ok "npm user: $NPM_USER"

  # verify the scope/org exists (npm can't create orgs from the CLI)
  if ! npm access list packages "@$SCOPE" >/dev/null 2>&1 \
     && ! curl -sf "https://www.npmjs.com/org/$SCOPE" >/dev/null 2>&1; then
    cat <<EOF

  The npm scope "@$SCOPE" isn't reachable for your account yet.
  Create it once (free, ~30s):  https://www.npmjs.com/org/create  → name it "$SCOPE"
  (Or set SCOPE=$NPM_USER to publish under your personal scope instead.)

EOF
    die "Create the @$SCOPE org, then re-run."
  fi
fi

# ── 3. build + test ──────────────────────────────────────────────────────────
say "Building all packages…";  $PNPM -r --filter "./packages/**" run build
say "Testing…";                $PNPM -r --filter "./packages/**" run test

# ── 4. publish npm (pnpm rewrites workspace:^ → real versions, skips private) ─
if [ "$DRY" = "1" ]; then
  say "npm DRY-RUN publish…"
  $PNPM -r --filter "./packages/**" publish --access public --no-git-checks --dry-run
else
  say "Publishing 7 packages to npm…"
  NPM_CONFIG_PROVENANCE=${NPM_CONFIG_PROVENANCE:-false} \
    $PNPM -r --filter "./packages/**" publish --access public --no-git-checks
  ok "npm packages published under @$SCOPE"
fi

# ── 5. pub.dev (Flutter) ─────────────────────────────────────────────────────
if [ "$DRY" != "1" ] && ! (flutter pub token list 2>/dev/null | grep -q pub.dev) \
   && [ ! -f "$HOME/Library/Application Support/dart/pub-credentials.json" ] \
   && [ ! -f "$HOME/.config/dart/pub-credentials.json" ]; then
  say "Not authenticated with pub.dev — launching 'dart pub login' (authorize in browser)…"
  dart pub login
fi
say "Publishing neptune_flutter_ui to pub.dev…"
pushd packages/neptune_flutter_ui >/dev/null
if [ "$DRY" = "1" ]; then flutter pub publish --dry-run; else flutter pub publish --force; fi
popd >/dev/null

echo
ok "ALL PUBLISHED"
echo "   npm     → https://www.npmjs.com/org/$SCOPE"
echo "   pub.dev → https://pub.dev/packages/neptune_flutter_ui"

# Publishing Neptune Odyssey

## Status

- **npm — DONE.** All JS/TS packages are live under the **`@neptune.fintech`** org
  (alongside the existing `@neptune.fintech/astro-*` packages).
- **pub.dev — DONE.** `neptune_flutter_ui` is live at **v2.13.0**.
- **GitHub Pages — DONE.** Auto-deploys on push to `main`.
- **Not yet published** (built and verified this session, publishing is a deliberate next
  step, not a blocker): `neptune_sound_kit` (pub.dev — `publish_to: none` until the
  synthesized chimes are listened-to-and-approved; see the package README) and
  `neptune_laravel_ui` (Composer/Packagist — verified end-to-end against a real Laravel
  app; no `PACKAGIST_TOKEN` wired into CI yet).

## What gets published, and where

| Registry | Packages |
|----------|----------|
| **npm** (scope `@neptune.fintech`) | `tokens`, `web-ui`, `svelte-ui`, `vue-ui`, `react-ui`, `react-native-ui`, `icons`, `brand-configs`, `product-configs`, `create-neptune` |
| **pub.dev** | `neptune_flutter_ui`; `neptune_sound_kit` once approved |
| **Packagist** (not yet wired) | `neptune_laravel_ui` — installable today via a git/path Composer dependency |
| **GitHub Pages** | the design-system site (`/`) + the configurator / hash-preset maker (`/configurator/`) — auto-deploys on push to `main`, no secrets needed |

`@neptune.fintech/docs`, `apps/configurator`, `apps/neptune_studio`, and `apps/neptune_desktop`
are `private` and never published to npm.

## Publish everything in one command

In a terminal where you can complete the logins:

```sh
bash scripts/publish-all.sh          # logs you in if needed, builds, tests, publishes all
DRY_RUN=1 bash scripts/publish-all.sh   # validate without uploading
```

## Publish only the Flutter package

```sh
cd packages/neptune_flutter_ui
flutter pub publish --force
```

## Publishing neptune_sound_kit (once the chimes are approved)

Flip `publish_to: none` to nothing (remove the line) in `packages/neptune_sound_kit/pubspec.yaml`,
then the same `flutter pub publish --force` as above, from that package's directory.

## Publishing neptune_laravel_ui to Packagist (not yet done)

Packagist tracks a GitHub repo directly rather than receiving uploads — submit
`neptune-ly/neptune_odyssey` with the package root set to `packages/neptune_laravel_ui`
(Packagist supports monorepo subdirectories via its "vendor repository" auto-crawl, or
split the package into its own repo/subtree if a cleaner root is preferred). Until then,
consumers install it via a Composer path or VCS repository (see the package's own README).

## CI-on-tag (optional, for future releases)

The `Release` workflow publishes on a `v*` tag with **npm provenance**. One-time setup:

1. **npm token:** npm → Access Tokens → *Generate* → **Automation** (bypasses 2FA in CI).
2. **pub.dev credentials:** run `dart pub login` once; copy `~/.config/dart/pub-credentials.json`.
3. **Repo secrets** (Settings → Secrets and variables → Actions):
   - `NPM_TOKEN` = the npm automation token (must have publish rights to `@neptune.fintech`).
   - `PUB_CREDENTIALS` = the full contents of `pub-credentials.json`.
4. **GitHub Pages** is already enabled (Source: GitHub Actions).

## Cutting a release

```sh
# 1. bump versions (keep all packages in lockstep for a coordinated release)
#    edit each package.json "version" + pubspec.yaml "version" + CHANGELOG entries
# 2. tag and push — this triggers .github/workflows/release.yml
git tag -a v1.0.1 -m "Neptune Odyssey v1.0.1"
git push origin v1.0.1
```

The **Release** workflow then:
- builds all packages, and publishes the npm packages with `pnpm -r publish --access public`
  **with provenance** (`NPM_CONFIG_PROVENANCE=true` + `id-token` — a signed supply-chain attestation
  linking each tarball to this repo + commit);
- restores `PUB_CREDENTIALS` and runs `flutter pub publish --force` for `neptune_flutter_ui`.

If a secret is missing the corresponding job fails fast at a guard step with a clear message —
nothing half-publishes.

## Verifying before a tag (no auth required)

```sh
pnpm -r --filter "./packages/**" run build
pnpm -r --filter "./packages/**" run test          # JS golden + unit
( cd packages/neptune_flutter_ui && flutter test && flutter pub publish --dry-run )
( cd packages/neptune_sound_kit && flutter test && flutter pub publish --dry-run )
for p in tokens web_ui svelte_ui vue_ui react_ui icons brand_configs product_configs; do
  ( cd "packages/neptune_$p" && npm pack --dry-run )   # inspect files that would ship
done
( cd create-neptune && npm pack --dry-run )
```

## Notes

- Versioning follows the token layer (see `docs/09-governance-and-versioning.md`): token renames are
  breaking (major), new tokens minor, value fixes patch. Bump `tokens.json › meta.version` on any
  token change.
- The brandprint format is version-tagged (`NO1-`) and registries are append-only — old brandprints
  keep resolving across releases.
- Licensing: source-available under the Neptune Odyssey Community License v1.0. Each package ships its
  own `LICENSE` + attribution; do not strip them.

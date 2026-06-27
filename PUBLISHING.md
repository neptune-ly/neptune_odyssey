# Publishing Neptune Odyssey

Everything is **publish-ready** and validated by dry-runs. Publishing happens **from CI on a
version tag** — no credentials ever touch a developer machine. This doc is the exact runbook.

## What gets published, and where

| Registry | Packages |
|----------|----------|
| **npm** (scope `@neptune-odyssey`) | `tokens`, `web-ui`, `svelte-ui`, `vue-ui`, `react-ui`, `brand-configs`, `product-configs` |
| **pub.dev** | `neptune_flutter_ui` |
| **GitHub Pages** | the gallery (`/`) + the configurator / hash-preset maker (`/configurator/`) — auto-deploys on push to `main`, no secrets needed |

`@neptune-odyssey/docs` and the demo/configurator apps are `private` and never published to npm.

## One-time setup

1. **Create the npm org/scope.** On npmjs.com create an org named **`neptune-odyssey`** (free for
   public packages). Add the publishing user as a member with publish rights. (The packages are
   already scoped `@neptune-odyssey/*` with `publishConfig.access: public`.)
2. **Create an npm automation token.** npm → Access Tokens → *Generate* → **Automation** (bypasses
   2FA in CI). Copy it.
3. **Create pub.dev credentials.** On a machine with Flutter, run `dart pub login` once and authorize
   the Google account that owns/will own `neptune_flutter_ui` on pub.dev. The credentials file lands at
   `~/.config/dart/pub-credentials.json`. Copy its full contents.
4. **Add repo secrets** (GitHub → repo → Settings → Secrets and variables → Actions → *New repository secret*):
   - `NPM_TOKEN` = the npm automation token.
   - `PUB_CREDENTIALS` = the entire contents of `pub-credentials.json`.
5. **Enable GitHub Pages** (GitHub → Settings → Pages → *Build and deployment* → Source: **GitHub Actions**).
   The `Pages` workflow then deploys automatically.

## Cutting a release

```sh
# 1. bump versions (keep all packages in lockstep for a coordinated release)
#    edit each package.json "version" + pubspec.yaml "version" + CHANGELOG entries
# 2. tag and push — this triggers .github/workflows/release.yml
git tag -a v1.0.1 -m "Neptune Odyssey v1.0.1"
git push origin v1.0.1
```

The **Release** workflow then:
- builds all packages, and publishes the 7 npm packages with `pnpm -r publish --access public`
  **with provenance** (`NPM_CONFIG_PROVENANCE=true` + `id-token` — a signed supply-chain attestation
  linking each tarball to this repo + commit);
- restores `PUB_CREDENTIALS` and runs `flutter pub publish --force` for `neptune_flutter_ui`.

If a secret is missing the corresponding job fails fast at a guard step with a clear message —
nothing half-publishes.

## Verifying before a tag (no auth required)

```sh
pnpm -r --filter "./packages/**" run build
pnpm -r --filter "./packages/**" run test          # JS golden + unit
( cd packages/neptune_flutter_ui && flutter test && flutter pub publish --dry-run )  # 0 warnings, ~19 KB
for p in tokens web_ui svelte_ui vue_ui react_ui brand_configs product_configs; do
  ( cd "packages/neptune_$p" && npm pack --dry-run )   # inspect files that would ship
done
```

## Notes

- Versioning follows the token layer (see `docs/09-governance-and-versioning.md`): token renames are
  breaking (major), new tokens minor, value fixes patch. Bump `tokens.json › meta.version` on any
  token change.
- The brandprint format is version-tagged (`NO1-`) and registries are append-only — old brandprints
  keep resolving across releases.
- Licensing: source-available under the Neptune Odyssey Community License v1.0. Each package ships its
  own `LICENSE` + attribution; do not strip them.

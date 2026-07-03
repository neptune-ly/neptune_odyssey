# Changelog

All notable changes to Neptune Odyssey are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com); the system follows [Semantic Versioning](https://semver.org) against the token layer (see `docs/09-governance-and-versioning.md`).

## [2.0.0] — 2026-06-27

### Changed (breaking)
- **Renamed the three non-Neptune reference themes** to neutral, Neptune-coined demo names (after
  Neptune's moons) so the system never ships names or identities it does not own. The example skins
  exist purely to demonstrate white-labelling ("same component, four skins"):
  - `andalus` → **`triton`** (emerald demo) · `nuran` → **`nereid`** (violet demo) ·
    `fglb` → **`proteus`** (navy demo). `neptune` is unchanged.
  - All brand ids, `[data-theme="…"]` selectors, tenant config files/ids, generated data, Flutter
    schemes, docs and the live pages were updated. **Brandprint strings are unchanged** (they encode
    seeds, not names), so a saved `NO1-…` still resolves identically.
- **Removed every real-institution name and culture/region-specific framing** from the code,
  libraries, descriptions and pages. The example tenants are reference illustrations only.

### Migration
- Replace `"andalus"`/`"nuran"`/`"fglb"` brand ids with `"triton"`/`"nereid"`/`"proteus"`
  (e.g. `applyTheme(root, "triton")`, `NeptuneTheme.light('triton')`, `[data-theme="triton"]`).
- 1.0.0 is deprecated on npm.

## [Unreleased]

### Added
- **`@neptune.fintech/react-ui`** — React layer, promoted from the roadmap. A thin wrapper over `@neptune.fintech/web-ui`: `<NeptuneProvider>`, a `useNeptuneTheme` hook, and typed `Npt*` component wrappers, with the same three-way theming surface (brand id / config / brandprint). No new color math — it inherits the determinism contract from `@neptune.fintech/tokens`, mirroring the Vue layer. Builds and tests green in CI.
- **`neptune_flutter_ui` 2.7.0 → 2.13.0** — the remaining nine screen templates, state-completeness contracts (`NeptuneStateSwitcher`/`NeptuneShimmer`), a full onboarding-flow suite mirroring a real production sequence, `NeptuneDemoShellApp` (a complete branded demo app in ~10 lines), bidirectional OKLCH↔sRGB colour + logo seed extraction, and a design-evolution pass: density modes, dark-mode elevation as a brand-tinted glow instead of a flat shadow, per-brand CTA motion timing, haptic/sound feedback tokens (`NptFeedback`), Arabic-Indic numerals as an independent lever, a standalone loader family (`NeptuneSpinner`/`NeptuneDotsLoader`/`NeptunePulseLoader`/`NeptuneHourglassLoader`), `NeptuneSplashScreen`, and `NeptuneAppBar`'s M3 medium/large collapsing-header variant.
- **`neptune_sound_kit`** (new package) — four synthesized (not recorded) feedback chimes wired to `NptFeedback.onSoundCue`, kept separate from the core UI package so apps that don't want sound never pay for an audio-plugin dependency. Not yet published (chimes pending listen-and-approve).
- **`neptune_laravel_ui`** (new package) — Blade components over `@neptune.fintech/web-ui`'s custom elements, vendoring the built JS/CSS so a Laravel app needs no Node/npm build step for the four reference brands. Verified against a real Laravel 11 app.
- **`tools/sound-identity`** (new dev tool) — generates a distinct 5-file sound identity (success + 4 notification cues) for any bank via a melodic shape + soundfont patch, the sound counterpart to `tools/client-demo`'s visual brandprint generator.
- **`apps/neptune_studio`** (new app) — a desktop GUI for the client-demo factory: drop a logo, watch live seed extraction, tune levers, preview live, generate + run.
- **`site/vs-material.html`** — a live, evidence-based answer to "why not just Material 3," with a side-by-side of the same UI pieces as a stock M3 baseline vs. a real Odyssey theme.
- **`@neptune.fintech/web-ui` 2.4.0 → 2.5.0** — ported Flutter's dark-mode elevation glow to web: `system.css` gains a `[data-mode="dark"]` override of `--npt-elev-1..5` that lerps the shadow 35% toward the brand `primary` (scoped there, not in `--md-sys-color-scrim` itself, so backdrop/dialog scrims stay neutral) instead of flattening to literal black. **Also fixed a real, pre-existing bug found while wiring this up**: 9 component source files (`button`, `card`, `cards`, `actions`, `containers`, `corporate`, `feedback`, `feedback-status`, `wallet-pay`) read a token name, `--npt-elevation-N`, that was never defined anywhere (only `--npt-elev-N` exists) — every one of these components had silently rendered its literal CSS fallback shadow, in both light and dark mode, since it was written. Verified per-brand and per-mode via computed-style inspection (not just screenshots — dark mode confirmed brand-tinted and distinct per reference brand; light mode confirmed byte-identical to the pre-fix values).

### Fixed
- **`site/icons.html` brand-mark grid — 7 more real official assets, one real bug.** Following the same pattern as Western Union/LyPay (real licensed artwork loaded at runtime via `registerBrandMark`, never bundled into the public npm package):
  - **NUMO** — was a fabricated navy badge; NCB/Jumhouria-Bank-issued cards actually carry Moamalat's real three-overlapping-rings mark (confirmed against `ncb.ly`). Now the real ring geometry (matching a production Libyan app's asset), recoloured navy/gold to read on a light background.
  - **Visa, Mastercard** — swapped hand-drawn placeholders for the real marks from a production Libyan deployment. (Visa's real file is a white-only knockout meant for a blue chip — added the missing `#1A1F71` backing rect so it isn't invisible on a light page.)
  - **Sadad** — the السداد wordmark now sits next to Almadar's real parent-brand globe swoosh (embedded from a real licensed asset, not redrawn), instead of a freehand approximation of it.
  - **Google Pay, Apple Pay, SWIFT** — replaced hand-drawn approximations with each brand's real official mark (Google Pay/Apple Pay/SWIFT-2023 logos, sourced from Wikimedia Commons' standard reproductions).
  - **Still placeholders — no official asset found anywhere:** MoneyGram, OnePay Libya (وان باي). Same one-line `registerBrandMarksFromUrls` wiring once a real file exists.
- **CI has been red since R1 (`ac0f8a3`, 2026-07-02) — root-caused and fixed.** Every push since the token-codegen pipeline was introduced failed two independent gates:
  - `packages/neptune_tokens/test/oklch.golden.test.ts`'s "(A) pinned reference palettes == tokens.resolved.json EXACTLY" (8/50 tests). Cause: `tools/codegen.mjs` regenerates `assets/tokens.resolved.json` but never regenerated its sibling `src/data/resolved.generated.ts` (the module `resolve.ts`'s `getResolvedPalette()` actually imports at runtime) — that file was last hand-generated at v2.0.0 (`bca426a`, 2026-06-27) and had silently drifted from every codegen run since, including R6's contrast-lift pass. Fixed by adding `resolved.generated.ts` as a proper codegen output (`emitResolvedTs()`, wired into both the write and `--check` drift-gate paths) so it can never drift again, then regenerating it.
  - "Visual sweep — Flutter gallery" 's Blank-region gate: `pip3 install pillow` fails with `externally-managed-environment` on the `macos-14` runner (PEP 668). Fixed with `--break-system-packages` (applied to both blank-gate jobs for consistency).
  - Separately, **`Desktop build`'s Windows job has failed on every run since its introduction** (`03a074e8`, 2026-06-29): `windows-latest` now resolves to a VS2026-preinstalled image, and Flutter's stable toolchain can't detect/use VS2026 yet (`CMake Error ... could not find any instance of Visual Studio` — see [flutter/flutter#180481](https://github.com/flutter/flutter/issues/180481), [#178702](https://github.com/flutter/flutter/issues/178702)). Fixed by pinning `runs-on: windows-2022`.

### Changed
- Roadmap now lists **React Native** and **Kotlin Multiplatform** only; React moved to `packages/` and is documented as Stable in the README.

## [1.0.0] — 2026-06-26

First stable release of **Neptune Odyssey**, the Neptune.Fintech white-label banking design system.

### Added
- **Brand identity** — the system is now **Neptune Odyssey**, published under Neptune.Fintech. Versioning, component status and a governance gate.
- **Four reference brands** — Neptune, Triton, Nereid and **Proteus** (Proteus), each a full M3 tonal palette × light/dark with its own corner family, type set, motif and hero emblem. Proteus is now first-class throughout (motif + emblem tokens added).
- **Five reference tenant configs** (`configs/`) — Neptune Retail, Neptune Corporate, Triton Retail, Nereid Wallet, Proteus Retail — covering all eight white-label config layers, each documenting the brand levers it moves (≥ 6 of 12). Plus a runtime registry + live theme loader (`configs/tenants.js`).
- **Neptune Wallet Web** (`Neptune Wallet Web.dc.html`) — a payment-led wallet web reference (balance hero, add money, top-up, send/request, QR/NFC merchant pay, vouchers, activity, limits, linked cards), wired to the live tenant loader. A sibling product to retail web, not relabeled banking.
- **Corporate web depth** — audit-trail screen, editable approval-matrix editor, and a repair-failed-rows flow in bulk payments.
- **Documentation-grade reference sections** in the mobile DC — named principles, M3 state-layer + focus specs, live motion curves, the 4-pt spacing scale, an accessibility panel (contrast pairs, touch targets, checks), component anatomy, the 12-lever same-but-distinct grid, and a governance/status board.
- **Twelve brand levers, all tokenised** — the final five (login shell, dashboard hero, motion feel, glass tint, content tone) are now real per-brand tokens in `tokens/themes.css` (`--npt-ease-*`, `--npt-dur-*`, `--npt-glass-tint/-blur`, `--npt-login-shell`, `--npt-dashboard-hero`, `--npt-content-tone`) and documented in `tokens.json › levers`. The Wallet web reference applies per-brand glass tint live.
- **Brandprint** (`tools/brandprint.js`, `docs/11-config-hash.md`) — a deterministic, portable `NO1-…` theme string: pick levers → string → identical theme on any platform. Proven idempotent, checksummed, registry-versioned.
- **Build prompt** (`HANDOFF_PROMPT.md`) — the full Claude Code brief to generate the multi-framework libraries (Flutter, web, Svelte, Vue now; React/React Native/KMP roadmap), the online configurator, and publish.
- **License** (`LICENSE`) — Neptune Odyssey Community License: free for non-commercial use and for organisations under USD $25,000/yr revenue; commercial otherwise.
- **New docs** — `07-design-principles`, `08-accessibility`, `09-governance-and-versioning`, `10-token-naming`, `11-config-hash`; a `README.md` front door and this changelog.
- **Accessibility** — global keyboard-only focus ring (`:focus-visible`, token-driven) and a `prefers-reduced-motion` guard across the living references.

### Libraries (multi-framework implementation)
- **Monorepo** — pnpm workspace (JS/TS) + a standalone Flutter package; `@neptune.fintech/*` scope; per-package LICENSE + headers; CI (`ci.yml`) and tag-driven publish (`release.yml`).
- **`@neptune.fintech/tokens`** — the determinism backbone: OKLCH→sRGB converter (CSS Color 4 path), the v1 seed→palette ramp, the brandprint codec ported from the JS reference, the pinned reference palettes, CSS/Dart codegen, and `buildTheme()` (the 3-way theming API). **50 golden tests**: codec byte-parity + idempotency + tamper rejection; pinned palettes == `tokens.resolved.json` exactly; converter ≤ 1 LSB; the three theming entry points agree.
- **`neptune_flutter_ui`** — const M3 `ColorScheme`s × 4 brands × light/dark, ThemeExtensions (colors/shape/type/motion), `NeptuneTheme.light/dark/fromBrandprint/fromConfig`, theme-only widgets, Dart codec + OKLCH ports. **31 golden tests**; `flutter analyze` clean; no literals in widgets.
- **`@neptune.fintech/web-ui`** — pure CSS-variable theming (`applyTheme`) + standards-based custom elements (Shadow DOM, custom-property driven, no literals), shipping `themes.css` + `system.css`.
- **`@neptune.fintech/svelte-ui`** + **`@neptune.fintech/vue-ui`** — thin framework layers over the web core; same 3-way theming surface.
- **`@neptune.fintech/brand-configs`** + **`@neptune.fintech/product-configs`** — the 5 tenants as a loader (tenant → brandprint) and the product-flavor/feature-flag layer.
- **`apps/configurator`** — client-only theme builder (brandprint encode/decode, live preview, AA contrast check).
- **Roadmap** — React, React Native, Kotlin Multiplatform scaffolded under `roadmap/` (not in v1).

### Changed
- Rebranded the mobile reference header/footer to Neptune Odyssey · Neptune.Fintech, with a version badge.
- Corrected the brand count from 3 → 4 across the hero, headings and counters.
- `CLAUDE.md` and `AGENTS.md` updated for Odyssey, Proteus and the new docs.

### Notes
- All components ship **Stable** in v1.0.0 — no Beta surfaces.
- Token layer is the public API. Token renames are breaking; new tokens are minor; value fixes are patch.
- Brandprint registries are append-only; the format is version-tagged (`NO1-`).

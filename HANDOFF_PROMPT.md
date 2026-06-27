# Neptune Odyssey — Build Prompt for Claude Code

Copy everything below the line into Claude Code, opened at the root of the Neptune Odyssey
repository. It has the design system as its source of truth; your job is to turn it into a
production, multi-framework component library + an online theme configurator, and publish it.

You have permission to create files, scaffold packages, run builds/tests, and commit & push.

────────────────────────────────────────────────────────────────────────────

## Mission

Build **Neptune Odyssey** — a white-label banking UI system by Neptune.Fintech — into a
versioned monorepo of libraries that are **smart, smooth, high-performance and trivially easy
to theme**. Ship **stable v1.0.0** (no "beta" surfaces). Then push to GitHub.

The design is fully specified already. Do **not** redesign. Match the reference exactly.

## Sources of truth (read first, in this order)

1. `README.md`, `docs/06-platform-plan.md` — what the system is and its shape.
2. `docs/07-design-principles.md` — the six rules you must not violate (esp. P2: tokens, never literals).
3. `tokens/themes.css` + `tokens/tokens.json` — the token layer. **The public API.**
4. `build/tokens.resolved.json` — every `--md-sys-color-*` already resolved to hex/ARGB,
   per brand × light/dark. Plus generated `build/neptune_color_schemes.dart` and
   `build/neptune_theme_extensions.dart` — your Flutter starting point.
5. `docs/04-flutter-implementation.md` — the exact Flutter mapping recipe.
6. `docs/10-token-naming.md` — the naming contract. `docs/09-governance-and-versioning.md` — semver gate.
7. `docs/11-config-hash.md` + `tools/brandprint.js` — the **brandprint** codec (proven, idempotent). Port it faithfully.
8. `configs/*.tenant.json` + `configs/tenants.js` — the 5 reference tenants + live loader.
9. The three living references are the **visual contract** — your output must match them across
   brand × mode × direction:
   - `Neptune Design System.dc.html` (mobile + full system docs)
   - `Neptune Web Banking.dc.html` (retail + corporate web)
   - `Neptune Wallet Web.dc.html` (payment-led wallet web)

## Four brands, every build

`neptune` · `triton` · `nereid` · `proteus` — each a full M3 tonal palette × **light/dark**,
its own corner family, type set, motif, and the five "expression" levers (login shell,
dashboard hero, motion feel, glass tint, content tone) now tokenised in `tokens/themes.css`
(`--npt-*`). Everything must work in **LTR and RTL** (logical properties only; Arabic faces swap).

────────────────────────────────────────────────────────────────────────────

## Monorepo structure

```
packages/
  neptune_tokens/          # tokens.resolved.json + generated CSS/Dart/TS; OKLCH→sRGB build; brandprint codec; golden tests
  neptune_flutter_ui/      # ThemeData per brand/mode, ThemeExtensions, widgets
  neptune_web_ui/          # themes.css + framework-agnostic CSS-variable component kit (custom elements)
  neptune_svelte_ui/       # Svelte components over the CSS-variable layer
  neptune_vue_ui/          # Vue 3 components over the CSS-variable layer
  neptune_brand_configs/   # the 5 tenant configs + loader + brandprints
  neptune_product_configs/ # product-flavor + feature-flag configs (from each tenant `features`)
  neptune_docs/            # docs/ + the .dc.html references (visual contract)
apps/
  configurator/            # the online theme builder (brandprint encode/decode + live preview)
```

Use a workspace tool appropriate to the stack (pnpm workspaces for JS/TS; melos for Dart).
JS/TS packages: TypeScript, ESM, fully tree-shakeable, side-effect-free, SSR-safe, zero
runtime CSS-in-JS. Publish-ready (`package.json` `exports`, types, `sideEffects:false`).

## Framework priority

- **Now (v1.0.0):** `neptune_tokens`, `neptune_flutter_ui`, `neptune_web_ui`, `neptune_svelte_ui`, `neptune_vue_ui`, the configurator.
- **Roadmap (scaffold + ROADMAP.md, do not block v1):** React, React Native, Kotlin Multiplatform (Compose + web). Build these on the same `neptune_tokens` outputs so they inherit the palette/brandprint for free.

────────────────────────────────────────────────────────────────────────────

## The theming API — make it effortless

Every library must accept a theme **three** ways, in increasing power, with one consistent surface:

1. **Brand id** — `"neptune" | "triton" | "nereid" | "proteus"` (the built-in reference brands).
2. **Config object** — the full lever set (seeds, corners, type, the five enums, flags).
3. **Brandprint string** — `"NO1-…"`; decode → config → theme. This is the headline feature:
   *pick a theme in the online configurator, copy the string, paste it into the app, get the
   exact same theme.* Same string ⇒ same theme on every platform.

Plus **global params** for `mode` (`light|dark|system`) and `dir` (`ltr|rtl|auto`).

Sketches (match per-framework idioms):

```ts
// web / svelte / vue  — driven entirely by data-attributes + CSS variables
applyTheme(root, "triton", { mode: "system", dir: "auto" });
applyTheme(root, "NO1-AYygAQ…");                 // brandprint
applyTheme(root, { primary:{L,C,H}, corners:{…}, motion:"calm-graceful", … });
```
```dart
// flutter
MaterialApp(
  theme: NeptuneTheme.light('triton'),
  darkTheme: NeptuneTheme.dark('triton'),
  // or: NeptuneTheme.fromBrandprint('NO1-…') , or NeptuneTheme.fromConfig(cfg)
);
```

Token access is always through the framework's theme context — **never a literal** in a
component (P2). Web components read `var(--md-sys-color-*)` / `var(--npt-*)`; Flutter reads
`Theme.of(context)` + the `NeptuneColors`/`NeptuneShapes`/`NeptuneType` extensions.

## The token + palette pipeline (the determinism backbone)

1. In `neptune_tokens`, implement **OKLCH→sRGB** in code (Dart + TS; e.g. `culori` for TS,
   a small HCT/OKLCH step for Dart). **Golden test:** output must equal `build/tokens.resolved.json`
   for all 4 brands × light/dark. This is what guarantees Flutter == web.
2. Implement **one palette-generation algorithm from a seed**, shared by all platforms
   (`docs/11` "Determinism"). The four reference brands' brandprints must regenerate palettes
   equal to `tokens.resolved.json`. Golden-test it.
3. Port the **brandprint codec** (28-byte layout in `docs/11`, reference in `tools/brandprint.js`)
   to Dart/TS. Golden-test encode/decode against the JS reference for the 4 brands. Registries
   are **append-only** — never reorder.

## The configurator app (`apps/configurator`)

A small client-only web app (no backend) over the brandprint codec:
- Pick `primary`/`tertiary` seed (colour wheel in OKLCH), corner family, fonts, and the five
  lever enums; toggle mode/dir.
- **Live preview** against the real reference screens (reuse `neptune_web_ui` components).
- Show the `NO1-…` brandprint; one-click copy; paste-to-load.
- Validate AA contrast live (warn if a seed fails) — see `docs/08`.

## Performance & quality bar (this is the point — "smart, smooth, optimized")

- **Web:** theming is **pure CSS variables** — zero JS to re-skin (set `data-theme`/`data-mode`/`dir`).
  Components ship as standards-based custom elements (or framework-native wrappers) — no heavy
  runtime, no CSS-in-JS. Tree-shakeable ESM, `sideEffects:false`, critical-CSS friendly, SSR-safe.
  Honour `prefers-reduced-motion`; animations use the per-brand `--npt-ease-*`/`--npt-dur-*` tokens.
- **Flutter:** `const` `ColorScheme`s and `ThemeExtension`s for the reference brands (no runtime
  palette gen on the hot path — only custom brandprints generate at load). 60fps; cheap rebuilds;
  tree-shaken icons; `FontFeature.tabularFigures()` on money.
- **All:** no literal colour/radius/font anywhere in components. 48dp targets, visible
  `:focus-visible`, full keyboard nav, screen-reader labels, AA contrast (`docs/08`).
- Bundle budgets: document them; keep the CSS-variable core tiny; lazy-load non-critical components.

## Licensing & docs

- Add `LICENSE` (already in repo — Neptune Odyssey Community License: free for non-commercial
  and for orgs under USD $25k/yr; commercial otherwise) to every published package and its
  `package.json`/`pubspec.yaml` (`license` field + a `LICENSE` copy + a header notice).
- Keep `CHANGELOG.md` (Keep a Changelog) and bump `tokens.json › meta.version` on any token change.
- Per-package `README.md` with install + the three theming entry points + a brandprint example.

## Definition of done (the gate — all must pass)

- [ ] OKLCH→sRGB golden test == `build/tokens.resolved.json` (4 brands × light/dark), Dart **and** TS.
- [ ] Brandprint encode/decode golden test == `tools/brandprint.js` for the 4 brands; idempotent; checksum rejects tampered strings.
- [ ] Each library themes via brand id, config object, **and** brandprint — same string ⇒ same theme cross-platform.
- [ ] Light **and** dark, LTR **and** RTL verified on every reference screen; Arabic faces load; layout mirrors.
- [ ] WCAG AA throughout; visible focus; reduced-motion honoured; 48dp targets.
- [ ] **No literal colour / radius / font** in any component (grep the component layer — zero hits).
- [ ] Output matches the three `.dc.html` references at brand × mode × direction.
- [ ] Everything **Stable** — no "beta" labels in shipped surfaces.
- [ ] Builds, lints, and tests green in CI; packages are publish-ready.
- [ ] Committed and pushed to GitHub with tag `v1.0.0`; roadmap packages stubbed with `ROADMAP.md`.

## Suggested phasing (don't boil the ocean)

0. Repo + workspace + `neptune_tokens` (pipeline, brandprint port, golden tests).
1. `neptune_flutter_ui` (from `build/` artifacts + `docs/04`).
2. `neptune_web_ui` (CSS-variable core + custom-element components).
3. `neptune_svelte_ui` + `neptune_vue_ui` (thin layers over the CSS-variable core).
4. `apps/configurator`.
5. Roadmap stubs: React, React Native, KMP.

Work phase by phase; keep CI green at each step; open a PR per phase with screenshots compared
to the reference `.dc.html`.

────────────────────────────────────────────────────────────────────────────
*Neptune Odyssey · © 2026 Neptune.Fintech. The `.dc.html` files are design references — recreate
them in each framework's idioms; do not ship the HTML.*

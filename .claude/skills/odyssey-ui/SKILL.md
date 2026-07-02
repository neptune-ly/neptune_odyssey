---
name: odyssey-ui
description: Build or restyle Neptune Odyssey UI correctly — web components, the neptune_flutter_ui package, themes/brandprints, templates, or client white-label prototypes. Use whenever working on Odyssey widgets/components, brand theming, visual fidelity ("make it match the site"), the Flutter package, or a bank/client demo. Enforces the identity doctrine, the no-literals law, and pixel verification.
---

# Odyssey UI — do it right

You are working on **Neptune Odyssey**, the white-label banking design system.
Read `ODYSSEY_RULEBOOK.md` (repo root) for the full law + history. This skill
is the operational checklist.

## Before writing ANY styled code

1. **Extract the recipe from the source of truth — never style from memory:**
   - Tokens (colours, glass, motifs, elevation, motion, fonts, per brand):
     `packages/neptune_tokens/assets/themes.css`
   - Exact component CSS: `packages/neptune_web_ui/src/components/*.ts`
   - Composed templates + animations: `site/templates.html`
   - In-context app + EN/AR string table: `site/system.html` (`const L = {`)
2. Find the Flutter counterpart idiom in
   `packages/neptune_flutter_ui/lib/src/widgets/` and the theme API in
   `lib/src/theme/` (`NptShape`, `NptColors`, `NptType`, `NptMotion`,
   `NptIdentity`).

## The identity bar (what "matches the site" means)

M3 colours alone = generic Material = WRONG. A finished Odyssey surface has,
where the web has them: the 135° primary→tertiary gradient, `NeptuneGlass`,
`NeptuneMotifLayer` (sonar/arcs/grid/guilloché per brand), elevation tokens +
primary key-light glow, `NeptuneEyebrow`/tabular money type, and the motion
recipes (CTA sheen 4.8s hold-sweep-hold 62–82%, arrow nudge ±4dp/2.4s, dock
raised-active spring, welcome orbs 15/19/17s) — all reduced-motion safe.

## Flutter hard rules (CI-enforced)

- NO `Colors.*`, `Color(0x…)`, `BorderRadius.circular(<digit>` in
  `lib/src/widgets` — **not even in comments** (gate greps raw text).
- `.withValues(alpha:)`, `EdgeInsetsDirectional`, ≥48dp, `const`, RTL-safe.
- Tests set `NeptuneTheme.debugSkipFontLoading = true`.
- Layout traps (all bit us before — see rulebook §4 table): stretch-Row needs
  `IntrinsicHeight`; no `Expanded` in min-Columns; slot-Rows must `Flexible`
  their children (unbounded width silently blanks subtrees); fixed-size
  `CustomPaint` needs `Center` under tight constraints; test at ≤430dp width.

## Verify with pixels, then ship

1. `flutter analyze` → `flutter test` → gate:
   `grep -rnE 'Color\(0x|Colors\.|BorderRadius\.circular\([0-9]' lib/src/widgets`
2. SHOTS sweep (engine-rendered PNGs, no macOS screencapture — permission
   trap): `cd example && flutter build macos --debug --dart-define=SHOTS=true
   --dart-define=SHOTS_DIR=<dir>` then run the binary; it sweeps every scroll
   viewport × 4 brands × light/dark × RTL and exits. **Open the PNGs and
   look.** Blank region = broken layout, not empty content.
3. Ship: bump + CHANGELOG + COVERAGE (honest) →
   `flutter pub publish --force` → commit as `Tellesy <mtellesy@gmail.com>`
   + Co-Authored-By trailer → push main.
4. **Client material (logos, bank demos) never enters the public repo and
   never sits in `example/` at publish time** (pub bundles example/).

## Client white-label prototype (fast path)

Logo hexes → OKLCH seeds → `BrandprintConfig` (+ fitting levers) →
`NeptuneTheme.fromConfig(cfg, arabic: …)` → reuse `NeptuneWelcome`
(`lockup:` real logo) + the 5-tab in-context shell + `site/system.html`'s
bilingual strings + `NeptuneStatusMotion` for transfer outcomes → SHOTS pass →
run live via a `--dart-define` flag in the example app.

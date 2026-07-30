# The Odyssey Rulebook — how to build Neptune Odyssey right

**Audience: every agent, chat, and human who touches this system.** This is the
distilled doctrine from building the web kit, the Flutter package
(`neptune_flutter_ui` 2.2 → 2.6), the desktop app, and the first client
prototypes — including every mistake we made so you don't repeat it.
`AGENTS.md` gives the mental model; this file gives the law.

---

## 1 · What Neptune Odyssey IS

A **vendor-neutral, white-label banking design system** by Neptune.Fintech
(neptune.ly). One deterministic **brandprint** (`NO1-…` hash) produces the
identical theme on every platform — web components, Flutter, React/Vue/Svelte
adapters. Four reference brands (**neptune / triton / nereid / proteus**), and
any client becomes a **config**, never a fork.

A brand is not just colours. A brand in Odyssey =
**M3 colour scheme** (from OKLCH seeds) **+ corner family + type set
(incl. Arabic faces) + motion feel + the identity levers**:
glass tint, signature motif, login shell, dashboard hero, content tone.

## 2 · Sources of truth (read these BEFORE styling anything)

| What | Where |
|---|---|
| Token layer (per-brand, light+dark, incl. `--npt-glass-*`, `--npt-motif`, `--npt-hero-emblem`, elevation, motion) | `packages/neptune_tokens/assets/themes.css` |
| Component recipes (exact CSS: paddings, radii, shadows, animations) | `packages/neptune_web_ui/src/components/*.ts` |
| Composed screens/templates + the animated flourishes | `site/templates.html` (9 templates incl. Welcome/Sign-in) |
| The in-context phone app + **the bilingual EN/AR string table** | `site/system.html` (search `IN CONTEXT`, `const L = {`) |
| Flutter theme engine | `packages/neptune_flutter_ui/lib/src/theme/` (`neptune_theme.dart`, `identity.dart`, `brand_tables.dart`, `extensions.dart`) |
| Flutter widget catalogue + status | `packages/neptune_flutter_ui/COVERAGE.md` |

**The cardinal rule: never style from imagination.** Every colour, radius,
shadow, easing, duration, letter-spacing and animation timing already exists in
the web source. Extract the exact recipe first, then port it.

**The codegen pipeline (R1).** `themes.css` is canon; `node tools/codegen.mjs`
(`pnpm codegen`) generates `tokens.resolved.json`, the Flutter
`generated/brand_data.g.dart` (schemes, success roles, shapes, types incl.
Arabic, motion, glass recipes), the TS `tokens.g.ts`, and the Flutter oklch
golden fixture — all through the same OKLCH math (1:1 with `oklch.dart`).
**Never hand-edit colour tables**: edit `themes.css`, regenerate, and let the
data-driven goldens verify. `pnpm codegen:check` is the CI drift gate. (The
old browser-derived hexes differed by ±1 LSB on 21 roles; the portable math is
canon since this change.)

## 3 · The identity doctrine (the lesson of 2.5.0)

Widgets that only read M3 colour roles come out as **generic Material** — this
was the single biggest mistake of the early Flutter port. Odyssey's vibe lives
in the layers ABOVE the colour scheme:

1. **Brand gradients** — heroes/cards ride `linear-gradient(135°, primary, tertiary)`.
2. **Glass** — per-brand tint (`color-mix` of primary — *tertiary for triton* —
   into translucent surface at 7–12%) + per-brand blur 14–22px + hairline
   `outlineVariant` seal. Dock pane = `surfaceContainer @ 86%` + blur.
   Flutter: `NeptuneGlass`, `NptIdentity.glassTint()`.
3. **Signature motifs** (`--npt-motif`) — neptune **sonar tide-rings**, triton
   **coastal arcs**, nereid **grid-spark**, proteus **shield guilloché**.
   Layered over heroes/card-art at strength ×1, cards ×0.65–0.8, page washes
   ×0.055. Flutter: `NeptuneMotifLayer`.
4. **Elevation tokens** — e1 `0 1px 3px @.20`, e2 `0 2px 6px @.18`,
   e3 `0 8px 20px @.20`, e5 `0 28px 60px @.30`, plus the **primary key-light
   glow** under heroes/CTAs. Flutter: `NptIdentity.elevation1..5/glowPrimary`.
   **Dark mode is a glow, not a cast shadow** on both platforms: a scrim/
   black shadow at 16–40% alpha barely registers against an already-dark
   surface, so dark mode lerps the shadow color 35% toward `primary`, drops
   the directional offset, and widens the blur — reads as ambient light
   lifting the surface, not a shape cast beneath it. Web: `system.css`'s
   `[data-mode="dark"]` override of `--npt-elev-1..5` (scoped there, not in
   `--md-sys-color-scrim` itself, so backdrop/dialog scrims stay neutral).
   Flutter: `NptIdentity.elevation1..5`'s `_isDark` branch.
5. **Expressive type details** — the eyebrow (uppercase, display face,
   tracking 0.08em → `NeptuneEyebrow`), card scheme labels, tabular money
   figures (`NeptuneTheme.moneyStyle`), mixed-weight promises (w500 + w800
   primary).
6. **Motion recipes** (all reduced-motion safe):
   - CTA sheen: 110° on-colour highlight (α .38), −130%→+130%,
     **4.8s cycle, sweeping only during 62%→82%** (hold-sweep-hold).
   - CTA arrow nudge: ±4dp, 2.4s sine, mirrors under RTL. Press scale 0.98.
   - Welcome orbs: primary/tertiary/secondary blobs drifting on
     **15/19/17s** loops over a radial wash (primary 26% → surface at 68%).
   - Dock raised-active: circle pops **above** the bar on the brand spring.
   - Outcome flow: `NeptuneStatusMotion` hourglass → stroke-drawn success
     check / rejected cross (linked spin-out/spring-in).

**A surface without gradients, glass, motif, glow or the type details is not
done — it's a grey Material mockup.**

The reader-facing version of this argument (a live side-by-side of the same
balance card as a stock M3 baseline vs. brand-themed) lives at
`site/vs-material.html` — keep the two in sync when either changes.

## 4 · Flutter package law (`neptune_flutter_ui`)

Hard rules — CI enforces the first one by grepping `lib/src/widgets`:

- **No literals**: no `Colors.*`, no `Color(0x…)`, no
  `BorderRadius.circular(<number>)` — **not even inside comments** (the gate
  greps raw text). Read `Theme.of(context)`: `colorScheme`,
  `extension<NptShape>()` (`rXs..rXxl`, `full`), `<NptColors>` (success roles),
  `<NptType>` (faces incl. `displayAr/textAr/numAr`), `<NptMotion>`
  (curves/durations/blur), `<NptIdentity>` (glass/motif/elevation/glow).
- Alpha via `.withValues(alpha:)` — never `withOpacity`.
- `EdgeInsetsDirectional` / `PositionedDirectional` / `AlignmentDirectional`
  everywhere. Icons that imply direction mirror under RTL.
- Touch targets ≥ 48dp. `const` where valid. Every widget gets a `///` doc
  naming its web counterpart.
- Fonts load via `google_fonts` at runtime; tests must set
  `NeptuneTheme.debugSkipFontLoading = true` (the loader throws async in
  `flutter test`).
- Money: `NeptuneTheme.moneyStyle(context, base:)` — brand num face + tabular
  figures, direction-aware (Arabic numeral face under RTL).
- **Implicitly-animated shadow lists must keep the same length in every state**
  (2.15.0, the dock's raised-active key-light). `active ? [shadow] : null` makes
  `BoxDecoration.lerp` pad the shorter list with `BoxShadow.scale(1 - t)`, and
  the brand springs overshoot outside `0..1` — a negative factor is a negative
  `blurRadius`, which asserts in `dart:ui`. Emit one shadow per state with
  identical offset/blur/spread and animate the **alpha** only (`Color.lerp`
  clamps; `BoxShadow.scale` does not). Latent for nine minor versions because
  every test and SHOT built the dock with a *fixed* active item — any
  implicitly-animated selection state needs a test that actually *changes* it.
- **White-label means the host's icons too.** Icon-bearing chrome takes an
  optional `iconWidget` next to `IconData` (`NeptuneDockItem`,
  `NeptuneQuickAction`, `NeptuneAccountTile` since 2.15.0) — client banks ship
  their own designed marks, and an `IconData`-only API makes every bank's chrome
  identical. Publish the state tint to the supplied widget via `IconTheme` +
  `DefaultTextStyle`, never a forced colour filter (that would flatten a
  multi-colour brand mark); document that a monochrome SVG should inherit
  `currentColor`.

**Layout traps that actually bit us (regression-tested — don't reintroduce):**

| Trap | Fix |
|---|---|
| `CrossAxisAlignment.stretch` on a `Row` in unbounded height | wrap in `IntrinsicHeight` |
| `Expanded` inside a `mainAxisSize: min` `Column` | don't — use `Padding`/`Align` |
| A bare `Row` gives children **unbounded width** → any flex descendant (e.g. `NeptuneSearchField`) fails layout and **silently blanks the whole subtree** | wrap slot children in `Flexible` (see `NeptuneToolbar`) |
| A widget with internal flex (e.g. `NeptuneSegmented`) placed in an unbounded slot (`NeptuneListTile.trailing`) — same silent blank; **no exception reaches the app log** | widgets with internal flex must self-adapt: `LayoutBuilder` → shrink-wrap when `!hasBoundedWidth` (see `NeptuneSegmented`; regression: `unbounded_slots_regression_test.dart`) |
| `SizedBox` size is overridden by tight constraints (`Expanded` parent) → `CustomPaint` paints **outside its bounds** | wrap in `Center`/`Align` to loosen (see `NeptuneCreditScoreGauge`) |
| `Positioned.fill` outside a `Stack` | only valid as a `Stack` child |
| Trailing text in rows overflowing at ≤430dp width | `Flexible` + ellipsis; stack action rows on narrow widths |

## 5 · Verification doctrine — no claim without pixels

- **The SHOTS harness** is the law: the example app with
  `--dart-define=SHOTS=true --dart-define=SHOTS_DIR=…` renders pixel-exact
  PNGs from the engine (`RepaintBoundary.toImage`) and exits. Sweep
  **every viewport of scroll × 4 brands × light/dark × RTL**, then LOOK at
  them. Two real library bugs were only found this way.
- The capture boundary must wrap the **navigator**
  (`MaterialApp.builder`), not `home:` — otherwise pushed routes are invisible.
- **Never use macOS `screencapture`** for verification — it spirals into
  screen-recording permission dialogs. Render from inside the app.
- A layout exception in release-ish runs = **silent blank region**, not a red
  screen. Blank ≠ empty; blank = broken.
- Run before every ship: `flutter analyze` (zero), `flutter test` (all green),
  the no-literals grep, and a SHOTS pass reviewed by eye.
- **CI gates (R2)**: `pnpm codegen:check` (token drift) · `pnpm contrast`
  (WCAG AA per brand × mode) · `tools/blank_check.py` over the SHOTS sweep and
  the Playwright web sweep (`tools/web-shots.mjs`) — the blank gate detects
  the *contiguous flat band* signature (>55% of height), which caught the
  `NeptuneSegmented` bug on a client Profile screen with **zero** console
  output. Shots upload as CI artifacts for eyes-on review.

## 6 · Web component law (`neptune_web_ui`)

- Custom elements extend `NptElement` (Shadow DOM, one cached stylesheet).
- **Custom-property driven only** — components read `--md-sys-color-*` /
  `--npt-*`; zero literals; properties inherit through the shadow boundary.
- Logical properties (`inline-size`, `padding-inline`, `inset-inline-start`)
  so RTL mirrors for free; `:dir(rtl)` only for glyph flips.
- Every animation ships a `prefers-reduced-motion: reduce` guard (shared
  `A11Y` css). Focus-visible ring from the shared token.
- Glass only on approved surfaces (nav/hero/auth/overlays) — never on
  tables/forms (docs/06 §3).

## 7 · Ship flow (Flutter package)

1. `flutter analyze` clean → `flutter test` green → no-literals gate → SHOTS
   sweep reviewed.
2. Bump `pubspec.yaml`, write `CHANGELOG.md`, update `COVERAGE.md`
   (honest status — nothing silently dropped).
3. `flutter pub publish --force` (credentials stored).
4. Commit as `Tellesy <mtellesy@gmail.com>`, trailer
   `Co-Authored-By: Claude <the model in use>`, push `main`.

**⚠️ pub.dev bundles `example/`.** Client material (logos, client demos) must
NEVER sit inside the package directory when publishing — and never in this
public repo at all. Client prototypes stay local or in a private location;
only generic capabilities (like `NeptuneWelcome.lockup`) get upstreamed.

### Platform positioning (decided 2026-07)
**Flutter is the flagship mobile/desktop implementation.** React Native
(`@neptune.fintech/react-native-ui`) is in **maintenance mode** — theme parity
+ its existing core set, no new widget back-ports (its README says so). Web
components remain the canonical recipe source for both.

**Compose Multiplatform** (`packages/neptune_kmp_ui`, coordinates
`ly.neptune.odyssey:odyssey-tokens` / `:odyssey-compose-ui`) is the KMP-native
implementation for teams already on Kotlin — Android/iOS/desktop/web(js+wasm)
from one `commonMain`. It follows the same law as Flutter, enforced by the
same kinds of CI gates:

- **Generated brand data only** — `tools/codegen.mjs` emits `BrandData.g.kt`
  + `GoldenFixtures.g.kt`; goldens must stay green on jvm, Android,
  iOS-native, js AND wasm (`tokens.resolved.json` per role + the 4 reference
  brandprints, exactly like the Dart port).
- **No literals** in `odyssey-compose-ui/src/commonMain/kotlin/ly/neptune/odyssey/ui/components`:
  no `Color(0x…`, no `Color.<Capital>`, no `RoundedCornerShape(<digit>` —
  the CI grep reads raw text, comments included. Read `NeptuneTheme.*`
  accessors instead.
- **Pixel verification** — `./gradlew :gallery:renderShots` is the SHOTS
  analog (headless ImageComposeScene, software Skia): every gallery section ×
  4 brands × light/dark × LTR/RTL, gated by `tools/blank_check.py` in CI.
  Same doctrine: blank = broken, and no fidelity claim without opening the
  PNGs.
- **Glass is Haze-backed** (the one third-party runtime dep): CMP has no
  common backdrop-blur primitive. Haze stays an internal detail of
  `NeptuneGlass` — no Haze type in the public API — and the fallback is a
  denser tint, never transparent.
- **Compose layout trap (bit us on the dock, 0.2.x)**: `Modifier.clip()` is
  NOT Flutter's `InkWell(borderRadius:)` — it clips **all descendant
  drawing**, not just the ripple. Any content that animates past its own
  bounds (the dock's raised-active circle) gets sliced. Fix pattern: put the
  rounded ripple on its own clipped `matchParentSize` layer and keep the
  overshooting content on the unclipped layer above (see `NeptuneDock.kt`).

**Framework adapters** (`packages/neptune_react_ui`, `neptune_vue_ui`,
`neptune_svelte_ui`, `neptune_laravel_ui`) all sit on top of the SAME
framework-agnostic `neptune_web_ui` custom elements — they add framework-
idiomatic ergonomics (typed wrappers, a theme composable, Blade components),
never their own rendering. `neptune_laravel_ui` (R8) is the odd one out
structurally: Composer has no concept of resolving an npm package's built
output, so it vendors a synced copy of `web-ui`'s `dist/` rather than
depending on the npm package directly (`tools/sync-assets.mjs` keeps the two
in sync) — this is *why* it's a real Composer package with PHP + a service
provider, not just another `styles.css` re-export.

## 8 · Client prototype playbook (white-label proof)

**The one-command path (R5, proven end-to-end):**

```sh
node tools/client-demo/generate.mjs --logo <file> --name "Bank Name" \
  --name-ar "الاسم بالعربية" --tone formal --run
```

This shells `extract_colors.py` (PIL — dominant colour extraction, PDF via
`sips`) → converts to OKLCH seeds → picks a `--tone` lever preset → writes
gitignored `client_config.dart`/`client_main.dart` calling
[`NeptuneDemoShellApp`](../packages/neptune_flutter_ui/lib/src/templates/neptune_demo_shell.dart)
(Welcome → 5-tab glass-dock shell, entirely composed from existing templates)
→ builds and launches on macOS. See `tools/client-demo/README.md`.

**The manual path** (when you need finer control than the CLI's `--tone`
presets, or you're building the shell composition itself):

1. Get the client's brand colours (their logo/guidelines carry the hex/CMYK).
2. Convert to OKLCH seeds (`primary`, `tertiary`) → `BrandprintConfig` with
   fitting levers (corner family, fonts, glass tint, motif, motion, tone).
3. `NeptuneTheme.fromConfig(cfg, arabic: …)` — the engine generates the whole
   palette; the identity layer resolves through the `glassTint` lever, so
   custom brands get glass/motif/elevation automatically.
4. Reuse `NeptuneDemoShellApp` (or hand-compose the templates it wraps:
   `NeptuneWelcome` with `lockup:` for the real logo, `NeptuneDashboardTemplate`,
   `NeptuneTransferTemplate`, `NeptuneCardsTemplate`) plus
   `NeptuneOnboardingStatusTemplate`/`NeptuneStatusMotion` for account-opening
   and transfer outcomes.
5. Verify with a SHOTS pass; present live
   (`flutter build macos --target=lib/client_main.dart`).

**Always**: client logos/demos are `**/lib/client_*` / `**/assets/client_*` —
gitignored, never committed, never bundled by `pub publish` (pub bundles
`example/`).

**The desktop GUI path** (`apps/neptune_studio`, R5c): the same generator as
a point-and-click macOS/Windows app — drop a logo, watch live OKLCH seed
extraction, tune tone/dark/Arabic, preview the real `NeptuneWelcome` in a
phone frame, "Generate & run" writes the same `client_config.dart`/
`client_main.dart` pair the CLI writes and shells `flutter build macos`. It's
local dev tooling only (never Mac-App-Store distributed), so its
`Runner.entitlements` have `com.apple.security.app-sandbox = false` — it
needs to shell `flutter build`/`open` and write into a sibling repo
directory, neither of which App Sandbox permits.

**Logo colour profiles**: any image picked from disk (Studio's file picker,
or a future drag-drop) MUST be colour-matched to sRGB before decoding via
`dart:ui`. Design-tool exports are routinely tagged Display P3 on macOS;
`toByteData(rawRgba)` hands back the profile-native bytes as-is, and reading
P3 bytes as sRGB shifts hues badly (see §9). Normalize first:
`sips -m "/System/Library/ColorSync/Profiles/sRGB Profile.icc" in --out out`.

**The sound half of white-label** (`tools/sound-identity`, R7): white-label
isn't just visual. Real bank apps built on Odyssey want their own *sound*
identity too — a distinct notification/success chime family, not the
generic sine chimes in `neptune_sound_kit`. `tools/sound-identity/generate.mjs`
is that generator: pick a melodic `--shape` (`rising-phrase`/`tap-chord`) and
a soundfont `--patch` (or let both auto-pick, collision-checked against
`registry.json`), get 5 FluidSynth-rendered WAVs
(`success`/`general`/`money_in`/`security`/`reminder`) via the same pipeline
proven on two real bank apps (Andalus, Nuran — see
`neptune-mobile/.agent/SOUND_IDENTITY_HANDOFF.md`). **Never converge two
banks' shapes onto the same feel** — that's a deliberate brand-identity
decision the tool exists to make repeatable, not to erase. Preview any new
identity in `preview/listening_room.html` (self-contained, base64-embedded
audio, 64kbps mono — a high-bitrate build of this exact kind of page failed
to load once already) before shipping it anywhere.

## 9 · History — the mistakes, so you don't repeat them

- **`tools/sound-identity`'s MIDI encoder threw on its first real run** —
  `vlq()` is guarded against both negative AND non-integer input (the
  negative guard is ported deliberately from the source pipeline, see R7
  above; the integer guard caught a fresh bug of its own). Shape durations
  computed as `PPQ * 0.18`-style fractions produced non-integer tick values,
  which the integer guard correctly rejected before they could reach
  FluidSynth. Fixed by rounding every tick/duration to an integer at the
  single `note()` choke point rather than trusting each shape's arithmetic
  to land on integers.
- **2.2–2.4: "correctly themed Material" ≠ Odyssey.** ~88 widgets read the M3
  scheme faithfully and still looked generic. The identity layer (gradients,
  glass, motifs, glow, motion) is what makes it Odyssey → shipped in 2.5.0.
  Never declare fidelity from code review alone; render and look.
- `NeptuneToolbar` handed its center slot unbounded width → a SearchField
  blanked an entire section (found only by the full-depth SHOTS sweep, 2.5.2).
- `NeptuneCreditScoreGauge` painted a giant arc outside its bounds inside
  `Expanded` (2.5.2).
- `NeptuneTabs` used `Expanded` in a min-height `Column` → unbounded-height
  crash (2.4.0).
- Narrow-width overflows in `NeptuneAccountTile` / `NeptuneLimitMeter` /
  `NeptuneApprovalItem` (2.4.0) — always test at ≤430dp.
- `google_fonts` throws async in widget tests → `debugSkipFontLoading`.
- A comment containing `Colors.` failed the CI gate — the grep reads raw text.
- macOS `screencapture` triggered endless permission dialogs mid-verification —
  the in-app SHOTS harness replaced it permanently.
- **A Display-P3-tagged logo PNG decoded via `dart:ui` extracted the WRONG
  brand colours** (real FGLB navy `#364680` read back as azure `#00A0E0`,
  red `#EE4037` as green `#40C880`) — `toByteData(rawRgba)` doesn't convert
  profiled pixel data to sRGB, it returns the profile-native bytes verbatim.
  Caught by comparing Studio's live-extracted swatch against the logo's own
  printed hex spec, not by unit tests (the extractor's own tests use
  synthetic sRGB pixel arrays, which never exercise a codec's colour-space
  handling). Fixed by `sips -m` normalizing to sRGB before decode (R5c).
  Any future pixel-sampling-from-a-real-image code path needs this same
  normalization — it's not specific to Studio.

---
© 2026 Neptune.Fintech (neptune.ly). Keep this file honest: when you learn a
new rule the hard way, add it here in the same commit as the fix.

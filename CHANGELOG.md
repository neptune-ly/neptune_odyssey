# Changelog

## 2.33.0

- **`NeptuneAccountTile` takes a `ruled` override.** The tile decides between a tonal slab and a
  hairline-ruled row off `NptIdentity.ruledRegister`, and that is still its default. But that one
  flag carries a second, unrelated decision — it is also what squares the app's buttons out of
  their stadium — so a brand whose LISTS are ruled and whose BUTTONS are capsules had no way to
  say so. Two decisions on one bit is a collision, not a lever. `ruled: null` keeps the theme read,
  so no existing caller and no shipped brand moves; the host states the list half explicitly where
  it has to. The flags byte has no room for a second bit without a codec format bump, which is a
  wire change and needs agreeing rather than editing in.

- **And the ruled treatment is now an actual RULE.** It drew a hairline BORDER around the row with
  the fill removed, and an outlined box is still a box: eight of them down a page is eight objects
  where there is one list. The leading chip was the same failure one level down — an outlined
  square is a slab with its fill taken out. Ruled rows now carry no border, no corner and no fill,
  set the mark bare in the slot the chip occupied, and are separated by the hairline BETWEEN them,
  run to both edges. No shipped brand sets `ruledRegister`, so nothing in the wild moves.

- **`NeptuneQuickActions` takes `accentLead`.** The `rule-grid` shell marks the first action in the
  brand's reserved accent, which is right on a home screen — the lead verb is the forward motion
  and a brand that rations one colour per screen spends it there. It is wrong on a screen that has
  already spent it: a card page draws the card, and on a brand whose mark is a red arrow the card
  IS the spend, so the row put a second red object on the same screen from inside the component
  that exists to honour the rule. The host knows which screen it is on; the component cannot.
  Defaults true, so nothing shipped moves.
- **Quick-action peers stop reading as disabled.** The three peer verbs were drawn on the neutral
  ramp's tonal step, which measures within 2-30/255 of the colour this app paints a control it has
  switched OFF — a customer reading three of four verbs as unavailable was reading the screen
  correctly. The peers now keep the brand's own ink at full strength and the lead is told apart by
  FORM, not by the peers being dimmed.

- **The lead tile's glow is gone.** At ~30% brand colour, blur ~18, offset ~7 it rendered as a
  hard-edged offset duplicate of the tile in a washed tint rather than as elevation — a pale slab
  protruding below the most prominent control on the screen. The hierarchy never depended on it:
  the lead is the only FILLED tile on a row of keylines.

- **The register strip draws the page's own ink, not the neutral ramp's grey.** Its divider and
  its two edges were `outlineVariant`, so on a bank that forbids grey slabs four cells read as an
  unstyled table boxed in grey. One function at all three call sites, because the divider and the
  two edges are one decision.

## 2.32.0

- **Each bank draws its own icon set, and the difference between them is a table rather than a
  pile of drawings.** `packages/neptune_icons/src/profiles.ts` declares the three banks on seven
  levers — stroke weight, cap, join, miter limit, optical scale, corner-radius multiplier and
  coordinate grid — plus whether the bank has a filled active state at all. `iconSvg(name, {
  profile })` renders through one. There is **no default**: `iconProfile("sahara")` throws rather
  than quietly handing back Andalus's weight, which is the same rule the Flutter asset roots
  follow and for the same reason.

  * **Andalus** — stroke 1.25, round terminals, corners ×1.40, and the only bank with a filled
    cut for the selected state. 1.25 is not a number chosen for it: its existing 129-file set
    measured 1.25 on 60 files against eight other values, and outline on 88 against 30 filled.
    The majority is the rule; the set was brought onto it rather than redesigned.
  * **Nuran** — stroke 1.00, **butt** terminals, corners ×0.00, drawn at 0.88 of the box with
    every coordinate snapped to a 0.25 grid. Marks in a ledger. No filled state, because the nav
    pill already carries selection and a second signal for one fact is two things arguing.
  * **FGLB** — stroke 1.60, **square** terminals, corners ×0.65, full-frame and right-angled.
    Nothing in the set names a colour, so the bank's one red spend per screen is never taken by
    an icon.

- **`bank-sets/` writes the Flutter apps' three asset roots from one roster.** 136 declared names,
  each recording what it is, where it came from, which banks carry it and whether it mirrors in
  RTL. `test/profiles.test.ts` parses `emit.py` and fails if its table and `profiles.ts` drift —
  a bank must not be one weight on the phone and another on the web.

- **Two bugs the generator had to be taught, both of which shipped broken glyphs before they were
  found.** A dot written as a zero-length subpath (`M12 17h.01`) renders only under a *round* cap,
  so Nuran's warning triangle had no `!` in it at all; the idiom is now rewritten to an explicit
  circle before any profile is applied. And **arc flags are single characters** — `a5 5 0 014-2`
  is legal SVG, a naive tokeniser reads `014` as one number, and five glyphs came out with two of
  seven arc arguments missing and would not parse.

- **Licences recorded.** Lucide 1.45.0 (ISC, with an MIT Feather-derived subset) and Tabler Icons
  3.46.0 (MIT), in `packages/neptune_icons/LICENSES.md`. Brand marks stay third-party trademarks:
  carried verbatim, never restyled to a profile, and only by the banks that have that partner.

## 2.31.2

- **`2.31.1` traded a truncated balance at 2.0x for a shredded account name at 1.0x. This is the
  correction; do not ship `2.31.1`.** Repinning the app moved 80 goldens, and they split cleanly:
  64 at a 0.28–0.78% pixel delta were the intended change (the balance sliding to the row's end
  edge), and 16 at 19–62% were a regression.

  **What went wrong, measured.** `2.31.1` made the balance a non-flex `Row` child so it would be
  laid out first and keep its natural width — which was the right half of the fix, and is why those
  64 goldens moved correctly. But it gave that claim no ceiling. A real balance of `14,678,363.00`
  measures **235.9dp of a 358dp row**, leaving the `Expanded` name column **18.1dp**; a masked
  account number is one unbreakable token, so it wrapped to a character per line and the tile went
  **76dp → 284dp**. A row became a tower. The knock-on is the part worth remembering: those extra
  208dp pushed a "confirm purchase" CTA out of a lazy `ListView`'s build window, so four goldens in
  an unrelated flow silently rendered the wrong screen **and still passed**.

  * **The balance keeps its non-flex, measured-first placement** — unchanged from `2.31.1`, and
    every 1.0x rendering of a balance that fits is byte-identical to it.
  * **It now has a ceiling of 0.58 of the contested measure**, and both edges of that number are
    measured rather than chosen: a realistic long balance (`LYD 1,234,567.890`, ~162dp of a 286dp
    measure) must clear it at full size, which puts the floor at 0.568; and the 42% left to the
    name column must still seat a masked number on one line, which needs ~112dp and puts the
    ceiling under 0.610.
  * **Over that ceiling the figure is scaled down, never wrapped and never ellipsized** —
    `FittedBox(fit: BoxFit.scaleDown)`, one line, at both text sizes. Shrinking a figure is bad for
    low vision; dropping its digits is worse; and a balance running one digit per line is worse
    than both.
  * **The masked number now carries `maxLines: 1`**, so the tower is impossible by construction and
    not merely unlikely at the current ceiling. Ellipsis is safe there in a way it never is on a
    balance: those digits are already redacted, and the semantics label speaks the number in full.
  * The 2.0x reflow from `2.31.1` is unchanged.

  Two test files now pull against each other on purpose, and both must stay green:
  `account_tile_large_text_test.dart` (13 cases, all fail at `2.31.0`) and
  `account_tile_wide_balance_test.dart` (7 cases, all fail at `2.31.1`). Widening the balance's
  claim until the second passes re-truncates the first.

## 2.31.1

- **`NeptuneAccountTile` dropped the digits off a balance at large text, on the screen that
  decides a transfer.** At 2.0x text scale `1,000.000` rendered as `1,000.` — a customer using
  large text could read a number the account does not hold, in all three production brands and in
  both languages. The widget's semantics were already correct; this was purely layout, and nothing
  about the spoken form, the `minHeight: 64` floor or the ruled/slab registers changed.

  The cause was a flex contest the balance had no way to win. The name column was an `Expanded`
  and the balance a `Flexible` of the same weight, so the two split the row down the middle and the
  balance was ellipsized against a half it had no claim on — while the row still had room the name
  column was not using.

  * **The balance is now measured first, at its own width, and the name column takes what is
    left.** The balance is a plain, non-flex child; `Expanded` on the name column consumes the
    remainder. A truncated account NAME is recoverable from the masked number beside it; a
    truncated BALANCE is a different figure on a transfer screen.
  * **`maxLines: 1` and `TextOverflow.ellipsis` are gone from the balance.** A money figure has no
    safe truncation point.
  * **Above `textScaler.scale(14) > 20` the balance reflows UNDER the name column** instead of
    competing with it for the same line. `minHeight: 64` was already a floor, so the row grows.

  **This moves the 1.0x rendering, by design, in one way:** the balance now sits flush at the row's
  end edge and the name column gains that measure (about 55dp on a 390dp-wide tile), where before
  the balance floated short of the edge at half the free width. That is the placement the
  component's own documentation already described ("the tabular balance at the end edge"). Hosts
  carrying pixel goldens of an account row should expect them to move by that amount and no other.

  One residual is recorded rather than papered over: in the narrow band between 1.2x and the
  large-text step, a balance of roughly twenty characters or more can now overflow the row instead
  of ellipsizing. Capping it again would re-shrink realistic long balances (`LYD 1,234,567.890`)
  that this change keeps at full size, so the cap was not reinstated.

## 2.31.0

- **The two design lines are one again, and `drift-depth` moved from login-shell index 6 to 7.**
  `design/fglb-wallet` (the POCKET composition) and `design/nuran-ink` (the INK composition) forked
  from the same commit and were strictly disjoint in both directions, so neither pin could compile
  the other bank and the app could not ship either one. They are merged here. Nothing from either
  side was dropped: `NeptunePocketBalance`, `NeptuneDriftCanvas`, `NeptuneSpotArt`,
  `NeptuneCardFlip`, `NptSpotArtKind` and `warmGround` arrive beside `NeptuneDriftField`,
  `NptBrandScheme`, `NptBrandCanvas.deep`, `NeptuneAmountStage`, `NeptuneDockShell.inkPill` and
  `BrandprintConfig.amountFirstTransfer`.

  **The one real collision was an ordinal.** Both lines appended a seventh entry at index 6 of
  `kLoginShells`: FGLB's `pocket-drift` and Nuran's `drift-depth`. An index in that registry IS the
  wire format, so the two could not both be 6. **`pocket-drift` keeps index 6; `drift-depth` is now
  index 7.**

  Why that is safe, stated plainly rather than assumed:

  * `kLoginShells` is encoded as a **whole byte** (`buf[o++] = _ix(kLoginShells, cfg.loginShell)`),
    not as a packed field. Indices 6 and 7 both fit with 248 slots still free, so the payload did
    **not** have to grow and no string changes length.
  * **No brandprint in customers' hands encodes index 6.** The three production strings decode to
    login shells 0 (`depth-emblem`, Andalus), 4 (`paper-lockup`) and 5 (`lockup-rule`), and all
    three are 28-byte version-1 payloads with no extension byte at all. The renumber therefore
    repoints nothing that was ever issued, and every production string encodes to the same bytes
    after this release as before it — asserted by test, byte for byte, for all three.
  * FGLB kept 6 because its line is the larger divergence and carries the published 2.30.x
    numbering, so leaving it alone is the cheaper side.

  **The one thing that DOES break:** a brandprint string minted from a **pre-merge
  `design/nuran-ink` build** carries byte 6 for its login shell and will now decode as
  `pocket-drift`, not `drift-depth` — silently, because the byte is still valid. That build produced
  one artifact and it was never distributed. Any such string must be re-minted against 2.31.0.

- **The extension byte needed no arbitration.** FGLB took bit 2 (`warmGround`) knowing Nuran held
  bit 1 (`amountFirstTransfer`); both are kept exactly where they were authored, and bits 3-7 remain
  free. `kNavShells` is likewise untouched by the merge — `ink-pill` keeps index 3, which is the
  last slot in that two-bit field.

- **Version.** 2.31.0, not 2.30.2: this release adds new capability from both sides, so it is a
  minor bump.

## 2.29.0

- **A brand may hand Odyssey its finished `ColorScheme` (`NptBrandScheme`).** The v1 ramp reads only
  hue and chroma off a seed and pins every role's LIGHTNESS to a constant — `_light['primary']` is
  `_Recipe(0.48, ...)` whatever it is given. So a bank whose primary is a deep navy could not be
  seeded into existence: Nuran's `#114075` (L 0.372) came back a mid blue, and no amount of tuning
  was going to change that, because the seed's `l` is discarded on the way in. That is fine for a
  brand being designed inside Odyssey and wrong for one that has already shipped — a palette in
  customers' hands is a fact, not a starting point, and "close enough" is the wrong standard for a
  colour someone has been looking at for a year. Pass `scheme:` to `fromConfig` / `fromBrandprint`
  and the Material roles come from the brand verbatim; pass nothing and the generated path runs
  byte for byte as before (asserted). It costs **no byte, no flag bit and no registry slot** — this
  is theme construction, not a wire change, and the brandprint still carries the seeds that the web
  and Studio ports build from. Both brightnesses are required, because a brand supplying one would
  silently fall back to the ramp at the other, which is the inversion bug `NptBrandCanvas` exists to
  prevent. On this path the card gradient travels `primary -> secondary`, never `-> tertiary`: a
  shipped scheme's `tertiary` is a free accent role and one real bank's is a 12%-alpha grey, which
  as a gradient stop is a translucent smudge.

- **`NptBrandCanvas.deep` — the brand's ground with a below.** A card's gradient starts at the
  brand's primary and `canvas` IS the brand's primary, so the moment a scene puts a real card face
  on the brand ground the card *is* the ground and vanishes. Every brand hits it, because both
  values come from the same role by design. `deep` is the canvas carried 70% toward the scheme's own
  `scrim` — a lerp to black moves lightness only, so it stays unmistakably the bank's colour rather
  than a second invented navy, and it is fixed across brightness like everything else on this class.
  It deliberately does NOT promise 3:1 against that card: for a brand whose primary is already dark
  the ratio asymptotes below 2:1 at any lerp, and reaching for a lighter ground to "fix" that would
  mean inventing a colour the bank does not own. A dark object on a dark ground reads by its edge
  and its shadow; the role owes a ground that is unmistakably behind it and one near-white ink can
  still be set on (18.6:1 measured).

- **`NeptuneDriftField` — the pre-login moment as a scene rather than a lockup.** Objects suspended
  at different depths in a brand's own ground, drifting on an ambient clock and answering a drag
  with parallax. Depth is one number per object and it drives THREE things at once — scale, travel
  distance and how far the object is carried toward the ground colour — because any one of them
  alone reads as a sticker sliding about and together they read as space. It is deliberately not
  blurred: an `ImageFiltered` per object is a full-screen blur per object per frame, and on a 120Hz
  display that is the difference between a scene that floats and one that stutters. Under reduced
  motion every object still renders at its resting position, scale and tilt — the composition is
  complete and simply still, never an empty ground. Decorative objects are `ExcludeSemantics`, so a
  screen reader moves from the headline to the button instead of stopping on five anonymous images.

- **`NeptuneAmountStage` + `NeptuneStageKeypad` — the amount as the screen.** No container: no box,
  no ring, no underline, no placeholder frame. The figure steps DOWN a ladder as digits arrive
  rather than scaling continuously, because a continuously-scaled numeral has a different stroke
  weight at every size and money that gets lighter as it gets larger reads as a rendering fault; it
  is set in tabular figures so the number does not jitter sideways as it is typed, and the currency
  sits on the figure's own baseline rather than centred against its box, where it would read as a
  superscript. The keypad has **no keys** — no fills, no separators, no grid — so the two things a
  drawn key really provides are provided another way: the target is the whole cell (60dp, clear of
  the 44pt floor) and the press is confirmed by a tonal bloom plus the brand's own haptic weight.
  The grid is NOT mirrored under RTL, because a keypad is a physical object customers have muscle
  memory for and no Arabic keypad mirrors; the backspace IS mirrored, because it is an arrow.
  `NeptuneAmountKeypad` stays exactly as it was and is still the right one when the amount is a
  value on a form — both widgets now say which case they are for.

- **`BrandprintConfig.amountFirstTransfer` — extension byte, bit 1.** Whether a transfer on this
  brand starts with the AMOUNT (a full-bleed figure and a keypad, rail chosen afterwards) or with
  the rail list, amount inside the rail's own form. It is a lever rather than a redesign of the
  shared screen because the order those two questions are asked in is a brand decision: a bank
  whose identity is a list of correspondent services reads worse amount-first, and a bank whose
  argument is that sending money is one gesture reads worse rail-first. Both orders funnel into the
  same rail forms, the same validation and the same confirm path. False for every string issued
  before this release, so nothing already in the wild changes. Bit 0 (`ruledRegister`) is
  undisturbed and both are round-tripped together in `drift_and_stage_test.dart`.

- **`NeptuneAmountStage` groups the integer part as it is typed.** An ungrouped seven-digit figure
  is the one number on an amount screen a customer cannot check at a glance, and "is that two
  hundred thousand or two million" should never be a question you count digits to answer. It is a
  DISPLAY transform only — the host's value stays plain digits, so nothing downstream has to strip
  a separator back out, and a screen reader still hears the figure rather than the punctuation.

- **`NeptuneDockShell.inkPill` — a solid stadium of the brand's ink, floating over the content.**
  Not `raised` in another colour: `raised` is glass, so it borrows the page and recedes, and it
  marks the active item by lifting a circle OUT of the bar; this is opaque, so it is the darkest
  object on a pale page and advances, and it marks the active item with a lozenge INSIDE its own
  outline. It fills from `NptBrandCanvas.canvas`, so it is the bank's real colour at both
  brightnesses instead of a light tone at night, and the label is painted for the active item only
  while every label is still announced.

- Registry appends, no flag bit claimed and no existing index moved, so every brandprint already in
  the wild encodes and decodes unchanged:

      kLoginShells += 'drift-depth'   index 6 of a full byte    free
                                      (moved to index 7 in 2.31.0 — see above)
      kNavShells   += 'ink-pill'      index 3 - THE LAST SLOT

  `kNavShells` is two bits and is now full at four values. A fifth navigation shell needs a format
  bump rather than another line in that list — the 29-byte form's extension byte has bits 1-7 free,
  so the bump is available, but it is a wire change and must be agreed, not taken.

All notable changes to Neptune Odyssey are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com); the system follows [Semantic Versioning](https://semver.org) against the token layer (see `docs/09-governance-and-versioning.md`).

## [Unreleased]

### Added
- **The glance subset, emitted for native surfaces.** A Lock Screen Live Activity, a Dynamic
  Island and an ongoing Android notification are drawn by the operating system from a widget
  extension or a RemoteViews layout, and neither can import `neptune_flutter_ui` or
  `neptune_kmp_ui` - so every native glance surface in a Neptune app was styled from
  imagination (`.orange`, `.green`, `.red`). `tools/codegen.mjs` now also emits
  `packages/neptune_tokens/generated/native/swift/OdysseyGlanceTokens.swift` and
  `.../android/values{,-night}/odyssey_glance_tokens.xml`: primary, success, error and the
  neutrals they sit on, per reference brand, light and dark, resolved through the same OKLCH
  math as every other output and gated by `codegen:check`. Apps vendor the file verbatim and
  keep the header; the first consumer is the Neptune mobile transfer-in-flight surface.

## [2.21.2] — 2026-09-05

### Fixed
- **Every directional arrow in the system pointed backwards in RTL.** `NeptuneCta`'s trailing
  arrow, `NeptuneBreadcrumbs`' separator and `NeptunePager`'s Previous/Next each chose the
  opposite Material glyph under RTL — but `arrow_forward_rounded`, `arrow_back_rounded`,
  `chevron_left_rounded` and `chevron_right_rounded` all carry `matchTextDirection: true`, so
  `Icon` was already mirroring them. Two mirrors cancel, and the CTA on every screen of an
  Arabic app drew a right-pointing arrow. Each site now names the forward glyph once and lets
  the framework do the mirroring. The nudge translation and the sheen sweep still key off
  `Directionality` explicitly, because `Transform` is not direction-aware.

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

### Added
- **`@neptune.fintech/icons` 2.4.2 → 2.5.0** — 19 new icons (94 total, up from 75): directional completeness (`chevron-up`, `chevron-left`, `arrow-up`, `arrow-down` — previously only one direction of each existed), fintech-specific (`dispute`, `refund`, `otp`, `goal`, `id-card`, `shopping-bag`, `category-tag`), and common UI (`edit`, `trash`, `refresh`, `star`, `link`, `camera`, `chat`, `globe`). All hand-authored on the same 24px/stroke-1.8/round-cap grid as the existing set.

### Fixed
- **Mastercard's mark had an opaque black background instead of transparent.** Traced to the source file (from a production Libyan app, previously trusted as "real = correct"): 6 of its 9 `<path>` elements were solid black fill covering most of the canvas — invisible against that app's own dark chip background, but opaque and wrong on Neptune's light site. Replaced with a clean Wikimedia Commons reproduction (correct official red `#EB001B` / yellow `#F79E1B` / overlap `#FF5A00`, genuinely transparent, includes the modern lowercase wordmark).
- **LyPay and OnePay were showing the wrong colours/content, not just placeholders.** LyPay's asset (trusted as real since an earlier session) turned out to be a Figma luminance-mask export whose color-carrying rect had been flattened to flat black — it was rendering the correct swoosh *shape* but solid black instead of LyPay's real green→blue gradient, with no wordmark. Replaced with the actual asset from `lypay.gov.ly` (the Central Bank of Libya's own LyPay site), which has the correct `#A4CE39`→`#17A3DD` gradient and the "LYPAY" wordmark. OnePay's placeholder was a generic blue-circle-plus-text approximation; replaced with the real "وان باي" mark (a stylised ribbon "1" + Arabic wordmark), sourced from `dpay.ly`'s own accepted-payment-methods logo set.
- **Amex and Discover were hand-drawn approximations.** Replaced with each brand's real mark: Amex's current flat-blue (2018 rebrand — the Wikimedia file needed a `viewBox` added, since it only carried the pre-rendered pixel width/height and cropped without one) and Discover's real wordmark + gradient circle, both via Wikimedia Commons.
- **UnionPay, PayPal, Mada, Moamalat, Tadawul were also placeholders** — continued the same real-asset sweep: UnionPay/PayPal/Mada from Wikimedia Commons; Moamalat's real gold-ribbon "M" mark from `moamalat.net` directly; Tadawul Tech's real teal/blue mark from `tadawul.ly`. Only MoneyGram remains a placeholder (no official asset found anywhere).
- **Inconsistent brand-mark sizing** — every mark was sized to a fixed HEIGHT with width left to its own native aspect ratio, so wordmark-shaped logos (Western Union, SWIFT) rendered much wider/heavier than icon-shaped ones (Mastercard, NUMO) at the same nominal size. Fixed by fitting every mark into the SAME fixed-footprint box (CSS `width/height:100%` on the `<svg>`, which overrides the library's own presentation attributes and lets the default `preserveAspectRatio="xMidYMid meet"` contain-and-centre each logo identically) — sizes are now genuinely comparable across brands.
- **`site/icons.html` brand-mark grid — 7 more real official assets, one real bug.** Following the same pattern as Western Union/LyPay (real licensed artwork loaded at runtime via `registerBrandMark`, never bundled into the public npm package):
  - **NUMO** — was a fabricated navy badge; NCB/Jumhouria-Bank-issued cards actually carry Moamalat's real three-overlapping-rings mark (confirmed against `ncb.ly`). Now the real ring geometry (matching a production Libyan app's asset), recoloured navy/gold to read on a light background.
  - **Mastercard** — swapped the hand-drawn placeholder for the real mark from a production Libyan deployment.
  - **Visa** — two passes. First swapped in a "real" file from the same Libyan deployment, but that file turned out to be a badly-cropped knockout (letters clipped by its own frame) — replaced again with Visa's actual current flat-blue 2021 rebrand mark (Wikimedia Commons), which also isn't a white-only knockout so needs no backing rect.
  - **Sadad** — corrected a real mistake: Sadad and Almadar are related (Sadad is Almadar's mobile-payment service) but **visually distinct brands** — Sadad has its own orange/gold circular app icon, not Almadar's green globe. First pass wrongly combined the Almadar globe with a سداد wordmark; fixed by sourcing Sadad's actual app icon (Google Play listing for `ly.almadar.sadad`) instead.
  - **Google Pay, Apple Pay, SWIFT** — replaced hand-drawn approximations with each brand's real official mark (Google Pay/Apple Pay/SWIFT-2023 logos, sourced from Wikimedia Commons' standard reproductions).
  - **Still placeholders — no official asset found anywhere:** MoneyGram, OnePay Libya (وان باي). Same one-line `registerBrandMarksFromUrls` wiring once a real file exists.
  - **Sizing** — the dedicated brand-marks showcase was fixed at a 26px render height regardless of context; added its own Size control (16/20/24/32, default 20 — down from 26) so mobile-appropriate small sizes are directly previewable, matching the pattern the main icon-library grid already used.
  - **Real logos leaking into the monochrome icon-library grid, looking broken.** The combined "Neptune icon library" grid up top renders every glyph — icons and brand marks alike — as a single flat `currentColor` shape so the Ink/Primary/Tertiary/Coral buttons recolour the whole grid uniformly. A real trademark (Visa's actual blue, Mastercard's red/orange circles, Western Union's yellow, …) can't be forced into that without looking broken and without violating the brand's own colour guidelines — but the moment a name got a real `registerBrandMark` override, `brandMarkSvg(name, {variant:'mono'})` started returning that full-colour override regardless of the requested variant (registering a single SVG fills the color/mono/outline slots identically), so those marks showed up full-colour in what's supposed to be a uniform monochrome grid. Fixed by excluding any brand with a real registered asset from that grid entirely — they now appear ONLY in their real colours, in the dedicated "Payment & fintech brands" section below (which already had an explicit Colour/Mono/Outline choice and a trademark disclaimer). Glyph count dropped from 97 to 88 accordingly.
- **`@neptune.fintech/web-ui` 2.5.0 → 2.5.1 — `<npt-top-app-bar>`'s `medium`/`large` variants had no accessible title at all.** Flagged during the R9 component audit but not yet fixed until now. The bar renders two headings — a small `<h1>` (the normal-size title row) and a large `<h2>` (the big M3 headline shown only in `medium`/`large`). The `<h2>` was correctly `aria-hidden` (it's a duplicate, decorative echo of the same text), but the `<h1>` was hidden via `visibility: hidden` — which most browsers also drop from the accessibility tree, leaving screen-reader users with **no page title announced at all** in those two variants. Fixed by hiding the `<h1>` with a standard visually-hidden-but-accessible clip technique instead, so it stays in the a11y tree as the bar's name while the `<h2>` remains its purely visual stand-in. No visual change in any variant. Re-synced into `neptune_laravel_ui`'s vendored assets.
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

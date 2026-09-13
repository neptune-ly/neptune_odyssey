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
      kNavShells   += 'ink-pill'      index 3 - THE LAST SLOT

  `kNavShells` is two bits and is now full at four values. A fifth navigation shell needs a format
  bump rather than another line in that list — the 29-byte form's extension byte has bits 1-7 free,
  so the bump is available, but it is a wire change and must be agreed, not taken.

## 2.28.0

- **Two more composition levers: `navShell` and `actionRow`.** The lesson of 2.24.0 was that hue is
  not identity, composition is — and it was only half-applied. A brand could pick its own pre-login
  shell and its own dashboard hero, and then every white-label bank wore the SAME bar underneath:
  the floating glass pill with the raised circular active button, which is one bank's signature, not
  a neutral default. Same for the home quick actions, where a pale `secondaryContainer` circle sat
  behind every glyph on every brand and said nothing about any of them. A greyscale screenshot of
  two banks' chrome was indistinguishable. Now:
  - `NeptuneDock(shell:)` — `NeptuneDockShell.raised` (the floating glass pill, unchanged and still
    the default), `.register` (a flat, full-width bar on one `outlineVariant` hairline: no pill, no
    float, no fill, the active item marked by weight and the brand colour so it survives greyscale)
    and `.rule` (a full-width bar under a rule, the active item claiming its segment of that rule in
    `NptColors.accent` — structure drawn in lines, and the accent used as direction, its one job).
  - `NeptuneQuickActions(shell:)` — `.filledCircles` (the tonal chip, unchanged and the default),
    `.registerRows` (no chip: one strip ruled top and bottom, actions divided by hairlines) and
    `.ruleGrid` (a hairline cell per action, the FIRST action — the one that moves the customer
    forward — carrying the accent). The row publishes the shell to its children through an inherited
    scope, so a host still hands over a plain `List<NeptuneQuickAction>`.
  - The levers are data: `kNavShells` / `kActionRows` in the codec, `NptIdentity.navShell` /
    `.actionRow` on the theme. **The 28-byte wire layout had no spare byte**, so both ride the free
    high nibble of the flags byte, two bits each — index 0 on both is exactly today's composition,
    so every brandprint already in the wild encodes and decodes byte-identically. Two bits means
    FOUR entries max per registry; a fifth shell needs a format bump, not a list entry.
  - A widget never reads the lever string itself. The host parses its brandprint's lever once, at
    one place, and passes the enum — so a lever name no template exists for fails at the host's
    parse instead of silently drawing the default (the "capability that gates nothing" bug).
  - **A flat bar eats the bottom safe area inside its own fill.** The floating dock is inset by the
    host, so the obvious thing was to let the host pad the flat bars too — and that leaves a
    transparent strip under a bar the page scrolls behind (`extendBody: true`). On a gesture-nav
    handset the first thing to slide into it was a transaction divider, drawing a stray hairline
    beside the home pill. The inset belongs inside `Container(color: surface)`, so it lives in
    `.register` / `.rule` rather than in every host that adopts them.
- **The ruled register: `ruledRegister`, and the payload that had to grow to hold it.** The white
  register landed in 2.25.0 and reached the page ground and the field fill — and then stopped. Every
  surface a customer actually looks at on a signed-in screen was still a tone-filled slab, so a bank
  could declare the white, structural register and still ship its sibling's cards. `ruledRegister`
  finishes it: buttons are ruled rectangles at the brand's **own `md` corner** instead of stadium
  pills, and the grouped surfaces — `NeptuneListTile`, `NeptuneAccountTile`, `NeptuneDetailList` —
  are hairline-ruled groups **on** the page instead of tone-filled cards floating on it.
  - The button half is genuinely not derivable from `corners`. Flutter clamps a radius to half the
    height, so 44 (a round brand) and 28 (a square one) both resolve to the same pill on a 52dp
    button: the corner family cannot express the distinction. That is how six declared numbers
    reached cards, sheets, fields and chips and stopped at the one component a customer touches on
    every screen. So it is **declared, not inferred** — the same rule that made `motif` its own
    lever in 2.24.0 rather than a thing read off `glassTint`. Deriving it from `whiteGround` would
    have been one line and would have taken the choice away from the two banks that want the white
    ground and keep their cards.
  - **`ruledRegister` and `navShell` were authored against the same bit.** Two design branches each
    claimed flags bit 4, independently, because the flags byte looked like it still had room and
    then did not: bits 0-3 are the existing booleans, bits 4-7 are the two registries above, byte 26
    is the motif. No spare bit, no spare byte. The resolution is **not** to cram — a bit that means
    two things is a bug with a scheduled delivery date — but to do what 2.24.0 did when it claimed
    the reserved byte, only one step further: **grow the payload.**
  - **28 bytes (version byte `1`) or 29 bytes (version byte `2`).** The 29-byte layout keeps bytes
    0-26 exactly as they are, adds an **extension flags** byte at 27 (bit 0 `ruledRegister`, bits
    1-7 reserved and written `0`), and moves the checksum to byte 28 — it is always the last byte.
    `encode` emits the long form **only when the extension byte would carry something**, so a config
    that sets no extension flag produces the identical 28 bytes it produced in 2.27.0. The version
    byte and the length must **agree**, so a truncated or padded payload is rejected rather than
    decoding as a plausible neighbour. The `NO1-` prefix does not move: it is the codec family, and
    `NO2-` stays reserved for a genuinely breaking change (a reordered or removed registry). Growth
    that leaves old strings decoding unchanged is a version byte, not a new prefix.
  - **Proven on the banks, not on a synthetic.** `test/brandprint_production_test.dart` carries the
    three brandprints that are actually in production — Andalus, Nuran, FGLB — copied from the app's
    `lib/core/brand/brandprints.dart`, alongside the exact strings a worktree at tag `v2.27.0`
    encodes them to. It asserts byte-identical re-encoding, a 28-byte payload on version byte 1, a
    decode that returns every lever including the 2.28.0 ones at their index-0 defaults, and
    `encode(decode(x)) == x`. A value this tree produced could not have proved this tree did not
    shift it, which is why the expected strings come from the old tag.
  - Mirrored in the TypeScript reference (`neptune_tokens` `registries.ts` / `codec.ts`) **and** in
    `tools/brandprint.reference.js`, which had silently drifted three releases: it never learned
    `whiteGround` (2.25.0) or the 2.28.0 nibble, and `neptune_tokens`' golden suite had been failing
    four parity assertions against it. The vendored copy the test loads
    (`packages/neptune_tokens/assets/brandprint.reference.cjs`) is synced in the same change, and
    that suite is green again: **75 pass, 0 fail** (was 61 pass, 4 fail).
  - **The KMP port is NOT updated, for either half of this release.** `Brandprint.kt` still reads a
    28-byte payload only: it ignores the flags high nibble and knows nothing about the extension
    byte, so a Compose host decodes `raised-dock` / `filled-circles` / `ruledRegister: false` and —
    worse — **throws `bad length` on a 29-byte brandprint** rather than degrading to the defaults.
    That is safe for the three banks in production, none of which sets an extension flag, but it
    means a brandprint carrying the ruled register cannot be read by a Compose host at all. Naming
    it here rather than letting it drift silently; it is the next port's first task.

## 2.27.0

- **Accessibility: the widget set speaks.** 2.23.0 shipped `Semantics` in two of twenty-seven
  widget files; a blind customer met unnamed tap targets, colour-only states and amounts spelled
  digit by digit. This release adds one contract and threads it through every widget:
  - `NeptuneAccessibility` + `NeptuneA11yStrings` (`theme/accessibility.dart`). The library has
    no l10n layer, so every word a screen reader hears from a widget - credit, debit, balance,
    loading, digit 3 of 6, valid IBAN - comes from the HOST through this inherited widget, with an
    English fallback when none is mounted. A bank whose customers speak Arabic must mount it above
    the navigator or they hear English mid-screen. `money(amount, currency)` and `currencyName`
    are the spoken-money hooks: the visual stays tabular, the label says "12,480.500 Libyan
    dinars". `maskedNumber()` turns "•••• 4821" into "ending in 4 8 2 1".
  - Roles and states. `NeptuneCta`, `NeptuneQuickAction`, `NeptuneAccountTile`,
    `NeptuneTransactionRow`, `NeptuneMethodRow`, `NeptuneBeneficiaryTile`, `NeptuneListTile`,
    `NeptuneDateField`, `NeptuneMenu`'s anchor, the keypad tiles, pagination, breadcrumbs and
    accordion headers were `InkWell`s with no button role - now named buttons. Dock items, tabs,
    segments, page pills, rating stars, beneficiary tiles carry `selected`; accordion `expanded`;
    the freeze control `toggled`; method rows and radio tiles `inMutuallyExclusiveGroup`.
  - One stop per row. Account tile, transaction row, balance card, receipt rows, transfer-review
    rows and total, stat card, checkbox tile, radio tile and beneficiary tile merge their fragments
    into one label with `excludeSemantics`, so a row is heard once, whole.
  - Live regions. Toast, alert, banner, the outcome motion (success / rejected was PAINTED and
    silent), skeletons and loaders ("loading"), field errors, the IBAN verdict, the stepper, the
    balance card and `NeptuneStateSwitcher`'s error/empty faces announce themselves.
  - Busy buttons keep their name: `NeptuneButton`/`NeptunePrimaryButton` with `busy: true` were
    an anonymous "button, disabled"; now "Confirm, loading".
  - Fields: an outer `Semantics(label:)` merges INTO a `TextField`'s node (verified against the
    framework), so `NeptuneTextField`, `NeptuneSelect`, `NeptuneAmountInput`,
    `NeptuneCurrencyField`, `NeptuneIbanField`, `NeptuneSearchField` and every OTP cell are named
    edit boxes; errors carry `validationResult`.
  - Never colour alone: `NeptuneTransactionRow` shows a "+"/"-" sign (`showSign`, default on) and
    says credit/debit; `NeptuneAlert` speaks its tone first; `NeptuneStatCard` says up/down.
  - Targets: `NeptuneTag` remove (was ~18dp), pagination arrows and pills (40), segments (40),
    breadcrumbs, `NeptuneInsightCard` action (40, shrinkWrap) are 48dp.
  - Reduced motion: dock, tabs, accordion, toast, checkbox, radio, switch, segment, CTA press
    scale and the state switcher collapse to `Duration.zero` under
    `MediaQuery.disableAnimations` - the END STATE is shown, never nothing.
  - Fixed: `NeptuneCheckbox`/`NeptuneSwitch` passed the VALUE as `enabled:`; a checked, disabled
    control read as enabled.
  - Localised what was hardcoded English: stepper tooltips, "Select currency", dialog "OK",
    receipt "Share", search hint, transfer-review captions (`fromCaption` etc.).
  - `NeptuneIconSlot.semanticLabel`, `NeptuneNumeral.semanticsLabel`, `currency:` on the money
    widgets, `selected:` on `NeptuneAccountTile`.
  - `test/accessibility_test.dart`: 39 tests, each named for the assertion that fails on 2.23.0.
  Branched from `v2.23.0` because that is the tag the Neptune app pins; forward-merge into
  `main` (2.24.x / 2.25.0) is still to do.

## 2.26.0

- **`NptGlance` - the wrist scale.** A watch has no room for the fifteen-step Material type
  ramp, and a glance has exactly four registers: the figure (30), its unit (13), the line that
  dates it (12), and the rows under it (14/12), plus the eyebrow (11, tracked 0.08em) and the
  one rule a round face imposes - a safe inset of a tenth of the diameter on every side. Every
  assembled theme now carries `NptGlance.standard` as a `ThemeExtension`; `figureStyle(context)`
  is `moneyStyle` at wrist size (num face, tabular, Arabic num face under RTL) and
  `eyebrowStyle(context)` is the display face tracked. One instance for every brand on purpose:
  a brand colours and typesets a glance, it does not resize it. The KMP twin is
  `ly.neptune.odyssey.tokens.NptGlance` (`Glance.kt`, pure Kotlin). Honest scope: Flutter and
  Kotlin tokens only - no `<npt-glance>` element, and no glance widget yet; the first consumers
  are neptune-mobile's native Wear OS and watchOS targets, which copy the numbers and pin the
  copy with a test because neither can depend on either package.

## 2.25.0

- **`BrandprintConfig.whiteGround` - flags bit 3, the white structural register.** A bank
  whose identity is white paper and navy lines (FGLB) had no lever for its ground: every
  assembled theme sat on `surface`, Material's tinted tone 98, and every text field was a
  `surfaceContainerHighest` slab - a grey box on a screen whose whole point is that structure
  is drawn in lines. With the flag set the scaffold ground and the app bar are
  `surfaceContainerLowest` (tone 100, pure white in a light scheme) and a field is white
  inside its `outline` ring. Dark mode is untouched, because a dark scheme's lowest container
  is its darkest tone. Every pre-2.25.0 string decodes with the bit clear; the TS codec
  mirrors it (`neptune_tokens`). The Kotlin codec has NOT been updated in this release and
  ignores the bit.
- **`NptBrandCanvas.paperOf(ThemeData)`** - the paper canvas over a finished theme, its ground
  taken from `scaffoldBackgroundColor` rather than `surface`, so a pre-login paper shell sits
  on exactly the ground the signed-in screens sit on.

- **The register composition - what `dashboardHero: 'statement-ledger'` draws.** 2.24.0 put
  `statement-ledger` and `paper-lockup` on the wire and left what they draw to the host; the
  first bank to pick them then had to compose a passbook out of `Container`s. `neptune_register.dart`
  ships it: `NeptuneLedgerFigure` (an eyebrow, the integer part at `displaySmall`, the fraction
  stepped down to `headlineSmall` in `onSurfaceVariant`, the currency code set apart - tabular
  throughout and laid out LTR under RTL), `NeptuneRegisterGroupHeader` (a `surfaceContainerLow`
  band with an eyebrow and a subtotal, no radius), `NeptuneRegisterRow` (title, subtitle,
  end-edge figure, 56dp, nothing decorative), `NeptuneRegisterGroup` (rows on hairlines),
  `NeptuneLedgerLine` + `NeptuneLedger` (a confirm step's review) and `NeptuneHairline`, the
  one-pixel `outlineVariant` rule every one of them uses. Flat by construction: no radius, no
  shadow, no fill but the header band.
- **`NeptunePaperWelcome` - what `loginShell: 'paper-lockup'` draws.** A small centred lockup, a
  40dp hairline under it, the bank's name as an eyebrow, the CTA pair at the foot. Colours come
  from `NptBrandCanvas.paper`, so it re-tones with the theme; no orbs, no motif, no watermark - a
  body, not a screen, so the host keeps its own `Scaffold` and language switch.
- **Text fields are the lightest tone inside an `outline` ring, as on the web.** `inputs.ts`
  has always drawn `<npt-text-field>` as `surface-container-lowest` with a 1px `outline`
  stroke; this port drifted to `surfaceContainerHighest` - the darkest container tone - in
  the theme's `inputDecorationTheme` and, with no ring at rest, in `NeptuneTextField`,
  `NeptuneSelect`, `NeptuneStepperInput` and `NeptuneDateField`. Every form became a row of
  grey slabs, and a host mixing those widgets with a bare themed `TextField` got two kinds
  of field on one screen. All five now share one recipe: `surfaceContainerLowest` fill, 1px
  `outline` at rest, 2px `primary` on focus, `error` when errored.
- **`NeptuneDetailList` + `NeptuneDetailItem`** (`neptune_detail_list.dart`) - the
  labelled-value list a transaction detail, a bill summary or a payee's particulars are
  made of. One `surfaceContainerLow` surface on the `lg` corner, rows on `outlineVariant`
  hairlines, label at the start edge and value at the end; `numeric` pins a value LTR
  through `NeptuneNumeral`, `emphasis` sets the one row that is the figure in the money
  face, `trailing` holds a 40dp end-edge action (copy, chevron). An optional `title` is an
  eyebrow above the surface, not a heading inside a box. Hosts had been re-inventing this
  with `Container`s at a different radius each time.
- **`NeptuneListTile.flat`** - transparent, square, ripple clipped to the row, for a tile
  that sits inside a grouped surface (a `NeptuneDetailList` of payees) where a per-row
  `surfaceContainerLow` slab with its own corners read as boxes on a box.

## 2.24.1

- **`textButtonTheme` carries the label captured at assembly**, exactly as `filledButtonTheme`
  and `outlinedButtonTheme` already did. Left unset, `TextButton` read `labelLarge` at build
  time through `Theme.of` - after localization merged the Material 3 geometry in (height 1.43,
  tracking 0.1) - so a text button sat on a different line box from every other button on the
  screen. This is the third slot the deprecated `withHostFont` used to fill; a host that moved
  from it to `hostFont:` in 2.24.0 saw every `TextButton` label shift, and this closes that.

## 2.24.0

- **`NeptuneTheme.fromConfig` (and `light`/`dark`/`fromBrandprint`) return a FINISHED bank theme.**
  Four `ThemeData` slots the library used to leave empty are now set from tokens, so a host has
  nothing to patch after assembly: `appBarTheme` (`centerTitle: false` on every platform, no M3
  scroll tint, surface background), `floatingActionButtonTheme` (brand `primary`/`onPrimary` on
  `NptShape.xs` - unset, Material fell back to `primaryContainer` and every FAB went off-brand),
  `inputDecorationTheme` (all seven states, error and disabled included, as the non-outline
  `NeptuneFieldBorder`, resting ring on `outline` not `outlineVariant`), and an `NptBrandCanvas`
  extension derived from the LIGHT scheme in both brightnesses. Every value is a move, not a
  change: they were measured on production devices in a host that patched them at two assembly
  sites, and a fix applied at one of the two was the recurring bug.
- **`hostFont:` on every entry point** (`NptHostFont(family:, fallback:)`). A host that bundles its
  own faces passes them AT assembly instead of patching the result with `withHostFont`. The text
  theme, `primaryTextTheme`, both button label styles and `NptType` (every face, the Arabic ones
  included, `bundled: true` + `fontFamilyFallback`) all name the host family, `moneyStyle` under RTL
  stops resolving `numAr` through google_fonts, and no code path reaches the runtime loader - so a
  production host no longer has to flip `debugSkipFontLoading`. `withHostFont` is deprecated (body
  unchanged, removed at 3.0).
- **Motif is its own lever.** Byte 26 of the brandprint - reserved, always `0` - now carries a
  `MOTIF` registry index: `auto` (0, derive from `glassTint` exactly as before, so every string in
  the wild decodes to the identical theme), `sonar-rings`, `coastal-arcs`, `grid-spark`,
  `guilloche`, `none`. `BrandprintConfig.motif` (default `auto`), `NptMotifKind.none` (paints
  nothing by definition, `motifStrength` 0, glass numbers untouched). Ported to the TS and Kotlin
  codecs and the JS reference; a synthetic `custom-none` golden entry proves the byte round-trips
  in all three. The four reference strings are byte-identical.
- **Two shells and two heroes appended to the lever registries.** `loginShell` gains
  `paper-lockup` (light surface, the lockup centred and small, no watermark, no motif) and
  `lockup-rule` (white ground, the lockup, one hairline rule under it); `dashboardHero` gains
  `statement-ledger` (one tabular balance statement over compact account rows) and
  `chevron-summary` (the total across the top, each account row carrying a movement chevron in
  the accent). Append-only, indices 4 and 5 in every codec; the four reference strings are
  unchanged. What each name DRAWS is the host's composition switch, as it always was - the
  library carries the name on `NptIdentity` and guarantees it survives the wire.
- **A direction accent distinct from the primary.** `BrandprintConfig.accentOnTertiary` (flags
  bit 2, clear on every existing string) says the tertiary seed is the brand's ACCENT, spent on
  direction and confirmation only. `NptColors.accent`/`onAccent` carry it; `NeptuneCta` paints
  its non-tonal fill and glow with it. With the flag set the seed feeds NO Material role - the
  `tertiary*` roles and the card gradient are ramped from the primary seed - so a bank whose
  second colour is a red cannot have that red leak into chrome and read as an error state.
  Without the flag the accent IS the primary, so no existing brand moves a pixel.
- **`NptBrandCanvas.paper(ColorScheme)`**: the eight pre-login roles for a shell that puts the
  lockup on a plain ground. Re-tones with brightness on purpose - it is a surface, not an
  identity moment.
- **`NeptuneFieldBorder`** (new, `theme/field_border.dart`): the `isOutline: false` border that
  floats a filled field's label INSIDE the fill. Radius is required - always a shape token.
- **`NptBrandCanvas`** (new, `theme/brand_canvas.dart`) + `context.brandCanvas()`: the eight fixed
  pre-login colour roles, brightness-invariant for the same reason the card-art roles are.
- `NptType` gains `bundled` and `fontFamilyFallback` (carried through `copyWith`/`lerp`).

## 2.23.0

- **Merged with `2.22.0`, which was published from a tree that predated the RTL work.** `2.22.0` on
  pub.dev carries `NeptuneTabs.width` but ships the OLD `neptune_buttons.dart`, so adopting it whole
  would have put the double-mirrored CTA arrow back on every Arabic screen. This release is
  `2.22.0`'s tabs feature plus the RTL fixes, both intact. `2.21.1` and `2.21.2` were never
  published; their content is included here.
- **`NeptuneTabs.width`** (`NeptuneTabsWidth.hug` | `.fill`) - from `2.22.0`. The tabs can share the
  available width instead of hugging their labels at the start edge. A host could not do this from
  the outside at any price: the strip wraps its `Row` in a horizontal `SingleChildScrollView`, which
  hands that row an UNBOUNDED width, so `SizedBox(width: double.infinity)`, `Expanded` and
  `CrossAxisAlignment.stretch` all stop at the viewport and the divider kept ending with the last
  label. `fill` drops the scroll view and puts each tab in an `Expanded`; labels wider than their
  share ellipsize. Default is `hug`, so every existing call site is unchanged. `fill` self-adapts in
  unbounded-width slots (falls back to the hugging strip) rather than blanking the subtree - the
  rulebook §4 rule `NeptuneSegmented` already follows.
- **RTL: one mirror, not two.** `Icons.arrow_forward_rounded`, `chevron_right_rounded` and
  `chevron_left_rounded` all carry `matchTextDirection: true`, so `Icon` flips them under RTL by
  itself. Choosing the opposite glyph in an `isRtl ? ... : ...` mirrored them a SECOND time and the
  two cancelled: the animated CTA arrow pointed backwards, `NeptuneBreadcrumbs` separators pointed
  back up the trail, and `NeptunePagination` had Previous and Next the wrong way round - in every
  Arabic locale, which is every screen for the banks this system serves. Covered by
  `test/rtl_arrow_mirroring_test.dart`.

## 2.21.1

- **`NeptuneCardArt`: removed the tiled arc motif from the card face.** At full strength on a compact 1.586-ratio card, the repeating micro-pattern read as busy/cheap rather than premium. Checked against the category (Mercury, Chase, Monzo, N26, Chime, Airwallex, Brex, PayPal, Revolut Business): every one uses a clean flat/gradient card face with zero repeating texture. The brand gradient + typography now carry the identity alone, matching every reference.

## 2.21.0

- `NeptuneTheme.withHostFont()`: re-applies a host's bundled font across the text theme AND every component theme carrying its own `textStyle`. Hosts patching `theme.textTheme.apply(...)` by hand left `filledButtonTheme`/`outlinedButtonTheme` holding the family captured at assembly, so BUTTON LABELS rendered in a different face than the rest of the screen — invisible in a widget test, obvious on a device.

## 2.20.0

- **Dark mode: the brand colour stops washing out.** The dark ramp put primary at OKLCH L 0.80, where the sRGB gamut caps chroma near 0.10 for a blue hue — a brand seed of 0.209 lost ~40% of its saturation and rendered as a pale, washed blue. Primary is now L 0.66 / chroma x0.85 (tertiary 0.70, secondary 0.76), where the full brand chroma survives. Contrast measures ~5.9:1 against both the dark surface and on-primary, comfortably past WCAG AA. Changed in `neptune_tokens` (the cross-platform source of truth) and regenerated, so all 13 platform packages inherit it identically.

## 2.19.0

- `NeptuneNumeral`: text that always reads left-to-right whatever the locale, for account numbers, IBANs, card numbers, amounts and references. Forces only the INTERNAL direction, so RTL layouts stay mirrored. `NeptuneNumeral.isolated()` wraps a value in LRI/PDI isolate marks for safe interpolation into a translated sentence — stronger than a bare LRM, which lets adjacent weak characters merge with the run.

## 2.18.1

- **Fix release-build breakage**: `NeptunePageTransitionsBuilder.theme` no longer names `CupertinoPageTransitionsBuilder`. That symbol moved between Flutter versions and a newer stable failed with "Method not found", breaking Android release builds. iOS/macOS now inherit the framework defaults by spreading `const PageTransitionsTheme().builders` — same behaviour, version-proof.

## 2.18.0

- `NeptunePageTransitionsBuilder` + wired into every generated theme: M3 fade-through with a gentle upward settle on push, receding lift-and-dim on the covered page, natural reverse on pop. iOS keeps `CupertinoPageTransitionsBuilder` so the native edge-swipe back gesture survives. Reduced motion falls back to a plain cross-fade — position never animates.

## 2.17.0

- Dark mode overhaul: neutral floor raised to M3's dark-surface level (OKLCH L 0.13 → 0.18) with the container ladder re-spaced, neutral chroma halved to kill the primary-hue cast on dark ground.
- Card-art gradient is now mode-aware: dark gets a deeper, slightly desaturated ramp instead of the light-seed gradient glaring on dark surfaces.

## 2.16.0

- `NeptuneUnlockReveal.background`: hosts can replace the generic motif wash on the unlock sheet with their own brand canvas, keeping one background language across splash, unlock, and home.

# Changelog

## 2.15.0 — white-label icon slots + a host FAB gap in the dock

White-label was only half-true in the chrome: `NeptuneDock`, `NeptuneQuickAction`
and `NeptuneAccountTile` accepted **only** Material `IconData`, so every bank
built on Odyssey wore the same glyphs no matter which icon set its designers had
drawn. Each of the three now takes an optional `iconWidget` alongside `icon`,
and the dock can reserve a hole for a host-owned centre FAB. Fully additive —
every existing call site compiles and renders unchanged.

- **`iconWidget` on `NeptuneDockItem`, `NeptuneQuickAction` and
  `NeptuneAccountTile`.** Pass any widget — a per-brand SVG, an `ImageIcon`, a
  lettermark — and it replaces the Material glyph. `icon` is now optional
  (`IconData?`) with a constructor assert requiring one of the two; the
  `NeptuneAccountTile` wallet default is untouched, so its call sites need
  nothing.
- **The supplied widget inherits the state tint.** A mark gets the exact colour
  the `Icon` would have received — the dock's `onPrimary` when raised-active vs
  `onSurfaceVariant` when idle, `onSecondaryContainer` in a quick-action chip,
  `onPrimaryContainer` in an account tile — published to its subtree as an
  `IconTheme` **and** a `DefaultTextStyle`, plus the same square the glyph
  occupied (22dp in the dock, the ambient icon size elsewhere). The tint is
  deliberately **not** forced through a colour filter, so a brand's multi-colour
  mark stays multi-colour; a monochrome SVG should inherit `currentColor`
  (i.e. read `IconTheme.of(context).color`) to follow the active/inactive
  treatment.
- **`NeptuneDock.centerGap` / `centerGapWidth`** (default `false` / `72`)
  reserve inert space in the middle of the item row so an app with a centre
  floating action button can adopt the dock — the host stacks and owns the
  button, the dock just leaves room. The glass pane, hairline, elevation and the
  raised-active spring are all untouched, item cells stay equal-width, and with
  an even item count the hole straddles the dock's centre line.
- **Fix — the raised-active spring crashed on a real selection change.** The
  key-light was `active ? [shadow] : null`, so `BoxDecoration.lerp` padded the
  shorter list with `BoxShadow.scale(1 - t)`; the brand spring overshoots
  outside `0..1`, the factor went negative, and `dart:ui` asserted on a negative
  blur radius. Latent because every test and shot built the dock with a fixed
  active item. Both states now emit one shadow with identical geometry and
  animate alpha only (`Color.lerp` clamps, `BoxShadow.scale` does not).

flutter analyze clean · 128 tests pass (13 new) · CI no-literals gate green.

## 2.14.0 — NeptuneUnlockReveal: swipe-up unlock ritual

**`NeptuneUnlockReveal`** — the "swipe up to open" unlock ritual for a
returning-user lock screen (canvas pill cutout reveals gradient + motif).
Odyssey-original, beyond the web set.

- A full-bleed canvas in the brand `primary` hides the 135° primary → tertiary
  gradient overlaid with the signature motif (`NeptuneMotifLayer` in
  `onPrimary` at a quiet ~0.15-alpha ink wash). A vertical pill-shaped cutout
  near the bottom reveals a sliver of it, capped by a circular arrow chip
  (60dp, inside a ≥48dp interactive zone).
- Dragging the pill (or chip) upward grows the cutout, its top edge tracking
  the finger; releasing past ~60% progress completes the reveal on the brand's
  emphasized curve and fires `onUnlock` exactly once; releasing earlier
  settles back on the brand spring. An upward fling completes regardless of
  progress, and a tap on the chip unlocks too (doubling as the accessible
  activation — the zone is a labelled semantic button).
- Optional `label` under the pill (in `onPrimary`) and `logo` in the upper
  canvas area; both yield as the reveal grows.
- Reduced motion: no growth animation — tap/drag-complete cross-fades straight
  to the revealed state, then fires `onUnlock`.
- Theme-only (colour, motion and elevation all from the active brandprint),
  RTL-safe, reduced-motion safe.

flutter analyze clean · 115 tests pass (6 new) · CI no-literals gate green.

## 2.13.1 — docs + pub.dev screenshot refresh

No code changes. Adds a new pub.dev/README screenshot (`r6_additions.png`, real
`RepaintBoundary.toImage` engine render) showing the 2.13.0 additions — the loader family,
`NeptuneSplashScreen`, and `NeptuneAppBar`'s medium variant — and updates install snippets
and the widget list to the current version. Screenshots are pinned per published version on
pub.dev, so this needed a release rather than just an edit to `main`.

## 2.13.0 — R9: full component-suite audit

Audited all 89 web custom elements (`neptune_web_ui`, the canonical recipe
source) against the 149 Flutter classes for genuine capability gaps — not a
naming diff, an actual missing thing a consumer would hit. Result: **one**
real gap. Everything else either has a dedicated Flutter widget, is covered
by a Material widget the theme already brands (`Divider`, `FloatingActionButton`,
`IconButton`, `NavigationBar` all read the Odyssey `ColorScheme` with zero
wrapper needed), or is a deliberate idiom difference already established
throughout this library (data-driven widgets — `NeptuneAccordion`,
`NeptuneTabs`, `NeptuneStepper` — take a `List<...>` of records rather than
exposing discrete child widgets per item).

- **`NeptuneAppBar` gained `variant`** (`small`/`center`/`medium`/`large`,
  matching web's `<npt-top-app-bar>`): `medium`/`large` reserve the 56dp row
  for leading/actions only and drop a bigger headline (28px / 45px) below it
  — the M3 collapsing-header pattern the Flutter widget was missing
  entirely. Ported with one accessibility improvement over the web source:
  the title stays in the semantics tree via an explicit `Semantics(header:
  true)` wrapper in every variant, rather than the web version's pattern of
  hiding the inline title via `visibility:hidden` (which removes it from the
  accessibility tree) and marking the stacked headline `aria-hidden` (same
  problem) — as shipped, the web component has no accessible title in
  medium/large.

flutter analyze clean · 109 tests pass · CI no-literals gate green.

## 2.12.0 — R6: design evolution

**Density, dark-mode elevation, per-brand motion, feedback tokens, Arabic
numerals, and a new loading/splash widget family.**

- **Dark-mode elevation is a glow, not an invisible shadow.** `NptIdentity`'s
  `elevation1..5` used a fixed dark-shadow recipe that barely registers
  against an already-dark surface; dark mode now lerps toward `primary` with
  more blur and less directional offset, reading as ambient light rather
  than a cast shadow. Light mode is byte-identical to before.
- **Density lever.** `NptDensity` (comfortable/compact, `NeptuneTheme.fromConfig(density:)`)
  scales spacing at density-aware call sites — `NeptuneListTile` and the
  `NeptuneCta` family today; more widgets opt in incrementally.
- **Per-brand signature motion.** `NeptuneCta`'s sheen/nudge cycle length
  used to be a fixed 4800ms/2400ms for every brand; it's now derived from
  the brand's own `motion.slow`/`durationStandard` (Neptune's smooth-fluid
  reproduces the old constants exactly; calmer/snappier brands now visibly
  differ, not just in easing but in tempo).
- **Haptic + sound tokens.** `NptFeedback` (haptics via real
  `HapticFeedback` calls, weighted per brand `contentTone`; `onSoundCue` is
  a plain hook — no bundled audio in this package, see `neptune_sound_kit`)
  fires from `NeptuneCta`, `NeptuneCheckbox`, `NeptuneSwitch`.
- **Arabic-Indic numerals.** `NeptuneNumeralStyle`/`NptNumerals` +
  `NeptuneTheme.formatDigits` — an independent lever from `arabic:` (many
  Gulf/Libyan banking apps run an Arabic UI with Latin digits, or vice
  versa). Wired into `NeptuneBalanceCard`/`NeptuneTransactionRow` today.
- **New loader family** (`neptune_loaders.dart`): `NeptuneSpinner`,
  `NeptuneDotsLoader`, `NeptunePulseLoader`, and `NeptuneHourglassLoader`
  (extracted from `NeptuneStatusMotion` so it's usable standalone).
  `NeptuneStatusMotion` gained `loaderStyle` so any of the four can precede
  the same success/reject morph — one hand-off choreography, four "waiting"
  feelings.
- **`NeptuneSplashScreen`** — the ambient welcome backdrop + a large brand
  mark + a loader, for the cold-start moment before an app has real state.
- **Contrast lift.** Light-mode `tertiary`/`success` fills measured
  3.0–4.4:1 (2.10's audit finding); a small `themes.css` lightness tune
  brings every brand to 4.5–4.6:1, giving body-text headroom above the
  UI-tier floor those pairs are actually held to.

flutter analyze clean · 105 tests pass · CI no-literals gate green.

## 2.11.0

**The colour pipeline is now bidirectional.** `hexToOklch`/`rgb255ToOklch`
invert the existing OKLCH→sRGB path exactly (round-trips a colour through
OKLCH and back to the identical hex) — turn any sampled or picked colour
straight into brandprint seeds. `extractSeedsFromRgba` finds a dominant
primary + a sufficiently-distinct saturated accent from raw decoded pixels
(e.g. a client's logo), the same algorithm as `tools/client-demo`'s Python
extractor, now available to any Dart/Flutter consumer with no Python
dependency.

flutter analyze clean · 83 tests pass · CI no-literals gate green.


## 2.10.0

**`NeptuneDemoShellApp` — a complete branded demo app in ~10 lines.** Hand it
any `BrandprintConfig` (a client's real seeds) and a logo widget; get a
running, navigable, bilingual (EN/AR) app: the Welcome template, then a
5-tab glass-dock shell (Home/Transfer/Cards/Insights/Profile) composed
entirely from the existing screen templates — dashboard, transfer (with the
hourglass→success outcome), cards, an Insights tab built on `NeptuneCompareBars`
+ `NeptuneFxCard` + `NeptuneBudgetRing`, and a Profile tab with dark-mode and
language toggles that re-skin the whole app live.

This formalizes the pattern proven in the first client prototype into a
public, reusable library widget — the foundation for the CLI/desktop
demo-factory tooling. `NeptuneDemoStrings` carries sensible bilingual
defaults for every string; override only what a client wants changed.

Verified end-to-end with a custom (non-reference) brandprint: welcome → every
tab → transfer → confirm → the linked outcome motion → logout, LTR and
RTL-start, zero exceptions.

flutter analyze clean · 74 tests pass · CI no-literals gate green.


## 2.9.0

**The full account-opening onboarding flow (R5)** — modelled on a real
production banking app's onboarding sequence, not a generic wizard. Ten new
template widgets in `lib/src/templates/neptune_onboarding_flow.dart`:

- `NeptuneOtpStepTemplate`, `NeptuneInstructionTemplate` (the reusable
  "how this works" pattern for document/selfie steps).
- `NeptuneDocumentCaptureTemplate` — a document frame drawn with four
  INDEPENDENT corner brackets (not a full rectangle), a colour-coded status
  pill and a shutter that glows once ready.
- `NeptuneSelfieCaptureTemplate` — an oval face guide with colour-coded
  readiness (idle/challenge/aligned) and a large centred countdown numeral.
- `NeptuneOcrReviewTemplate` — read-only OCR fields alongside editable date
  fields, with an optional validation banner.
- `NeptuneOnboardingFormStep` — labelled fields + tappable pickers (branch,
  municipality, job) for the personal/account-details steps.
- `NeptuneAttachmentTile` + `NeptuneDocumentsStep` — dashed-until-attached
  upload tiles (birth certificate, signature).
- `NeptuneTermsTemplate` — scrollable terms with Accept/Decline.
- `NeptuneOnboardingStatusTemplate` — the shared terminal screen: EVERY
  backend outcome (processing, success, manual review, rejected, failed)
  renders through one widget driven by `NeptuneStatusMotion`, plus a
  tap-to-copy detail card and Check-now/Refresh + Leave actions.
- `NeptuneIdentityCorrectionTemplate` — the identity-mismatch recovery screen.

Verified against engine renders of all ten screens (corner-bracket frame,
oval countdown, OCR review, dashed-to-filled attachments, the checkmark
morph) before shipping — not just widget tests.

flutter analyze clean · 72 tests pass · CI no-literals gate green.


## 2.8.0

**State completeness + insights charts (R4b).** Banks judge kits by the
unhappy paths — loading/empty/error is now a first-class contract:

- `NeptuneStateSwitcher` — one wrapper that cross-fades between loading
  (skeleton), error (branded alert + retry), empty (`NeptuneEmptyState`) and
  the ready content, on the brand motion curve.
- `NeptuneShimmer` + `NeptuneSkeletonCard` / `NeptuneSkeletonRow` — a real
  sweeping shimmer (RTL-aware direction) over bones shaped like the actual
  card/row anatomy, not generic grey boxes.
- `NeptuneBarChart` — labelled vertical bars with an optional highlighted
  period and tabular-money caption.
- `NeptuneCompareBars` — paired this-vs-last-period bars per category with a
  computed delta chip (the "vs last month" story from the web Insights tier).

Example gallery gains a States & charts section; SHOTS captures it (fixed
scroll targeting after the previous section grew).

flutter analyze clean · 57 tests pass · CI no-literals gate green.


## 2.7.0

**All nine published templates, composed.** `lib/src/templates/` ships the
full templates.html set as data-parameterised screen widgets (joining
`NeptuneWelcome`): `NeptuneAuthTemplate` (credentials → OTP),
`NeptuneKycTemplate` (capture tiles + tier limit), `NeptuneDashboardTemplate`,
`NeptuneCardsTemplate` (swipeable carousel + controls),
`NeptuneTransferTemplate` (amount → review → hourglass/success outcome),
`NeptuneWalletTemplate` and `NeptuneCorporateTemplate` (responsive side-nav
workspace). Hand them data + callbacks; they wear the active brand — any
brandprint, LTR/RTL, light/dark. The example gallery gains a template browser
and the SHOTS harness captures every template.


## 2.6.1

- Colour canon: brand tables are now GENERATED from themes.css via the repo's
  token codegen (single OKLCH implementation shared with the web). 21 of 296
  role values shift by ±1 LSB — imperceptible — making pinned brands and
  custom-seed generation exactly consistent.
- Fix: `NeptuneSegmented` no longer fails layout (silently blanking the
  subtree) in unbounded-width slots such as `NeptuneListTile.trailing` — it
  shrink-wraps when unbounded, keeps equal-width segments when bounded.
- `NeptuneWelcome` gains `lockup:` for real client logos.
- pub.dev screenshots added.


## 2.6.0

**Templates & motion — the living Odyssey vibes.** The Welcome / Sign-in
template and the animated flourishes from templates.html, ported for real
(engine-rendered screenshots verified per brand), plus a new Odyssey-original
outcome motion:

- `NeptuneStatusMotion` — an animated HOURGLASS (draining sand + flip loop)
  that hands off smoothly to an animated SUCCESS check (stroke-drawn, colour-
  able, defaults to the brand success role) or an animated REJECTED cross
  (stroke-drawn with a decaying shake). The three states are linked through a
  spin-out/spring-in transition on the brand motion curves.
- `NeptuneCta` is now the real premium CTA: a slow SPECULAR SHEEN sweeps the
  pill on the web's 4.8s cycle, the arrow NUDGES (±4dp / 2.4s, mirrors under
  RTL), press scales to 0.98 on the emphasized curve, and the primary
  key-light glow rides underneath. New `tonal:` secondary tone. All motion
  pauses under reduced-motion.
- `NeptuneWelcome` + `NeptuneAmbientBackdrop` + `NeptuneBrandLockup` — the
  full Welcome / Sign-in template: radial brand wash, three soft orbs drifting
  on 15/19/17s loops (static under reduced-motion), the brand lockup with its
  accent dot, and the bold mixed-weight promise (display-w500 + w800 primary).
- Example: "Motion & templates" gallery section + a push-able Welcome route;
  the SHOTS harness now captures pushed routes (boundary moved to
  MaterialApp.builder) and renders the Welcome per brand.


## 2.5.2

Two real layout bugs caught by the full-depth visual sweep (every gallery
viewport × 4 brands × light/dark):

- `NeptuneToolbar` now hands its center slot BOUNDED width (children wrapped in
  `Flexible`). A flex child there (e.g. `NeptuneSearchField`, which contains an
  `Expanded`) previously failed layout and blanked the surrounding subtree.
  Regression-tested with a SearchField in the center slot.
- `NeptuneCreditScoreGauge` honours its `size` under tight constraints (e.g.
  inside `Expanded`) instead of painting a giant arc outside its bounds.

## 2.5.1

Depth polish: `NeptuneCta` now rides elevation-3 with a soft primary key-light
(the web CTA recipe) instead of sitting flat, and `showNeptuneDialog` gets the
deep soft drop (web elevation-5). Verified via the SHOTS harness.

## 2.5.0

**The identity release — Odyssey stops looking like generic Material.** Ports
the web token levers that sit above the M3 colour scheme, so every brand
carries its signature look (verified pixel-by-pixel against the shipped web
templates via engine-rendered screenshots across 4 brands × light/dark × RTL):

- `NptIdentity` theme extension: per-brand glass recipes (`--npt-glass-tint`
  mix ratios + blur), the signature motif lever, elevation tokens
  (`--npt-elevation-1/2/3/5`), the primary key-light glow, and the
  login-shell / dashboard-hero / content-tone levers. Resolves for custom
  brandprint seeds too (keyed off the `glassTint` lever).
- `NeptuneMotifLayer`: the four brand motifs as CustomPainters — Neptune sonar
  tide-rings, Triton coastal arcs, Nereid grid-spark, Proteus shield
  guilloché — ported from the `--npt-motif` CSS gradients.
- `NeptuneGlass`: real backdrop-blur glass with the brand tint and hairline
  seal (card glass + dock pane recipes). `NeptuneCard` with the web's four
  variants (standard / elevated / tonal / glass, `motif:` overlay opt-in).
- `NeptuneEyebrow`: the uppercase, letter-spaced display-face micro-label.
- Widgets now wear the identity: the dock is glass with the raised-active
  circle popping above the bar (sprung on the brand motion curve), card art
  carries the motif + elevation + selection glow, the balance-card hero etches
  the motif over its gradient with the web's display-md amount, onboarding
  heroes get the login-shell motif backdrop, stat cards use the eyebrow.
- Example gallery: fixed phone-frame window on macOS, content scrolls under
  the glass dock, and a `--dart-define=SHOTS=true` harness renders pixel-exact
  gallery screenshots per brand/mode/scroll for visual regression.

## 2.4.0

The "fully fledged" release — ~33 new branded widgets take the package past
Material parity into a complete fintech design system (now ~88 widgets). All
theme-only (no literal colours/radii/fonts), RTL-safe, ≥48dp; 40 widget tests
pass under light/dark/RTL × brands; `flutter analyze` clean.

- Form fields: `NeptuneTextField`, `NeptuneSelect`, `NeptuneStepperInput`,
  `NeptuneDateField`.
- Selection controls: `NeptuneCheckbox`/`NeptuneCheckboxTile`,
  `NeptuneRadioGroup`, `NeptuneSwitch`, `NeptuneSegmented`, `NeptuneSlider`.
- Overlays: `showNeptuneDialog`, `showNeptuneSheet`, `NeptuneMenu`,
  `NeptuneTooltip`.
- Navigation / structure: `NeptuneTabs`, `NeptuneBreadcrumbs`,
  `NeptunePagination`, `NeptuneAccordion`.
- Display: `NeptuneAvatar`/`NeptuneAvatarGroup`, `NeptuneBadge`, `NeptuneTag`,
  `NeptuneProgressBar`, `NeptuneProgressRing`, `NeptuneRating`,
  `NeptuneListTile`, `NeptuneTimeline`.
- Fintech: `NeptuneInsightCard`, `NeptuneFxCard`, `NeptuneBudgetRing`,
  `NeptuneSpendBreakdown`, `NeptuneCreditScoreGauge`.

Mobile-readiness fixes (found by narrow-width testing): `NeptuneAccountTile`
and `NeptuneLimitMeter` trailing values now flex/ellipsize; `NeptuneApprovalItem`
stacks its actions on narrow widths; `NeptuneTabs` no longer requires a bounded
height. The example app gained gallery sections for every new widget.

## 2.3.0

The full solution — real brand typography + the remaining structural widgets.

- **Fonts now render for real.** `NeptuneTheme` integrates `google_fonts`: each
  brand's display / text / num families (Hanken Grotesk, Bricolage Grotesque,
  Space Grotesk, Sora) are loaded and applied to the whole `TextTheme`, and
  `moneyStyle` resolves the brand `num` face with tabular figures.
- **Arabic / RTL faces.** `NptType` now carries the Arabic faces per brand
  (`displayAr` / `textAr` / `numAr` — IBM Plex Sans Arabic, Reem Kufi, Tajawal,
  Readex Pro, Noto Kufi Arabic, matching the web `--npt-font-*-ar` tokens). Pass
  `arabic: true` to `NeptuneTheme.light/dark/fromConfig/fromBrandprint` for an
  RTL build; `moneyStyle` is direction-aware and swaps to the Arabic numeral
  face under RTL, mirroring the web's `[dir="rtl"]` font swap.
- **New widgets:** `NeptuneDataTable` (themed Material `DataTable`, zebra rows,
  numeric/money columns), the responsive shell — `NeptuneAppShell`,
  `NeptuneSideNav` / `NeptuneSideNavItem`, `NeptuneToolbar`, `NeptuneNavRail`
  (Material `NavigationRail`) — plus `NeptuneCardControls`, `NeptuneAddCard`
  (dashed tile), and `NeptuneToast` + `showNeptuneToast` (overlay, no Scaffold
  needed).
- **Example:** a full components-gallery screen showcasing every widget.
- Colour goldens unchanged (byte-identical); `flutter analyze` clean; all
  widget tests pass under light / dark / RTL × 4 brands. COVERAGE.md updated.

## 2.2.0

Widget parity, round 2 — the package now ships ~46 branded widgets (up from 16),
covering the full dashboard / transfer / corporate / wallet surfaces:

- Money inputs: NeptuneAmountInput, NeptuneCurrencyField, NeptuneIbanField,
  NeptuneOtpInput, NeptunePinInput, NeptuneAmountKeypad.
- Money movement: NeptuneStepper, NeptuneTransferReview, NeptuneMethodRow,
  NeptuneBeneficiaryTile, NeptuneSuccess, NeptuneReceipt.
- Data-viz (CustomPainter): NeptuneSparkline, NeptuneDonut, NeptuneLimitMeter,
  NeptuneTrend.
- Corporate: NeptuneApprovalItem, NeptuneBatchCard, NeptuneAuditRow,
  NeptuneUserRow, NeptunePermissionToggle, NeptuneWorkflowStatus.
- Wallet/pay: NeptuneMerchantRow, NeptuneVoucherCard, NeptuneQrPay,
  NeptuneTopupRow, NeptuneTierBadge.
- Feedback/shell: NeptuneAlert, NeptuneBanner, NeptuneEmptyState,
  NeptuneSkeleton, NeptunePageHeader, NeptuneSearchField.

All theme-only (no literals), RTL-safe, ≥48dp; 36 widget tests pass under
light/dark/RTL × 4 brands; flutter analyze clean. COVERAGE.md updated.

## 2.1.0

Widget parity pass — the package now ships **16 branded widgets** (up from 4),
matching the web components shown in the docs templates. New:

- `NeptuneButton` (filled / tonal / outlined / text) + `NeptuneCta` (animated
  pill CTA), `NeptuneStatCard`, `NeptuneCardArt` (gradient card + `selected`
  ring), `NeptuneQuickActions` / `NeptuneQuickAction`, `NeptuneDock` /
  `NeptuneDockItem` (floating nav, raised active indicator), `NeptuneAppBar`,
  `NeptuneOnboarding`, `NeptuneSection`, `NeptuneChip`, `NeptuneStatusChip`.
- A real **example app** (`example/`) — a themed dashboard + onboarding screen
  built only from the widget set.
- Honest **COVERAGE.md** mapping every web component → implemented / Material
  fallback / TODO (nothing silently dropped).
- All widgets theme-only (no literals), RTL-safe, ≥48dp targets;
  `test/widgets_test.dart` builds them under light/dark/RTL × 4 brands.
  `flutter analyze` clean.

## 2.0.0

Aligns the Flutter package with the Neptune Odyssey 2.x line (vendor-neutral, white-label).

- Reference brands are the four neutral demo skins — `neptune` / `triton` / `nereid` /
  `proteus` (no real-institution identity).
- Brandprint strings remain byte-identical to the JS/TS reference and stable across
  versions: a saved `NO1-…` resolves to the same theme on Flutter, Web, React, Vue,
  Svelte and React Native (golden-tested).
- `NeptuneTheme.light` / `.dark` / `.fromBrandprint` / `.fromConfig`; `ThemeExtension`s
  `NptColors` / `NptShape` / `NptType` / `NptMotion`; theme-only widgets (balance card,
  transaction row, account tile, primary button). RTL-safe, ≥48dp targets, no literals.
- 31 golden tests; `flutter analyze` clean.

## 1.0.0

First stable release of the Neptune Odyssey Flutter package by Neptune.Fintech.

- Const M3 `ColorScheme`s for the four reference brands × light/dark, byte-identical
  to the cross-platform pinned palettes (`build/tokens.resolved.json`).
- `ThemeExtension`s: `NptColors` (incl. success roles), `NptShape`, `NptType`, `NptMotion`.
- `NeptuneTheme.light` / `.dark` / `.fromBrandprint` / `.fromConfig` → full
  `ThemeData(useMaterial3: true)`; money uses `FontFeature.tabularFigures()`.
- Brandprint codec (byte-identical to the JS reference, idempotent, checksum-validated)
  and the shared OKLCH→sRGB converter for custom seeds.
- Theme-only widgets (balance card, transaction row, account tile, primary button);
  `EdgeInsetsDirectional` + ≥48dp targets; no literal colours/radii/fonts.
- 31 golden tests; `flutter analyze` clean.

# 02 · Components

Every component is theme-driven and ships in light/dark, LTR/RTL. Anatomy + states below; visual contract is the live `.dc.html`. Sizes are defaults — drive radius from the shape family, colour from roles.

## Buttons
- **Filled** — `primary` bg, `on-primary` text, full-radius, soft primary shadow. Primary action, one per view.
- **Tonal** — `secondary-container` / `on-secondary-container`. Secondary action.
- **Outlined** — transparent, `outline` border, `primary` text. Tertiary.
- **Text** — `primary` text only. Lowest emphasis / inline.
- **Elevated** — `surface-container-lowest` + shadow, `primary` text. On busy/coloured surfaces.
- States: enabled / hover (state layer 8%) / focus (3:1 ring) / pressed (12%) / disabled (38% on-surface). Min height 48dp.

## FAB & icon buttons
- **FAB** 56dp, `primary-container`, corner `lg`. **Extended FAB** adds a label. **Icon buttons** 44–48dp, `full` radius, standard / tonal / outlined variants.

## Selection
- **Segmented button** — outlined track, selected segment fills `secondary-container`. 2–4 options.
- **Filter / assist / input chips** — corner `sm`; selected = `secondary-container` + leading check.
- **Switch** — track `primary` (on) / `surface-container-highest` (off); thumb springs (spatial motion). 
- **Checkbox / radio** — `primary` when selected, `outline` when not; animate the mark/dot in.
- **Slider** — `primary` active track + thumb, `surface-container-highest` inactive.

## Text fields
- **Filled** — `surface-container-highest` fill, 2px `primary` underline on focus, floating label in `primary`. Corner top sm.
- **Outlined** — `outline` border → `primary` on focus. Corner sm.
- Always pair with helper/error text; error uses `error` role.

## Cards
- **Elevated** — `surface-container-lowest` + shadow. **Filled** — `surface-container-highest`. **Outlined** — `outline-variant` border. Corner `md`. Choose one emphasis level per context; don't stack shadows.

## Lists
- 40–44dp leading icon/avatar (corner sm or full), title (title) + supporting (body, on-surface-variant), trailing value/meta. Dividers use `outline-variant`. Credits in `success`.

## Navigation
- **Bottom nav bar** — `surface-container`; active item shows a `secondary-container` pill behind the icon + `primary` label. 3–5 destinations. Min 48dp targets. This is the primary mobile nav.
- **Top app bar** — display-font title, optional leading back (start-aligned, RTL-aware) and trailing actions.

## Containment & feedback
- **Bottom sheet** — corner `xl` top, drag handle, `surface` bg, `scrim` behind.
- **Dialog** — corner `lg`, `surface-container-high`, title (headline) + body + action row.
- **Snackbar** — `inverse-surface` / `inverse-on-surface`, optional `inverse-primary` action.
- **Badges** — `error` dot/count on icons. **Status pill** — `success-container`. **Progress** — linear + circular in `primary` over `surface-container-highest`.

## Product modes — Banking vs Wallet

One app, two product personalities (a build/launch switch, not a runtime user toggle):
- **Banking** (NUB, Andalus, Nuran, FGLB…): multi-account carousel, IBAN, transfers (incl. SWIFT/Western Union), full card management. Quick actions lead with **Send · Request · Pay bill · Scan & Pay**.
- **Wallet** (a fintech wallet product): single **Wallet balance** hero with a prominent **Add money** CTA on the card; quick actions lead with **Top up**. Both have cards.
The two share 100% of components — only the home composition, hero caption and lead actions differ. Implement as a `ProductMode` enum that selects a layout config, never a fork.

## Clean-design rules (non-negotiable)
- **No duplicated affordances.** A "Pay bill" quick action and a "Bills" service tile are the same thing — pick one. Quick actions = transactional verbs (Send, Request, Pay, Top up); services = value-added destinations (Vouchers, Goals, Statements, More); a destination that's already a bottom-nav tab does **not** also get a service tile.
- **No redundant detail panels.** The card already shows its number/expiry/CVV — don't repeat them in a list below. Put copy **on** the artifact.

## Banking patterns (composed)
- **Sensitive-info masking** — balances and card data are **masked by default** behind `••••••`; a single eye toggle (lives *inside* the balance card and on each card) reveals. Card screen: number/expiry/CVV masked until "Show details". This is a global `masked` flag, not per-widget.
- **Copy & share, in place** — tap the card number (when revealed) or IBAN to copy; share buttons only where sharing is real (IBAN, receipt, request link). Each fires a single transient toast (`inverse-surface`). Never a copy icon next to a duplicate of the same value.
- **Card management (N26-style)** — featured card + horizontal selector rail; **Show details** reveals + enables copy on-card; **Freeze/Unfreeze** applies a frosted overlay (`surface` 74% + tertiary snowflake badge). Frozen is a per-card state.
- **Smart Pay** — one entry that combines **QR** (module grid) and **NFC tap** as two tabs, plus a "paying-from" selector: a **default** source account that's **overridable in-flow** (both, never one).
- **Transfer** — a **scalable vertical list** of methods (icon · label · sub · chevron), not a fixed grid — it must hold 4 or 10 (Between accounts, Local, Western Union, LyPay, OnePay, SWIFT…). Recent payees rail on top.
- **Promo / ad slot** — swipeable carousel of brand-authored offer cards (`primary/secondary/tertiary-container` + faint hero emblem). Content is **per-brand data**, never bespoke layout. Dot indicators.
- **Multi-session** — accounts on one device, switch like social apps (avatar → bottom sheet, check on active, "add account").
- **Settings & personalization** — grouped rows; *customer* prefs (appearance, language→`dir`, biometric, notifications), distinct from the *bank* theme.
- **Balance hero** — `primary`/`primary-container` card, corner `xl`, display-font tabular amount, faint `on-primary` motif, meta pills; eye + (wallet) Add-money inside.
- **Payment status** — sending spinner → spring success; offers Share receipt + Done.
- **Spend insights** — total in display font + category bars (`primary` over `surface-container-highest`).

## Cross-platform note (Flutter + web)
Every pattern here is layout/token-driven and platform-agnostic by design: the same `ColorScheme`, shape, type and spacing tokens drive the Flutter widgets and the web components. Mobile uses bottom-sheets and a bottom nav bar; the web app re-flows the same components into a left rail + content pane and uses dialogs instead of sheets — but card, list, button, chip, field, masking, copy/share and the balance/card/transfer patterns are identical. Build each component once against the tokens; let the platform choose navigation chrome.

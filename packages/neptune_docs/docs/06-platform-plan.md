# 06 · Neptune Platform Plan & Design Direction

> This is the **governing document** for the Neptune Design System. Everything else (tokens, components, the Flutter/web libraries, every tenant) serves the model defined here. Read `00`→`05` for specifics; read this for the *why* and the *system shape*.

---

## 1. Vision

**NEPTUNE DESIGN SYSTEM** — a complete, production-grade, configurable, white-label financial platform that powers mobile banking, wallets, retail & corporate internet banking, and back-office portals from **one core**.

Design philosophy, in one line:

> **M3 Expressive foundation. Neptune signature. Institution-specific identity. One system, many products.**

A customer must never feel *"this is the same app with a different logo."* They must feel *"this is my bank — and it's excellent."* That feeling is engineered, not hoped for (see §5, the Same-but-Distinct rule).

The system feels: clean, premium, trustworthy, modern, expressive, financially serious, human, calm, scalable, configurable, real.

## 2. Material 3 Expressive is the foundation

Neptune inherits M3's color system, tonal palettes, tokens, type scale, shape system, motion principles, component anatomy, adaptive layout, elevation/surface hierarchy, state layers, accessibility expectations, and navigation patterns — and **extends** them with a financial layer: trust, banking clarity, premium account/card surfaces, white-label theming, corporate workflow density, wallet energy, Arabic/RTL polish, and Flutter/web implementation contracts.

M3E shows up as **expressive-but-controlled** color, stronger hierarchy, larger emotional hero moments, shape contrast, motion feedback, adaptive components, and human warmth. **Never a default Material template.**

## 3. The Neptune signature

Oceanic depth · confident financial calm · premium blue/aqua energy · intentional motion · high-trust surfaces · expressive account/card heroes · soft-but-structured geometry · clean data · **functional glass only where useful** · distinct brand motifs · elegant RTL · no clutter · no redundant UI.

**Liquid Glass is an optional material, not the language.** Allowed on: floating nav, web command bars, account hero cards, card-management overlays, login/auth panels, high-priority modals, corporate approval panels, Smart-Pay sheets. **Forbidden on:** dense tables, long forms, transaction lists, corporate reports, error/legal text, anywhere contrast or clarity suffers. Reference Apple for premium translucency, Spotify Encore for cross-platform system architecture — **copy neither.**

## 4. White-label configuration architecture

The platform is **multi-tenant by configuration, not by fork.** Eight layers:

| Layer | Owns | Shared? |
|---|---|---|
| **A · Core System** | tokens, component anatomy, a11y, grid, spacing/type/motion/elevation scales, form/table/nav/security behavior, states, RTL, responsive | shared by all tenants |
| **B · Brand** | logo, wordmark, app icon, palettes, gradients, shape family, surface recipe, optional glass tint, motif, illustration, card art, login shell, dashboard hero, motion & type personality, tone | per institution |
| **C · Product Flavor** | which experience is active (retail mobile / wallet / retail web / corporate web / admin / hybrid / merchant / agent) | per deployment |
| **D · Feature Flags** | accounts, wallet, cards (virtual/physical), freeze, limits, QR/NFC, bills, vouchers, goals, statements, transfers (local/intl/SWIFT/WU/OnePay), beneficiaries, bulk, batches, approvals, users, roles, reports, uploads, audit, multi-session, security center, notifications | per institution |
| **E · Content/Localization** | EN + AR labels, tone, legal, help, errors, empty states, campaigns, product names, contacts | per institution |
| **F · Compliance/Regional** | currency, IBAN/phone/ID formats, KYC, limits, approval limits, working days, cutoffs, notices, statement formats, audit rules | per market |
| **G · Layout Density** | comfortable/compact mobile, retail-web standard, corporate-web dense, executive, ops table-heavy | per product |
| **H · Platform Adapter** | Flutter tokens/ThemeExtension/widgets, web CSS vars/components, Figma vars, Storybook, QA specs | per platform |

**Config artifacts** (one set per tenant): `tenant.config.json`, `brand.tokens.json`, `product-flavor.config.json`, `features.config.json`, `content.en.json`, `content.ar.json`, `compliance.config.json`, `platform-overrides.flutter.json`, `platform-overrides.web.json`. Author 5 reference sets: Neptune Retail, Neptune Corporate, Andalus Retail, Nuran Wallet, FGLB Retail.

## 5. The Same-but-Distinct rule (non-negotiable)

**Shared across tenants:** component anatomy, token structure, a11y, interaction model, security patterns, layout logic, data-viz rules, form behavior, nav architecture, RTL, implementation model.

**Differs per tenant:** palette, shape, type feel, motif, card art, login shell, motion personality, illustration, dashboard hero, campaign system, feature set, content tone.

> **A new tenant cannot launch with color-only customization.** It must customize **at least 6 of these 12 levers:** ① color ② shape ③ typography ④ logo/lockup ⑤ motif/pattern ⑥ card art ⑦ illustration ⑧ motion ⑨ login/auth world ⑩ dashboard hero ⑪ nav accent ⑫ content tone.

This rule is what makes the platform sellable many times without looking sold-many-times. The current build already moves levers ①②③④⑤⑥⑨ per brand (color, shape family, type, logomark+wordmark, motif, hero emblem/card art, login shell).

## 6. Brands

| Brand | Personality | Color | Motif | Shape | Motion |
|---|---|---|---|---|---|
| **Neptune** | oceanic, premium, confident, calm, futuristic | deep blue + aqua | trident / tide-rings / depth | soft 16px | smooth, confident, fluid |
| **Andalus** | warm, heritage, Mediterranean, human | emerald + warm neutral/gold | arches / Islamic geometry | organic 26px | calm, graceful |
| **Nuran** | light, digital, youthful, optimistic | violet + luminous white | star / spark | crisp 12px | light, quick, crisp |
| **FGLB** | institutional, secure, corporate, stable | navy + gold + neutral | shield / hexagon | structured 14px | stable, minimal, authoritative |

Each documents: brand story, color/type/shape/motion tokens, surface recipes, card art, empty states, login, mobile home hero, web dashboard hero, icon accent, illustration direction, *what can change* vs *what must stay consistent*.

## 7. Product flavors & information architecture

**Banking ≠ Wallet. Retail ≠ Corporate. Web ≠ Mobile (siblings, not clones).**

- **Retail mobile banking** — account-led. Login, onboarding, home, accounts, account details, cards, card details, transfers, beneficiaries, bills, QR/NFC Smart-Pay, statements, insights, goals, profile, security, settings, notifications, language, light/dark, RTL.
- **Wallet mobile** — balance-led, payment-led, top-up-led, *faster and lighter* than banking (never relabeled banking). Wallet home, balance hero, add money, top-up, send, request, QR/NFC pay, vouchers, merchant pay, activity, limits, linked cards, profile, promos, security.
- **Retail internet banking (web)** — left nav + command bar, overview dashboard, accounts, transfers, payments, cards, statements, insights, beneficiaries, profile, security center, support, filters, export, responsive, RTL. *True internet banking, not stretched mobile.*
- **Corporate internet banking (web)** — structured, permissioned, data-heavy, workflow-driven: corporate login (domain-aware), overview, cash position, user management, roles/permissions, approval matrix, **maker-checker (multi-level) approvals**, approval queue, **bulk payments / salary & supplier batches / file upload + validation + repair rows**, beneficiaries, corporate cards, limits, reports, custom reports, exports, cost-center views, **audit trail**, session management, admin settings.

## 8. Corporate domain & user-management model

Company workspace bound to a **verified domain** (e.g. Neptune → `neptune.ly`). Every corporate user's email **must** end with the allowed domain; the invite form validates the domain **immediately** with a clear inline error; admins see allowed domains and can request additional verified ones. *(Built: the invite dialog rejects non-`@neptune.ly` addresses live.)*

**Roles:** Viewer · Accountant · Maker · Checker · Approver · Finance Manager · Admin · Super Admin.
**Permissions (assignable):** view accounts · create payment · upload batch · edit batch · submit for approval · approve · reject · manage users · manage roles · export reports · change limits.
**UX to design:** invite + domain validation, role assignment, approval limits, permission preview, user status, audit log, suspended-user state.

## 9. Bulk payments & file upload UX

Three-step stepper: **Upload → Review → Submit.** Upload offers a template download and accepts CSV/XLSX. Review parses **row-by-row** with status badges — *validated / warnings (acknowledgeable) / errors (must fix)* — plus totals, payee counts, and the **required approval count**. Submit routes to the maker-checker queue and notifies checkers. *(Built in the corporate web demo.)*

## 10. Token architecture (6 layers)

**Primitive** (raw values) → **Semantic** (`color.primary`, `radius.card`, `motion.enter`, `elevation.modal`) → **Component** (`button.container`, `accountHero.background`, `table.rowHover`, `input.focusRing`, `sheet.scrim`) → **Brand** (`brand.primary`, `brand.gradient.hero`, `brand.motif`, `brand.motion.personality`, `brand.surface.glassTint`) → **Product** (`wallet.balance.hero`, `corporate.table.density`, `web.sidebar.width`) → **Platform** (`flutter.themeExtension`, `web.cssVariables`, `figma.variables`).

Everything token-driven. **No hardcoded color, radius, spacing, type, shadow, or motion.** Source of truth: `tokens/themes.css` + `tokens/tokens.json`.

## 11. Component inventory

Foundation (app/page shell, grid, section header, toolbar, command bar, search, filters, tabs, chips, badges, status, toasts, alerts, empty/loading/skeleton/error) · Inputs (text, amount, currency, IBAN, phone, search, select, date, **file upload**, OTP, password, **domain-validated email**) · Actions (primary/secondary/tertiary/icon/split/FAB, **bulk-action bar**, destructive, **approval action**) · Financial (account card, wallet balance card, card art, transaction row + table, transfer-method row, beneficiary tile, statement row, receipt, QR/NFC module, limit meter, FX row, insight chart, report card, **corporate batch card**, **approval queue item**, **audit log row**) · Navigation (mobile bottom nav, top app bar, **web sidebar**, web top bar, **corporate workspace switcher**, breadcrumbs, stepper, segmented, **product-flavor switcher**) · Surfaces (standard/expressive/elevated/tonal/glass-accent cards, modal, bottom sheet, side sheet, dialog, popover, data panel, **corporate detail drawer**).

Each documents: purpose, anatomy, variants, states, tokens, a11y, RTL, mobile, web, Flutter map, web map, do/don't.

## 12. Motion

M3E principles + Neptune personality. Motion clarifies hierarchy, guides attention, confirms actions, feels premium, **never slows a banking task**, and **respects reduced-motion**. Define durations, easings, page/sheet transitions, card reveal, balance mask/unmask, payment success/failure, QR↔NFC switch, approval transition, batch-validation animation, skeletons. Personalities: Neptune *smooth/fluid* · Andalus *calm/graceful* · Nuran *light/crisp* · FGLB *stable/authoritative*.

## 13. Accessibility & RTL

WCAG AA (4.5:1 body, 3:1 large/UI). Targets ≥48dp mobile, keyboard-complete on web, focus rings, screen-reader labels, respect text scaling & reduced motion. **Arabic is designed, not auto-flipped:** logical properties only (`inset-inline`, `margin-inline`, `start/end` — never left/right), per-brand Arabic typefaces, considered spacing/rhythm, correct numerals, mirrored icons where directional.

## 14. Flutter & web implementation

**Flutter:** `ThemeData(useMaterial3:true)` + explicit `ColorScheme` per brand/mode, `ThemeExtension`s for shape/motif/success/glass, brand theme loader, product-flavor config, feature flags, adaptive/responsive rules, RTL via `Directionality` + `EdgeInsetsDirectional`. **Web:** CSS variables (the `themes.css` layer), component tokens, framework-agnostic anatomy, breakpoints, web shell, corporate table system, Storybook, tenant config loader.

**Package structure:**
```
packages/
  neptune_tokens/          # primitives → semantic → component, JSON + generated CSS/Dart
  neptune_flutter_ui/      # ThemeExtensions + widgets
  neptune_web_ui/          # CSS vars + web components
  neptune_brand_configs/   # per-tenant brand.tokens.json + assets
  neptune_product_configs/ # flavor + feature-flag configs
  neptune_docs/            # this system
```

## 15. Documentation map

`00` agents/CLAUDE · `01` foundations · `02` components · `03` theming/white-label · `04` Flutter · `05` brand identity & platforms · **`06` this plan**. Plus the two living references: `Neptune Design System.dc.html` (mobile) and `Neptune Web Banking.dc.html` (retail + corporate web).

## 16. Design QA checklist

- [ ] Every value is a token (no literals)
- [ ] Light + dark verified
- [ ] LTR + RTL verified (logical props only)
- [ ] AA contrast on text and UI
- [ ] No duplicated affordances; no redundant data echoes
- [ ] Sensitive data masked by default; reveal/copy/share in-place
- [ ] Banking vs Wallet meaningfully different
- [ ] Retail vs Corporate meaningfully different
- [ ] Web is sibling to mobile (rail/tables/filters, not stretched mobile)
- [ ] Tenant moves ≥6 of 12 brand levers
- [ ] Glass only on approved surfaces; never on tables/forms/reports
- [ ] Reduced-motion path exists
- [ ] Targets ≥48dp; keyboard-complete on web
- [ ] Empty / loading / error / skeleton states designed

## 17. Do / Don't

**Do** — lead with clarity; one primary action per view; mask sensitive data; design AR & dark as first-class; drive everything from tokens; make corporate dense but calm; make wallet fast and payment-led.
**Don't** — repeat affordances; echo data above & below a card; glass-ify tables/forms/reports; auto-flip for RTL; hardcode anything; relabel banking as "wallet"; ship a color-only tenant; copy Apple/Google/Spotify.

## 18. Self-critique → improvements (applied / tracked)

- *Tenants risk looking alike* → enforced the **6-of-12 levers** rule; per-brand motif + logomark + login shell already differentiate at a glance.
- *Default-Material risk* → expressive heroes, per-brand shape families & motion, signature motifs pull it away from stock M3.
- *Corporate over-complexity* → density is a **token** (`corporate.table.density`); progressive disclosure via detail drawers; maker-checker surfaced as a calm queue, not a wall of controls.
- *Wallet feeling like banking* → wallet is balance-led with Top-up/Add-money primary; **must not** reuse account-led banking IA.
- *Glass harming readability* → codified allow/deny surface lists (§3).
- *Token gaps* → added product & platform token layers; success/glass-tint as `ThemeExtension`s.
- *Apple/Google maturity* → obsessive spacing rhythm, real empty/loading/error states, motion that confirms not decorates, and a config model that scales — these are the maturity markers to keep raising.

## 19. Next prototype screens to build

1. **Wallet mobile** as a distinct payment-led IA (not relabeled banking).
2. **Corporate**: approval-matrix editor, audit trail, cost-center views, repair-failed-rows flow.
3. **Retail web**: transfer review→success, statements with export, security center.
4. **Onboarding/KYC** (mobile) and **corporate workspace setup** (web).
5. **Reference tenant configs** (the 5 JSON sets in §4) wired to a live theme loader.

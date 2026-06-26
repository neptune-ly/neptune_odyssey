# Changelog

All notable changes to Neptune Odyssey are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com); the system follows [Semantic Versioning](https://semver.org) against the token layer (see `docs/09-governance-and-versioning.md`).

## [1.0.0] — 2026-06-26

First stable release of **Neptune Odyssey**, the Neptune.Fintech white-label banking design system.

### Added
- **Brand identity** — the system is now **Neptune Odyssey**, published under Neptune.Fintech. Versioning, component status and a governance gate.
- **Four reference brands** — Neptune, Andalus, Nuran and **FGLB** (First Gulf Libyan), each a full M3 tonal palette × light/dark with its own corner family, type set, motif and hero emblem. FGLB is now first-class throughout (motif + emblem tokens added).
- **Five reference tenant configs** (`configs/`) — Neptune Retail, Neptune Corporate, Andalus Retail, Nuran Wallet, FGLB Retail — covering all eight white-label config layers, each documenting the brand levers it moves (≥ 6 of 12). Plus a runtime registry + live theme loader (`configs/tenants.js`).
- **Neptune Wallet Web** (`Neptune Wallet Web.dc.html`) — a payment-led wallet web reference (balance hero, add money, top-up, send/request, QR/NFC merchant pay, vouchers, activity, limits, linked cards), wired to the live tenant loader. A sibling product to retail web, not relabeled banking.
- **Corporate web depth** — audit-trail screen, editable approval-matrix editor, and a repair-failed-rows flow in bulk payments.
- **Documentation-grade reference sections** in the mobile DC — named principles, M3 state-layer + focus specs, live motion curves, the 4-pt spacing scale, an accessibility panel (contrast pairs, touch targets, checks), component anatomy, the 12-lever same-but-distinct grid, and a governance/status board.
- **Twelve brand levers, all tokenised** — the final five (login shell, dashboard hero, motion feel, glass tint, content tone) are now real per-brand tokens in `tokens/themes.css` (`--npt-ease-*`, `--npt-dur-*`, `--npt-glass-tint/-blur`, `--npt-login-shell`, `--npt-dashboard-hero`, `--npt-content-tone`) and documented in `tokens.json › levers`. The Wallet web reference applies per-brand glass tint live.
- **Brandprint** (`tools/brandprint.js`, `docs/11-config-hash.md`) — a deterministic, portable `NO1-…` theme string: pick levers → string → identical theme on any platform. Proven idempotent, checksummed, registry-versioned.
- **Build prompt** (`HANDOFF_PROMPT.md`) — the full Claude Code brief to generate the multi-framework libraries (Flutter, web, Svelte, Vue now; React/React Native/KMP roadmap), the online configurator, and publish.
- **License** (`LICENSE`) — Neptune Odyssey Community License: free for non-commercial use and for organisations under USD $25,000/yr revenue; commercial otherwise.
- **New docs** — `07-design-principles`, `08-accessibility`, `09-governance-and-versioning`, `10-token-naming`, `11-config-hash`; a `README.md` front door and this changelog.
- **Accessibility** — global keyboard-only focus ring (`:focus-visible`, token-driven) and a `prefers-reduced-motion` guard across the living references.

### Changed
- Rebranded the mobile reference header/footer to Neptune Odyssey · Neptune.Fintech, with a version badge.
- Corrected the brand count from 3 → 4 across the hero, headings and counters.
- `CLAUDE.md` and `AGENTS.md` updated for Odyssey, FGLB and the new docs.

### Notes
- All components ship **Stable** in v1.0.0 — no Beta surfaces.
- Token layer is the public API. Token renames are breaking; new tokens are minor; value fixes are patch.
- Brandprint registries are append-only; the format is version-tagged (`NO1-`).

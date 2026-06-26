# 05 · Brand identity & per-product playbook

Neptune's promise: **every bank looks like itself, not like every other Neptune bank.** Colour alone isn't enough — customers spot a reskinned template instantly. A Neptune brand is identifiable on *any* screen from six independent levers. This doc is the playbook for standing up a new bank or wallet so it feels bespoke while inheriting our engineering, accessibility and structure.

## The six identity levers (in order of recognisability)

1. **Logomark + wordmark** — a distinct mark in the brand's display face, shown top-left of the home app bar and on auth/splash. This is the fastest "which bank am I in?" signal. *(In the reference: Neptune trident, Andalus arch, Nuran star, FGLB hexagon shield.)*
2. **Signature motif** — the per-brand CSS texture behind heroes/cards (`--npt-motif` + `--npt-hero-emblem`): Neptune sonar rings, Andalus heritage arches, Nuran light-grid, FGLB concentric gulf. Carries the brand even with the logo off-screen.
3. **Colour** — full M3 tonal palette from the brand seed (light + dark), not just a primary swap.
4. **Shape** — the corner-radius family (crisp → organic). Reshapes every card, button, sheet.
5. **Type** — display + Arabic display face. The headline voice.
6. **Motion & voice** — spring feel + copy tone (Andalus warm/heritage, Nuran precise/digital, FGLB formal/premium).

**Rule:** a new brand must move **at least levers 1–4**. Colour-only is forbidden — that's the template trap we exist to kill.

## Onboarding a new bank — checklist

1. **Seed & palette** — brand primary (OKLCH) + tertiary accent → generate full role set, light + dark (see `03-theming-white-label.md`).
2. **Shape family** — pick xs…2xl to match personality (digital=tight, heritage=generous).
3. **Type** — display + text + Arabic display (`-ar`) faces; set display weight/tracking.
4. **Logomark** — author the mark (24×24, stroke-based to inherit colour) + wordmark string.
5. **Motif + emblem** — design the signature texture (pure CSS gradients, `currentColor`).
6. **Voice** — greeting, promo tone, tagline; promo/ad content set (per-brand data).
7. **Verify** — light/dark, LTR/RTL, contrast AA, both product modes. Compare to the living reference.
8. Touch **zero** component or screen code.

## Two product archetypes

The same component kit assembles into two distinct products. Selected at build/flavour time (`ProductMode`), never a user toggle.

### Banking (a licensed bank — NUB, Andalus, Nuran, FGLB…)
- **Identity:** full brand (all six levers), formal/secure tone.
- **Home:** multi-account carousel, IBAN, "Total balance".
- **Lead actions:** Send · Request · Pay bill · Scan & Pay.
- **Money in/out:** transfers hub (Between accounts, Local, **SWIFT**, Western Union, OnePay…), full card management, statements.
- **Trust surfaces:** IBAN copy/share, masking by default, biometric, trusted devices.

### Wallet (a fintech wallet product)
- **Identity:** same six levers, lighter/faster tone.
- **Home:** single **Wallet balance** + prominent **Add money** on the card.
- **Lead actions:** **Top up** · Send · Request · Scan & Pay.
- **Money in/out:** top-up rails, P2P, QR/NFC pay, vouchers/rewards forward.
- **Identity surfaces:** wallet ID/QR, cashback, lighter KYC tiers.

Both have cards; both inherit masking, copy/share, multi-session, personalization. The difference is **home composition + lead actions + hero caption** — a layout config, not a fork.

## How a bank vs a wallet stays unique *and* on-brand

| | Shared (our vibe) | Per-implementation (their identity) |
|---|---|---|
| Structure, flows, a11y, motion grammar | ✅ fixed | — |
| Components (card, list, sheet, field…) | ✅ fixed | — |
| Colour / shape / type / motif / logo / voice | — | ✅ authored per brand |
| Home composition & lead actions | — | ✅ by product archetype |
| Feature set (SWIFT, top-up, vouchers…) | menu of modules | ✅ enabled per product |

A bank turns features **on**; a wallet turns a different set on. Neither rebuilds a button.

## Platforms — one system, three surfaces

- **Mobile (Flutter, production):** bottom nav + bottom sheets. `04-flutter-implementation.md`.
- **Web (internet banking):** the *same* tokens & components re-flow into a **left rail + content pane**; sheets become **dialogs**, the bottom nav becomes the rail. Card/list/button/field/masking/copy-share/balance-hero/transfer patterns are identical. See `Neptune Web Banking.dc.html` for the reference layout.
- **Back-office (non-white-label):** Neptune-core theme only, denser tables, same tokens.

Build each component once against the tokens; let the platform pick its navigation chrome. That is the whole point of the system.

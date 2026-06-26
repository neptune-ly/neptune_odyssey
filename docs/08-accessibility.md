# 08 · Accessibility

> AA is the floor, not the goal. Because accessibility lives in the **tokens**, it ships with every brand for free — but it must be verified, not assumed. This is the checklist a bank's security/compliance review will hold us to.

## Contrast

Authoring is in OKLCH, which makes perceptually even ramps — but contrast is still **measured**, per brand, per mode, before release.

| Content | Minimum (WCAG) | Where |
|---------|----------------|-------|
| Body text | **4.5:1** | All `on-surface` / `on-*-container` on their surface |
| Large text (≥ 24px or ≥ 19px bold) | **3:1** | Display, headlines, balances |
| UI components & icons | **3:1** | Borders, icon glyphs, focus ring, control outlines |
| Disabled content | exempt | …but still aim for legibility |

The `on-*` pairings are pre-validated. **If you compose a new fill** (a custom gradient, a tinted container), re-check the pair before shipping. Status colours (`success`, `error`, `tertiary`) are validated against their containers in both modes.

> Rule: status is **never** signalled by colour alone — always pair with an icon, label or shape.

## Touch & pointer targets

- Minimum **48 × 48 dp** hit area for any interactive element, even when the visual glyph is smaller (a 22px icon still gets a 48dp button).
- Targets pad to size; they never shrink to fit a dense row.
- Spacing between adjacent targets ≥ 8dp.

## Focus

- Every control has a **visible keyboard focus** indicator: a 2px `primary` ring at 2px offset.
- Keyboard-only via `:focus-visible` — never shown on mouse/touch, never suppressed with `outline:none` and left unreplaced.
- Focus order follows reading order (which follows `dir`).
- Modals trap focus; sheets return focus to their trigger on close.

## Motion

- Honour `prefers-reduced-motion: reduce` — drop travel/scale/overshoot to near-instant cross-fades.
- No essential information is conveyed by motion alone.
- Nothing flashes more than 3×/second.

## Text & language

- Respect OS text scaling to **200%** without clipping or overlap; layouts reflow, they don't truncate meaning.
- Use **tabular figures** for money so digits don't reflow as values change.
- RTL: mirror layout and directional icons (`.npt-mirror`); never mirror logos, numerals, or media controls that imply real-world direction incorrectly.
- Don't bake meaning into font choice — the text face carries content; the display face carries brand.

## Semantics (implementation)

- Use native/semantic roles (`button`, `nav`, `dialog`, `tablist`) — not styled `div`s with click handlers.
- Label icon-only controls (`aria-label`).
- Inputs have associated labels; errors are announced and described in text, not just a red border.

## Pre-release checklist (per brand × mode × direction)

- [ ] Body ≥ 4.5:1, large/UI ≥ 3:1, all roles
- [ ] Every control reachable and operable by keyboard, focus visible
- [ ] 48dp targets throughout
- [ ] Reduced-motion path verified
- [ ] 200% text scale: no clipping
- [ ] RTL mirror correct; Arabic faces load
- [ ] Status conveyed by icon/label, not colour alone

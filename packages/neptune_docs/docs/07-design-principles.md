# 07 · Design Principles

> Six rules decide every call in Neptune Odyssey. When a decision is hard, the principle wins — not the individual screen. They are the constitution the tokens, components and screens all answer to.

---

## 1. One core, many crowns
Structure is shared; only the **skin** is per-brand. A component built once must be correct for every bank, in every mode, in both directions. If a bank wants to look different, that is a *theme* change — never a component fork.

**In practice:** there is exactly one `TransactionRow`, one `BalanceHero`, one `BulkPaymentReview`. Triton and Nereid differ only in the theme object passed in.

## 2. Tokens are the contract
Components read **roles**, never literals. A colour, radius, font or spacing value hard-coded inside a widget is a defect, not a style. Tokens are the public API of the system — see `10-token-naming.md`.

**The test:** grep the component layer for `oklch(`, `#`, `Color(0xFF`, or a literal `px` radius. Any hit is a bug.

## 3. Bidirectional by birth
Every layout is authored in **logical directions** (start/end, inline/block) — RTL is a default the system is born with, not a port bolted on later. Banks are largely MENA; Arabic is a first-class citizen, including its own display/text faces per brand.

**Never** `margin-left`, `left:`, `padding-right`. Always `margin-inline-start`, `inset-inline-start`, `padding-inline-end`.

## 4. Accessibility is the floor
AA contrast, 48dp touch targets, visible keyboard focus, honoured OS text-scaling and `prefers-reduced-motion` — in **every** brand and mode. Accessibility is not a feature to add; it ships free because it lives in the tokens. See `08-accessibility.md`.

## 5. Expressive, with intent
Adopt M3 **Expressive** shape, motion and emphasis to carry brand feeling — overshoot on selection, generous corners, confident type. But expression must earn its place: it communicates state, hierarchy or brand. It is never decoration for its own sake, and never at the cost of legibility or speed.

## 6. Same, but unmistakable
The white-label rule. Twelve brand levers separate every bank; **a brand must move at least six**. Move too few and two banks look like the same app reskinned lazily; ignore the shared skeleton and they stop feeling like one product family. Six-of-twelve is the band that keeps every bank distinct *and* coherent. The twelve levers and the per-brand counts live in `03-theming-white-label.md` and `06-platform-plan.md §4`.

---

### How the principles resolve conflicts

| Tension | Resolution |
|---------|-----------|
| A bank wants a bespoke screen layout | No. Bespoke = theme (colour/shape/type/motif), not structure. (P1) |
| A one-off colour "just here" | No. Add or reuse a role; never a literal. (P2) |
| "We'll do RTL later" | No. It's already done if you used logical properties. (P3) |
| A beautiful animation that hurts contrast/motion-sensitivity | Cut or gate it behind reduced-motion. (P4, P5) |
| Two banks look too similar | Move more levers — but keep the shared skeleton. (P6) |

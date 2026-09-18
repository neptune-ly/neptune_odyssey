# Odyssey implementation-grade agent handoff — 18 September 2026

## Purpose

This is the handoff contract for agents that modify Neptune Odyssey across Figma and code.

Odyssey is not a screenshot set and not a Figma-first design exercise. It is a multi-platform design system with deterministic theming, published web/Flutter packages, KMP parity gates, white-label configuration, product grammars and real visual regression tests.

**Philosophy:** Distinct worlds. Shared trust.

The agent must preserve one shared implementation foundation while allowing product/world/tenant composition to differ.

## Source of truth

Use these together:

1. **Repository:** `neptune-ly/neptune_odyssey`
2. **Figma:** `https://www.figma.com/design/JuC8o1hJzoGv8G6EHGXoro`
3. **Shipped component contract:** `contracts/odyssey-component-contract.json`
4. **Web registration:** `packages/neptune_web_ui/src/register.ts`
5. **Flutter parity record:** `packages/neptune_flutter_ui/COVERAGE.md`
6. **KMP parity/release bar:** `packages/neptune_kmp_ui/README.md`
7. **Canonical token/codegen gates:** `.github/workflows/ci.yml`
8. **Product grammar/state policy:** `packages/neptune_product_configs/src/experience.ts` and `servicing.ts` on the product-world branch

The 304-item Figma catalogue is **target scope**, not proof that 304 implementation components ship.

## Non-negotiable engineering rules

- Do not create tenant/bank-specific component forks.
- Do not branch component code on bank/customer name.
- A product is configuration and composition, not a duplicate widget library.
- Implementation components use tokens/theme context only. No literal colours, radii or fonts.
- Preserve light/dark, LTR/RTL, reduced-motion and accessible target-size behavior.
- Web is not a stretched mobile layout.
- Money, authorization, pending, failed, reversed and unknown states remain explicit.
- Do not treat artwork as evidence of booking/payment/driver/provider success.
- Do not silently queue financial actions offline.
- Keep numeric identifiers, amounts, PNRs, plates and similar identifiers logically ordered in RTL.
- Do not publish packages or merge to main unless explicitly requested.

## Current shipped parity

As of 18 September 2026:

- 89 registered web custom elements are parsed from `packages/neptune_web_ui/src/register.ts`.
- 88 have canonical Figma component/component-set node mappings.
- 1 is intentionally non-visual: `npt-toast-host`, a runtime host/queue API.
- 0 shipped web tags are unclassified in the component contract.
- Native Figma Code Connect is not enabled for the current Figma seat, so the authoritative fallback is the repo contract + canonical node IDs + Figma shared plugin metadata.
- The 304-item Figma catalogue remains target inventory and must not be described as 304 shipped widgets.

The component drift checker fails if web registration and the contract diverge, if a canonical Figma mapping lacks a node ID/name, or if a host API pretends to have a visual node.

## Component workflow

Before changing or adding a component:

1. Locate the entry in `contracts/odyssey-component-contract.json`.
2. Confirm the registered web tag and Flutter mapping.
3. Check whether Figma status is:
   - `canonical`: update the mapped Figma component, not a duplicate.
   - `mapped-pattern`: reuse the mapped composition and decide whether a real canonical component is now justified.
   - `missing-canonical`: do not fake completion. Implement a real semantic/state component or leave status missing.
4. Confirm whether Flutter intentionally uses themed Material directly instead of a wrapper.
5. Check KMP parity expectations and existing gallery/golden coverage.
6. Update the implementation and tests.
7. Update the Figma component with the same state/variant semantics.
8. Update the contract only when the real shipped or canonical surface changed.
9. Run the contract drift checker.

## Figma component requirements

A Figma component is implementation-grade only if:

- its semantic role maps to shipped code or an explicit approved new contract;
- states/variants match implementation behavior;
- dimensions and interaction targets are realistic;
- tokens/variables are used instead of hard-coded brand values;
- RTL and dark behavior are defined;
- loading/error/disabled/pending states exist where applicable;
- financial/safety states do not rely on colour alone;
- it is named as a reusable system component, not as a screen-specific decoration.

Product composites such as Orbit flight offers or Move ride-choice rows may exist when the domain has a genuine ordering/state contract. They remain layered over shared Odyssey primitives.

## Illustration contract

Vega is the craft benchmark, not a skin.

Production illustration construction:
- soft editorial field;
- one dominant subject;
- visible confident contour;
- slight editorial tilt;
- two or three disciplined accent colours;
- sparse motion/spark marks;
- one meaningful contextual prop.

Orbit and Move change the subject vocabulary, not the craft quality.

Illustration never replaces semantic status, totals, references, or evidence.

## Platform parity

### Web
The registered custom-element surface is canonical for the shipped web component count. `register.ts` and the contract must match exactly.

### Flutter
Use `COVERAGE.md` as the parity record. Some web components intentionally map to themed Material widgets or data-driven compositions rather than one-to-one wrappers. Do not invent a wrapper just to make names line up.

### KMP
KMP is promoted and guarded by goldens, no-literal checks, multi-target builds and render sweeps. Exact symbol-level mapping should be verified in source before claiming a Figma component is KMP-canonical.

## Product worlds

The shared component contract is independent from product grammar.

- Vega: wallet/payments.
- Orbit: travel commerce and agency operations.
- Move: mobility/ride-hailing.
- Other product grammars remain configuration/recipe layers.

Product/world/tenant identity are independent axes.

## Required checks

At minimum:

```sh
node tools/check-component-contract.mjs
node tools/codegen.mjs --check
node tools/contrast-check.mjs
pnpm -r --filter "./packages/**" run build
pnpm -r --filter "./packages/**" run test
```

Then run platform-specific Flutter/KMP/native checks relevant to the change.

CI already contains:
- P2 no-literals gate;
- token/codegen drift gate;
- WCAG contrast gate;
- Flutter tests/goldens;
- KMP goldens/build/render sweep;
- web visual sweep.

## Evidence an agent must leave

For each meaningful change, report:

- repository branch/ref;
- files changed;
- component contract entries touched;
- Figma component node IDs touched;
- variants/states added or changed;
- code tests/goldens run and outcome;
- RTL/dark/reduced-motion behavior checked;
- any platform parity gap still open;
- no claim of completion for anything not implemented/tested.

## Current Figma direction

Canonical visual work must use the Vega-DNA quality gate already documented in Odyssey. Gold-standard Move/Orbit screens are reference compositions, not permission to create screen-specific component forks.

Legacy exploration rows remain flow references only.

## Code Connect

Native Figma Code Connect is preferable when the account plan supports it. If unavailable, use:
- the machine-readable repo contract;
- canonical Figma node IDs;
- shared plugin metadata on Figma components;
- the parity board in the Odyssey Figma file.

Do not claim Code Connect is configured when it is not.

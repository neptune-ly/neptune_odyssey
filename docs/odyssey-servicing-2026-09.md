# Odyssey continuation: Orbit aftercare and Move driver readiness

This is an additive batch in the existing Odyssey file and PR #3. It does not restart the design system, rename its six original visual worlds, or publish a package. Neptune Orbit uses the Voyage product recipe; Neptune Move uses Pulse. Both continue using the existing shared controls, semantic roles and accessibility/interaction rules.

## Review entry points

- [Delivery board](https://www.figma.com/design/JuC8o1hJzoGv8G6EHGXoro?node-id=353-168)
- [Orbit after-booking prototype](https://www.figma.com/proto/JuC8o1hJzoGv8G6EHGXoro?node-id=343-980)
- [Move driver-setup prototype](https://www.figma.com/proto/JuC8o1hJzoGv8G6EHGXoro?node-id=345-1056)
- [Arabic Orbit](https://www.figma.com/proto/JuC8o1hJzoGv8G6EHGXoro?node-id=349-1023)
- [Arabic Move](https://www.figma.com/proto/JuC8o1hJzoGv8G6EHGXoro?node-id=349-1337)
- [Existing review PR](https://github.com/neptune-ly/neptune_odyssey/pull/3)

## Delivered in this batch

Seven Orbit screens cover trip care, a cancellation quote, cancellation requested, refund processing, confirmed refund, quote expiry and a closed-trip record. The original booking record is a read-only overlay, not a current ticket. Pending/completed cancellation navigation does not reopen an active cancellation action.

Six Move screens cover onboarding, document review, pending verification, a document requiring correction, approved-but-offline readiness and expired-document recovery. Provider-result actions are labelled as demo previews. Uploading files is never presented as operator approval, and approval is not presented as an assigned ride.

All thirteen screens have Arabic counterparts. The new batch also includes four dark previews and two read-only booking overlays, one per language. The Arabic approved-driver screen explicitly hands off to the existing English driver workspace; full Arabic coverage of all older driver operations remains unfinished.

The native Figma output adds two original reusable flat illustrations: `O2/Scene/Orbit aftercare` (`341:201`) and `O2/Scene/Move driver onboarding` (`342:203`). Named groups separate architectural, luggage, ticket, document, driver, vehicle and environment elements. Colors bind to existing Voyage/Pulse/shared tokens. No new parallel palette or illustration raster layer was introduced.

SVG geometry was exported from those actual components into:

- `site/product-worlds/assets/orbit-aftercare.svg`
- `site/product-worlds/assets/move-driver-onboarding.svg`

The repository assets replace exported literal paints with the existing recipe CSS variables and light fallbacks. Degenerate zero-area black fill paths from the export were omitted. Group identifiers remain available for controlled motion. Render the SVG inline inside the appropriate `data-recipe` container to inherit theme variables; an external `<img>` does not inherit the parent's CSS variables. No animation is active in these assets. Keep confirmation, security and live driver-navigation views restrained and respect reduced motion.

## Code and integration contract

`packages/neptune_product_configs/src/servicing.ts` is exported through the existing package entry point. It reuses `Money`, `sumMoney` and `transitionJourney` from `experience.ts` rather than duplicating canonical arithmetic or the booking state machine.

### Orbit

`reviewCancellation` checks the booking reference and revision, exact original payment, quote issue/expiry bounds, currency/scale consistency, nonnegative fees, refund destination and the fee ceiling. The demo reconciliation is 1,250.000 paid minus 125.000 supplier penalty minus 25.000 agency fee: 1,100.000 LYD estimated refund. These values are illustrative, not a tariff.

`requestCancellation` requires explicit Boolean consent tied to the same quote, booking and revision, and revalidates the quote at submission. Its result is only `cancel_requested`. It does not cancel a supplier reservation.

`advanceAftercare` preserves the existing sequence:

```text
cancel_requested -> cancelled -> refund_pending -> refunded
```

Provider cancellation is not refund credit. A provider event and reference are required. Completed outcomes cannot silently restart a cancellation through this policy. The host remains responsible for uncertain network outcomes, authoritative status inquiry and duplicate-event handling.

### Move

`newDriverReview`, `recordDriverDocument`, `submitDriverReview` and `applyDriverDecision` model document versions and review state. Operator requirements are supplied explicitly; the module does not assume one jurisdiction's document list or insurance rules. Required expiry dates are checked at the exact boundary.

A provider decision must match the driver, vehicle and current document revision and include a review reference. Replayed approval and approval of a stale revision are rejected. Document replacement clears prior approval. Suspended drivers remain unavailable.

`canDriverGoOnline` is a fail-closed UI eligibility check: the capability must be explicitly enabled, review approved, approval unexpired, required documents current and the host snapshot still fresh. The function does not set availability or contact a dispatch service.

**This is not an authorization boundary.** The host must authenticate and order events, perform access checks, supply trusted freshness/validity deadlines, persist state, enforce idempotency and revalidate at the actual operation. A caller-supplied `authority` string or reference is not proof of authorization. No live booking, refund, identity, document upload or driving availability is changed by the Figma prototype or this module.

## Verification performed

Run the new checks from the package:

```sh
npm run test:servicing
```

Or from the repository root with TypeScript on PATH:

```sh
node packages/neptune_product_configs/test/servicing.check.mjs
```

The runner compiles the new module and its actual `experience.ts` dependency in a temporary ES2022 directory with strict checking, then executes dependency-free Node assertions. It does not replace the existing Vitest suite.

This batch: **55 checks passed, 0 failed** on Node 22.16.0 and TypeScript 5.8.3. Tested Git blob hashes were matched against the saved branch:

| File | Tested blob |
| --- | --- |
| `experience.ts` | `beff2a0dcaaa9a728c0b2a1ade269560ba71d3fc` |
| `servicing.ts` | `f09be0dda8aed620ed006f72369c40792ab4a723` |
| `servicing.check.mjs` | `535284faa306412731d27e787d158af583f357d4` |

Figma checks: 26 English/Arabic screen frames, all 52 primary/secondary footer actions connected, no invalid inspected destination, no EN/AR money mismatch, and footer bounds within every 390 x 844 viewport. Scrollable bodies keep actions fixed. English, Arabic and all four dark previews were rendered and inspected. These checks are not an accessibility certification or a substitute for device testing.

## Remaining gates

The new servicing module and art sources are not yet wired into `site/product-worlds/app.mjs`; the existing browser lab is unchanged. Its earlier 19 browser checks and 51 experience-policy checks were not rerun in this batch. Repository-wide CI, full package/workspace builds, real-device behavior and live integrations remain separate gates.

Next integration work is the interactive servicing lab, additional supplier-rejection/refund-failure recovery and the operator-side cancellation/document-review workspaces. Broader responsive templates, complete Arabic parity, framework implementations, Code Connect and package publication remain part of the larger Odyssey roadmap. No claim is made that the entire roadmap is complete.

`site/product-worlds/manifest.json` records the aggregate product-expansion scope plus this batch's exact nodes, checks and boundaries. Keep the existing draft PR for review; no merge or release was performed.

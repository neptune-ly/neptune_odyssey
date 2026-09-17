# Odyssey product expansion — 17 September 2026

## Continuation, not restart

This additive pass continues `neptune-ly/neptune_odyssey` and the existing Figma file `JuC8o1hJzoGv8G6EHGXoro`. Existing banking, wallet, corporate, merchant, identity, catalogue and framework work is preserved.

**Distinct worlds. Shared trust.** The original six worlds remain Orbit, Current, Bloom, Atelier, Signal and Horizon. Product grammar and tenant identity are independent axes. Neptune Orbit is the travel product name; its demonstration recipe reuses `voyage`, not a renamed or replaced visual world. Move uses `pulse`; commerce uses `market`.

## Delivered in this pass

| Surface | Implemented scope |
| --- | --- |
| Orbit travel | 16 English screens: discovery, flight search/results, destination, stay search/detail, flight/stay reviews, independent pending/confirmed states, itinerary, experiences, document sample, preferences |
| Move | 24 English screens: 14 rider/safety/recovery screens and 10 driver/earnings/payout screens |
| Market commerce | 11 English screens: discovery, search, product, bag, delivery, payment review, pending/confirmed order, tracking, return request and refund pending |
| Arabic | 14 representative layouts and three guided sub-flows; not full 51-screen parity |
| Dark mode | Nine semantic previews including two Arabic layouts; existing appearance tokens reused |
| Operations | Three 1440px agency/dispatch/order workspaces using existing web navigation and table components |
| Illustration | Three original grouped vector scenes; aircraft/traveler/luggage, rider/car/city, shopper/storefront/parcel; themed without rasterization |
| Motion | Three native component families, four full/reduced/rest/entered variants each, six interactive board examples |
| Code | Additive typed product grammar/state/money policy plus a runnable framework-neutral browser consumer |

Detailed entry IDs live in `site/product-worlds/manifest.json`. Counts above refer only to this pass, not the entire Odyssey file. Frames and components remain editable; no new Figma file is created.

## Component and illustration decisions

Existing Action, Field, Navigation item, Desktop navigation item and Data row APIs are reused. New domain composites add Flight offer, Ride choice, Commerce tile, Route map and five navigation glyphs. Only domain composites with a genuine ordering difference get RTL counterparts.

Scenes use strong flat silhouettes, solid colours and independently grouped objects. Use colour roles from the current product recipe; do not invent a competing primitive palette. Text and essential status must remain readable without artwork. Illustrations are decorative, not evidence of a confirmed ticket, live driver, completed payment or delivered order.

Keep geography, QR/barcode matrices, identifiers, times and numeric keypads logically ordered. RTL changes the interface around a map, not the world represented by the map. Flight and account identifiers remain isolated. Arabic is a composed layout, not a horizontally flipped screenshot.

Dark mode adapts surfaces, foregrounds, map layers and scene colours deliberately. The original geometry remains editable. No font binaries are bundled; Figma uses available approved fonts, while the offline lab uses system fallbacks.

## Motion contract

Full discovery scene entrance: 16px travel, 420ms, no endless looping. Reduced counterpart: static artwork, at most brief non-spatial feedback. Existing O2 motion token references are preserved in code. Security, financial confirmation and driver navigation are guarded contexts and cannot opt into decorative expressive motion. The browser lab reads the device reduced-motion preference; Figma uses explicit demonstration variants rather than claiming OS preference detection.

## Domain trust contracts

### Travel

Quotes expire; revalidate availability, currency, total and provider terms. Authorization, supplier confirmation and ticket issuance are distinct. A cached itinerary is not proof of a currently valid booking. The design travel document is explicitly not a boarding pass or usable ticket.

Sample flight: DA 218, MJI 09:10 to IST 13:20 on 18 December 2026; 3h10 duration. The fare is 1,150.000 + 100.000 = 1,250.000 LYD. Sample stay: four nights at 280.000 = 1,120.000 LYD. These are synthetic offers, not market prices or actual availability.

### Mobility and driver operations

Quote, request, acceptance, arrival, trip start, trip completion and payment confirmation are different states. Show location freshness and stale/reconnecting states in the implementation. Do not display emergency services as operational until the authorized provider exists.

Sample fare: 16.000 + 2.000 service fee = 18.000 LYD. Driver illustration: 186.000 gross - 18.600 platform fees = 167.400 net. Before payout: 120.000 available + 47.400 pending. Reserving 100.000 leaves 20.000 available + 47.400 pending + 100.000 reserved = 167.400. A requested payout is not a confirmed bank credit.

### Commerce

Item, cart, inventory reservation, authorization, order confirmation, fulfilment, delivery and refund require separate status. Sample cart: 145.000 bag + 220.000 trainer + 15.000 delivery = 380.000 LYD. The trainer is explicitly already in the sample bag. Refund requested is not refund completed; retain the original order and provider references.

### Code boundary

`transitionJourney` accepts trusted, ordered, deduplicated host events. Its authority field and reference checks are UI policy, not cryptographic authentication, idempotency storage or a backend ledger. Unknown outcomes prohibit blind resubmission. BigInt minor-unit arithmetic prevents floating-point totals; the host still supplies approved currency scale and tariff data.

## Validation performed

- Strict TypeScript compilation of the new policy source.
- 51 local Node policy checks: product/world separation, opt-in capabilities, invalid values, RTL, guarded/reduced motion, exact money totals, quote expiry and state/authority/retry behaviour.
- 19 local Chromium browser checks: SVG loading, booking/ride/order/refund events, unknown-result retry protection, real Arabic DOM direction, computed dark surfaces, LTR money, reduced motion, phone overflow and JavaScript errors.
- Figma: all primary actions in 51 new English and 14 representative Arabic screens have reactions. English travel/mobility, commerce and Arabic wiring batches reported no rejected destinations. Relevant screens, dark variants and desktop layouts were inspected as screenshots.

This is not repository-wide CI, a production security audit, complete accessibility certification or native framework parity. Provider, network, screen-reader, large-text, keyboard coverage beyond these checks and real device testing remain necessary.

## Release gates still open

1. Review and merge this branch; regenerate/build through the normal workspace toolchain and run the repository's existing test suites.
2. Expand representative Arabic layouts to full journey parity; extend tablet/responsive variants and real native renderer consumers.
3. Reconcile the scoped recipe CSS with the canonical token-generation pipeline without changing the original worlds or breaking existing packages.
4. Complete remaining catalogue implementation and documentation, framework parity, platform widgets/intents and CLI/scaffolding integration according to the existing roadmap.
5. Connect authorized airline/hotel, map/dispatch, card/payment, courier/refund and operational permission/audit providers; validate state event sequencing and reconciliation.
6. Review legally approved terms, cancellation/refund policies, privacy and real tenant brand assets. Do not invent logos or infer licenses.
7. Validate the shared library/Code Connect mapping, full accessibility and regression tests; publish packages and GitHub Pages only after explicit release approval.

Banking, corporate, merchant and other non-financial examples already in Odyssey were inspected/preserved, not represented as newly completed applications. This branch defines twelve product grammars; it does not claim twelve production-ready apps.

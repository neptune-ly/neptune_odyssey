# Odyssey: shared servicing workspace and operator reviews

Continuation of the existing Orbit/Move work, not a new design system. The canonical experience and servicing policies, recipe CSS and original artwork remain unchanged.

## Open and build

The product-worlds landing page links to `site/product-worlds/servicing.html`. Build first:

```sh
npm exec --yes --package=typescript@5.6.3 -- node tools/build-servicing-lab.mjs
node --test tests/servicing-session.test.mjs
```

The build compiles the existing `packages/neptune_product_configs/src/servicing.ts` and its experience dependency with strict TypeScript settings. It produces ignored `_servicing/` modules and `servicing-standalone.html`. The latter is a self-contained offline review artifact: open it in a browser without a server. It contains no font binaries or external runtime dependencies.

The original purchase/ride/commerce lab is preserved. This addition is a linked servicing workspace with separately seeded demo cases; it does not silently reuse the original lab's purchase-state session. Within the new workspace, traveller/agency and driver/operator views share one in-memory case per product.

## Behaviour

Orbit uses the existing example OR-DEMO-021 / r1 and quote CQ-021: 1,250.000 LYD original payment, 125.000 supplier penalty, 25.000 agency fee, 1,100.000 estimated return. Consent must match the current quote and booking revision. Expired quotes require renewal and fresh consent. Supplier cancellation, refund processing and provider-confirmed credit are separate events. Duplicate references, stale revisions and invalid event order are rejected without mutating the case.

Move uses DR-DEMO-1042 and VEH-DEMO-1042 with identity, licence and insurance documents. Submission is not approval. The operator checks the current document revision, writes a note and queues a decision. A distinct simulated provider acknowledgement applies it. Approved drivers remain offline until they choose otherwise and satisfy document, approval and snapshot-freshness checks. Replacing a document invalidates prior approval; suspension cannot be cleared by self-upload. A local event trace retains the decision note and revision.

English/Arabic, light/dark and reduced-motion controls are functional. Amounts and identifiers use directionally isolated elements. Editable review notes survive locale/theme changes. Focus is restored after state changes, status updates use a live region, and the workspace stacks at narrow widths.

## Figma delivery

Existing file: `JuC8o1hJzoGv8G6EHGXoro`.

- Delivery board: `424:273`.
- Orbit agency EN: `403:565`, `409:17722`, `409:17850`.
- Orbit agency AR: `415:8312`, `415:8442`, `415:8572`.
- Move operations EN: `405:17449`, `410:1027`, `410:1159`, `410:1291`.
- Move operations AR: `416:1198`, `416:1330`, `416:1462`, `416:1594`.
- Dark previews: `419:2085`, `420:5975`.

These are 14 new operator screens and two dark previews, using existing Odyssey actions, navigation and original flat-vector artwork. Figma cases are guided snapshots; provider buttons explicitly simulate events. Cross-page customer links open the existing customer prototypes. The browser workspace is where both perspectives observe the same live local case state.

## Verification scope

Local results: 51 Node session tests passed; 47 offline Chromium functional/responsive checks passed. Strict canonical TypeScript policy compilation succeeded. Browser checks used Chromium 144.0.7559.96 at 390, 768 and 1440 px, exercised real controls, Arabic/dark mode, reduced motion, note preservation, focus and state transitions; the offline artifact made zero network requests and had zero JavaScript errors.

Optional browser test:

```sh
python -m pip install playwright
python -m playwright install chromium
python tests/servicing-browser.py
```

Set `CHROMIUM_PATH` for a specific executable; the test also detects `/usr/bin/chromium`. It loads the generated HTML directly rather than depending on a local HTTP server. Reports and screenshots are written to `evidence/`.

The existing manual `product-worlds-check.yml` now builds both labs, runs the new Node tests and uploads both HTML artifacts. It remains manual and does not deploy or publish. The Python browser suite is not included in that CI job. Updating the workflow is not evidence that hosted CI has run.

## Boundaries and remaining work

This is a local reference simulator, not production authentication, persistence, identity verification, settlement or dispatch. An `authority: provider` value is an explicit demo input, not a security boundary. Production must authenticate operators, validate signed provider events, enforce event ordering/idempotency, persist revisions and prevent concurrent stale writes.

Provider transports, full workspace CI, framework bindings, Safari/Firefox tests and comprehensive accessibility review remain release gates. Demo requirements and expiries are illustrative, not jurisdictional rules. Terminal/suspended or expired-decision scenarios may require resetting this bounded demo; they do not imply a complete production case-management recovery system. No real booking, refund, identity file or driver availability is changed.

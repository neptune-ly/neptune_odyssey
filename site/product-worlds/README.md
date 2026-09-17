# Odyssey product-worlds lab

A runnable reference for **Neptune Orbit** (travel), **Neptune Move** (mobility), and **Market** (commerce). This extends Odyssey; it does not replace the existing bank, wallet, merchant, framework or token packages.

## Run

From the repository root, with the workspace dependencies installed:

```sh
pnpm exec node tools/build-product-worlds.mjs
pnpm --filter @neptune.fintech/product-configs test:experience
```

Open the generated `site/product-worlds/standalone.html` directly in a browser. It includes all artwork, CSS and the compiled policy module and needs no network or font downloads. Alternatively serve the repository and open `/site/product-worlds/` for the modular version.

The generated `experience.js` and `standalone.html` are build outputs; regenerate them after source edits. `experience.ts` is the single policy source. Do not edit generated files independently.

## What is interactive

Product selection changes the primary object and composition: itinerary, route/trip, or product/order. English/Arabic changes the real DOM reading direction. Light/dark recolours the grouped SVG artwork as well as surfaces. Reduced motion follows the device preference or the explicit override.

The action panel runs local simulated user/provider/device events through the same tested state policy. Booking authorization is not supplier confirmation. Ride completion is not settlement. An order in transit is not delivered. A requested refund is not money returned. An unknown result cannot be blindly resubmitted.

This is a policy demonstration, not an authenticated backend, real checkout, map SDK, dispatch service, KYC provider or financial ledger. The event authority field is not security; the host must authenticate, order and deduplicate real events.

## Browser checks

```sh
python -m pip install playwright
python -m playwright install chromium
python tools/check-product-worlds.py
```

Set `ODYSSEY_CHROMIUM` only when a system Chromium executable is required. Reports and screenshots are written below `.artifacts/product-worlds/` by default; use `ODYSSEY_ARTIFACTS` to change the output location. Browser checks load the generated standalone document and do not need a web server.

## Sources and boundaries

- `packages/neptune_product_configs/src/experience.ts`: 12 product-grammar configurations, locale/capability resolution, money/quote validation and state policy. Configurations are not 12 complete application implementations.
- `recipes.css`: scoped bridge to the existing Figma Voyage/Pulse/Market recipes. It deliberately does not overwrite generated canonical token CSS.
- `app.mjs`: small framework-neutral reference consumer. It is not a claim of React/Vue/Svelte/Flutter/React Native/KMP parity.
- `assets/*.svg`: original editable scene geometry, also built as Figma vector components. No third-party photos, real customer logos or font files are bundled.
- `manifest.json`: actual Figma locations and scope counts for this expansion.
- `docs/odyssey-product-expansion-2026-09.md`: design and release-gate handoff.

Retain the repository's existing licence terms. No package publication or production deployment is performed by this lab.

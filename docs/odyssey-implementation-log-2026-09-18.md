# Odyssey 2.0 implementation log — 18 September 2026

Branch: `feat/odyssey-code-parity-contract-20260918`  
Base: `feat/odyssey-orbit-move-commerce-20260917`  
Draft PR: `#4`

## Outcome

Odyssey now has one executable path from the registered web surface to framework wrappers, the machine contract, audited Figma nodes, verified native symbols and named test evidence. This work did not add product screens, merge the branch or publish packages.

## Figma information architecture

The existing file was migrated in place. Valuable nodes were moved, not recreated or deleted.

- `00 · Start / Source of truth`
- `01 · Foundations`
- `02 · Identity / Themes`
- `03 · Core components / Shipped`
- `04 · Financial components / Shipped`
- `05 · Data + Operations / Shipped`
- `06 · Illustration + Motion`
- `07 · Vega`
- `08 · Orbit`
- `09 · Move`
- `10 · Web / Responsive references`
- `11 · Prototypes`
- `12 · Code parity / Implementation contract`
- `90 · Legacy / Archive`

Nine canonical nodes that still lived in legacy pages were promoted with their node IDs preserved: button, balance, transaction row, text field, app bar, navigation item, amount keypad, transfer review and quick action. The `npt-segmented-option` component set had inconsistent variant axes and was repaired in place.

All 88 canonical component/component-set descriptions now record their web tag/class, exact source file, React/Vue symbols, Flutter mapping, verified KMP status and proof location. The parity board now reports the generated framework surface and verified KMP count.

The component paint audit removed one literal fill and replaced all product-world bindings inside shared canonical components with shared identity aliases. Final live verification: zero literal solid paints and zero `o2/world/*` paint bindings across the 88 canonical nodes.

## Executable contract

`tools/generate-component-contract.mjs` derives the contract from `register.ts`, exact source declarations and the live Figma audit snapshot. Every entry records:

- web tag, class and exact source;
- canonical Figma node/page/variant axes/token-binding totals;
- generated React and Vue symbols;
- native Svelte strategy;
- verified Flutter symbol or explicit equivalent;
- exact KMP public symbol/source only where verified;
- React Native status;
- observed attributes, semantic tokens and source state signals;
- package tests, visual sweep and native proof locations.

Current counts: 89 registered tags, 88 canonical visual mappings, one host API, 68 verified exact KMP symbols and 21 entries with no claimed one-to-one KMP symbol.

## Generated wrappers

`tools/generate-framework-wrappers.mjs` owns the React and Vue wrapper blocks and has a deterministic `--check` mode. CI checks wrapper drift. Svelte remains a native custom-element consumer. The work also restored the missing React `passthrough` implementation that the existing 89 exports required.

## Verification executed

Passed:

- contract generation/check and structural drift check;
- React/Vue wrapper generation/check;
- affected Web, React, Vue, Svelte and React Native typechecks;
- 27 affected package tests (11 Web, 4 React, 3 Vue, 2 Svelte, 7 React Native);
- 176 tests across 18 repository test files via a direct Vitest sweep;
- WCAG contrast gate;
- token codegen drift gate;
- Figma visual checks for Start, Financial, Data/Operations and framework coverage.

Not claimed as passed:

- The full monorepo build stops in pre-existing `packages/neptune_product_configs/src/experience.ts` strict-null errors around lines 111–118. A clean checkout also requires tokens to build before dependent package typechecks.
- The repository-wide Vitest sweep has one unloaded suite because `site/product-worlds/_servicing/servicing.js` is absent; the other 18 files and all 176 collected tests pass.
- Web visual screenshots could not run because Playwright Chromium is absent and the environment could not complete the browser download.
- Flutter is not installed in the execution environment.
- KMP tests could not start because the Gradle wrapper distribution download was blocked by network policy. Java 17 is present.

## Continue Odyssey

1. Fix the unrelated `neptune_product_configs` strict-null build failure, then rerun the full root build/test sequence.
2. Run `node tools/web-shots.mjs <out-dir>` in an environment with Playwright Chromium.
3. Run Flutter tests/goldens with the Flutter SDK available.
4. Run `:odyssey-tokens:jvmTest` and `:odyssey-compose-ui:jvmTest`, then the KMP render/golden sweep, with Gradle dependencies available.
5. Treat the 21 unverified KMP entries as reconciliation work, not permission to invent equivalent symbols.
6. Add or change product examples only after the shared component contract and product grammar justify them.

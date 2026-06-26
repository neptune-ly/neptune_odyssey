# 09 · Governance & Versioning

> Neptune Odyssey is a product, not a folder of files. It ships on semantic versioning, components carry a status, and changes flow through one gate: **tokens first.**

## Semantic versioning — tokens are the public API

The token layer is the contract every platform consumes (`tokens/themes.css`, `tokens/tokens.json`). Versioning is defined against it:

| Change | Bump | Examples |
|--------|------|----------|
| **Major** (breaking) | `X.0.0` | Rename/remove a token or role; change a component's anatomy or required props; drop a brand. |
| **Minor** (additive) | `x.Y.0` | New token, new role, new component, new brand theme, new variant — existing usage unaffected. |
| **Patch** (fix) | `x.y.Z` | Re-tune a token *value* (contrast fix, hue nudge); bug fix that doesn't change the API. |

A token **rename is always breaking** even if the value is identical — downstream code keys on the name. Deprecate first (alias old → new for one minor), then remove on the next major.

## Component status

Every component advertises a status so teams know what they can build on:

| Status | Meaning | Guarantee |
|--------|---------|-----------|
| **Stable** | Production-ready, API frozen within the major. | Safe to build on; breaking changes only on a major + migration note. |
| **Beta** | Usable, API may still shift. | Build with care; expect minor adjustments. |
| **Experimental** | Preview / RFC. | Do not ship to customers. |

Current (v1.0): Buttons, FAB, chips, inputs, selection, cards, lists, sheets, navigation, app bars, charts/insights and corporate data tables → all **Stable**. No surface ships as Beta in v1.0.0.

## The one gate: tokens first

Every visual change is proposed as a **token change first**, then components inherit it. You may not "fix it in the component."

```
propose token / role / status change
        │
        ▼
validate: light + dark · LTR + RTL · AA contrast · all 4 brands
        │
        ▼
version it (major / minor / patch)  →  update tokens.json + themes.css + CHANGELOG
        │
        ▼
components & screens inherit — no per-brand edits
```

## Adding or onboarding a bank

A new bank is **one tenant config set** — not a fork. See `configs/*.tenant.json` for the five reference tenants and `06-platform-plan.md §4` for the eight config layers.

1. Author the config: seed hue(s) → full M3 tonal palette, corner family, type set, motif + emblem, content/feature/compliance layers.
2. Confirm it moves **≥ 6 of 12** brand levers (the same-but-distinct rule).
3. Validate light + dark, LTR + RTL, AA contrast.
4. Ship. **Component and screen code never changes.**

## Release discipline

- Every release updates `CHANGELOG.md` (Keep a Changelog format) and bumps `tokens.json › meta.version`.
- The living references (`Neptune Design System.dc.html`, `Neptune Web Banking.dc.html`, `Neptune Wallet Web.dc.html`) are the **visual contract** — if a build doesn't match them, the build is wrong.
- Breaking changes ship with a migration note in the changelog.

## Ownership

- **Core team** owns tokens, components, screens, principles. Changes here are reviewed against `07-design-principles.md`.
- **Bank/integration teams** own only their tenant config. They never touch core.
- A request that can't be expressed as a config change is a core proposal — it goes through the gate above.

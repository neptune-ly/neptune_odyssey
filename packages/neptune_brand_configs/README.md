# @neptune-odyssey/brand-configs

The five reference **tenant configs** for [Neptune Odyssey](https://neptune.ly) by
**Neptune.Fintech**, plus a loader that maps each tenant to a portable **brandprint**.
A new bank is **one tenant config — never a fork**.

> Source-available under the **Neptune Odyssey Community License v1.0** (see `LICENSE`).
> The example tenants (Neptune Retail/Corporate, Andalus, Nuran, FGLB) are reference
> illustrations only — they demonstrate the same-but-distinct rule (≥6 of 12 levers).

## Install

```sh
pnpm add @neptune-odyssey/brand-configs @neptune-odyssey/tokens
```

## Use

```ts
import { listTenants, themeInputForTenant } from "@neptune-odyssey/brand-configs";
import { applyTheme } from "@neptune-odyssey/web-ui";

for (const t of listTenants()) console.log(t.id, t.brand, t.flavor, t.leversMoved);

// theme any library from a tenant id — same brandprint everywhere
applyTheme(document.documentElement, themeInputForTenant("andalus-retail"), { mode: "system" });
```

`getTenant(id)` returns the full config (brand levers, product flavor, feature flags,
content EN/AR, compliance). `passesSameButDistinct(id)` enforces the ≥6-of-12 rule.

---
© 2026 Neptune.Fintech.

# @neptune.fintech/product-configs

The **product-flavor + feature-flag** layer of [Neptune Odyssey](https://neptune.ly) by
**Neptune.Fintech** (config layers C + D from the platform plan). Which experience is
active (retail mobile / wallet / corporate web / …) and which features are on is a
**configuration**, not a code path.

> Source-available under the **Neptune Odyssey Community License v1.0** (see `LICENSE`).

## Install

```sh
pnpm add @neptune.fintech/product-configs @neptune.fintech/brand-configs
```

## Use

```ts
import { getProductConfig, isFeatureEnabled, enabledFeatures } from "@neptune.fintech/product-configs";

getProductConfig("nuran-wallet");            // { flavor, density, platforms, features }
isFeatureEnabled("nuran-wallet", "wallet");  // true
isFeatureEnabled("neptune-retail", "cards.freeze"); // true (nested → dot-path)
enabledFeatures("neptune-corporate");        // ["accounts", "approvals", "userManagement", …]
```

---
© 2026 Neptune.Fintech. The bundled example tenants are reference illustrations only.

// Neptune Odyssey — @neptune.fintech/product-configs · © 2026 Neptune.Fintech (neptune.ly)
// Product-flavor + feature-flag layer (config layers C + D from docs/06 §4). Reads
// the reference tenants and exposes typed flavor/density/feature lookups. A product
// is a configuration, not a code path. Licensed under the Community License v1.0.

import { TENANTS, type TenantId } from "@neptune.fintech/brand-configs";

export type { TenantId };

export type Density = "comfortable" | "compact" | "standard" | "dense" | "executive";

export interface ProductConfig {
  /** active product flavor string, e.g. "retail-mobile+retail-web" | "corporate-web" | "wallet-mobile+wallet-web" */
  flavor: string;
  density: Density;
  platforms: readonly string[];
  /** flattened feature flags (dot-paths → boolean) */
  features: Record<string, boolean>;
}

function flatten(obj: unknown, prefix = ""): Record<string, boolean> {
  const out: Record<string, boolean> = {};
  if (obj && typeof obj === "object") {
    for (const [k, v] of Object.entries(obj as Record<string, unknown>)) {
      const key = prefix ? `${prefix}.${k}` : k;
      if (typeof v === "boolean") out[key] = v;
      else if (v && typeof v === "object") Object.assign(out, flatten(v, key));
    }
  }
  return out;
}

const CONFIGS: Record<TenantId, ProductConfig> = Object.fromEntries(
  (Object.keys(TENANTS) as TenantId[]).map((id) => {
    const t = TENANTS[id];
    return [
      id,
      {
        flavor: t.productFlavor.active,
        density: t.productFlavor.density as Density,
        platforms: t.productFlavor.platforms,
        features: flatten(t.features),
      } satisfies ProductConfig,
    ];
  }),
) as unknown as Record<TenantId, ProductConfig>;

/** The product config (flavor, density, platforms, flags) for a tenant. */
export function getProductConfig(id: TenantId): ProductConfig {
  return CONFIGS[id];
}

/**
 * Is a feature enabled for a tenant? Accepts a dot-path, e.g.
 * `isFeatureEnabled("nereid-wallet", "wallet")` or `"cards.freeze"`.
 */
export function isFeatureEnabled(id: TenantId, featurePath: string): boolean {
  return CONFIGS[id].features[featurePath] ?? false;
}

/** Every enabled feature path for a tenant. */
export function enabledFeatures(id: TenantId): string[] {
  return Object.entries(CONFIGS[id].features)
    .filter(([, on]) => on)
    .map(([k]) => k);
}

export const PRODUCT_CONFIGS_VERSION = "2.0.0";

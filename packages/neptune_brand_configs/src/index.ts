// Neptune Odyssey — @neptune.fintech/brand-configs · © 2026 Neptune.Fintech (neptune.ly)
// The five reference tenant configs + a loader that maps each tenant to a theme
// input (a brandprint string) for any Odyssey library. A new bank is ONE tenant
// config — never a fork. Licensed under the Neptune Odyssey Community License v1.0.

import { TENANTS } from "./tenants.generated.js";
import { BRAND_BRANDPRINT, type Brand, type ThemeInput } from "@neptune.fintech/tokens";

export type TenantId = keyof typeof TENANTS;
export type Tenant = (typeof TENANTS)[TenantId];

export const TENANT_IDS = Object.keys(TENANTS) as TenantId[];

/** All reference tenants, keyed by id. */
export { TENANTS };

/** Look up a tenant config by id. */
export function getTenant(id: TenantId): Tenant {
  return TENANTS[id];
}

/** List every reference tenant (id + display name + brand + flavor). */
export function listTenants(): Array<{
  id: TenantId;
  displayName: string;
  brand: Brand;
  flavor: string;
  leversMoved: number;
}> {
  return TENANT_IDS.map((id) => {
    const t = TENANTS[id];
    return {
      id,
      displayName: t.tenant.displayName,
      brand: t.brand.theme as Brand,
      flavor: t.productFlavor.active,
      leversMoved: t.levers.count,
    };
  });
}

/** The reference brand a tenant skins from. */
export function brandForTenant(id: TenantId): Brand {
  return TENANTS[id].brand.theme as Brand;
}

/**
 * The theme input for a tenant — its brand's canonical brandprint string.
 * Pass straight to applyTheme() (web) or NeptuneTheme.fromBrandprint() (Flutter).
 * Same string ⇒ same theme on every platform.
 */
export function themeInputForTenant(id: TenantId): ThemeInput {
  return BRAND_BRANDPRINT[brandForTenant(id)]!;
}

/** Verify a tenant satisfies the same-but-distinct rule (≥6 of 12 levers). */
export function passesSameButDistinct(id: TenantId): boolean {
  return TENANTS[id].levers.count >= 6;
}

export const BRAND_CONFIGS_VERSION = "2.0.0";

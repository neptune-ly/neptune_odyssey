import { describe, it, expect } from "vitest";
import {
  TENANT_IDS,
  getTenant,
  listTenants,
  brandForTenant,
  themeInputForTenant,
  passesSameButDistinct,
} from "../src/index.js";
import { buildTheme, decode } from "@neptune-odyssey/tokens";

describe("@neptune-odyssey/brand-configs", () => {
  it("ships the 5 reference tenants", () => {
    expect(TENANT_IDS).toHaveLength(5);
    expect(TENANT_IDS).toContain("nuran-wallet");
  });

  it("every tenant satisfies the same-but-distinct rule (≥6 of 12 levers)", () => {
    for (const id of TENANT_IDS) expect(passesSameButDistinct(id)).toBe(true);
  });

  it("each tenant maps to a valid, decodable brandprint that themes to its brand", () => {
    for (const id of TENANT_IDS) {
      const input = themeInputForTenant(id) as string;
      expect(input.startsWith("NO1-")).toBe(true);
      expect(() => decode(input)).not.toThrow();
      const theme = buildTheme(input, { mode: "light" });
      expect(theme.brand).toBe(brandForTenant(id));
    }
  });

  it("listTenants returns display metadata", () => {
    const list = listTenants();
    expect(list.find((t) => t.id === "andalus-retail")?.brand).toBe("andalus");
    expect(getTenant("neptune-corporate").productFlavor.active).toContain("corporate");
  });
});

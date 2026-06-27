import { describe, it, expect } from "vitest";
import { getProductConfig, isFeatureEnabled, enabledFeatures } from "../src/index.js";

describe("@neptune.fintech/product-configs", () => {
  it("wallet flavor enables wallet features; retail does not", () => {
    expect(isFeatureEnabled("nereid-wallet", "wallet")).toBe(true);
    expect(isFeatureEnabled("neptune-retail", "wallet")).toBe(false);
  });

  it("flattens nested flags into dot-paths", () => {
    expect(isFeatureEnabled("neptune-retail", "cards.freeze")).toBe(true);
    expect(isFeatureEnabled("neptune-retail", "transfers.swift")).toBe(true);
  });

  it("corporate enables maker-checker approvals + userManagement", () => {
    expect(isFeatureEnabled("neptune-corporate", "approvals.makerChecker")).toBe(true);
    expect(isFeatureEnabled("neptune-corporate", "batches.fileUpload")).toBe(true);
    expect(isFeatureEnabled("neptune-corporate", "userManagement")).toBe(true);
  });

  it("exposes flavor + density + platforms", () => {
    const cfg = getProductConfig("neptune-corporate");
    expect(cfg.flavor).toContain("corporate");
    expect(cfg.density).toBeTruthy();
    expect(cfg.platforms.length).toBeGreaterThan(0);
  });

  it("enabledFeatures returns only the on flags", () => {
    const feats = enabledFeatures("nereid-wallet");
    expect(feats).toContain("wallet");
    expect(feats).not.toContain("approvals");
  });
});

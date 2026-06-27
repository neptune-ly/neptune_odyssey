// @vitest-environment jsdom
import { describe, it, expect } from "vitest";
import {
  NeptuneProvider,
  NptButton,
  NptBalanceCard,
  applyTheme,
  buildTheme,
  VUE_UI_VERSION,
} from "../src/index.js";

describe("@neptune.fintech/vue-ui surface", () => {
  it("exports the provider + wrappers as Vue components", () => {
    expect(NeptuneProvider.name).toBe("NeptuneProvider");
    expect(NptButton.name).toBe("NptButton");
    expect(NptBalanceCard.name).toBe("NptBalanceCard");
  });

  it("re-exports a working theming surface", () => {
    const root = document.createElement("div");
    document.body.appendChild(root);
    const h = applyTheme(root, "fglb", { mode: "light" });
    expect(root.dataset.theme).toBe("fglb");
    expect(buildTheme("fglb").brand).toBe("fglb");
    expect(h.theme.brand).toBe("fglb");
  });

  it("is version 1.0.0 (stable)", () => {
    expect(VUE_UI_VERSION).toBe("1.0.0");
  });
});

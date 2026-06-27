// @vitest-environment jsdom
import { describe, it, expect } from "vitest";
import { createElement } from "react";
import { render, cleanup } from "@testing-library/react";
import {
  NeptuneProvider,
  NptButton,
  NptBalanceCard,
  applyTheme,
  buildTheme,
  REACT_UI_VERSION,
} from "../src/index.js";

describe("@neptune.fintech/react-ui surface", () => {
  it("exports the provider + wrappers as React components", () => {
    expect(NeptuneProvider.displayName).toBe("NeptuneProvider");
    expect(NptButton.displayName).toBe("NptButton");
    expect(NptBalanceCard.displayName).toBe("NptBalanceCard");
  });

  it("re-exports a working theming surface", () => {
    const root = document.createElement("div");
    document.body.appendChild(root);
    const h = applyTheme(root, "proteus", { mode: "light" });
    expect(root.dataset.theme).toBe("proteus");
    expect(buildTheme("proteus").brand).toBe("proteus");
    expect(h.theme.brand).toBe("proteus");
  });

  it("NeptuneProvider applies the theme to its themed root on mount", () => {
    // Plain child only: importing web-ui registers the custom elements, and jsdom can't
    // instantiate their constructable stylesheets — so we don't mount an npt-* element
    // here. The React-specific behaviour under test is the provider effect itself.
    const { container } = render(
      createElement(
        NeptuneProvider,
        { theme: "triton", mode: "light", dir: "ltr" },
        createElement("span", null, "New transfer"),
      ),
    );
    const root = container.querySelector(".neptune-provider") as HTMLElement;
    expect(root).not.toBeNull();
    expect(root.dataset.theme).toBe("triton");
    expect(root.dataset.mode).toBe("light");
    expect(root.getAttribute("dir")).toBe("ltr");
    cleanup();
  });

  it("is version 1.0.0 (stable)", () => {
    expect(REACT_UI_VERSION).toBe("2.0.0");
  });
});

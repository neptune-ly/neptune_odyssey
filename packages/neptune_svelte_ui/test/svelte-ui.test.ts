// @vitest-environment jsdom
import { describe, it, expect } from "vitest";
import { theme, buildTheme, SVELTE_UI_VERSION } from "../src/index.js";

describe("@neptune.fintech/svelte-ui surface", () => {
  it("the use:theme action applies and updates a theme", () => {
    const node = document.createElement("div");
    document.body.appendChild(node);
    const action = theme(node, { input: "triton", mode: "light" });
    expect(node.dataset.theme).toBe("triton");

    action.update({ input: "nereid", mode: "dark" });
    expect(node.dataset.theme).toBe("nereid");
    expect(node.dataset.mode).toBe("dark");

    action.destroy();
  });

  it("re-exports buildTheme and is stable v2.0.0", () => {
    expect(buildTheme("neptune").brand).toBe("neptune");
    expect(SVELTE_UI_VERSION).toBe("2.0.0");
  });
});

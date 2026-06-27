// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// Node-env unit tests. We deliberately test ONLY the non-RN logic: the pure style
// helpers and the React-only context module. We do NOT import `../src/index.ts` or any
// `components/*` file, because those import `react-native`, which is not installed and
// would crash under node. Licensed under the Neptune Odyssey Community License v1.0.

import { describe, it, expect } from "vitest";
import { buildTheme } from "@neptune.fintech/tokens";
import { radius, colorOf, makeThemedStyles, SPACE } from "../src/styles.js";
import { NeptuneProvider, useNeptuneTheme } from "../src/context.js";

describe("@neptune.fintech/react-native-ui — non-RN logic", () => {
  const theme = buildTheme("triton", { mode: "light", dir: "ltr" });

  it("buildTheme passthrough resolves the requested brand", () => {
    expect(theme.brand).toBe("triton");
    expect(theme.mode).toBe("light");
    expect(theme.dir).toBe("ltr");
  });

  it("radius() returns a number from the theme shape scale", () => {
    expect(typeof radius(theme, "md")).toBe("number");
    expect(radius(theme, "full")).toBe(theme.shape.full);
  });

  it("colorOf() returns the theme hex for a role", () => {
    expect(colorOf(theme, "primary")).toBe(theme.colors.primary);
    expect(colorOf(theme, "primary")).toMatch(/^#[0-9a-fA-F]{6}$/);
  });

  it("makeThemedStyles() maps theme values onto RN-shaped fragments", () => {
    const s = makeThemedStyles(theme);
    expect(s.screen.backgroundColor).toBe(theme.colors.background);
    expect(s.surface.borderRadius).toBe(theme.shape.lg);
    expect(s.textNum.fontVariant).toContain("tabular-nums");
    expect(s.textBody.fontFamily).toBe(theme.type.text);
  });

  it("exposes a stable spacing scale", () => {
    expect(SPACE.md).toBe(12);
  });

  it("provider + hook are exported functions", () => {
    expect(typeof NeptuneProvider).toBe("function");
    expect(typeof useNeptuneTheme).toBe("function");
  });

  it("useNeptuneTheme throws when invoked outside React's render cycle", () => {
    // Called bare (no provider, no render), the hook must fail loudly rather than
    // return undefined — React's dispatcher itself throws here, before our guard.
    expect(() => useNeptuneTheme()).toThrow();
  });
});

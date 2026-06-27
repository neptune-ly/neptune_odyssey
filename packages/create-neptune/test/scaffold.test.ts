import { existsSync, promises as fs } from "node:fs";
import os from "node:os";
import path from "node:path";

import { afterAll, describe, expect, it } from "vitest";

import { FRAMEWORKS, frameworkById, type Brand } from "../src/frameworks.js";
import {
  applyTokens,
  normalizeForFramework,
  replacements,
  scaffold,
  templatesRoot,
} from "../src/scaffold.js";

const TOKEN_RE = /\{\{[A-Z0-9_]+\}\}/;
const tmpDirs: string[] = [];

async function freshDir(): Promise<string> {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "create-neptune-"));
  tmpDirs.push(dir);
  return dir;
}

afterAll(async () => {
  await Promise.all(tmpDirs.map((d) => fs.rm(d, { recursive: true, force: true })));
});

describe("applyTokens", () => {
  it("replaces known tokens and leaves unknown ones untouched", () => {
    const out = applyTokens("{{BRAND}} {{MYSTERY}}", { BRAND: "triton" });
    expect(out).toBe("triton {{MYSTERY}}");
  });
  it("ignores lowercase / spaced braces (so JSX object literals survive)", () => {
    expect(applyTokens("style={{ color: 'red' }}", { BRAND: "x" })).toBe(
      "style={{ color: 'red' }}",
    );
  });
});

describe("normalizeForFramework", () => {
  it("downgrades system→light and auto→ltr for runtimes that lack them", () => {
    expect(normalizeForFramework("react-native", "system", "auto")).toEqual({
      mode: "light",
      dir: "ltr",
    });
  });
  it("keeps system/auto for web-class runtimes", () => {
    expect(normalizeForFramework("web", "system", "auto")).toEqual({
      mode: "system",
      dir: "auto",
    });
  });
});

describe("replacements", () => {
  it("maps brand, mode, dir and injects concrete versions", () => {
    const map = replacements({
      framework: "web",
      projectName: "my-bank",
      projectTitle: "My Bank",
      brand: "triton",
      mode: "dark",
      dir: "rtl",
      targetDir: "/tmp/x",
    });
    expect(map.BRAND).toBe("triton");
    expect(map.BRAND_CAP).toBe("Triton");
    expect(map.MODE).toBe("dark");
    expect(map.DIR).toBe("rtl");
    expect(map.V_WEB_UI).toMatch(/^\^?\d+\.\d+\.\d+$/);
  });
});

// Scaffold every framework whose template ships, and assert the output is clean.
const present = FRAMEWORKS.filter((f) => existsSync(path.join(templatesRoot(), f.template)));

describe("scaffold (per framework)", () => {
  it("has at least the web + react templates present", () => {
    const ids = present.map((f) => f.id);
    expect(ids).toContain("web");
    expect(ids).toContain("react");
  });

  for (const fw of present) {
    it(`scaffolds ${fw.id} with no leftover tokens`, async () => {
      const dir = await freshDir();
      const brand: Brand = "triton";
      const result = await scaffold({
        framework: fw.id,
        projectName: "acme-bank",
        projectTitle: "Acme Bank",
        brand,
        mode: "system",
        dir: "rtl",
        targetDir: dir,
      });

      expect(result.files.length).toBeGreaterThan(0);

      // No template file leaves an unresolved {{TOKEN}} behind.
      for (const rel of result.files) {
        const buf = await fs.readFile(path.join(dir, rel), "utf8");
        expect(TOKEN_RE.test(buf), `leftover token in ${rel}`).toBe(false);
      }

      // Dotfiles were un-underscored.
      expect(result.files.some((f) => f.startsWith("_"))).toBe(false);

      // The project name landed in the manifest.
      const manifest = fw.id === "flutter" ? "pubspec.yaml" : "package.json";
      expect(result.files).toContain(manifest);
      const text = await fs.readFile(path.join(dir, manifest), "utf8");
      expect(text).toContain(fw.id === "flutter" ? "acme_bank" : "acme-bank");

      // The runtime's mode/dir were normalized for the framework.
      const norm = normalizeForFramework(fw.id, "system", "rtl");
      if (!frameworkById(fw.id)!.supportsSystemMode) expect(norm.mode).toBe("light");
    });
  }
});

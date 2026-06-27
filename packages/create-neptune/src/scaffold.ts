// Neptune Odyssey — scaffolding core for create-neptune.
// © 2026 Neptune.Fintech (neptune.ly)
//
// Copies a framework template tree into a target directory, substituting
// {{TOKENS}} in both file contents and file names. Template dotfiles are stored
// with a leading underscore (e.g. `_gitignore`) and restored to `.gitignore` on
// write so npm does not strip them from the published package.

import { promises as fs } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { NEPTUNE_VERSIONS, TOOLING_VERSIONS } from "./versions.js";
import type { Brand, DirOption, FrameworkId, ModeOption } from "./frameworks.js";
import { frameworkById } from "./frameworks.js";

export interface ScaffoldOptions {
  framework: FrameworkId;
  /** npm-safe package/dir slug, e.g. "my-bank". */
  projectName: string;
  /** Human title used in app bars / page titles, e.g. "My Bank". */
  projectTitle: string;
  brand: Brand;
  mode: ModeOption;
  dir: DirOption;
  /** Absolute path of the directory to create the app in. */
  targetDir: string;
}

export interface ScaffoldResult {
  /** Relative paths of every file written, in write order. */
  files: string[];
}

/** Absolute path to the bundled templates directory (works from src and dist). */
export function templatesRoot(): string {
  return fileURLToPath(new URL("../templates", import.meta.url));
}

const CAP = (s: string): string => (s ? s[0]!.toUpperCase() + s.slice(1) : s);

/**
 * Normalize mode/dir to what the chosen runtime actually supports, so callers
 * can pass through user input without producing an invalid starter.
 */
export function normalizeForFramework(
  framework: FrameworkId,
  mode: ModeOption,
  dir: DirOption,
): { mode: ModeOption; dir: DirOption } {
  const fw = frameworkById(framework);
  const outMode: ModeOption = fw && !fw.supportsSystemMode && mode === "system" ? "light" : mode;
  const outDir: DirOption = fw && !fw.supportsAutoDir && dir === "auto" ? "ltr" : dir;
  return { mode: outMode, dir: outDir };
}

/** The full {{TOKEN}} → value map used for substitution. */
export function replacements(opts: ScaffoldOptions): Record<string, string> {
  const { mode, dir } = normalizeForFramework(opts.framework, opts.mode, opts.dir);
  return {
    PROJECT_NAME: opts.projectName,
    // Dart/Flutter package names must be lowercase snake_case.
    PROJECT_NAME_SNAKE: opts.projectName.replace(/[-.]/g, "_"),
    PROJECT_TITLE: opts.projectTitle,
    BRAND: opts.brand,
    BRAND_CAP: CAP(opts.brand),
    MODE: mode,
    DIR: dir,
    YEAR: "2026",
    // @neptune.fintech package ranges
    V_TOKENS: NEPTUNE_VERSIONS.tokens,
    V_WEB_UI: NEPTUNE_VERSIONS.webUi,
    V_ICONS: NEPTUNE_VERSIONS.icons,
    V_REACT_UI: NEPTUNE_VERSIONS.reactUi,
    V_VUE_UI: NEPTUNE_VERSIONS.vueUi,
    V_SVELTE_UI: NEPTUNE_VERSIONS.svelteUi,
    V_RN_UI: NEPTUNE_VERSIONS.reactNativeUi,
    V_FLUTTER: NEPTUNE_VERSIONS.flutter,
    // tooling ranges
    V_VITE: TOOLING_VERSIONS.vite,
    V_TYPESCRIPT: TOOLING_VERSIONS.typescript,
    V_REACT: TOOLING_VERSIONS.react,
    V_REACT_DOM: TOOLING_VERSIONS.reactDom,
    V_REACT_TYPES: TOOLING_VERSIONS.reactTypes,
    V_REACT_DOM_TYPES: TOOLING_VERSIONS.reactDomTypes,
    V_VITE_REACT: TOOLING_VERSIONS.viteReact,
    V_VUE: TOOLING_VERSIONS.vue,
    V_VITE_VUE: TOOLING_VERSIONS.viteVue,
    V_VUE_TSC: TOOLING_VERSIONS.vueTsc,
    V_SVELTE: TOOLING_VERSIONS.svelte,
    V_VITE_SVELTE: TOOLING_VERSIONS.viteSvelte,
    V_SVELTE_CHECK: TOOLING_VERSIONS.svelteCheck,
    V_EXPO: TOOLING_VERSIONS.expo,
    V_EXPO_STATUS_BAR: TOOLING_VERSIONS.expoStatusBar,
  };
}

const TOKEN_RE = /\{\{([A-Z0-9_]+)\}\}/g;

/** Replace every {{TOKEN}} in `text`. Unknown tokens are left untouched. */
export function applyTokens(text: string, map: Record<string, string>): string {
  return text.replace(TOKEN_RE, (whole, key: string) =>
    Object.prototype.hasOwnProperty.call(map, key) ? map[key]! : whole,
  );
}

/** Restore a template file name: leading `_` → `.`, then token-substitute. */
function realName(name: string, map: Record<string, string>): string {
  const dotted = name.startsWith("_") ? "." + name.slice(1) : name;
  return applyTokens(dotted, map);
}

/** Treat as binary if the first chunk contains a NUL byte. */
function looksBinary(buf: Buffer): boolean {
  const n = Math.min(buf.length, 8000);
  for (let i = 0; i < n; i++) if (buf[i] === 0) return true;
  return false;
}

async function copyTree(
  srcDir: string,
  destDir: string,
  map: Record<string, string>,
  written: string[],
  destRoot: string,
): Promise<void> {
  await fs.mkdir(destDir, { recursive: true });
  const entries = await fs.readdir(srcDir, { withFileTypes: true });
  // Stable order so written[] is deterministic (helps tests + readable logs).
  entries.sort((a, b) => a.name.localeCompare(b.name));

  for (const entry of entries) {
    const srcPath = path.join(srcDir, entry.name);
    const outName = realName(entry.name, map);
    const destPath = path.join(destDir, outName);
    if (entry.isDirectory()) {
      await copyTree(srcPath, destPath, map, written, destRoot);
    } else if (entry.isFile()) {
      const raw = await fs.readFile(srcPath);
      if (looksBinary(raw)) {
        await fs.writeFile(destPath, raw);
      } else {
        await fs.writeFile(destPath, applyTokens(raw.toString("utf8"), map), "utf8");
      }
      written.push(path.relative(destRoot, destPath));
    }
  }
}

/**
 * Scaffold a starter app from a bundled template into `opts.targetDir`.
 * The target directory is created if needed; callers should ensure it is empty.
 */
export async function scaffold(opts: ScaffoldOptions): Promise<ScaffoldResult> {
  const fw = frameworkById(opts.framework);
  if (!fw) throw new Error(`Unknown framework: ${opts.framework}`);

  const templateDir = path.join(templatesRoot(), fw.template);
  try {
    const stat = await fs.stat(templateDir);
    if (!stat.isDirectory()) throw new Error("not a directory");
  } catch {
    throw new Error(`Missing template for "${opts.framework}" at ${templateDir}`);
  }

  const map = replacements(opts);
  const written: string[] = [];
  await copyTree(templateDir, opts.targetDir, map, written, opts.targetDir);
  written.sort();
  return { files: written };
}

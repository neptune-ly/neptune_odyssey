// Neptune Odyssey — @neptune.fintech/create-neptune
// © 2026 Neptune.Fintech (neptune.ly)
//
// Programmatic entry: import { scaffold } from "@neptune.fintech/create-neptune".
// The CLI lives in cli.ts (bin: create-neptune).

export {
  scaffold,
  replacements,
  applyTokens,
  normalizeForFramework,
  templatesRoot,
} from "./scaffold.js";
export type { ScaffoldOptions, ScaffoldResult } from "./scaffold.js";

export {
  FRAMEWORKS,
  BRANDS,
  frameworkById,
  isBrand,
} from "./frameworks.js";
export type {
  Framework,
  FrameworkId,
  Brand,
  ModeOption,
  DirOption,
} from "./frameworks.js";

export { NEPTUNE_VERSIONS, TOOLING_VERSIONS } from "./versions.js";

/** Semantic version of the CLI (kept in lockstep with package.json). */
export const CREATE_NEPTUNE_VERSION = "2.0.0";

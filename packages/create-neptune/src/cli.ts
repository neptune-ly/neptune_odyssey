#!/usr/bin/env node
// Neptune Odyssey — create-neptune CLI · © 2026 Neptune.Fintech (neptune.ly)
//
// Scaffolds a themed starter app for one of six frameworks. Interactive by
// default; fully flag-drivable for CI / non-TTY use. Zero runtime dependencies.

import { promises as fs } from "node:fs";
import path from "node:path";
import process from "node:process";
import { parseArgs } from "node:util";

import {
  BRANDS,
  FRAMEWORKS,
  frameworkById,
  isBrand,
  type Brand,
  type DirOption,
  type FrameworkId,
  type ModeOption,
} from "./frameworks.js";
import { normalizeForFramework, scaffold } from "./scaffold.js";
import { CREATE_NEPTUNE_VERSION } from "./index.js";
import {
  banner,
  c,
  errln,
  info,
  select,
  success,
  text,
  warn,
  type Choice,
} from "./term.js";

const MODES: ModeOption[] = ["light", "dark", "system"];
const DIRS: DirOption[] = ["ltr", "rtl", "auto"];

function usage(): string {
  const fws = FRAMEWORKS.map((f) => `      ${c.cyan(f.id.padEnd(14))} ${c.gray(f.blurb)}`).join(
    "\n",
  );
  return `${banner()}
  ${c.bold("Usage")}
    ${c.cyan("npx @neptune.fintech/create-neptune")} ${c.gray("[directory] [options]")}

  ${c.bold("Options")}
    -f, --framework <id>   ${c.gray("web | react | vue | svelte | react-native | flutter")}
    -b, --brand <id>       ${c.gray("neptune | triton | nereid | proteus  (default: neptune)")}
        --name <slug>      ${c.gray("npm package name (default: from directory)")}
        --title <text>     ${c.gray("display title (default: from name)")}
    -m, --mode <mode>      ${c.gray("light | dark | system  (default: system)")}
    -d, --dir <dir>        ${c.gray("ltr | rtl | auto  (default: ltr)")}
    -y, --yes              ${c.gray("accept defaults, no prompts")}
        --force            ${c.gray("scaffold into a non-empty directory")}
    -h, --help             ${c.gray("show this help")}
    -v, --version          ${c.gray("print version")}

  ${c.bold("Frameworks")}
${fws}

  ${c.bold("Examples")}
    ${c.gray("# interactive")}
    ${c.cyan("npx @neptune.fintech/create-neptune")}
    ${c.gray("# one-liner")}
    ${c.cyan("npx @neptune.fintech/create-neptune my-bank -f react -b triton")}
`;
}

/** Lowercase, npm-safe slug from arbitrary input. */
function slugify(input: string): string {
  return input
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9-~]+/g, "-")
    .replace(/^[-_.]+|[-_.]+$/g, "")
    .replace(/-{2,}/g, "-")
    .slice(0, 214);
}

/** Title-case a slug for a default display title. */
function titleCase(slug: string): string {
  return slug
    .split(/[-_]/)
    .filter(Boolean)
    .map((w) => w[0]!.toUpperCase() + w.slice(1))
    .join(" ");
}

/** npm package-name validity (the subset we care about). */
function isValidName(name: string): boolean {
  return /^[a-z0-9-~][a-z0-9-._~]*$/.test(name) && name.length <= 214;
}

async function dirIsEmpty(dir: string): Promise<boolean> {
  try {
    const entries = await fs.readdir(dir);
    return entries.filter((e) => e !== ".git").length === 0;
  } catch (err) {
    if ((err as NodeJS.ErrnoException).code === "ENOENT") return true;
    throw err;
  }
}

interface Cli {
  positionals: string[];
  framework?: string;
  brand?: string;
  name?: string;
  title?: string;
  mode?: string;
  dir?: string;
  yes: boolean;
  force: boolean;
  help: boolean;
  version: boolean;
}

function parse(argv: string[]): Cli {
  const { values, positionals } = parseArgs({
    args: argv,
    allowPositionals: true,
    options: {
      framework: { type: "string", short: "f" },
      brand: { type: "string", short: "b" },
      name: { type: "string" },
      title: { type: "string" },
      mode: { type: "string", short: "m" },
      dir: { type: "string", short: "d" },
      yes: { type: "boolean", short: "y", default: false },
      force: { type: "boolean", default: false },
      help: { type: "boolean", short: "h", default: false },
      version: { type: "boolean", short: "v", default: false },
    },
  });
  return {
    positionals,
    framework: values.framework,
    brand: values.brand,
    name: values.name,
    title: values.title,
    mode: values.mode,
    dir: values.dir,
    yes: Boolean(values.yes),
    force: Boolean(values.force),
    help: Boolean(values.help),
    version: Boolean(values.version),
  };
}

async function run(): Promise<number> {
  let cli: Cli;
  try {
    cli = parse(process.argv.slice(2));
  } catch (err) {
    errln((err as Error).message);
    process.stdout.write(usage());
    return 1;
  }

  if (cli.help) {
    process.stdout.write(usage());
    return 0;
  }
  if (cli.version) {
    process.stdout.write(`create-neptune ${CREATE_NEPTUNE_VERSION}\n`);
    return 0;
  }

  process.stdout.write(banner());

  // ── Framework ──────────────────────────────────────────────────────────
  let framework: FrameworkId;
  if (cli.framework) {
    if (!frameworkById(cli.framework)) {
      errln(`Unknown framework "${cli.framework}". Try one of: ${FRAMEWORKS.map((f) => f.id).join(", ")}.`);
      return 1;
    }
    framework = cli.framework as FrameworkId;
  } else if (cli.yes) {
    framework = "react";
  } else {
    const choices: Choice<FrameworkId>[] = FRAMEWORKS.map((f) => ({
      value: f.id,
      label: f.label,
      hint: f.blurb,
    }));
    framework = await select("Which framework?", choices, "react");
  }
  const fw = frameworkById(framework)!;

  // ── Project directory + name ───────────────────────────────────────────
  let rawTarget = cli.positionals[0];
  if (!rawTarget && !cli.yes) {
    rawTarget = await text("Project directory", "neptune-app");
  }
  rawTarget = rawTarget || "neptune-app";
  const targetDir = path.resolve(process.cwd(), rawTarget);

  const defaultName = slugify(cli.name || path.basename(targetDir) || "neptune-app");
  let projectName = defaultName || "neptune-app";
  if (!cli.name && !cli.yes) {
    projectName = slugify(await text("Package name", defaultName));
  } else if (cli.name) {
    projectName = slugify(cli.name);
  }
  if (!isValidName(projectName)) {
    errln(`"${projectName}" is not a valid npm package name.`);
    return 1;
  }

  const defaultTitle = cli.title || titleCase(projectName);
  let projectTitle = defaultTitle;
  if (!cli.title && !cli.yes) {
    projectTitle = (await text("Display title", defaultTitle)) || defaultTitle;
  }

  // ── Brand ──────────────────────────────────────────────────────────────
  let brand: Brand;
  if (cli.brand) {
    if (!isBrand(cli.brand)) {
      errln(`Unknown brand "${cli.brand}". Choose: ${BRANDS.join(", ")}.`);
      return 1;
    }
    brand = cli.brand;
  } else if (cli.yes) {
    brand = "neptune";
  } else {
    const choices: Choice<Brand>[] = [
      { value: "neptune", label: "Neptune", hint: "deep ocean blue" },
      { value: "triton", label: "Triton", hint: "teal / aqua" },
      { value: "nereid", label: "Nereid", hint: "violet / orchid" },
      { value: "proteus", label: "Proteus", hint: "warm amber" },
    ];
    brand = await select("Which reference brand?", choices, "neptune");
  }

  // ── Mode + direction (constrained by the runtime) ──────────────────────
  let mode: ModeOption;
  const modeDefault: ModeOption = fw.supportsSystemMode ? "system" : "light";
  if (cli.mode) {
    if (!MODES.includes(cli.mode as ModeOption)) {
      errln(`Unknown mode "${cli.mode}". Choose: ${MODES.join(", ")}.`);
      return 1;
    }
    mode = cli.mode as ModeOption;
  } else if (cli.yes) {
    mode = modeDefault;
  } else {
    const choices: Choice<ModeOption>[] = MODES.filter(
      (m) => m !== "system" || fw.supportsSystemMode,
    ).map((m) => ({ value: m, label: m }));
    mode = await select("Default colour mode?", choices, modeDefault);
  }

  let dir: DirOption;
  if (cli.dir) {
    if (!DIRS.includes(cli.dir as DirOption)) {
      errln(`Unknown direction "${cli.dir}". Choose: ${DIRS.join(", ")}.`);
      return 1;
    }
    dir = cli.dir as DirOption;
  } else if (cli.yes) {
    dir = "ltr";
  } else {
    const choices: Choice<DirOption>[] = DIRS.filter(
      (d) => d !== "auto" || fw.supportsAutoDir,
    ).map((d) => ({
      value: d,
      label: d === "ltr" ? "ltr (left-to-right)" : d === "rtl" ? "rtl (Arabic / RTL)" : "auto",
    }));
    dir = await select("Default text direction?", choices, "ltr");
  }

  const norm = normalizeForFramework(framework, mode, dir);

  // ── Guard the target directory ─────────────────────────────────────────
  if (!cli.force && !(await dirIsEmpty(targetDir))) {
    errln(`Directory ${c.bold(path.relative(process.cwd(), targetDir) || ".")} is not empty.`);
    warn("Pass --force to scaffold into it anyway, or pick another directory.");
    return 1;
  }

  // ── Scaffold ───────────────────────────────────────────────────────────
  process.stdout.write("\n");
  info(
    `Creating ${c.bold(fw.label)} app ${c.bold(projectName)} ` +
      `(${c.cyan(brand)} · ${norm.mode} · ${norm.dir}) …`,
  );
  let result;
  try {
    result = await scaffold({
      framework,
      projectName,
      projectTitle,
      brand,
      mode,
      dir,
      targetDir,
    });
  } catch (err) {
    errln(`Scaffold failed: ${(err as Error).message}`);
    return 1;
  }

  success(`Wrote ${c.bold(String(result.files.length))} files to ${c.bold(rawTarget)}`);

  // ── Next steps ─────────────────────────────────────────────────────────
  const rel = path.relative(process.cwd(), targetDir) || ".";
  process.stdout.write(`\n${c.bold("Next steps")}\n`);
  if (rel !== ".") process.stdout.write(`  ${c.cyan(`cd ${rel}`)}\n`);
  process.stdout.write(`  ${c.cyan(fw.install)}\n`);
  process.stdout.write(`  ${c.cyan(fw.dev)}\n`);
  process.stdout.write(
    `\n${c.gray("Docs:")} https://neptune-ly.github.io/neptune_odyssey/\n` +
      `${c.gray("Theme builder:")} https://neptune-ly.github.io/neptune_odyssey/apps/configurator/\n\n`,
  );
  return 0;
}

run().then(
  (code) => process.exit(code),
  (err) => {
    errln((err as Error).stack || String(err));
    process.exit(1);
  },
);

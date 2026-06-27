// Neptune Odyssey — tiny zero-dependency terminal kit for create-neptune.
// © 2026 Neptune.Fintech (neptune.ly)
//
// No prompt/colour libraries: keeps `npm create @neptune.fintech` install-free
// and instant. Colours respect NO_COLOR and non-TTY output; the selector uses
// raw-mode keypresses when interactive and falls back to a numbered prompt.

import readline from "node:readline";
import process from "node:process";

const useColor =
  !process.env.NO_COLOR &&
  (process.env.FORCE_COLOR != null || process.stdout.isTTY === true);

function wrap(open: number, close: number) {
  return (s: string): string => (useColor ? `[${open}m${s}[${close}m` : s);
}

export const c = {
  reset: "[0m",
  bold: wrap(1, 22),
  dim: wrap(2, 22),
  italic: wrap(3, 23),
  underline: wrap(4, 24),
  red: wrap(31, 39),
  green: wrap(32, 39),
  yellow: wrap(33, 39),
  blue: wrap(34, 39),
  magenta: wrap(35, 39),
  cyan: wrap(36, 39),
  gray: wrap(90, 39),
};

/** Neptune trident-ish header. */
export function banner(): string {
  return (
    "\n" +
    c.cyan(c.bold("  ◬  Neptune Odyssey")) +
    c.gray("  ·  create-neptune") +
    "\n" +
    c.gray("  A themed fintech starter, wired and ready.") +
    "\n"
  );
}

export function info(msg: string): void {
  process.stdout.write(`${c.cyan("›")} ${msg}\n`);
}
export function success(msg: string): void {
  process.stdout.write(`${c.green("✓")} ${msg}\n`);
}
export function warn(msg: string): void {
  process.stdout.write(`${c.yellow("!")} ${msg}\n`);
}
export function errln(msg: string): void {
  process.stderr.write(`${c.red("✗")} ${msg}\n`);
}

function ask(question: string): Promise<string> {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer);
    });
  });
}

/** Free-text prompt with a default. Returns the default on empty input. */
export async function text(message: string, def: string): Promise<string> {
  const suffix = def ? c.gray(` (${def})`) : "";
  const answer = (await ask(`${c.cyan("?")} ${c.bold(message)}${suffix} `)).trim();
  return answer || def;
}

/** Yes/no prompt. */
export async function confirm(message: string, def = true): Promise<boolean> {
  const hint = def ? "Y/n" : "y/N";
  const answer = (await ask(`${c.cyan("?")} ${c.bold(message)} ${c.gray(`(${hint})`)} `))
    .trim()
    .toLowerCase();
  if (!answer) return def;
  return answer[0] === "y";
}

export interface Choice<T extends string> {
  value: T;
  label: string;
  hint?: string;
}

/**
 * Single-select. Arrow keys + Enter when stdin is a raw-capable TTY; otherwise
 * prints a numbered list and reads a number. Always resolves to a value.
 */
export async function select<T extends string>(
  message: string,
  choices: Choice<T>[],
  initialValue?: T,
): Promise<T> {
  const startIndex = Math.max(
    0,
    choices.findIndex((ch) => ch.value === initialValue),
  );

  const interactive =
    process.stdin.isTTY === true && typeof process.stdin.setRawMode === "function";

  if (!interactive) return numberedSelect(message, choices, startIndex < 0 ? 0 : startIndex);

  return new Promise<T>((resolve) => {
    let index = startIndex < 0 ? 0 : startIndex;
    const out = process.stdout;

    readline.emitKeypressEvents(process.stdin);
    process.stdin.setRawMode(true);
    process.stdin.resume();

    const render = (first: boolean) => {
      if (!first) out.write(`[${choices.length + 1}A`); // cursor up to redraw
      out.write(`${c.cyan("?")} ${c.bold(message)}[K\n`);
      choices.forEach((ch, i) => {
        const active = i === index;
        const pointer = active ? c.cyan("❯") : " ";
        const label = active ? c.cyan(ch.label) : ch.label;
        const hint = ch.hint ? c.gray(`  ${ch.hint}`) : "";
        out.write(`${pointer} ${label}${hint}[K\n`);
      });
    };

    const cleanup = () => {
      process.stdin.setRawMode(false);
      process.stdin.pause();
      process.stdin.removeListener("keypress", onKey);
    };

    const onKey = (_str: string, key: readline.Key) => {
      if (!key) return;
      if (key.name === "up" || (key.name === "k" && !key.ctrl)) {
        index = (index - 1 + choices.length) % choices.length;
        render(false);
      } else if (key.name === "down" || (key.name === "j" && !key.ctrl)) {
        index = (index + 1) % choices.length;
        render(false);
      } else if (/^[1-9]$/.test(_str)) {
        const n = Number(_str) - 1;
        if (n < choices.length) {
          index = n;
          render(false);
        }
      } else if (key.name === "return" || key.name === "enter") {
        cleanup();
        out.write("\n");
        resolve(choices[index]!.value);
      } else if (key.name === "c" && key.ctrl) {
        cleanup();
        out.write("\n");
        process.exit(130);
      }
    };

    process.stdin.on("keypress", onKey);
    render(true);
  });
}

async function numberedSelect<T extends string>(
  message: string,
  choices: Choice<T>[],
  startIndex: number,
): Promise<T> {
  process.stdout.write(`${c.cyan("?")} ${c.bold(message)}\n`);
  choices.forEach((ch, i) => {
    const hint = ch.hint ? c.gray(`  ${ch.hint}`) : "";
    process.stdout.write(`  ${c.cyan(String(i + 1))}. ${ch.label}${hint}\n`);
  });
  const def = String(startIndex + 1);
  const raw = (await text(`Choose 1-${choices.length}`, def)).trim();
  const n = Number(raw);
  if (Number.isInteger(n) && n >= 1 && n <= choices.length) return choices[n - 1]!.value;
  return choices[startIndex]!.value;
}

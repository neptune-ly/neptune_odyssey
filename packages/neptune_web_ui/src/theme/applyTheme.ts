// Neptune Odyssey — web theming surface · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// Theming is PURE CSS VARIABLES. For the four reference brands, the shipped
// themes.css already defines every var — so re-skinning is zero JS: just set
// data-theme / data-mode / dir. For a custom config or a brandprint string we
// resolve the palette (via @neptune.fintech/tokens, the shared determinism
// backbone) and write the vars onto the root element. SSR-safe: no module-level
// DOM access; everything is guarded and runs only when called with an element.

import {
  buildTheme,
  COLOR_ROLES,
  odyssey3Foundation,
  type NeptuneTheme,
  type ThemeInput,
  type Direction,
  type OdysseyProduct,
} from "@neptune.fintech/tokens";

export type ModeOption = "light" | "dark" | "system";
export type DirOption = Direction | "auto";

export interface ApplyThemeOptions {
  mode?: ModeOption;
  dir?: DirOption;
  edition?: "v1" | "odyssey3";
  product?: OdysseyProduct;
  reducedMotion?: boolean;
}

export interface ThemeHandle {
  /** The resolved theme that was applied. */
  theme: NeptuneTheme;
  /** Stop watching `system`/`auto` listeners and leave the last applied values in place. */
  dispose(): void;
}

const REFERENCE_BRANDS = new Set(["neptune", "triton", "nereid", "proteus"]);
const ODYSSEY3_TYPE_RAMP = {
  shared: {
    "--npt-text-display": "40px", "--npt-leading-display": "48px",
    "--npt-text-display-md": "40px", "--npt-leading-display-md": "48px",
    "--npt-text-display-sm": "36px", "--npt-leading-display-sm": "44px",
    "--npt-text-heading": "32px", "--npt-leading-heading": "40px",
    "--npt-text-headline": "32px", "--npt-leading-headline": "40px",
    "--npt-text-title": "24px", "--npt-leading-title": "32px",
    "--npt-text-title-lg": "24px", "--npt-leading-title-lg": "32px",
    "--npt-text-subtitle": "20px", "--npt-leading-subtitle": "28px",
    "--npt-text-body": "16px", "--npt-leading-body": "24px",
    "--npt-text-body-lg": "16px", "--npt-leading-body-lg": "24px",
    "--npt-text-body-sm": "14px", "--npt-leading-body-sm": "20px",
    "--npt-text-label": "14px", "--npt-leading-label": "20px",
    "--npt-text-caption": "12px", "--npt-leading-caption": "16px",
    "--npt-text-amount": "36px", "--npt-leading-amount": "44px",
    "--npt-font-weight-regular": "400", "--npt-font-weight-semibold": "600", "--npt-font-weight-bold": "700",
    "--npt-display-tracking": "0em", "--npt-label-tracking": "0em",
  },
  rtl: {
    "--npt-text-body": "20px", "--npt-leading-body": "28px",
    "--npt-text-body-lg": "20px", "--npt-leading-body-lg": "28px",
    "--npt-text-body-sm": "18px", "--npt-leading-body-sm": "24px",
    "--npt-text-label": "18px", "--npt-leading-label": "24px",
    "--npt-text-caption": "16px", "--npt-leading-caption": "22px",
  },
} as const;
interface ThemeController {
  options: ApplyThemeOptions;
  theme: NeptuneTheme;
  ownedVars: Set<string>;
  paint(): void;
  stopWatching(): void;
  dispose(): void;
}

const CONTROLLERS = new WeakMap<HTMLElement, ThemeController>();

function prefersDark(): boolean {
  return typeof matchMedia === "function" && matchMedia("(prefers-color-scheme: dark)").matches;
}

function resolveMode(mode: ModeOption | undefined, fallback: "light" | "dark"): "light" | "dark" {
  if (mode === "light" || mode === "dark") return mode;
  if (mode === "system") return prefersDark() ? "dark" : "light";
  return fallback;
}

function resolveDir(dir: DirOption | undefined, root: HTMLElement, fallback: Direction): Direction {
  if (dir === "ltr" || dir === "rtl") return dir;
  if (dir === "auto") {
    const inherited = getComputedStyle?.(root)?.direction;
    return inherited === "rtl" ? "rtl" : "ltr";
  }
  return fallback;
}

/** Write the resolved palette + npt expression vars onto the element (custom themes). */
function writeVars(root: HTMLElement, theme: NeptuneTheme, ownedVars: Set<string>): void {
  const s = root.style;
  const set = (name: string, value: string) => {
    ownedVars.add(name);
    s.setProperty(name, value);
  };
  for (const role of COLOR_ROLES) set(`--md-sys-color-${role}`, theme.colors[role]);
  // shape (themes.css computes --npt-corner-* from *-base * --npt-shape-scale)
  set("--npt-corner-xs-base", `${theme.shape.xs}px`);
  set("--npt-corner-sm-base", `${theme.shape.sm}px`);
  set("--npt-corner-md-base", `${theme.shape.md}px`);
  set("--npt-corner-lg-base", `${theme.shape.lg}px`);
  set("--npt-corner-xl-base", `${theme.shape.xl}px`);
  set("--npt-corner-2xl-base", `${theme.shape.xxl}px`);
  set("--npt-corner-full", "999px");
  set("--npt-shape-scale", "1");
  // type
  set("--npt-font-display", `'${theme.type.display}'`);
  set("--npt-font-text", `'${theme.type.text}'`);
  set("--npt-font-num", `'${theme.type.num}'`);
  set("--npt-display-weight", String(theme.type.displayWeight));
  set("--npt-display-tracking", `${theme.type.displayTracking}em`);
  // motion
  set("--npt-ease-standard", theme.motion.ease.standard);
  set("--npt-ease-emphasized", theme.motion.ease.emphasized);
  set("--npt-ease-spring", theme.motion.ease.spring);
  set("--npt-dur-fast", `${theme.motion.durMs.fast}ms`);
  set("--npt-dur-standard", `${theme.motion.durMs.standard}ms`);
  set("--npt-dur-slow", `${theme.motion.durMs.slow}ms`);
  set("--npt-glass-blur", `${theme.motion.glassBlurPx}px`);
  if (theme.expression) {
    for (const [role, color] of Object.entries(theme.expression.colors)) {
      set(`--npt-o3-${role}`, color);
    }
    const font = theme.dir === "rtl" ? theme.expression.fonts.ar : theme.expression.fonts.en;
    set("--npt-font-display", `'${font}'`);
    set("--npt-font-text", `'${font}'`);
    set("--npt-font-num", `'${theme.expression.fonts.en}'`);
    for (const [role, color] of Object.entries(odyssey3Foundation.fields)) {
      set(`--npt-o3-field-${role}`, color);
    }
    for (const [role, color] of Object.entries(odyssey3Foundation.content)) {
      set(`--npt-o3-content-${role}`, color);
    }
    for (const [role, radius] of Object.entries(odyssey3Foundation.shape)) {
      set(`--npt-o3-${role}-radius`, `${radius}px`);
    }
    for (const [role, family] of Object.entries(odyssey3Foundation.fonts)) {
      set(`--npt-o3-font-${role}`, `'${family}'`);
    }
    set("--npt-corner-xs-base", "4px");
    set("--npt-corner-sm-base", "8px");
    set("--npt-corner-md-base", "16px");
    set("--npt-corner-lg-base", "24px");
    set("--npt-corner-xl-base", "32px");
    set("--npt-dur-fast", `${theme.expression.motionMs.feedback}ms`);
    set("--npt-dur-standard", `${theme.expression.motionMs.navigate}ms`);
    set("--npt-dur-slow", `${theme.expression.motionMs.reveal}ms`);
    // Numeric aliases are consumed by legacy components: 1/2/4 follow the
    // O3 feedback/navigation/reveal tiers so reduced motion reaches them too.
    set("--npt-dur-1", `${theme.expression.motionMs.feedback}ms`);
    set("--npt-dur-2", `${theme.expression.motionMs.navigate}ms`);
    set("--npt-dur-4", `${theme.expression.motionMs.reveal}ms`);
    set("--npt-o3-target-min", "48px");
    set("--npt-o3-target-primary", "56px");
    set("--npt-o3-disabled-opacity", "1");
    set("--npt-o3-field-padding-block", "3px");
    set("--npt-o3-input-size", "var(--npt-text-body-lg)");
    set("--npt-o3-keypad-size", "24px");
    for (const [name, value] of Object.entries(ODYSSEY3_TYPE_RAMP.shared)) set(name, value);
    if (theme.dir === "rtl") for (const [name, value] of Object.entries(ODYSSEY3_TYPE_RAMP.rtl)) set(name, value);
  }
  // named levers
  set("--npt-login-shell", theme.levers.loginShell);
  set("--npt-dashboard-hero", theme.levers.dashboardHero);
  set("--npt-content-tone", theme.levers.contentTone);
}

/**
 * Apply a Neptune Odyssey theme to a root element.
 *
 * @example
 * applyTheme(document.documentElement, "triton", { mode: "system", dir: "auto" });
 * applyTheme(root, "NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA");
 * applyTheme(root, { primary: {L,C,H}, tertiary: {…}, corners: {…}, … });
 */
export function applyTheme(
  root: HTMLElement,
  input: ThemeInput,
  options: ApplyThemeOptions = {},
): ThemeHandle {
  const previous = CONTROLLERS.get(root);
  if (previous) {
    previous.dispose();
    for (const name of previous.ownedVars) root.style.removeProperty(name);
  }
  const isReferenceBrand =
    typeof input === "string" && REFERENCE_BRANDS.has(input);
  let controller: ThemeController;
  let mediaCleanup: (() => void) | undefined;
  controller = {
    options: { ...options },
    theme: buildTheme(input),
    ownedVars: new Set(),
    paint() {
      const base = buildTheme(input);
      const mode = resolveMode(controller.options.mode, base.mode);
      const dir = resolveDir(controller.options.dir, root, base.dir);
      controller.theme = buildTheme(input, { mode, dir, edition: controller.options.edition, product: controller.options.product, reducedMotion: controller.options.reducedMotion });

      if (isReferenceBrand) {
        root.dataset.theme = input as string;
        if (controller.options.edition === "odyssey3") writeVars(root, controller.theme, controller.ownedVars);
      } else {
        root.dataset.theme = "custom";
        writeVars(root, controller.theme, controller.ownedVars);
      }
      root.dataset.mode = mode;
      if (controller.options.edition === "odyssey3") {
        root.dataset.odyssey = "3";
        root.dataset.product = controller.options.product ?? "banking";
        root.dataset.reducedMotion = String(controller.options.reducedMotion ?? false);
      } else {
        delete root.dataset.odyssey;
        delete root.dataset.product;
        delete root.dataset.reducedMotion;
      }
      root.setAttribute("dir", dir);
    },
    stopWatching() {
      mediaCleanup?.();
      mediaCleanup = undefined;
    },
    dispose() {
      controller.stopWatching();
    },
  };
  controller.paint();
  CONTROLLERS.set(root, controller);

  if (controller.options.mode === "system" && typeof matchMedia === "function") {
    const mq = matchMedia("(prefers-color-scheme: dark)");
    const onChange = () => {
      controller.paint();
    };
    mq.addEventListener?.("change", onChange);
    mediaCleanup = () => mq.removeEventListener?.("change", onChange);
  }

  return {
    get theme() {
      return controller.theme;
    },
    dispose: controller.dispose,
  };
}

/** Convenience: set only the mode on an already-themed root. */
export function setMode(root: HTMLElement, mode: "light" | "dark"): void {
  const controller = CONTROLLERS.get(root);
  if (!controller) {
    root.dataset.mode = mode;
    return;
  }
  controller.options.mode = mode;
  controller.stopWatching();
  controller.paint();
}

/** Convenience: set only the direction on an already-themed root. */
export function setDirection(root: HTMLElement, dir: Direction): void {
  const controller = CONTROLLERS.get(root);
  if (!controller) {
    root.setAttribute("dir", dir);
    return;
  }
  controller.options.dir = dir;
  controller.paint();
}

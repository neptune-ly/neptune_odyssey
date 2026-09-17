// Neptune Odyssey — web theming surface · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// Tenant theming is PURE CSS VARIABLES. For the four reference brands, shipped
// themes.css defines every tenant var — so re-skinning remains zero JS: set
// data-theme / data-mode / dir. Product worlds are an orthogonal layer: when a
// caller opts into `world`, applyTheme writes only `--o2-world-*` and
// interaction-motion variables, never replacing the tenant M3 semantic roles.

import {
  buildTheme,
  COLOR_ROLES,
  type NeptuneTheme,
  type ThemeInput,
  type Direction,
  type MotionLevel,
  type ProductWorld,
} from "@neptune.fintech/tokens";

export type ModeOption = "light" | "dark" | "system";
export type DirOption = Direction | "auto";

export interface ApplyThemeOptions {
  mode?: ModeOption;
  dir?: DirOption;
  /** Product personality, independent from the tenant/brand theme. */
  world?: ProductWorld;
  /** Optional contextual override for the world's default interaction intensity. */
  motionLevel?: MotionLevel;
  /** Remove travel/stagger/overshoot while retaining at most a short dissolve. */
  reducedMotion?: boolean;
}

export interface ThemeHandle {
  /** The resolved theme that was applied. */
  theme: NeptuneTheme;
  /** Stop watching `system`/`auto` listeners and leave the last applied values in place. */
  dispose(): void;
}

const REFERENCE_BRANDS = new Set(["neptune", "triton", "nereid", "proteus"]);

const WORLD_PROPERTIES = [
  "--o2-world-accent",
  "--o2-world-on-accent",
  "--o2-world-tint",
  "--o2-world-hero",
  "--o2-world-spark",
  "--o2-world-background",
  "--o2-world-radius",
  "--o2-world-title-font",
  "--o2-motion-level-duration",
  "--o2-motion-level-distance",
  "--o2-motion-level-stagger",
  "--o2-motion-level-overshoot",
] as const;

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

/** Write the resolved tenant palette + expression vars onto the element (custom themes). */
function writeVars(root: HTMLElement, theme: NeptuneTheme): void {
  const s = root.style;
  for (const role of COLOR_ROLES) s.setProperty(`--md-sys-color-${role}`, theme.colors[role]);
  // shape (themes.css computes --npt-corner-* from *-base * --npt-shape-scale)
  s.setProperty("--npt-corner-xs-base", `${theme.shape.xs}px`);
  s.setProperty("--npt-corner-sm-base", `${theme.shape.sm}px`);
  s.setProperty("--npt-corner-md-base", `${theme.shape.md}px`);
  s.setProperty("--npt-corner-lg-base", `${theme.shape.lg}px`);
  s.setProperty("--npt-corner-xl-base", `${theme.shape.xl}px`);
  s.setProperty("--npt-corner-2xl-base", `${theme.shape.xxl}px`);
  s.setProperty("--npt-corner-full", "999px");
  s.setProperty("--npt-shape-scale", "1");
  // type
  s.setProperty("--npt-font-display", `'${theme.type.display}'`);
  s.setProperty("--npt-font-text", `'${theme.type.text}'`);
  s.setProperty("--npt-font-num", `'${theme.type.num}'`);
  s.setProperty("--npt-display-weight", String(theme.type.displayWeight));
  s.setProperty("--npt-display-tracking", `${theme.type.displayTracking}em`);
  // brand-level motion
  s.setProperty("--npt-ease-standard", theme.motion.ease.standard);
  s.setProperty("--npt-ease-emphasized", theme.motion.ease.emphasized);
  s.setProperty("--npt-ease-spring", theme.motion.ease.spring);
  s.setProperty("--npt-dur-fast", `${theme.motion.durMs.fast}ms`);
  s.setProperty("--npt-dur-standard", `${theme.motion.durMs.standard}ms`);
  s.setProperty("--npt-dur-slow", `${theme.motion.durMs.slow}ms`);
  s.setProperty("--npt-glass-blur", `${theme.motion.glassBlurPx}px`);
  // named tenant levers
  s.setProperty("--npt-login-shell", theme.levers.loginShell);
  s.setProperty("--npt-dashboard-hero", theme.levers.dashboardHero);
  s.setProperty("--npt-content-tone", theme.levers.contentTone);
}

/** Clear stale product-world values when a root is re-used without a world. */
function clearWorldVars(root: HTMLElement): void {
  for (const property of WORLD_PROPERTIES) root.style.removeProperty(property);
  delete root.dataset.world;
  delete root.dataset.motionLevel;
  delete root.dataset.reducedMotion;
}

/** Write only the orthogonal product-personality + interaction-motion layer. */
function writeWorldVars(root: HTMLElement, theme: NeptuneTheme): void {
  clearWorldVars(root);
  if (!theme.world) return;

  const s = root.style;
  const c = theme.world.colors;
  root.dataset.world = theme.world.id;
  s.setProperty("--o2-world-accent", c.accent);
  s.setProperty("--o2-world-on-accent", c.onAccent);
  s.setProperty("--o2-world-tint", c.tint);
  s.setProperty("--o2-world-hero", c.hero);
  s.setProperty("--o2-world-spark", c.spark);
  s.setProperty("--o2-world-background", c.background);
  s.setProperty("--o2-world-radius", `${theme.world.radius}px`);
  s.setProperty("--o2-world-title-font", `'${theme.world.titleFont}'`);

  if (theme.interactionMotion) {
    const m = theme.interactionMotion;
    root.dataset.motionLevel = m.level;
    root.dataset.reducedMotion = String(m.reduced);
    s.setProperty("--o2-motion-level-duration", `${m.durationMs}ms`);
    s.setProperty("--o2-motion-level-distance", `${m.distancePx}px`);
    s.setProperty("--o2-motion-level-stagger", `${m.staggerMs}ms`);
    s.setProperty("--o2-motion-level-overshoot", String(m.overshoot));
  }
}

/**
 * Apply a Neptune Odyssey theme to a root element.
 *
 * @example
 * applyTheme(document.documentElement, "triton", { mode: "system", dir: "auto" });
 * applyTheme(root, "neptune", { world: "voyage", mode: "dark", dir: "rtl" });
 * applyTheme(root, "NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA");
 */
export function applyTheme(
  root: HTMLElement,
  input: ThemeInput,
  options: ApplyThemeOptions = {},
): ThemeHandle {
  const isReferenceBrand = typeof input === "string" && REFERENCE_BRANDS.has(input);
  const cleanups: Array<() => void> = [];

  const paint = () => {
    const base = buildTheme(input);
    const mode = resolveMode(options.mode, base.mode);
    const dir = resolveDir(options.dir, root, base.dir);
    const theme = buildTheme(input, {
      mode,
      dir,
      ...(options.world ? { world: options.world } : {}),
      ...(options.motionLevel ? { motionLevel: options.motionLevel } : {}),
      ...(options.reducedMotion !== undefined ? { reducedMotion: options.reducedMotion } : {}),
    });

    if (isReferenceBrand) {
      root.dataset.theme = input as string;
    } else {
      root.dataset.theme = "custom";
      writeVars(root, theme);
    }
    root.dataset.mode = mode;
    root.setAttribute("dir", dir);
    writeWorldVars(root, theme);
    return theme;
  };

  let theme = paint();

  if (options.mode === "system" && typeof matchMedia === "function") {
    const mq = matchMedia("(prefers-color-scheme: dark)");
    const onChange = () => {
      theme = paint();
    };
    mq.addEventListener?.("change", onChange);
    cleanups.push(() => mq.removeEventListener?.("change", onChange));
  }

  return {
    get theme() {
      return theme;
    },
    dispose() {
      for (const c of cleanups) c();
    },
  };
}

/** Convenience: set only the mode on an already-themed root (zero re-resolve). */
export function setMode(root: HTMLElement, mode: "light" | "dark"): void {
  root.dataset.mode = mode;
}

/** Convenience: set only the direction on an already-themed root. */
export function setDirection(root: HTMLElement, dir: Direction): void {
  root.setAttribute("dir", dir);
}

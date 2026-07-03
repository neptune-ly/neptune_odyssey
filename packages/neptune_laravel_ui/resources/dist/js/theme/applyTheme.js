// Neptune Odyssey — web theming surface · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// Theming is PURE CSS VARIABLES. For the four reference brands, the shipped
// themes.css already defines every var — so re-skinning is zero JS: just set
// data-theme / data-mode / dir. For a custom config or a brandprint string we
// resolve the palette (via @neptune.fintech/tokens, the shared determinism
// backbone) and write the vars onto the root element. SSR-safe: no module-level
// DOM access; everything is guarded and runs only when called with an element.
import { buildTheme, COLOR_ROLES, } from "@neptune.fintech/tokens";
const REFERENCE_BRANDS = new Set(["neptune", "triton", "nereid", "proteus"]);
function prefersDark() {
    return typeof matchMedia === "function" && matchMedia("(prefers-color-scheme: dark)").matches;
}
function resolveMode(mode, fallback) {
    if (mode === "light" || mode === "dark")
        return mode;
    if (mode === "system")
        return prefersDark() ? "dark" : "light";
    return fallback;
}
function resolveDir(dir, root, fallback) {
    if (dir === "ltr" || dir === "rtl")
        return dir;
    if (dir === "auto") {
        const inherited = getComputedStyle?.(root)?.direction;
        return inherited === "rtl" ? "rtl" : "ltr";
    }
    return fallback;
}
/** Write the resolved palette + npt expression vars onto the element (custom themes). */
function writeVars(root, theme) {
    const s = root.style;
    for (const role of COLOR_ROLES)
        s.setProperty(`--md-sys-color-${role}`, theme.colors[role]);
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
    // motion
    s.setProperty("--npt-ease-standard", theme.motion.ease.standard);
    s.setProperty("--npt-ease-emphasized", theme.motion.ease.emphasized);
    s.setProperty("--npt-ease-spring", theme.motion.ease.spring);
    s.setProperty("--npt-dur-fast", `${theme.motion.durMs.fast}ms`);
    s.setProperty("--npt-dur-standard", `${theme.motion.durMs.standard}ms`);
    s.setProperty("--npt-dur-slow", `${theme.motion.durMs.slow}ms`);
    s.setProperty("--npt-glass-blur", `${theme.motion.glassBlurPx}px`);
    // named levers
    s.setProperty("--npt-login-shell", theme.levers.loginShell);
    s.setProperty("--npt-dashboard-hero", theme.levers.dashboardHero);
    s.setProperty("--npt-content-tone", theme.levers.contentTone);
}
/**
 * Apply a Neptune Odyssey theme to a root element.
 *
 * @example
 * applyTheme(document.documentElement, "triton", { mode: "system", dir: "auto" });
 * applyTheme(root, "NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA");
 * applyTheme(root, { primary: {L,C,H}, tertiary: {…}, corners: {…}, … });
 */
export function applyTheme(root, input, options = {}) {
    const isReferenceBrand = typeof input === "string" && REFERENCE_BRANDS.has(input);
    const cleanups = [];
    const paint = () => {
        const base = buildTheme(input);
        const mode = resolveMode(options.mode, base.mode);
        const dir = resolveDir(options.dir, root, base.dir);
        const theme = buildTheme(input, { mode, dir });
        if (isReferenceBrand) {
            root.dataset.theme = input;
        }
        else {
            root.dataset.theme = "custom";
            writeVars(root, theme);
        }
        root.dataset.mode = mode;
        root.setAttribute("dir", dir);
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
            for (const c of cleanups)
                c();
        },
    };
}
/** Convenience: set only the mode on an already-themed root (zero re-resolve). */
export function setMode(root, mode) {
    root.dataset.mode = mode;
}
/** Convenience: set only the direction on an already-themed root. */
export function setDirection(root, dir) {
    root.setAttribute("dir", dir);
}
//# sourceMappingURL=applyTheme.js.map
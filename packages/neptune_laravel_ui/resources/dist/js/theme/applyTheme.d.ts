import { type NeptuneTheme, type ThemeInput, type Direction } from "@neptune.fintech/tokens";
export type ModeOption = "light" | "dark" | "system";
export type DirOption = Direction | "auto";
export interface ApplyThemeOptions {
    mode?: ModeOption;
    dir?: DirOption;
}
export interface ThemeHandle {
    /** The resolved theme that was applied. */
    theme: NeptuneTheme;
    /** Stop watching `system`/`auto` listeners and leave the last applied values in place. */
    dispose(): void;
}
/**
 * Apply a Neptune Odyssey theme to a root element.
 *
 * @example
 * applyTheme(document.documentElement, "triton", { mode: "system", dir: "auto" });
 * applyTheme(root, "NO1-AYB4AKKeeABWDBIaIiw4B_YBAAABAQEBAQAAyA");
 * applyTheme(root, { primary: {L,C,H}, tertiary: {…}, corners: {…}, … });
 */
export declare function applyTheme(root: HTMLElement, input: ThemeInput, options?: ApplyThemeOptions): ThemeHandle;
/** Convenience: set only the mode on an already-themed root (zero re-resolve). */
export declare function setMode(root: HTMLElement, mode: "light" | "dark"): void;
/** Convenience: set only the direction on an already-themed root. */
export declare function setDirection(root: HTMLElement, dir: Direction): void;
//# sourceMappingURL=applyTheme.d.ts.map
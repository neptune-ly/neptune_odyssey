import { NptElement } from "./base.js";
/**
 * <npt-progress variant="linear|circular" value="60" [indeterminate]></npt-progress>
 * Omit value (or set [indeterminate]) for the indeterminate state.
 */
export declare class NptProgress extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-snackbar message="Saved" [open]>…optional action slot…</npt-snackbar>
 * Inverse-surface toast. Provide an action via the default slot.
 */
export declare class NptSnackbar extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-tooltip label="Copy"><npt-icon-button>⧉</npt-icon-button></npt-tooltip>
 * Wraps a trigger; reveals the label on hover/focus.
 */
export declare class NptTooltip extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-banner text="Update available">…actions slot…</npt-banner>
 * Surface-level inline message with an actions slot.
 */
export declare class NptBanner extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=feedback.d.ts.map
import { NptElement } from "./base.js";
/**
 * <npt-dialog [open] headline="Confirm">
 *   …content… <span slot="actions">…</span>
 * </npt-dialog>
 * Scrim + centred surface. ESC and backdrop close; focus-trap-lite.
 */
export declare class NptDialog extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(name: string): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    /** Close the overlay and emit a `close` event. */
    close(): void;
    private focusFirst;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-bottom-sheet [open]>…content…</npt-bottom-sheet>
 * Bottom-anchored sheet with a drag affordance + scrim. Backdrop/ESC close.
 */
export declare class NptBottomSheet extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    /** Close the sheet and emit a `close` event. */
    close(): void;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-menu [open]> with <npt-menu-item> children.
 * Anchored popover. Place inside a positioned ancestor for anchoring.
 */
export declare class NptMenu extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/** <npt-menu-item [disabled]>Settings</npt-menu-item> */
export declare class NptMenuItem extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=containers.d.ts.map
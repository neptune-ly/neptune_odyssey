import { NptElement } from "./base.js";
/**
 * <npt-skeleton variant="text|circle|rect" width="200px" height="16px" [lines="3"]>
 * Shimmer placeholder. `text` repeats `lines` bars; reduced-motion → static.
 */
export declare class NptSkeleton extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-empty-state title="No transactions" body="…">
 *   <span slot="icon">📭</span><div slot="actions">…</div>
 * </npt-empty-state>
 * Centred placeholder for empty collections.
 */
export declare class NptEmptyState extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-alert tone="info|success|warning|error" title="Heads up" [dismissible]>
 *   …message…
 * </npt-alert>
 * Inline tonal banner; [dismissible] shows a close button that emits `dismiss`.
 */
export declare class NptAlert extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onClick;
    /** Hide the alert and emit a `dismiss` event. */
    dismiss(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-status-chip status="success|pending|failed|info|neutral">Settled</npt-status-chip>
 * Status pill with a coloured dot + tonal background; label via default slot.
 */
export declare class NptStatusChip extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-toast [open] message="Saved" tone="info|success|warning|error" timeout="4000">
 *   <span slot="action">…</span>
 * </npt-toast>
 * Fixed bottom toast; auto-hides after `timeout` ms (0 disables). Emits `close`.
 */
export declare class NptToast extends NptElement {
    static observedAttributes: string[];
    private timer;
    attributeChangedCallback(name: string): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private clearTimer;
    private arm;
    private onClick;
    /** Hide the toast and emit a `close` event. */
    close(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-toast-host></npt-toast-host>
 * Stacking container for toasts; place <npt-toast> elements in the default slot
 * (or append them imperatively). Fixed to the bottom; newest sits at the end.
 */
export declare class NptToastHost extends NptElement {
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=feedback-status.d.ts.map
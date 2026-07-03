import { NptElement } from "./base.js";
/**
 * <npt-text-field label="IBAN" value="" placeholder="LY.." [error="msg"]></npt-text-field>
 * Outlined M3 field. Logical padding → mirrors in RTL.
 */
export declare class NptTextField extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    get value(): string;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-chip variant="assist|filter|input|suggestion" [selected]>Label</npt-chip>
 * `filter` shows a leading ✓ when [selected]; `input` shows a removable ✕ that
 * dispatches a `remove` event. Defaults to the assist/filter treatment.
 */
export declare class NptChip extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onClick;
    protected styles(): string;
    protected render(): string;
}
/** <npt-badge tone="primary|success|error|neutral">3</npt-badge> */
export declare class NptBadge extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=inputs.d.ts.map
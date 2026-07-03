import { NptElement } from "./base.js";
/**
 * <npt-card-art holder="A. KELLER" last4="4821" expiry="08/29" scheme="VISA"
 *   variant="virtual|physical|frozen"><span slot="brand">◈</span></npt-card-art>
 * Payment-card visual on the brand gradient. `scheme` is a plain label; provide a
 * brand mark via the `brand` slot (top-trailing). [frozen] dims and shows a frozen
 * affordance. Card number digits use tabular figures.
 */
export declare class NptCardArt extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-card-row label="Salary card" last4="4821" scheme="VISA" [interactive]>
 *   <span slot="brand">◈</span></npt-card-row>
 * Saved-card list item. Leading `brand` slot, trailing chevron. [interactive] makes
 * the whole row a button (role/tabindex/hover) that emits a bubbling `select` event.
 */
export declare class NptCardRow extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private activate;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-add-card>Add a new card</npt-add-card>
 * Dashed call-to-action tile with a leading +. Behaves as a button (role/tabindex)
 * and emits a bubbling `add` event on click / Enter / Space.
 */
export declare class NptAddCard extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private activate;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-card-controls [frozen]></npt-card-controls>
 * Row of toggle actions (Freeze, Limits, Details, PIN). Each press dispatches a
 * bubbling `control` event whose detail is { action }. [frozen] flips the first
 * action's label/affordance to Unfreeze.
 */
export declare class NptCardControls extends NptElement {
    static observedAttributes: string[];
    private static readonly ACTIONS;
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onClick;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=cards.d.ts.map
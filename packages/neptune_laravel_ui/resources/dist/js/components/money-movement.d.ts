import { NptElement } from "./base.js";
/** A single declarative step label, consumed by <npt-stepper>. Renders nothing on its own. */
export declare class NptStep extends NptElement {
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-stepper active="1" steps="Amount,Review,Done"></npt-stepper>
 * or with light-DOM <npt-step>Amount</npt-step> children.
 * Horizontal progress indicator with numbered nodes + connectors.
 */
export declare class NptStepper extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    private labels;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-transfer-review rows='[{"label":"To","value":"Mona K"}]'
 *   total="1,250.00" currency="LYD"></npt-transfer-review>
 * Light-DOM rows are also supported: place elements with [slot="rows"].
 * Key/value summary with a highlighted total footer.
 */
export declare class NptTransferReview extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    private rows;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-success title="Transfer sent" message="Your money is on the way.">
 *   <npt-button slot="actions">Done</npt-button>
 * </npt-success>
 * Success hero with a spring-in check; honours reduced motion.
 */
export declare class NptSuccess extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-receipt merchant="Acme" amount="42.00" currency="LYD"
 *   date="27 Jun 2026" status="Completed" reference="TX-9931"></npt-receipt>
 * Receipt card with a dashed tear divider; extra rows via the default slot.
 */
export declare class NptReceipt extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-beneficiary-tile name="Mona Kamel" account="•••• 4821" [favorite]>
 * </npt-beneficiary-tile>
 * Avatar/initials + name + masked account + trailing chevron.
 */
export declare class NptBeneficiaryTile extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    private initials;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-method-row title="Bank transfer" subtitle="1–2 business days" [recommended]>
 *   <span slot="icon">🏦</span>
 * </npt-method-row>
 * Transfer-method row: leading icon slot, title/subtitle, trailing chevron, badge.
 */
export declare class NptMethodRow extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=money-movement.d.ts.map
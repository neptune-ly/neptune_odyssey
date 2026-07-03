import { NptElement } from "./base.js";
/**
 * <npt-balance-card label="Available balance" amount="12,480.50" currency="LYD"
 *   account="•••• 4821" [hero]></npt-balance-card>
 * The dashboard balance hero. `hero` enables the brand gradient surface.
 */
export declare class NptBalanceCard extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-transaction-row title="Coffee" subtitle="Today · Card" amount="-4.50"
 *   currency="LYD" [credit]></npt-transaction-row>
 */
export declare class NptTransactionRow extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=financial.d.ts.map
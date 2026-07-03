import { NptElement } from "./base.js";
/**
 * <npt-quick-actions> with <npt-quick-action> children.
 * A responsive grid of action tiles. Clicking a child emits a bubbling `select`
 * event from the grid carrying the chosen tile's label.
 */
export declare class NptQuickActions extends NptElement {
    connectedCallback(): void;
    disconnectedCallback(): void;
    private activate;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-quick-action label="Send"><svg slot="icon">…</svg></npt-quick-action>
 * A single tile inside <npt-quick-actions>. Provide the glyph via the `icon` slot.
 */
export declare class NptQuickAction extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-merchant-row name="Acme" category="Groceries" amount="-42.00" currency="LYD"
 *   time="14:32" [pending]>
 *   <img slot="logo" src="…" alt="" />
 * </npt-merchant-row>
 * Provide a logo via the `logo` slot; falls back to the name's initials.
 */
export declare class NptMerchantRow extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-voucher-card title="20% off" value="−20%" code="NEPTUNE20" expiry="Exp 31 Dec">
 *   …optional default-slot detail…
 * </npt-voucher-card>
 * A coupon visual with punched dashed-notch edges (radial-gradient masks).
 */
export declare class NptVoucherCard extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-qr-pay amount="42.00" currency="LYD" merchant="Acme Store">
 *   <img slot="qr" src="…" alt="QR code" />
 *   <npt-button slot="action">Pay</npt-button>
 * </npt-qr-pay>
 * Payment panel: a bordered QR area (`qr` slot), the amount + merchant, and a
 * primary action slot.
 */
export declare class NptQrPay extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-topup-row provider="Vodafone Cash"><svg slot="icon">…</svg></npt-topup-row>
 * A selectable top-up option: icon slot + provider label + trailing chevron.
 */
export declare class NptTopupRow extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-tier-badge tier="Gold" tone="gold|silver|primary|neutral"></npt-tier-badge>
 * A small premium membership pill.
 */
export declare class NptTierBadge extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=wallet-pay.d.ts.map
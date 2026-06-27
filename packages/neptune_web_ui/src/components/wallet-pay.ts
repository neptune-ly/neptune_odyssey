// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — wallet & pay surfaces
// <npt-quick-actions>/<npt-quick-action>, <npt-merchant-row>, <npt-voucher-card>,
// <npt-qr-pay>, <npt-topup-row>, <npt-tier-badge>.
// Custom-property driven only; money uses tabular figures; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-quick-actions> with <npt-quick-action> children.
 * A responsive grid of action tiles. Clicking a child emits a bubbling `select`
 * event from the grid carrying the chosen tile's label.
 */
export class NptQuickActions extends NptElement {
  override connectedCallback(): void {
    super.connectedCallback();
    this.addEventListener("click", this.onClick);
    this.addEventListener("keydown", this.onKey);
  }

  disconnectedCallback(): void {
    this.removeEventListener("click", this.onClick);
    this.removeEventListener("keydown", this.onKey);
  }

  private activate(target: EventTarget | null): void {
    const tile = (target as HTMLElement | null)?.closest("npt-quick-action");
    if (!tile || tile.hasAttribute("disabled")) return;
    const label = tile.getAttribute("label") ?? "";
    this.dispatchEvent(new CustomEvent("select", { detail: { label }, bubbles: true }));
  }

  private onClick = (e: Event): void => this.activate(e.target);
  private onKey = (e: KeyboardEvent): void => {
    if (e.key !== " " && e.key !== "Enter") return;
    if (!(e.target as HTMLElement | null)?.closest("npt-quick-action")) return;
    e.preventDefault();
    this.activate(e.target);
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .grid {
        display: grid;
        grid-template-columns: repeat(var(--npt-quick-actions-cols, 4), minmax(0, 1fr));
        gap: var(--npt-space-3, 12px);
      }
    `;
  }

  protected render(): string {
    return html`<div class="grid" part="grid" role="group"><slot></slot></div>`;
  }
}

/**
 * <npt-quick-action label="Send"><svg slot="icon">…</svg></npt-quick-action>
 * A single tile inside <npt-quick-actions>. Provide the glyph via the `icon` slot.
 */
export class NptQuickAction extends NptElement {
  static observedAttributes = ["label", "disabled"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .tile {
        inline-size: 100%;
        min-block-size: 88px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: var(--npt-space-2, 8px);
        padding-block: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-2, 8px);
        border: none;
        border-radius: var(--npt-corner-md, 16px);
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface);
        cursor: pointer;
        font-family: var(--npt-font-text);
        box-sizing: border-box;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          transform var(--npt-dur-fast, 200ms) var(--npt-ease-spring, ease);
      }
      .tile:hover {
        background: var(--md-sys-color-surface-container-high);
      }
      .tile:active {
        transform: scale(0.97);
      }
      :host([disabled]) .tile {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .glyph {
        inline-size: 44px;
        block-size: 44px;
        border-radius: var(--npt-corner-full, 999px);
        display: grid;
        place-items: center;
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
      }
      .label {
        font-size: var(--npt-text-label, 14px);
        line-height: var(--npt-leading-label, 20px);
        text-align: center;
        color: var(--md-sys-color-on-surface);
      }
      ::slotted([slot="icon"]) {
        inline-size: 24px;
        block-size: 24px;
        display: block;
      }
    `;
  }

  protected render(): string {
    const label = esc(this.getAttribute("label"));
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    return html`<button class="tile" part="tile" type="button" aria-label="${label}" ${disabled}>
      <span class="glyph" aria-hidden="true"><slot name="icon"></slot></span>
      <span class="label">${label}</span>
    </button>`;
  }
}

/**
 * <npt-merchant-row name="Acme" category="Groceries" amount="-42.00" currency="LYD"
 *   time="14:32" [pending]>
 *   <img slot="logo" src="…" alt="" />
 * </npt-merchant-row>
 * Provide a logo via the `logo` slot; falls back to the name's initials.
 */
export class NptMerchantRow extends NptElement {
  static observedAttributes = ["name", "category", "amount", "currency", "time", "pending"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .row {
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        min-height: 56px;
        padding-block: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-2, 8px);
        border-bottom: 1px solid var(--md-sys-color-outline-variant);
      }
      .logo {
        inline-size: 44px;
        block-size: 44px;
        flex: 0 0 auto;
        border-radius: var(--npt-corner-full, 999px);
        overflow: hidden;
        display: grid;
        place-items: center;
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
        font-family: var(--npt-font-display);
        font-weight: 700;
        font-size: var(--npt-text-label, 14px);
      }
      ::slotted([slot="logo"]) {
        inline-size: 100%;
        block-size: 100%;
        object-fit: cover;
      }
      .body {
        flex: 1 1 auto;
        min-inline-size: 0;
      }
      .name {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      .category {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
        display: flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
      }
      .pending {
        display: inline-flex;
        align-items: center;
        padding-inline: var(--npt-space-2, 8px);
        padding-block: 1px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-tertiary-container);
        color: var(--md-sys-color-on-tertiary-container);
        font-size: var(--npt-text-caption, 12px);
        font-weight: 600;
      }
      .trailing {
        text-align: end;
        flex: 0 0 auto;
      }
      .amount {
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-body-lg, 16px);
        font-weight: 600;
        color: var(--md-sys-color-on-surface);
        white-space: nowrap;
        margin: 0;
      }
      :host([pending]) .amount {
        color: var(--md-sys-color-on-surface-variant);
      }
      .time {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-caption, 12px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
      }
    `;
  }

  protected render(): string {
    const name = esc(this.getAttribute("name"));
    const category = esc(this.getAttribute("category"));
    const amount = esc(this.getAttribute("amount"));
    const currency = esc(this.getAttribute("currency"));
    const time = esc(this.getAttribute("time"));
    const pending = this.hasAttribute("pending");
    const initial = name.trim().charAt(0).toUpperCase() || "•";
    return html`<div class="row" part="row" role="group" aria-label="${name} ${amount} ${currency}">
      <span class="logo" part="logo">
        <slot name="logo"><span aria-hidden="true">${initial}</span></slot>
      </span>
      <div class="body">
        <p class="name">${name}</p>
        <p class="category">
          ${category ? html`<span>${category}</span>` : ""}
          ${pending ? html`<span class="pending">pending</span>` : ""}
        </p>
      </div>
      <div class="trailing">
        <p class="amount">${amount} ${currency}</p>
        ${time ? html`<p class="time">${time}</p>` : ""}
      </div>
    </div>`;
  }
}

/**
 * <npt-voucher-card title="20% off" value="−20%" code="NEPTUNE20" expiry="Exp 31 Dec">
 *   …optional default-slot detail…
 * </npt-voucher-card>
 * A coupon visual with punched dashed-notch edges (radial-gradient masks).
 */
export class NptVoucherCard extends NptElement {
  static observedAttributes = ["title", "value", "code", "expiry"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .voucher {
        position: relative;
        display: flex;
        align-items: stretch;
        gap: var(--npt-space-4, 16px);
        padding: var(--npt-space-5, 20px);
        border-radius: var(--npt-corner-lg, 24px);
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
        box-shadow: var(--npt-elevation-1, 0 1px 3px rgba(0, 0, 0, 0.2));
        box-sizing: border-box;
        overflow: hidden;
        /* Punch a notch out of each inline edge with a radial-gradient mask.
           Mask colour is alpha-only — currentColor supplies the opaque stop. */
        --_notch: 16px;
        -webkit-mask:
          radial-gradient(var(--_notch) at left 50%, transparent 98%, currentColor) left / 51% 100% no-repeat,
          radial-gradient(var(--_notch) at right 50%, transparent 98%, currentColor) right / 51% 100% no-repeat;
        -webkit-mask-composite: source-over;
        mask:
          radial-gradient(var(--_notch) at left 50%, transparent 98%, currentColor) left / 51% 100% no-repeat,
          radial-gradient(var(--_notch) at right 50%, transparent 98%, currentColor) right / 51% 100% no-repeat;
        mask-composite: add;
      }
      .value {
        flex: 0 0 auto;
        align-self: center;
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-headline, 28px);
        font-weight: 700;
        letter-spacing: -0.01em;
        padding-inline-end: var(--npt-space-4, 16px);
        /* dashed tear line between the value stub and the body */
        border-inline-end: 2px dashed var(--md-sys-color-outline);
      }
      .body {
        flex: 1 1 auto;
        min-inline-size: 0;
        display: flex;
        flex-direction: column;
        gap: var(--npt-space-1, 4px);
        justify-content: center;
      }
      .title {
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-title, 18px);
        font-weight: 600;
        margin: 0;
      }
      .detail {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        opacity: 0.86;
      }
      .meta {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: var(--npt-space-3, 12px);
        margin-block-start: var(--npt-space-1, 4px);
      }
      .code {
        display: inline-flex;
        align-items: center;
        padding-inline: var(--npt-space-3, 12px);
        padding-block: var(--npt-space-1, 4px);
        border-radius: var(--npt-corner-xs, 8px);
        background: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface);
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
        letter-spacing: 0.08em;
      }
      .expiry {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        opacity: 0.78;
      }
    `;
  }

  protected render(): string {
    const title = esc(this.getAttribute("title"));
    const value = esc(this.getAttribute("value"));
    const code = esc(this.getAttribute("code"));
    const expiry = esc(this.getAttribute("expiry"));
    return html`<div class="voucher" part="voucher" role="group" aria-label="${title} ${value}">
      ${value ? html`<div class="value" part="value">${value}</div>` : ""}
      <div class="body">
        ${title ? html`<p class="title">${title}</p>` : ""}
        <div class="detail"><slot></slot></div>
        <div class="meta">
          ${code ? html`<span class="code" part="code">${code}</span>` : ""}
          ${expiry ? html`<span class="expiry">${expiry}</span>` : ""}
        </div>
      </div>
    </div>`;
  }
}

/**
 * <npt-qr-pay amount="42.00" currency="LYD" merchant="Acme Store">
 *   <img slot="qr" src="…" alt="QR code" />
 *   <npt-button slot="action">Pay</npt-button>
 * </npt-qr-pay>
 * Payment panel: a bordered QR area (`qr` slot), the amount + merchant, and a
 * primary action slot.
 */
export class NptQrPay extends NptElement {
  static observedAttributes = ["amount", "currency", "merchant"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .panel {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: var(--npt-space-5, 20px);
        padding: var(--npt-space-6, 24px);
        border-radius: var(--npt-corner-xl, 32px);
        background: var(--md-sys-color-surface-container-low);
        color: var(--md-sys-color-on-surface);
        box-sizing: border-box;
      }
      .qr {
        inline-size: 200px;
        block-size: 200px;
        max-inline-size: 100%;
        aspect-ratio: 1;
        display: grid;
        place-items: center;
        border-radius: var(--npt-corner-md, 16px);
        border: 2px solid var(--md-sys-color-outline-variant);
        background: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface-variant);
        overflow: hidden;
      }
      ::slotted([slot="qr"]) {
        inline-size: 100%;
        block-size: 100%;
        object-fit: contain;
      }
      .merchant {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 0;
        text-align: center;
      }
      .amount {
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-display-sm, 36px);
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: 0;
        display: flex;
        align-items: baseline;
        gap: var(--npt-space-2, 8px);
      }
      .currency {
        font-size: var(--npt-text-title, 18px);
        opacity: 0.85;
      }
      .action {
        inline-size: 100%;
        display: flex;
        justify-content: center;
      }
      ::slotted([slot="action"]) {
        inline-size: 100%;
      }
    `;
  }

  protected render(): string {
    const amount = esc(this.getAttribute("amount"));
    const currency = esc(this.getAttribute("currency"));
    const merchant = esc(this.getAttribute("merchant"));
    return html`<div class="panel" part="panel" role="group" aria-label="Pay ${amount} ${currency} ${merchant}">
      <div class="qr" part="qr">
        <slot name="qr"><span aria-hidden="true">QR</span></slot>
      </div>
      ${merchant ? html`<p class="merchant">${merchant}</p>` : ""}
      <p class="amount"><span class="currency">${currency}</span>${amount}</p>
      <div class="action"><slot name="action"></slot></div>
    </div>`;
  }
}

/**
 * <npt-topup-row provider="Vodafone Cash"><svg slot="icon">…</svg></npt-topup-row>
 * A selectable top-up option: icon slot + provider label + trailing chevron.
 */
export class NptTopupRow extends NptElement {
  static observedAttributes = ["provider", "disabled"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .row {
        inline-size: 100%;
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        min-height: 56px;
        padding-block: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-4, 16px);
        border: none;
        border-radius: var(--npt-corner-md, 16px);
        background: var(--md-sys-color-surface-container-low);
        color: var(--md-sys-color-on-surface);
        text-align: start;
        cursor: pointer;
        font-family: var(--npt-font-text);
        box-sizing: border-box;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .row:hover {
        background: var(--md-sys-color-surface-container-high);
      }
      :host([disabled]) .row {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .icon {
        inline-size: 40px;
        block-size: 40px;
        flex: 0 0 auto;
        border-radius: var(--npt-corner-sm, 12px);
        display: grid;
        place-items: center;
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
      ::slotted([slot="icon"]) {
        inline-size: 24px;
        block-size: 24px;
        display: block;
      }
      .provider {
        flex: 1 1 auto;
        min-inline-size: 0;
        font-size: var(--npt-text-body-lg, 16px);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      .chevron {
        flex: 0 0 auto;
        color: var(--md-sys-color-on-surface-variant);
        /* point toward the inline-end; flips automatically in RTL */
        transform: scaleX(1);
      }
      :host(:dir(rtl)) .chevron {
        transform: scaleX(-1);
      }
    `;
  }

  protected render(): string {
    const provider = esc(this.getAttribute("provider"));
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    return html`<button class="row" part="row" type="button" aria-label="${provider}" ${disabled}>
      <span class="icon" aria-hidden="true"><slot name="icon"></slot></span>
      <span class="provider">${provider}</span>
      <span class="chevron" aria-hidden="true">›</span>
    </button>`;
  }
}

/**
 * <npt-tier-badge tier="Gold" tone="gold|silver|primary|neutral"></npt-tier-badge>
 * A small premium membership pill.
 */
export class NptTierBadge extends NptElement {
  static observedAttributes = ["tier", "tone"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: inline-flex;
      }
      .badge {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-1, 4px);
        min-height: 24px;
        padding-inline: var(--npt-space-3, 12px);
        padding-block: 2px;
        border-radius: var(--npt-corner-full, 999px);
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-label, 14px);
        line-height: var(--npt-leading-label, 20px);
        font-weight: 700;
        letter-spacing: 0.02em;
        /* default / neutral tone */
        background: var(--md-sys-color-surface-container-highest);
        color: var(--md-sys-color-on-surface);
        border: 1px solid var(--md-sys-color-outline-variant);
        box-sizing: border-box;
      }
      :host([tone="primary"]) .badge {
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
        border-color: transparent;
      }
      :host([tone="gold"]) .badge {
        background: var(--md-sys-color-tertiary-container);
        color: var(--md-sys-color-on-tertiary-container);
        border-color: transparent;
      }
      :host([tone="silver"]) .badge {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
        border-color: transparent;
      }
      .dot {
        inline-size: 6px;
        block-size: 6px;
        border-radius: var(--npt-corner-full, 999px);
        background: currentColor;
      }
    `;
  }

  protected render(): string {
    const tier = esc(this.getAttribute("tier"));
    return html`<span class="badge" part="badge" role="status" aria-label="${tier} tier">
      <span class="dot" aria-hidden="true"></span>${tier}
    </span>`;
  }
}

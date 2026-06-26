// Neptune Odyssey — financial components · © 2026 Neptune.Fintech (neptune.ly)
// <npt-balance-card>, <npt-transaction-row>. Money uses tabular figures.
import { NptElement, css, html } from "./base.js";

const escape = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-balance-card label="Available balance" amount="12,480.50" currency="LYD"
 *   account="•••• 4821" [hero]></npt-balance-card>
 * The dashboard balance hero. `hero` enables the brand gradient surface.
 */
export class NptBalanceCard extends NptElement {
  static observedAttributes = ["label", "amount", "currency", "account", "hero"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .hero {
        border-radius: var(--npt-corner-xl, 32px);
        padding: var(--npt-space-6, 24px);
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface);
        box-sizing: border-box;
      }
      :host([hero]) .hero {
        background: linear-gradient(135deg, var(--md-sys-color-primary), var(--md-sys-color-tertiary));
        color: var(--md-sys-color-on-primary);
      }
      .label {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        opacity: 0.86;
        margin: 0 0 var(--npt-space-2, 8px);
      }
      .amount {
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-display-md, 45px);
        line-height: var(--npt-leading-display-md, 52px);
        font-weight: var(--npt-display-weight, 700);
        letter-spacing: var(--npt-display-tracking, -0.02em);
        margin: 0;
        display: flex;
        align-items: baseline;
        gap: var(--npt-space-2, 8px);
      }
      .currency {
        font-size: var(--npt-text-title, 18px);
        opacity: 0.85;
      }
      .account {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-body, 14px);
        opacity: 0.78;
        margin: var(--npt-space-3, 12px) 0 0;
      }
    `;
  }

  protected render(): string {
    const label = escape(this.getAttribute("label"));
    const amount = escape(this.getAttribute("amount"));
    const currency = escape(this.getAttribute("currency"));
    const account = escape(this.getAttribute("account"));
    return html`
      <div class="hero" part="hero" role="group" aria-label="${label} ${amount} ${currency}">
        <p class="label">${label}</p>
        <p class="amount"><span class="currency">${currency}</span>${amount}</p>
        ${account ? html`<p class="account">${account}</p>` : ""}
      </div>
    `;
  }
}

/**
 * <npt-transaction-row title="Coffee" subtitle="Today · Card" amount="-4.50"
 *   currency="LYD" [credit]></npt-transaction-row>
 */
export class NptTransactionRow extends NptElement {
  static observedAttributes = ["title", "subtitle", "amount", "currency", "credit"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
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
      .icon {
        inline-size: 40px;
        block-size: 40px;
        border-radius: var(--npt-corner-md, 16px);
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
        display: grid;
        place-items: center;
        flex: 0 0 auto;
        font-family: var(--npt-font-display);
        font-weight: 700;
      }
      .body {
        flex: 1 1 auto;
        min-inline-size: 0;
      }
      .title {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      .subtitle {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
      }
      .amount {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-body-lg, 16px);
        font-weight: 600;
        color: var(--md-sys-color-on-surface);
        white-space: nowrap;
      }
      :host([credit]) .amount {
        color: var(--md-sys-color-success);
      }
    `;
  }

  protected render(): string {
    const title = escape(this.getAttribute("title"));
    const subtitle = escape(this.getAttribute("subtitle"));
    const amount = escape(this.getAttribute("amount"));
    const currency = escape(this.getAttribute("currency"));
    const initial = title.trim().charAt(0).toUpperCase() || "•";
    return html`
      <div class="row" part="row">
        <div class="icon" aria-hidden="true">${initial}</div>
        <div class="body">
          <p class="title">${title}</p>
          ${subtitle ? html`<p class="subtitle">${subtitle}</p>` : ""}
        </div>
        <div class="amount">${amount} ${currency}</div>
      </div>
    `;
  }
}

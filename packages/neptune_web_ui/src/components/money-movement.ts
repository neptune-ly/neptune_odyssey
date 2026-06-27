// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — money-movement flow
// <npt-stepper>, <npt-step>, <npt-transfer-review>, <npt-success>,
// <npt-receipt>, <npt-beneficiary-tile>, <npt-method-row>.
// Custom-property driven only; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y, define } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/** A single declarative step label, consumed by <npt-stepper>. Renders nothing on its own. */
export class NptStep extends NptElement {
  protected styles(): string {
    return css`
      :host {
        display: none;
      }
    `;
  }

  protected render(): string {
    return html``;
  }
}

/**
 * <npt-stepper active="1" steps="Amount,Review,Done"></npt-stepper>
 * or with light-DOM <npt-step>Amount</npt-step> children.
 * Horizontal progress indicator with numbered nodes + connectors.
 */
export class NptStepper extends NptElement {
  static observedAttributes = ["steps", "active"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  private labels(): string[] {
    const attr = this.getAttribute("steps");
    if (attr && attr.trim()) {
      return attr
        .split(",")
        .map((s) => s.trim())
        .filter((s) => s.length > 0);
    }
    return Array.from(this.querySelectorAll("npt-step")).map((s) => (s.textContent ?? "").trim());
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .stepper {
        display: flex;
        align-items: flex-start;
        gap: var(--npt-space-1, 4px);
        font-family: var(--npt-font-text);
      }
      .step {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        flex: 0 0 auto;
        min-inline-size: 56px;
      }
      .node {
        inline-size: 32px;
        block-size: 32px;
        border-radius: var(--npt-corner-full, 999px);
        display: grid;
        place-items: center;
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
        background: var(--md-sys-color-surface-container-highest);
        color: var(--md-sys-color-on-surface-variant);
        border: 2px solid var(--md-sys-color-outline-variant);
        box-sizing: border-box;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .step[data-state="active"] .node {
        background: var(--md-sys-color-primary);
        color: var(--md-sys-color-on-primary);
        border-color: var(--md-sys-color-primary);
      }
      .step[data-state="done"] .node {
        background: var(--md-sys-color-success);
        color: var(--md-sys-color-on-success);
        border-color: var(--md-sys-color-success);
      }
      .label {
        font-size: var(--npt-text-caption, 12px);
        color: var(--md-sys-color-on-surface-variant);
        text-align: center;
        max-inline-size: 80px;
      }
      .step[data-state="active"] .label {
        color: var(--md-sys-color-on-surface);
        font-weight: 600;
      }
      .connector {
        flex: 1 1 auto;
        block-size: 2px;
        margin-block-start: 15px;
        margin-inline: var(--npt-space-1, 4px);
        min-inline-size: var(--npt-space-4, 16px);
        background: var(--md-sys-color-outline-variant);
        border-radius: var(--npt-corner-full, 999px);
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .connector[data-done="true"] {
        background: var(--md-sys-color-success);
      }
    `;
  }

  protected render(): string {
    const labels = this.labels();
    const active = Math.max(0, Number(this.getAttribute("active") ?? 0));
    const total = labels.length;
    const nodes = labels
      .map((label, i) => {
        const state = i < active ? "done" : i === active ? "active" : "upcoming";
        const current = state === "active" ? html`aria-current="step"` : "";
        const mark = state === "done" ? "✓" : String(i + 1);
        const step = html`<li
          class="step"
          part="step"
          data-state="${state}"
          role="listitem"
          ${current}
        >
          <span class="node" aria-hidden="true">${mark}</span>
          <span class="label">${esc(label)}</span>
        </li>`;
        if (i < total - 1) {
          const done = i < active ? "true" : "false";
          return html`${step}<span class="connector" part="connector" data-done="${done}" aria-hidden="true"></span>`;
        }
        return step;
      })
      .join("");
    const label = `Step ${Math.min(active + 1, Math.max(total, 1))} of ${total}`;
    return html`<ol class="stepper" part="stepper" role="list" aria-label="${esc(label)}">${nodes}</ol>`;
  }
}

/**
 * <npt-transfer-review rows='[{"label":"To","value":"Mona K"}]'
 *   total="1,250.00" currency="LYD"></npt-transfer-review>
 * Light-DOM rows are also supported: place elements with [slot="rows"].
 * Key/value summary with a highlighted total footer.
 */
export class NptTransferReview extends NptElement {
  static observedAttributes = ["rows", "total", "currency", "total-label"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  private rows(): ReadonlyArray<{ label: string; value: string }> {
    const raw = this.getAttribute("rows");
    if (!raw) return [];
    try {
      const parsed: unknown = JSON.parse(raw);
      if (!Array.isArray(parsed)) return [];
      return parsed
        .filter((r): r is Record<string, unknown> => typeof r === "object" && r !== null)
        .map((r) => ({ label: String(r["label"] ?? ""), value: String(r["value"] ?? "") }));
    } catch {
      return [];
    }
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .review {
        background: var(--md-sys-color-surface-container-low);
        color: var(--md-sys-color-on-surface);
        border-radius: var(--npt-corner-lg, 24px);
        padding: var(--npt-space-5, 20px);
        box-sizing: border-box;
      }
      dl {
        margin: 0;
        display: grid;
        gap: var(--npt-space-3, 12px);
      }
      .row {
        display: flex;
        align-items: baseline;
        justify-content: space-between;
        gap: var(--npt-space-4, 16px);
      }
      dt {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 0;
      }
      dd {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
        margin: 0;
        text-align: end;
        min-inline-size: 0;
        overflow-wrap: anywhere;
      }
      .total {
        margin-block-start: var(--npt-space-4, 16px);
        padding-block-start: var(--npt-space-4, 16px);
        border-block-start: 1px solid var(--md-sys-color-outline-variant);
        display: flex;
        align-items: baseline;
        justify-content: space-between;
        gap: var(--npt-space-4, 16px);
      }
      .total-label {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
        color: var(--md-sys-color-on-surface);
      }
      .total-value {
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-title-lg, 22px);
        font-weight: 700;
        color: var(--md-sys-color-primary);
        white-space: nowrap;
      }
      .total-currency {
        font-size: var(--npt-text-body, 14px);
        opacity: 0.85;
        margin-inline-start: var(--npt-space-1, 4px);
      }
      ::slotted([slot="rows"]) {
        display: block;
      }
    `;
  }

  protected render(): string {
    const total = esc(this.getAttribute("total"));
    const currency = esc(this.getAttribute("currency"));
    const totalLabel = esc(this.getAttribute("total-label")) || "Total";
    const rows = this.rows()
      .map(
        (r) => html`<div class="row" part="row">
          <dt>${esc(r.label)}</dt>
          <dd>${esc(r.value)}</dd>
        </div>`,
      )
      .join("");
    const totalBlock = total
      ? html`<div class="total" part="total">
          <span class="total-label">${totalLabel}</span>
          <span class="total-value"
            >${total}${currency ? html`<span class="total-currency">${currency}</span>` : ""}</span
          >
        </div>`
      : "";
    return html`<section
      class="review"
      part="review"
      role="group"
      aria-label="${totalLabel} ${total} ${currency}"
    >
      <dl>${rows}</dl>
      <slot name="rows"></slot>
      ${totalBlock}
    </section>`;
  }
}

/**
 * <npt-success title="Transfer sent" message="Your money is on the way.">
 *   <npt-button slot="actions">Done</npt-button>
 * </npt-success>
 * Success hero with a spring-in check; honours reduced motion.
 */
export class NptSuccess extends NptElement {
  static observedAttributes = ["title", "message"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .hero {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        gap: var(--npt-space-4, 16px);
        padding: var(--npt-space-6, 24px);
        box-sizing: border-box;
      }
      .ring {
        inline-size: 96px;
        block-size: 96px;
        border-radius: var(--npt-corner-full, 999px);
        display: grid;
        place-items: center;
        background: var(--md-sys-color-success-container, var(--md-sys-color-secondary-container));
        color: var(--md-sys-color-success);
        animation: spring-in var(--npt-dur-slow, 400ms) var(--npt-ease-spring, ease) both;
      }
      .check {
        font-size: var(--npt-text-display-md, 45px);
        line-height: 1;
        animation: check-pop var(--npt-dur-standard, 300ms) var(--npt-ease-spring, ease) both;
        animation-delay: var(--npt-dur-fast, 200ms);
      }
      .title {
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-headline, 24px);
        font-weight: 700;
        color: var(--md-sys-color-on-surface);
        margin: 0;
      }
      .message {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 0;
        max-inline-size: 40ch;
      }
      .actions {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        gap: var(--npt-space-3, 12px);
        margin-block-start: var(--npt-space-2, 8px);
      }
      @keyframes spring-in {
        0% {
          transform: scale(0.6);
          opacity: 0;
        }
        60% {
          transform: scale(1.08);
          opacity: 1;
        }
        100% {
          transform: scale(1);
        }
      }
      @keyframes check-pop {
        0% {
          transform: scale(0);
        }
        100% {
          transform: scale(1);
        }
      }
    `;
  }

  protected render(): string {
    const title = esc(this.getAttribute("title"));
    const message = esc(this.getAttribute("message"));
    return html`<div class="hero" part="hero" role="status" aria-live="polite">
      <span class="ring" part="ring" aria-hidden="true"><span class="check">✓</span></span>
      ${title ? html`<h2 class="title" part="title">${title}</h2>` : ""}
      ${message ? html`<p class="message" part="message">${message}</p>` : ""}
      <div class="actions" part="actions"><slot name="actions"></slot></div>
    </div>`;
  }
}

/**
 * <npt-receipt merchant="Acme" amount="42.00" currency="LYD"
 *   date="27 Jun 2026" status="Completed" reference="TX-9931"></npt-receipt>
 * Receipt card with a dashed tear divider; extra rows via the default slot.
 */
export class NptReceipt extends NptElement {
  static observedAttributes = ["merchant", "amount", "currency", "date", "status", "reference"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .receipt {
        background: var(--md-sys-color-surface-container-lowest);
        color: var(--md-sys-color-on-surface);
        border: 1px solid var(--md-sys-color-outline-variant);
        border-radius: var(--npt-corner-lg, 24px);
        padding: var(--npt-space-5, 20px);
        box-sizing: border-box;
      }
      .merchant {
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-title, 18px);
        font-weight: 700;
        margin: 0;
      }
      .amount {
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-display-md, 45px);
        line-height: var(--npt-leading-display-md, 52px);
        font-weight: 700;
        letter-spacing: -0.02em;
        margin: var(--npt-space-2, 8px) 0 0;
        display: flex;
        align-items: baseline;
        gap: var(--npt-space-2, 8px);
      }
      .amount .currency {
        font-size: var(--npt-text-title, 18px);
        opacity: 0.85;
      }
      .divider {
        block-size: 0;
        border: none;
        border-block-start: 2px dashed var(--md-sys-color-outline-variant);
        margin-block: var(--npt-space-4, 16px);
      }
      dl {
        margin: 0;
        display: grid;
        gap: var(--npt-space-3, 12px);
      }
      .row {
        display: flex;
        align-items: baseline;
        justify-content: space-between;
        gap: var(--npt-space-4, 16px);
      }
      dt {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 0;
      }
      dd {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
        margin: 0;
        text-align: end;
        overflow-wrap: anywhere;
      }
      dd.num {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
      }
      .status {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        font-weight: 600;
        color: var(--md-sys-color-success);
      }
      .status::before {
        content: "";
        inline-size: 8px;
        block-size: 8px;
        border-radius: var(--npt-corner-full, 999px);
        background: currentColor;
      }
      ::slotted(*) {
        margin-block-start: var(--npt-space-3, 12px);
      }
    `;
  }

  protected render(): string {
    const merchant = esc(this.getAttribute("merchant"));
    const amount = esc(this.getAttribute("amount"));
    const currency = esc(this.getAttribute("currency"));
    const date = esc(this.getAttribute("date"));
    const status = esc(this.getAttribute("status"));
    const reference = esc(this.getAttribute("reference"));
    return html`<article
      class="receipt"
      part="receipt"
      role="group"
      aria-label="Receipt ${merchant} ${amount} ${currency}"
    >
      ${merchant ? html`<p class="merchant" part="merchant">${merchant}</p>` : ""}
      ${amount
        ? html`<p class="amount" part="amount">
            ${currency ? html`<span class="currency">${currency}</span>` : ""}${amount}
          </p>`
        : ""}
      <hr class="divider" part="divider" aria-hidden="true" />
      <dl>
        ${date ? html`<div class="row"><dt>Date</dt><dd>${date}</dd></div>` : ""}
        ${reference
          ? html`<div class="row"><dt>Reference</dt><dd class="num">${reference}</dd></div>`
          : ""}
        ${status
          ? html`<div class="row">
              <dt>Status</dt>
              <dd><span class="status">${status}</span></dd>
            </div>`
          : ""}
      </dl>
      <slot></slot>
    </article>`;
  }
}

/**
 * <npt-beneficiary-tile name="Mona Kamel" account="•••• 4821" [favorite]>
 * </npt-beneficiary-tile>
 * Avatar/initials + name + masked account + trailing chevron.
 */
export class NptBeneficiaryTile extends NptElement {
  static observedAttributes = ["name", "account", "favorite"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  private initials(name: string): string {
    const parts = name.trim().split(/\s+/).filter(Boolean);
    if (parts.length === 0) return "•";
    const first = parts[0]?.charAt(0) ?? "";
    const last = parts.length > 1 ? (parts[parts.length - 1]?.charAt(0) ?? "") : "";
    return (first + last).toUpperCase() || "•";
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .tile {
        inline-size: 100%;
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        min-height: 56px;
        padding-inline: var(--npt-space-3, 12px);
        padding-block: var(--npt-space-3, 12px);
        border: none;
        background: transparent;
        color: inherit;
        text-align: start;
        font-family: var(--npt-font-text);
        cursor: pointer;
        border-radius: var(--npt-corner-md, 16px);
        box-sizing: border-box;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .tile:hover {
        background: var(--md-sys-color-surface-container-high);
      }
      .avatar {
        position: relative;
        inline-size: 44px;
        block-size: 44px;
        flex: 0 0 auto;
        border-radius: var(--npt-corner-full, 999px);
        display: grid;
        place-items: center;
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
        font-family: var(--npt-font-display);
        font-weight: 600;
        font-size: var(--npt-text-label, 14px);
      }
      .star {
        position: absolute;
        inset-block-end: -2px;
        inset-inline-end: -2px;
        inline-size: 18px;
        block-size: 18px;
        border-radius: var(--npt-corner-full, 999px);
        display: grid;
        place-items: center;
        font-size: var(--npt-text-caption, 12px);
        background: var(--md-sys-color-tertiary);
        color: var(--md-sys-color-on-tertiary);
      }
      .body {
        flex: 1 1 auto;
        min-inline-size: 0;
      }
      .name {
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      .account {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
      }
      .chevron {
        flex: 0 0 auto;
        color: var(--md-sys-color-on-surface-variant);
        font-size: var(--npt-text-title, 18px);
        line-height: 1;
      }
    `;
  }

  protected render(): string {
    const name = esc(this.getAttribute("name"));
    const account = esc(this.getAttribute("account"));
    const favorite = this.hasAttribute("favorite");
    const initials = this.initials(name);
    const label = favorite ? `${name}, favourite${account ? `, ${account}` : ""}` : `${name}${account ? `, ${account}` : ""}`;
    return html`<button class="tile" part="tile" type="button" aria-label="${esc(label)}">
      <span class="avatar" aria-hidden="true">
        ${initials}${favorite ? html`<span class="star">★</span>` : ""}
      </span>
      <span class="body">
        <span class="name">${name}</span>
        ${account ? html`<span class="account">${account}</span>` : ""}
      </span>
      <span class="chevron" aria-hidden="true">›</span>
    </button>`;
  }
}

/**
 * <npt-method-row title="Bank transfer" subtitle="1–2 business days" [recommended]>
 *   <span slot="icon">🏦</span>
 * </npt-method-row>
 * Transfer-method row: leading icon slot, title/subtitle, trailing chevron, badge.
 */
export class NptMethodRow extends NptElement {
  static observedAttributes = ["title", "subtitle", "recommended"];

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
        min-height: 64px;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        border: 1px solid var(--md-sys-color-outline-variant);
        border-radius: var(--npt-corner-md, 16px);
        background: var(--md-sys-color-surface-container-lowest);
        color: inherit;
        text-align: start;
        font-family: var(--npt-font-text);
        cursor: pointer;
        box-sizing: border-box;
        transition: border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .row:hover {
        border-color: var(--md-sys-color-primary);
        background: var(--md-sys-color-surface-container);
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
        font-size: var(--npt-text-title, 18px);
      }
      .body {
        flex: 1 1 auto;
        min-inline-size: 0;
      }
      .titlebar {
        display: flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        flex-wrap: wrap;
      }
      .title {
        font-size: var(--npt-text-body-lg, 16px);
        font-weight: 600;
        color: var(--md-sys-color-on-surface);
        margin: 0;
      }
      .subtitle {
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
      }
      .badge {
        font-size: var(--npt-text-caption, 12px);
        font-weight: 600;
        line-height: 1;
        padding-inline: var(--npt-space-2, 8px);
        padding-block: var(--npt-space-1, 4px);
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-success-container, var(--md-sys-color-tertiary-container));
        color: var(--md-sys-color-on-success-container, var(--md-sys-color-on-tertiary-container));
      }
      .chevron {
        flex: 0 0 auto;
        color: var(--md-sys-color-on-surface-variant);
        font-size: var(--npt-text-title, 18px);
        line-height: 1;
      }
    `;
  }

  protected render(): string {
    const title = esc(this.getAttribute("title"));
    const subtitle = esc(this.getAttribute("subtitle"));
    const recommended = this.hasAttribute("recommended");
    const label = recommended ? `${title}, recommended` : title;
    return html`<button class="row" part="row" type="button" aria-label="${esc(label)}">
      <span class="icon" aria-hidden="true"><slot name="icon"></slot></span>
      <span class="body">
        <span class="titlebar">
          <span class="title">${title}</span>
          ${recommended ? html`<span class="badge" part="badge">Recommended</span>` : ""}
        </span>
        ${subtitle ? html`<span class="subtitle">${subtitle}</span>` : ""}
      </span>
      <span class="chevron" aria-hidden="true">›</span>
    </button>`;
  }
}

void define;

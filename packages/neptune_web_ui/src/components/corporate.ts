// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — corporate & back-office
// <npt-approval-item>, <npt-batch-card>, <npt-audit-row>, <npt-user-row>,
// <npt-permission-toggle>, <npt-workflow-status>.
// Maker-checker, bulk payments, audit logs, user admin & access control.
// Custom-property driven only; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-approval-item title="Vendor payment — ACME" amount="48,200.00" currency="LYD"
 *   maker="Mona Khaled" status="pending|approved|rejected"></npt-approval-item>
 * A maker-checker queue item. Approve/Reject buttons emit `approve` / `reject`.
 * Buttons hide once the item is no longer `pending`; the status chip reflects state.
 */
export class NptApprovalItem extends NptElement {
  static observedAttributes = ["title", "amount", "currency", "maker", "status"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  override connectedCallback(): void {
    super.connectedCallback();
    this.root.addEventListener("click", this.onClick);
  }

  disconnectedCallback(): void {
    this.root.removeEventListener("click", this.onClick);
  }

  private onClick = (e: Event): void => {
    const btn = (e.target as HTMLElement)?.closest("[data-action]");
    if (!btn) return;
    const action = btn.getAttribute("data-action");
    if (action === "approve" || action === "reject") {
      this.dispatchEvent(new CustomEvent(action, { bubbles: true }));
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .item {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: var(--npt-space-4, 16px);
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-4, 16px);
        border-radius: var(--npt-corner-md, 16px);
        background: var(--md-sys-color-surface-container-low);
        color: var(--md-sys-color-on-surface);
        box-sizing: border-box;
        border: 1px solid var(--md-sys-color-outline-variant);
      }
      .body {
        flex: 1 1 200px;
        min-inline-size: 0;
      }
      .title {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        font-weight: 600;
        color: var(--md-sys-color-on-surface);
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      .maker {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
      }
      .amount {
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-title, 18px);
        font-weight: 600;
        color: var(--md-sys-color-on-surface);
        white-space: nowrap;
        display: flex;
        align-items: baseline;
        gap: var(--npt-space-2, 8px);
      }
      .currency {
        font-size: var(--npt-text-label, 14px);
        opacity: 0.78;
      }
      .chip {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        font-weight: 600;
        min-height: 24px;
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-1, 4px);
        padding-inline: var(--npt-space-3, 12px);
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-surface-container-highest);
        color: var(--md-sys-color-on-surface-variant);
      }
      :host([status="approved"]) .chip {
        background: var(--md-sys-color-success);
        color: var(--md-sys-color-on-success);
      }
      :host([status="rejected"]) .chip {
        background: var(--md-sys-color-error-container);
        color: var(--md-sys-color-on-error-container);
      }
      .actions {
        display: inline-flex;
        gap: var(--npt-space-2, 8px);
      }
      :host([status="approved"]) .actions,
      :host([status="rejected"]) .actions {
        display: none;
      }
      button[data-action] {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
        min-height: 44px;
        padding-inline: var(--npt-space-5, 20px);
        border-radius: var(--npt-corner-full, 999px);
        border: none;
        cursor: pointer;
        transition: box-shadow var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      button[data-action="approve"] {
        background: var(--md-sys-color-success);
        color: var(--md-sys-color-on-success);
      }
      button[data-action="approve"]:hover {
        box-shadow: var(--npt-elevation-1, 0 1px 3px rgba(0, 0, 0, 0.2));
      }
      button[data-action="reject"] {
        background: transparent;
        color: var(--md-sys-color-error);
        border: 1px solid var(--md-sys-color-outline);
      }
    `;
  }

  protected render(): string {
    const title = esc(this.getAttribute("title"));
    const amount = esc(this.getAttribute("amount"));
    const currency = esc(this.getAttribute("currency"));
    const maker = esc(this.getAttribute("maker"));
    const status = this.getAttribute("status") || "pending";
    const chipLabel =
      status === "approved" ? "Approved" : status === "rejected" ? "Rejected" : "Pending";
    const chipIcon = status === "approved" ? "✓" : status === "rejected" ? "✕" : "•";
    return html`<div class="item" part="item" role="group" aria-label="${title} ${chipLabel}">
      <div class="body">
        <p class="title">${title}</p>
        ${maker ? html`<p class="maker">${maker}</p>` : ""}
      </div>
      <p class="amount"><span class="currency">${currency}</span>${amount}</p>
      <span class="chip" part="chip"><span aria-hidden="true">${chipIcon}</span>${chipLabel}</span>
      <div class="actions" part="actions">
        <button type="button" data-action="approve" part="approve">Approve</button>
        <button type="button" data-action="reject" part="reject">Reject</button>
      </div>
    </div>`;
  }
}

/**
 * <npt-batch-card filename="payroll-jun.csv" totalAmount="1,204,800.00" currency="LYD"
 *   payeeCount="312" requiredApprovals="2" validated="308" warnings="3" errors="1">
 *   <npt-button slot="action">Submit batch</npt-button>
 * </npt-batch-card>
 * A bulk-payment batch summary with a validated/warnings/errors counts row and an
 * action slot for the primary CTA.
 */
export class NptBatchCard extends NptElement {
  static observedAttributes = [
    "filename",
    "totalamount",
    "currency",
    "payeecount",
    "requiredapprovals",
    "validated",
    "warnings",
    "errors",
  ];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .card {
        border-radius: var(--npt-corner-lg, 24px);
        padding: var(--npt-space-6, 24px);
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface);
        box-sizing: border-box;
        box-shadow: var(--npt-elevation-1, 0 1px 3px rgba(0, 0, 0, 0.2));
      }
      .head {
        display: flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
      }
      .file-icon {
        inline-size: 40px;
        block-size: 40px;
        flex: 0 0 auto;
        border-radius: var(--npt-corner-sm, 12px);
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
        display: grid;
        place-items: center;
        font-size: var(--npt-text-title, 18px);
      }
      .filename {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        font-weight: 600;
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      .payees {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
      }
      .amount {
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-headline, 28px);
        line-height: var(--npt-leading-headline, 36px);
        font-weight: 700;
        letter-spacing: var(--npt-display-tracking, -0.02em);
        margin: var(--npt-space-4, 16px) 0 0;
        display: flex;
        align-items: baseline;
        gap: var(--npt-space-2, 8px);
      }
      .currency {
        font-size: var(--npt-text-title, 18px);
        opacity: 0.78;
      }
      .counts {
        display: flex;
        flex-wrap: wrap;
        gap: var(--npt-space-2, 8px);
        margin-block-start: var(--npt-space-4, 16px);
      }
      .count {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-1, 4px);
        padding-inline: var(--npt-space-3, 12px);
        padding-block: var(--npt-space-1, 4px);
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-surface-container-highest);
        color: var(--md-sys-color-on-surface-variant);
      }
      .count .n {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
      }
      .count.ok {
        background: var(--md-sys-color-success);
        color: var(--md-sys-color-on-success);
      }
      .count.warn {
        background: var(--md-sys-color-tertiary-container);
        color: var(--md-sys-color-on-tertiary-container);
      }
      .count.err {
        background: var(--md-sys-color-error-container);
        color: var(--md-sys-color-on-error-container);
      }
      .footer {
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        margin-block-start: var(--npt-space-5, 20px);
      }
      .approvals {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
      }
      .approvals .n {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        color: var(--md-sys-color-on-surface);
        font-weight: 600;
      }
      .action {
        margin-inline-start: auto;
        display: inline-flex;
      }
    `;
  }

  protected render(): string {
    const filename = esc(this.getAttribute("filename"));
    const amount = esc(this.getAttribute("totalamount"));
    const currency = esc(this.getAttribute("currency"));
    const payeeCount = esc(this.getAttribute("payeecount"));
    const required = esc(this.getAttribute("requiredapprovals"));
    const validated = esc(this.getAttribute("validated")) || "0";
    const warnings = esc(this.getAttribute("warnings")) || "0";
    const errors = esc(this.getAttribute("errors")) || "0";
    return html`<div class="card" part="card" role="group" aria-label="Batch ${filename}">
      <div class="head">
        <span class="file-icon" aria-hidden="true">▦</span>
        <div>
          <p class="filename">${filename}</p>
          ${payeeCount ? html`<p class="payees">${payeeCount} payees</p>` : ""}
        </div>
      </div>
      <p class="amount"><span class="currency">${currency}</span>${amount}</p>
      <div class="counts" part="counts" role="list" aria-label="Validation results">
        <span class="count ok" role="listitem">
          <span aria-hidden="true">✓</span><span class="n">${validated}</span> validated
        </span>
        <span class="count warn" role="listitem">
          <span aria-hidden="true">!</span><span class="n">${warnings}</span> warnings
        </span>
        <span class="count err" role="listitem">
          <span aria-hidden="true">✕</span><span class="n">${errors}</span> errors
        </span>
      </div>
      <div class="footer">
        ${required
          ? html`<span class="approvals">Requires <span class="n">${required}</span> approvals</span>`
          : ""}
        <span class="action"><slot name="action"></slot></span>
      </div>
    </div>`;
  }
}

/**
 * <npt-audit-row actor="Mona Khaled" action="approved payment" target="#PAY-3192"
 *   time="2026-06-27 14:02"></npt-audit-row>
 * A compact audit-log line with a leading status dot.
 */
export class NptAuditRow extends NptElement {
  static observedAttributes = ["actor", "action", "target", "time"];

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
        align-items: baseline;
        gap: var(--npt-space-3, 12px);
        min-height: 36px;
        padding-block: var(--npt-space-2, 8px);
        padding-inline: var(--npt-space-2, 8px);
        border-bottom: 1px solid var(--md-sys-color-outline-variant);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
      }
      .dot {
        flex: 0 0 auto;
        inline-size: 8px;
        block-size: 8px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-primary);
        align-self: center;
      }
      .text {
        flex: 1 1 auto;
        min-inline-size: 0;
        color: var(--md-sys-color-on-surface-variant);
      }
      .actor {
        color: var(--md-sys-color-on-surface);
        font-weight: 600;
      }
      .target {
        color: var(--md-sys-color-primary);
        font-weight: 600;
      }
      .time {
        flex: 0 0 auto;
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-caption, 12px);
        color: var(--md-sys-color-on-surface-variant);
        white-space: nowrap;
      }
    `;
  }

  protected render(): string {
    const actor = esc(this.getAttribute("actor"));
    const action = esc(this.getAttribute("action"));
    const target = esc(this.getAttribute("target"));
    const time = esc(this.getAttribute("time"));
    return html`<div class="row" part="row" role="listitem">
      <span class="dot" aria-hidden="true"></span>
      <span class="text">
        <span class="actor">${actor}</span> ${action}
        ${target ? html`<span class="target">${target}</span>` : ""}
      </span>
      ${time ? html`<time class="time">${time}</time>` : ""}
    </div>`;
  }
}

/**
 * <npt-user-row name="Mona Khaled" email="mona@bank.ly" role="Checker"
 *   initials="MK" src="" [suspended]>
 *   <npt-icon-button slot="actions">⋯</npt-icon-button>
 * </npt-user-row>
 * A user-admin list row: avatar/initials, name + email, role chip, status, and a
 * trailing actions slot. `suspended` dims the row and shows a Suspended chip.
 */
export class NptUserRow extends NptElement {
  static observedAttributes = ["name", "email", "role", "initials", "src", "suspended"];

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
      :host([suspended]) .avatar,
      :host([suspended]) .body {
        opacity: 0.55;
      }
      .avatar {
        inline-size: 40px;
        block-size: 40px;
        flex: 0 0 auto;
        border-radius: var(--npt-corner-full, 999px);
        overflow: hidden;
        display: grid;
        place-items: center;
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
        font-family: var(--npt-font-display);
        font-weight: 600;
        font-size: var(--npt-text-label, 14px);
      }
      .avatar img {
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
        font-weight: 600;
        color: var(--md-sys-color-on-surface);
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      .email {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      .meta {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        flex: 0 0 auto;
      }
      .chip {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        font-weight: 600;
        min-height: 24px;
        display: inline-flex;
        align-items: center;
        padding-inline: var(--npt-space-3, 12px);
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
      .chip.suspended {
        background: var(--md-sys-color-error-container);
        color: var(--md-sys-color-on-error-container);
      }
      .actions {
        display: inline-flex;
        gap: var(--npt-space-1, 4px);
      }
    `;
  }

  protected render(): string {
    const name = esc(this.getAttribute("name"));
    const email = esc(this.getAttribute("email"));
    const role = esc(this.getAttribute("role"));
    const initials = esc(this.getAttribute("initials"));
    const src = esc(this.getAttribute("src"));
    const suspended = this.hasAttribute("suspended");
    const avatarInner = src
      ? html`<img src="${src}" alt="${name}" />`
      : html`<span aria-hidden="true">${initials}</span>`;
    return html`<div class="row" part="row" role="listitem" aria-label="${name}${
      suspended ? " — suspended" : ""
    }">
      <span class="avatar" part="avatar" role="img" aria-label="${name}">${avatarInner}</span>
      <div class="body">
        <p class="name">${name}</p>
        ${email ? html`<p class="email">${email}</p>` : ""}
      </div>
      <div class="meta">
        ${suspended ? html`<span class="chip suspended">Suspended</span>` : ""}
        ${role ? html`<span class="chip" part="role">${role}</span>` : ""}
        <span class="actions"><slot name="actions"></slot></span>
      </div>
    </div>`;
  }
}

/**
 * <npt-permission-toggle label="Approve payments"
 *   description="Allow this role to release outgoing transfers" [checked] [disabled]>
 * </npt-permission-toggle>
 * Label + description + a switch-like toggle. Emits `change` when toggled.
 */
export class NptPermissionToggle extends NptElement {
  static observedAttributes = ["label", "description", "checked", "disabled"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  override connectedCallback(): void {
    super.connectedCallback();
    this.addEventListener("click", this.onClick);
    this.addEventListener("keydown", this.onKey);
  }

  disconnectedCallback(): void {
    this.removeEventListener("click", this.onClick);
    this.removeEventListener("keydown", this.onKey);
  }

  private toggle(): void {
    if (this.hasAttribute("disabled")) return;
    this.toggleAttribute("checked");
    this.dispatchEvent(new CustomEvent("change", { bubbles: true }));
  }

  private onClick = (): void => this.toggle();
  private onKey = (e: KeyboardEvent): void => {
    if (e.key === " " || e.key === "Enter") {
      e.preventDefault();
      this.toggle();
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
        cursor: pointer;
      }
      :host([disabled]) {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .wrap {
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        min-height: 48px;
        padding-block: var(--npt-space-2, 8px);
      }
      .body {
        flex: 1 1 auto;
        min-inline-size: 0;
      }
      .label {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
        margin: 0;
      }
      .description {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
      }
      .track {
        flex: 0 0 auto;
        inline-size: 52px;
        block-size: 32px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-surface-container-highest);
        border: 2px solid var(--md-sys-color-outline);
        position: relative;
        box-sizing: border-box;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .thumb {
        position: absolute;
        inset-block-start: 50%;
        inset-inline-start: 6px;
        inline-size: 16px;
        block-size: 16px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-outline);
        transform: translateY(-50%);
        transition: inset-inline-start var(--npt-dur-fast, 200ms) var(--npt-ease-spring, ease),
          inline-size var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([checked]) .track {
        background: var(--md-sys-color-primary);
        border-color: var(--md-sys-color-primary);
      }
      :host([checked]) .thumb {
        inset-inline-start: 26px;
        inline-size: 22px;
        block-size: 22px;
        background: var(--md-sys-color-on-primary);
      }
    `;
  }

  protected render(): string {
    const label = esc(this.getAttribute("label"));
    const description = esc(this.getAttribute("description"));
    const checked = this.hasAttribute("checked");
    return html`<div class="wrap" part="wrap">
      <div class="body">
        <p class="label">${label}</p>
        ${description ? html`<p class="description">${description}</p>` : ""}
      </div>
      <span
        class="track"
        part="track"
        role="switch"
        aria-checked="${checked}"
        aria-label="${label}"
        tabindex="0"
      ><span class="thumb" aria-hidden="true"></span></span>
    </div>`;
  }
}

/**
 * <npt-workflow-status steps="Submitted,Checked,Approved" active="1"></npt-workflow-status>
 * A compact multi-step status indicator. `active` is the zero-based index of the
 * current step; earlier steps render as complete, later steps as upcoming.
 */
export class NptWorkflowStatus extends NptElement {
  static observedAttributes = ["steps", "active"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .flow {
        display: flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        flex-wrap: wrap;
      }
      .step {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
      }
      .marker {
        inline-size: 24px;
        block-size: 24px;
        flex: 0 0 auto;
        border-radius: var(--npt-corner-full, 999px);
        display: grid;
        place-items: center;
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-caption, 12px);
        font-weight: 600;
        background: var(--md-sys-color-surface-container-highest);
        color: var(--md-sys-color-on-surface-variant);
        border: 2px solid transparent;
      }
      .name {
        color: var(--md-sys-color-on-surface-variant);
      }
      .step.done .marker {
        background: var(--md-sys-color-success);
        color: var(--md-sys-color-on-success);
      }
      .step.active .marker {
        background: var(--md-sys-color-primary);
        color: var(--md-sys-color-on-primary);
      }
      .step.active .name {
        color: var(--md-sys-color-on-surface);
        font-weight: 600;
      }
      .connector {
        flex: 0 0 auto;
        inline-size: 16px;
        block-size: 2px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-outline-variant);
      }
      .connector.filled {
        background: var(--md-sys-color-success);
      }
    `;
  }

  protected render(): string {
    const raw = this.getAttribute("steps") ?? "";
    const steps = raw
      .split(",")
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
    const active = Math.max(0, Math.min(steps.length - 1, Number(this.getAttribute("active") ?? 0)));
    const activeLabel = steps[active] ?? "";
    const body = steps
      .map((name, i) => {
        const state = i < active ? "done" : i === active ? "active" : "upcoming";
        const mark = i < active ? "✓" : String(i + 1);
        const connector =
          i < steps.length - 1
            ? html`<span class="connector ${i < active ? "filled" : ""}" aria-hidden="true"></span>`
            : "";
        return html`<span class="step ${state}">
            <span class="marker" aria-hidden="true">${mark}</span>
            <span class="name">${esc(name)}</span>
          </span>${connector}`;
      })
      .join("");
    return html`<div
      class="flow"
      part="flow"
      role="group"
      aria-label="Workflow: ${esc(activeLabel)} (step ${active + 1} of ${steps.length})"
    >${body}</div>`;
  }
}

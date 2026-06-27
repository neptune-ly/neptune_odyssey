// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — feedback & status
// <npt-skeleton>, <npt-empty-state>, <npt-alert>, <npt-status-chip>,
// <npt-toast> + <npt-toast-host>.
// Custom-property driven only; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-skeleton variant="text|circle|rect" width="200px" height="16px" [lines="3"]>
 * Shimmer placeholder. `text` repeats `lines` bars; reduced-motion → static.
 */
export class NptSkeleton extends NptElement {
  static observedAttributes = ["variant", "width", "height", "lines"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .stack {
        display: flex;
        flex-direction: column;
        gap: var(--npt-space-2, 8px);
      }
      .bone {
        background: var(--md-sys-color-surface-container-highest);
        background-image: linear-gradient(
          90deg,
          transparent 0%,
          color-mix(in oklab, var(--md-sys-color-on-surface) 8%, transparent) 50%,
          transparent 100%
        );
        background-size: 200% 100%;
        background-repeat: no-repeat;
        animation: shimmer 1.6s var(--npt-ease-standard, ease) infinite;
        border-radius: var(--npt-corner-sm, 12px);
        inline-size: 100%;
        block-size: 1em;
      }
      :host([variant="text"]) .bone {
        block-size: 0.8em;
        border-radius: var(--npt-corner-xs, 8px);
      }
      :host([variant="text"]) .bone:last-child:not(:only-child) {
        inline-size: 60%;
      }
      :host([variant="circle"]) .bone {
        border-radius: var(--npt-corner-full, 999px);
        aspect-ratio: 1;
      }
      :host([variant="rect"]) .bone {
        border-radius: var(--npt-corner-md, 16px);
      }
      @keyframes shimmer {
        0% { background-position: 200% 0; }
        100% { background-position: -200% 0; }
      }
    `;
  }

  protected render(): string {
    const variant = this.getAttribute("variant") || "rect";
    const width = esc(this.getAttribute("width"));
    const height = esc(this.getAttribute("height"));
    const lines = Math.max(1, Number(this.getAttribute("lines") ?? 1) || 1);
    const sizeStyle = `${width ? `inline-size:${width};` : ""}${height ? `block-size:${height};` : ""}`;
    const count = variant === "text" ? lines : 1;
    const bones = Array.from(
      { length: count },
      () => html`<div class="bone" part="bone" style="${sizeStyle}"></div>`,
    ).join("");
    return html`<div class="stack" part="stack" role="status" aria-busy="true" aria-live="polite" aria-label="Loading">
      ${bones}
    </div>`;
  }
}

/**
 * <npt-empty-state title="No transactions" body="…">
 *   <span slot="icon">📭</span><div slot="actions">…</div>
 * </npt-empty-state>
 * Centred placeholder for empty collections.
 */
export class NptEmptyState extends NptElement {
  static observedAttributes = ["title", "body"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .wrap {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        gap: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-8, 48px);
        padding-inline: var(--npt-space-6, 24px);
        color: var(--md-sys-color-on-surface);
      }
      .icon {
        display: grid;
        place-items: center;
        inline-size: 64px;
        block-size: 64px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-surface-container-high);
        color: var(--md-sys-color-on-surface-variant);
        font-size: var(--npt-text-headline, 28px);
      }
      .icon:empty {
        display: none;
      }
      .title {
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-title-lg, 22px);
        line-height: var(--npt-leading-title-lg, 28px);
        font-weight: var(--npt-display-weight, 700);
        margin: 0;
      }
      .body {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        line-height: var(--npt-leading-body, 20px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 0;
        max-inline-size: 40ch;
      }
      .actions {
        display: inline-flex;
        flex-wrap: wrap;
        justify-content: center;
        gap: var(--npt-space-2, 8px);
        margin-block-start: var(--npt-space-2, 8px);
      }
    `;
  }

  protected render(): string {
    const title = esc(this.getAttribute("title"));
    const body = esc(this.getAttribute("body"));
    return html`<div class="wrap" part="wrap" role="group">
      <div class="icon" part="icon"><slot name="icon"></slot></div>
      ${title ? html`<h2 class="title" part="title">${title}</h2>` : ""}
      ${body ? html`<p class="body" part="body">${body}</p>` : ""}
      <div class="actions" part="actions"><slot name="actions"></slot></div>
    </div>`;
  }
}

/**
 * <npt-alert tone="info|success|warning|error" title="Heads up" [dismissible]>
 *   …message…
 * </npt-alert>
 * Inline tonal banner; [dismissible] shows a close button that emits `dismiss`.
 */
export class NptAlert extends NptElement {
  static observedAttributes = ["tone", "title", "dismissible"];

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
    const t = e.target as HTMLElement;
    if (t.closest("[data-dismiss]")) this.dismiss();
  };

  /** Hide the alert and emit a `dismiss` event. */
  dismiss(): void {
    this.setAttribute("hidden", "");
    this.dispatchEvent(new CustomEvent("dismiss", { bubbles: true }));
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
        --_bg: var(--md-sys-color-secondary-container);
        --_fg: var(--md-sys-color-on-secondary-container);
        --_accent: var(--md-sys-color-secondary);
      }
      :host([hidden]) {
        display: none;
      }
      :host([tone="success"]) {
        --_bg: var(--md-sys-color-success-container);
        --_fg: var(--md-sys-color-on-success-container);
        --_accent: var(--md-sys-color-success);
      }
      :host([tone="warning"]) {
        --_bg: var(--md-sys-color-tertiary-container);
        --_fg: var(--md-sys-color-on-tertiary-container);
        --_accent: var(--md-sys-color-tertiary);
      }
      :host([tone="error"]) {
        --_bg: var(--md-sys-color-error-container);
        --_fg: var(--md-sys-color-on-error-container);
        --_accent: var(--md-sys-color-error);
      }
      .alert {
        display: flex;
        align-items: flex-start;
        gap: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        border-radius: var(--npt-corner-md, 16px);
        border-inline-start: 4px solid var(--_accent);
        background: var(--_bg);
        color: var(--_fg);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        line-height: var(--npt-leading-body, 20px);
        box-sizing: border-box;
      }
      .dot {
        flex: 0 0 auto;
        inline-size: 8px;
        block-size: 8px;
        margin-block-start: 6px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--_accent);
      }
      .body {
        flex: 1 1 auto;
        min-inline-size: 0;
      }
      .title {
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
        margin: 0 0 var(--npt-space-1, 4px);
      }
      .msg {
        display: block;
      }
      .close {
        flex: 0 0 auto;
        display: grid;
        place-items: center;
        inline-size: 44px;
        block-size: 44px;
        margin-block: -6px;
        margin-inline-end: calc(-1 * var(--npt-space-2, 8px));
        padding: 0;
        border: none;
        background: transparent;
        color: inherit;
        border-radius: var(--npt-corner-full, 999px);
        cursor: pointer;
        font-size: var(--npt-text-title, 18px);
        line-height: 1;
      }
      .close:hover {
        background: color-mix(in oklab, currentColor 12%, transparent);
      }
    `;
  }

  protected render(): string {
    const tone = this.getAttribute("tone") || "info";
    const title = esc(this.getAttribute("title"));
    const dismissible = this.hasAttribute("dismissible");
    const role = tone === "error" || tone === "warning" ? "alert" : "status";
    const live = tone === "error" || tone === "warning" ? "assertive" : "polite";
    return html`<div class="alert" part="alert" role="${role}" aria-live="${live}">
      <span class="dot" part="dot" aria-hidden="true"></span>
      <div class="body">
        ${title ? html`<p class="title" part="title">${title}</p>` : ""}
        <span class="msg"><slot></slot></span>
      </div>
      ${dismissible
        ? html`<button class="close" part="close" type="button" data-dismiss aria-label="Dismiss">✕</button>`
        : ""}
    </div>`;
  }
}

/**
 * <npt-status-chip status="success|pending|failed|info|neutral">Settled</npt-status-chip>
 * Status pill with a coloured dot + tonal background; label via default slot.
 */
export class NptStatusChip extends NptElement {
  static observedAttributes = ["status"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-flex;
        --_bg: var(--md-sys-color-surface-container-highest);
        --_fg: var(--md-sys-color-on-surface-variant);
        --_dot: var(--md-sys-color-on-surface-variant);
      }
      :host([status="success"]) {
        --_bg: var(--md-sys-color-success-container);
        --_fg: var(--md-sys-color-on-success-container);
        --_dot: var(--md-sys-color-success);
      }
      :host([status="pending"]) {
        --_bg: var(--md-sys-color-tertiary-container);
        --_fg: var(--md-sys-color-on-tertiary-container);
        --_dot: var(--md-sys-color-tertiary);
      }
      :host([status="failed"]) {
        --_bg: var(--md-sys-color-error-container);
        --_fg: var(--md-sys-color-on-error-container);
        --_dot: var(--md-sys-color-error);
      }
      :host([status="info"]) {
        --_bg: var(--md-sys-color-secondary-container);
        --_fg: var(--md-sys-color-on-secondary-container);
        --_dot: var(--md-sys-color-secondary);
      }
      .chip {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        min-block-size: 28px;
        padding-inline: var(--npt-space-3, 12px);
        padding-block: var(--npt-space-1, 4px);
        border-radius: var(--npt-corner-full, 999px);
        background: var(--_bg);
        color: var(--_fg);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        font-weight: 500;
        line-height: 1;
        box-sizing: border-box;
        white-space: nowrap;
      }
      .dot {
        flex: 0 0 auto;
        inline-size: 8px;
        block-size: 8px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--_dot);
      }
    `;
  }

  protected render(): string {
    const status = this.getAttribute("status") || "neutral";
    return html`<span class="chip" part="chip" role="status" aria-label="${esc(status)}">
      <span class="dot" part="dot" aria-hidden="true"></span>
      <slot></slot>
    </span>`;
  }
}

/**
 * <npt-toast [open] message="Saved" tone="info|success|warning|error" timeout="4000">
 *   <span slot="action">…</span>
 * </npt-toast>
 * Fixed bottom toast; auto-hides after `timeout` ms (0 disables). Emits `close`.
 */
export class NptToast extends NptElement {
  static observedAttributes = ["open", "message", "tone", "timeout"];

  private timer: ReturnType<typeof setTimeout> | undefined;

  attributeChangedCallback(name: string): void {
    if (this.isConnected) this.update();
    if (name === "open") {
      if (this.hasAttribute("open")) this.arm();
      else this.clearTimer();
    }
  }

  override connectedCallback(): void {
    super.connectedCallback();
    this.root.addEventListener("click", this.onClick);
    if (this.hasAttribute("open")) this.arm();
  }

  disconnectedCallback(): void {
    this.root.removeEventListener("click", this.onClick);
    this.clearTimer();
  }

  private clearTimer(): void {
    if (this.timer !== undefined) {
      clearTimeout(this.timer);
      this.timer = undefined;
    }
  }

  private arm(): void {
    this.clearTimer();
    const timeout = Number(this.getAttribute("timeout") ?? 4000);
    if (timeout > 0) this.timer = setTimeout(() => this.close(), timeout);
  }

  private onClick = (e: Event): void => {
    const t = e.target as HTMLElement;
    if (t.closest("[data-close]")) this.close();
  };

  /** Hide the toast and emit a `close` event. */
  close(): void {
    this.clearTimer();
    this.removeAttribute("open");
    this.dispatchEvent(new CustomEvent("close", { bubbles: true }));
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: none;
        --_bg: var(--md-sys-color-inverse-surface);
        --_fg: var(--md-sys-color-inverse-on-surface);
        --_accent: var(--md-sys-color-inverse-primary);
      }
      :host([open]) {
        display: block;
      }
      :host([tone="success"]) {
        --_bg: var(--md-sys-color-success-container);
        --_fg: var(--md-sys-color-on-success-container);
        --_accent: var(--md-sys-color-success);
      }
      :host([tone="warning"]) {
        --_bg: var(--md-sys-color-tertiary-container);
        --_fg: var(--md-sys-color-on-tertiary-container);
        --_accent: var(--md-sys-color-tertiary);
      }
      :host([tone="error"]) {
        --_bg: var(--md-sys-color-error-container);
        --_fg: var(--md-sys-color-on-error-container);
        --_accent: var(--md-sys-color-error);
      }
      .toast {
        position: fixed;
        inset-block-end: var(--npt-space-6, 24px);
        inset-inline: var(--npt-space-4, 16px);
        margin-inline: auto;
        inline-size: max-content;
        max-inline-size: min(560px, calc(100% - 2 * var(--npt-space-4, 16px)));
        z-index: var(--npt-z-toast, 80);
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        min-block-size: 48px;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        border-radius: var(--npt-corner-sm, 12px);
        background: var(--_bg);
        color: var(--_fg);
        box-shadow: var(--npt-elevation-3, 0 8px 20px rgba(0, 0, 0, 0.2));
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        line-height: var(--npt-leading-body, 20px);
        box-sizing: border-box;
        animation: rise var(--npt-dur-fast, 200ms) var(--npt-ease-spring, ease);
      }
      .msg {
        flex: 1 1 auto;
        min-inline-size: 0;
      }
      ::slotted(*) {
        color: var(--_accent);
      }
      .close {
        flex: 0 0 auto;
        display: grid;
        place-items: center;
        inline-size: 44px;
        block-size: 44px;
        margin-block: -8px;
        margin-inline-end: calc(-1 * var(--npt-space-2, 8px));
        padding: 0;
        border: none;
        background: transparent;
        color: inherit;
        border-radius: var(--npt-corner-full, 999px);
        cursor: pointer;
        font-size: var(--npt-text-title, 18px);
        line-height: 1;
      }
      .close:hover {
        background: color-mix(in oklab, currentColor 12%, transparent);
      }
      @keyframes rise {
        from { transform: translateY(var(--npt-space-4, 16px)); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
      }
    `;
  }

  protected render(): string {
    const message = esc(this.getAttribute("message"));
    return html`<div class="toast" part="toast" role="status" aria-live="polite">
      <span class="msg">${message}</span>
      <slot name="action"></slot>
      <button class="close" part="close" type="button" data-close aria-label="Close">✕</button>
    </div>`;
  }
}

/**
 * <npt-toast-host></npt-toast-host>
 * Stacking container for toasts; place <npt-toast> elements in the default slot
 * (or append them imperatively). Fixed to the bottom; newest sits at the end.
 */
export class NptToastHost extends NptElement {
  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        position: fixed;
        inset-block-end: var(--npt-space-6, 24px);
        inset-inline: 0;
        z-index: var(--npt-z-toast, 80);
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-4, 16px);
        pointer-events: none;
      }
      ::slotted(*) {
        pointer-events: auto;
      }
    `;
  }

  protected render(): string {
    return html`<slot></slot>`;
  }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — communication & feedback
// <npt-progress>, <npt-snackbar>, <npt-tooltip>, <npt-banner>.
// Custom-property driven only; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-progress variant="linear|circular" value="60" [indeterminate]></npt-progress>
 * Omit value (or set [indeterminate]) for the indeterminate state.
 */
export class NptProgress extends NptElement {
  static observedAttributes = ["variant", "value", "indeterminate", "label"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .track {
        block-size: 4px;
        inline-size: 100%;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-surface-container-highest);
        overflow: hidden;
      }
      .bar {
        block-size: 100%;
        background: var(--md-sys-color-primary);
        border-radius: var(--npt-corner-full, 999px);
        transition: inline-size var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([indeterminate]) .bar,
      :host(:not([value])) .bar {
        inline-size: 40%;
        animation: slide 1.4s var(--npt-ease-standard, ease) infinite;
      }
      @keyframes slide {
        0% { transform: translateX(-120%); }
        100% { transform: translateX(320%); }
      }
      .ring {
        inline-size: 48px;
        block-size: 48px;
        transform: rotate(-90deg);
      }
      .ring circle {
        fill: none;
        stroke-width: 4;
      }
      .ring .bg {
        stroke: var(--md-sys-color-surface-container-highest);
      }
      .ring .fg {
        stroke: var(--md-sys-color-primary);
        stroke-linecap: round;
        transition: stroke-dashoffset var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([indeterminate]) .ring {
        animation: spin 1.2s linear infinite;
      }
      @keyframes spin {
        to { transform: rotate(270deg); }
      }
    `;
  }

  protected render(): string {
    const variant = this.getAttribute("variant") || "linear";
    const indeterminate = this.hasAttribute("indeterminate") || !this.hasAttribute("value");
    const value = Math.max(0, Math.min(100, Number(this.getAttribute("value") ?? 0)));
    const label = esc(this.getAttribute("label")) || "progress";
    const aria = indeterminate
      ? html`role="progressbar" aria-label="${label}"`
      : html`role="progressbar" aria-label="${label}" aria-valuenow="${value}" aria-valuemin="0" aria-valuemax="100"`;
    if (variant === "circular") {
      const r = 20;
      const circ = 2 * Math.PI * r;
      const offset = indeterminate ? circ * 0.7 : circ * (1 - value / 100);
      return html`<svg class="ring" part="ring" viewBox="0 0 48 48" ${aria}>
        <circle class="bg" cx="24" cy="24" r="${r}"></circle>
        <circle class="fg" cx="24" cy="24" r="${r}"
          stroke-dasharray="${circ}" stroke-dashoffset="${offset}"></circle>
      </svg>`;
    }
    const width = indeterminate ? "40%" : `${value}%`;
    return html`<div class="track" part="track" ${aria}>
      <div class="bar" style="inline-size:${width}"></div>
    </div>`;
  }
}

/**
 * <npt-snackbar message="Saved" [open]>…optional action slot…</npt-snackbar>
 * Inverse-surface toast. Provide an action via the default slot.
 */
export class NptSnackbar extends NptElement {
  static observedAttributes = ["message", "open"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: none;
      }
      :host([open]) {
        display: block;
      }
      .bar {
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        min-height: 48px;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        border-radius: var(--npt-corner-xs, 8px);
        background: var(--md-sys-color-inverse-surface);
        color: var(--md-sys-color-inverse-on-surface);
        box-shadow: var(--npt-elevation-3, 0 8px 20px rgba(0, 0, 0, 0.2));
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
      }
      .msg {
        flex: 1 1 auto;
      }
      ::slotted(*) {
        color: var(--md-sys-color-inverse-primary);
      }
    `;
  }

  protected render(): string {
    const message = esc(this.getAttribute("message"));
    return html`<div class="bar" part="bar" role="status" aria-live="polite">
      <span class="msg">${message}</span>
      <slot></slot>
    </div>`;
  }
}

/**
 * <npt-tooltip label="Copy"><npt-icon-button>⧉</npt-icon-button></npt-tooltip>
 * Wraps a trigger; reveals the label on hover/focus.
 */
export class NptTooltip extends NptElement {
  static observedAttributes = ["label"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-flex;
        position: relative;
      }
      .tip {
        position: absolute;
        inset-block-end: calc(100% + var(--npt-space-2, 8px));
        inset-inline-start: 50%;
        transform: translateX(-50%);
        white-space: nowrap;
        padding-inline: var(--npt-space-3, 12px);
        padding-block: var(--npt-space-1, 4px);
        border-radius: var(--npt-corner-xs, 8px);
        background: var(--md-sys-color-inverse-surface);
        color: var(--md-sys-color-inverse-on-surface);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        opacity: 0;
        pointer-events: none;
        transition: opacity var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
        z-index: var(--npt-z-toast, 80);
      }
      :host(:hover) .tip,
      :host(:focus-within) .tip {
        opacity: 1;
      }
    `;
  }

  protected render(): string {
    const label = esc(this.getAttribute("label"));
    return html`<slot></slot>
      <span class="tip" part="tip" role="tooltip">${label}</span>`;
  }
}

/**
 * <npt-banner text="Update available">…actions slot…</npt-banner>
 * Surface-level inline message with an actions slot.
 */
export class NptBanner extends NptElement {
  static observedAttributes = ["text"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .banner {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: var(--npt-space-4, 16px);
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface);
        border-bottom: 1px solid var(--md-sys-color-outline-variant);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
      }
      .leading {
        display: inline-flex;
      }
      .text {
        flex: 1 1 200px;
      }
      .actions {
        display: inline-flex;
        gap: var(--npt-space-2, 8px);
        margin-inline-start: auto;
      }
    `;
  }

  protected render(): string {
    const text = esc(this.getAttribute("text"));
    return html`<div class="banner" part="banner" role="status">
      <span class="leading"><slot name="leading"></slot></span>
      <span class="text">${text}</span>
      <span class="actions"><slot></slot></span>
    </div>`;
  }
}

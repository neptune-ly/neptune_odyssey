// Neptune Odyssey — inputs · © 2026 Neptune.Fintech (neptune.ly)
// <npt-text-field>, <npt-chip>, <npt-badge>.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-text-field label="IBAN" value="" placeholder="LY.." [error="msg"]></npt-text-field>
 * Outlined M3 field. Logical padding → mirrors in RTL.
 */
export class NptTextField extends NptElement {
  static observedAttributes = ["label", "value", "placeholder", "error", "type"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  get value(): string {
    return this.root.querySelector("input")?.value ?? this.getAttribute("value") ?? "";
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      label {
        display: block;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin-block-end: var(--npt-space-2, 8px);
      }
      input {
        inline-size: 100%;
        box-sizing: border-box;
        min-height: 48px;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
        background: var(--md-sys-color-surface-container-lowest);
        border: 1px solid var(--md-sys-color-outline);
        border-radius: var(--npt-corner-sm, 12px);
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        transition: border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      input::placeholder {
        color: var(--md-sys-color-on-surface-variant);
        opacity: 0.7;
      }
      input:focus {
        outline: none;
        border-color: var(--md-sys-color-primary);
        box-shadow: 0 0 0 1px var(--md-sys-color-primary);
      }
      :host([error]) input {
        border-color: var(--md-sys-color-error);
      }
      .error {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        color: var(--md-sys-color-error);
        margin-block-start: var(--npt-space-2, 8px);
      }
    `;
  }

  protected render(): string {
    const label = esc(this.getAttribute("label"));
    const value = esc(this.getAttribute("value"));
    const placeholder = esc(this.getAttribute("placeholder"));
    const error = this.getAttribute("error");
    const type = esc(this.getAttribute("type")) || "text";
    return html`
      ${label ? html`<label>${label}</label>` : ""}
      <input
        type="${type}"
        value="${value}"
        placeholder="${placeholder}"
        aria-invalid="${error ? "true" : "false"}"
        aria-label="${label}"
      />
      ${error ? html`<p class="error" role="alert">${esc(error)}</p>` : ""}
    `;
  }
}

/**
 * <npt-chip variant="assist|filter|input|suggestion" [selected]>Label</npt-chip>
 * `filter` shows a leading ✓ when [selected]; `input` shows a removable ✕ that
 * dispatches a `remove` event. Defaults to the assist/filter treatment.
 */
export class NptChip extends NptElement {
  static observedAttributes = ["selected", "variant", "disabled"];

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
    if ((e.target as HTMLElement)?.closest(".remove")) {
      e.stopPropagation();
      this.dispatchEvent(new CustomEvent("remove", { bubbles: true }));
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-block;
      }
      .chip {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        min-height: 32px;
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        padding-inline: var(--npt-space-4, 16px);
        border-radius: var(--npt-corner-sm, 12px);
        border: 1px solid var(--md-sys-color-outline);
        background: transparent;
        color: var(--md-sys-color-on-surface-variant);
        cursor: pointer;
      }
      :host([disabled]) .chip {
        cursor: not-allowed;
        opacity: 0.38;
      }
      :host([selected]) .chip {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
        border-color: transparent;
      }
      .check {
        display: none;
        font-size: var(--npt-text-body, 14px);
      }
      :host([variant="filter"][selected]) .check {
        display: inline;
      }
      .remove {
        display: none;
        border: none;
        background: transparent;
        color: inherit;
        cursor: pointer;
        font-size: var(--npt-text-body-lg, 16px);
        line-height: 1;
        padding: 0;
        margin-inline-end: calc(-1 * var(--npt-space-1, 4px));
      }
      :host([variant="input"]) .remove {
        display: inline-flex;
      }
    `;
  }

  protected render(): string {
    const selected = this.hasAttribute("selected");
    const variant = this.getAttribute("variant") || "filter";
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    const role = variant === "filter" ? "option" : "button";
    const ariaSel = variant === "filter" ? html`aria-selected="${selected}"` : "";
    return html`<button class="chip" part="chip" role="${role}" ${ariaSel} ${disabled}>
      <span class="check" aria-hidden="true">✓</span>
      <slot></slot>
      <span class="remove" role="button" aria-label="Remove" tabindex="0">✕</span>
    </button>`;
  }
}

/** <npt-badge tone="primary|success|error|neutral">3</npt-badge> */
export class NptBadge extends NptElement {
  static observedAttributes = ["tone"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: inline-block;
      }
      .badge {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-caption, 12px);
        font-weight: 600;
        min-inline-size: 20px;
        block-size: 20px;
        padding-inline: var(--npt-space-2, 8px);
        border-radius: var(--npt-corner-full, 999px);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: var(--md-sys-color-primary);
        color: var(--md-sys-color-on-primary);
      }
      :host([tone="success"]) .badge {
        background: var(--md-sys-color-success);
        color: var(--md-sys-color-on-success);
      }
      :host([tone="error"]) .badge {
        background: var(--md-sys-color-error);
        color: var(--md-sys-color-on-error);
      }
      :host([tone="neutral"]) .badge {
        background: var(--md-sys-color-surface-container-highest);
        color: var(--md-sys-color-on-surface-variant);
      }
    `;
  }

  protected render(): string {
    return html`<span class="badge" part="badge"><slot></slot></span>`;
  }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — action components
// <npt-icon-button>, <npt-fab>, <npt-segmented-button> + <npt-segmented-option>.
// Logical layout → mirrors in RTL. Custom-property driven only.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-icon-button variant="standard|filled|tonal|outlined" [selected] [disabled]
 *   label="Favourite">★</npt-icon-button>
 * 48dp circular target. `selected` toggles the active treatment.
 */
export class NptIconButton extends NptElement {
  static observedAttributes = ["variant", "selected", "disabled", "label"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-block;
      }
      button {
        inline-size: 48px;
        block-size: 48px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: none;
        border-radius: var(--npt-corner-full, 999px);
        cursor: pointer;
        background: transparent;
        color: var(--md-sys-color-on-surface-variant);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-title, 18px);
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      button:disabled {
        cursor: not-allowed;
        opacity: 0.38;
      }
      :host([variant="filled"]) button {
        background: var(--md-sys-color-surface-container-highest);
        color: var(--md-sys-color-primary);
      }
      :host([variant="filled"][selected]) button {
        background: var(--md-sys-color-primary);
        color: var(--md-sys-color-on-primary);
      }
      :host([variant="tonal"]) button {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
      :host([variant="tonal"][selected]) button {
        background: var(--md-sys-color-secondary);
        color: var(--md-sys-color-on-secondary);
      }
      :host([variant="outlined"]) button {
        border: 1px solid var(--md-sys-color-outline);
        color: var(--md-sys-color-on-surface-variant);
      }
      :host([variant="outlined"][selected]) button {
        background: var(--md-sys-color-inverse-surface);
        color: var(--md-sys-color-inverse-on-surface);
        border-color: transparent;
      }
      :host(:not([variant])[selected]) button,
      :host([variant="standard"][selected]) button {
        color: var(--md-sys-color-primary);
      }
    `;
  }

  protected render(): string {
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    const pressed = this.hasAttribute("selected") ? "true" : "false";
    const label = esc(this.getAttribute("label"));
    return html`<button
      part="button"
      ${disabled}
      aria-pressed="${pressed}"
      aria-label="${label}"
    ><slot></slot></button>`;
  }
}

/**
 * <npt-fab size="sm|md|lg" [extended] label="Compose" [disabled]>＋</npt-fab>
 * Primary-container floating action. `extended` reveals the text label.
 */
export class NptFab extends NptElement {
  static observedAttributes = ["size", "extended", "label", "disabled"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-block;
      }
      button {
        min-inline-size: 56px;
        min-block-size: 56px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--npt-space-3, 12px);
        border: none;
        border-radius: var(--npt-corner-lg, 24px);
        cursor: pointer;
        padding-inline: var(--npt-space-4, 16px);
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
        box-shadow: var(--npt-elevation-3, 0 8px 20px rgba(0, 0, 0, 0.2));
        transition: box-shadow var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      button:disabled {
        cursor: not-allowed;
        opacity: 0.38;
      }
      :host([size="sm"]) button {
        min-inline-size: 40px;
        min-block-size: 40px;
        border-radius: var(--npt-corner-md, 16px);
      }
      :host([size="lg"]) button {
        min-inline-size: 96px;
        min-block-size: 96px;
        border-radius: var(--npt-corner-xl, 32px);
        font-size: var(--npt-text-title, 18px);
      }
      .icon {
        display: inline-flex;
        font-size: var(--npt-text-title, 18px);
      }
      .label {
        display: none;
      }
      :host([extended]) .label {
        display: inline;
      }
      :host([extended]) button {
        padding-inline: var(--npt-space-5, 20px);
      }
    `;
  }

  protected render(): string {
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    const label = esc(this.getAttribute("label"));
    return html`<button part="button" ${disabled} aria-label="${label}">
      <span class="icon"><slot></slot></span>
      ${label ? html`<span class="label">${label}</span>` : ""}
    </button>`;
  }
}

/**
 * <npt-segmented-button [multi]> with <npt-segmented-option> children.
 * Connected single- or multi-select group. Single-select is the default.
 */
export class NptSegmentedButton extends NptElement {
  static observedAttributes = ["multi"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  override connectedCallback(): void {
    super.connectedCallback();
    this.addEventListener("click", this.onClick);
  }

  disconnectedCallback(): void {
    this.removeEventListener("click", this.onClick);
  }

  private onClick = (e: Event): void => {
    const target = (e.target as HTMLElement)?.closest("npt-segmented-option");
    if (!target || target.hasAttribute("disabled")) return;
    if (this.hasAttribute("multi")) {
      target.toggleAttribute("selected");
    } else {
      for (const opt of this.querySelectorAll("npt-segmented-option")) {
        opt.toggleAttribute("selected", opt === target);
      }
    }
    this.dispatchEvent(new CustomEvent("change", { bubbles: true }));
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-flex;
      }
      .group {
        display: inline-flex;
        border: 1px solid var(--md-sys-color-outline);
        border-radius: var(--npt-corner-full, 999px);
        overflow: hidden;
      }
    `;
  }

  protected render(): string {
    const multi = this.hasAttribute("multi");
    return html`<div class="group" part="group" role="group" aria-multiselectable="${multi}">
      <slot></slot>
    </div>`;
  }
}

/** <npt-segmented-option value="day" [selected] [disabled]>Day</npt-segmented-option> */
export class NptSegmentedOption extends NptElement {
  static observedAttributes = ["selected", "disabled", "value"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-flex;
      }
      .opt {
        min-height: 48px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--npt-space-2, 8px);
        padding-inline: var(--npt-space-4, 16px);
        border: none;
        border-inline-start: 1px solid var(--md-sys-color-outline);
        background: transparent;
        color: var(--md-sys-color-on-surface);
        cursor: pointer;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host(:first-of-type) .opt {
        border-inline-start: none;
      }
      :host([selected]) .opt {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
      .opt:disabled {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .check {
        display: none;
      }
      :host([selected]) .check {
        display: inline;
      }
    `;
  }

  protected render(): string {
    const selected = this.hasAttribute("selected");
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    return html`<button
      class="opt"
      part="option"
      role="button"
      aria-pressed="${selected}"
      ${disabled}
    >
      <span class="check" aria-hidden="true">✓</span>
      <slot></slot>
    </button>`;
  }
}

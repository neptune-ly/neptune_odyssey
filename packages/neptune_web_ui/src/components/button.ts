// Neptune Odyssey — <npt-button> · © 2026 Neptune.Fintech (neptune.ly)
import { NptElement, css, html, A11Y } from "./base.js";

/**
 * <npt-button variant="filled|elevated|tonal|outlined|text" [disabled]>Label</npt-button>
 * M3 Expressive button. Pill shape, brand-tinted, 48dp min target.
 */
export class NptButton extends NptElement {
  static observedAttributes = ["variant", "disabled"];

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
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
        letter-spacing: 0.01em;
        min-height: 48px;
        padding-inline: var(--npt-space-6, 24px);
        border: none;
        border-radius: var(--npt-corner-full, 999px);
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--npt-space-2, 8px);
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          box-shadow var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      button:disabled {
        cursor: not-allowed;
        opacity: 0.38;
      }
      :host([variant="filled"]) button,
      :host(:not([variant])) button {
        background: var(--md-sys-color-primary);
        color: var(--md-sys-color-on-primary);
      }
      :host([variant="filled"]) button:hover:not(:disabled),
      :host(:not([variant])) button:hover:not(:disabled) {
        box-shadow: var(--npt-elevation-1, 0 1px 3px rgba(0, 0, 0, 0.2));
      }
      :host([variant="elevated"]) button {
        background: var(--md-sys-color-surface-container-low);
        color: var(--md-sys-color-primary);
        box-shadow: var(--npt-elevation-1, 0 1px 3px rgba(0, 0, 0, 0.2));
      }
      :host([variant="elevated"]) button:hover:not(:disabled) {
        box-shadow: var(--npt-elevation-2, 0 2px 6px rgba(0, 0, 0, 0.18));
      }
      :host([variant="tonal"]) button {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
      :host([variant="outlined"]) button {
        background: transparent;
        color: var(--md-sys-color-primary);
        border: 1px solid var(--md-sys-color-outline);
      }
      :host([variant="text"]) button {
        background: transparent;
        color: var(--md-sys-color-primary);
        padding-inline: var(--npt-space-3, 12px);
      }
    `;
  }

  protected render(): string {
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    return html`<button part="button" ${disabled}><slot></slot></button>`;
  }
}

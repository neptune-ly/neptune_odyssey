// Neptune Odyssey — <npt-card> · © 2026 Neptune.Fintech (neptune.ly)
import { NptElement, css, html } from "./base.js";

/**
 * <npt-card variant="standard|elevated|tonal|glass"> … </npt-card>
 * Brand-shaped surface. `glass` is the optional translucent material — use only
 * on approved surfaces (nav, hero, auth, modals), never on tables/forms (docs/06 §3).
 */
export class NptCard extends NptElement {
  static observedAttributes = ["variant"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .card {
        border-radius: var(--npt-corner-lg, 24px);
        padding: var(--npt-space-6, 24px);
        background: var(--md-sys-color-surface-container-low);
        color: var(--md-sys-color-on-surface);
        box-sizing: border-box;
      }
      :host([variant="elevated"]) .card {
        background: var(--md-sys-color-surface-container);
        box-shadow: var(--npt-elevation-2, 0 2px 6px rgba(0, 0, 0, 0.18));
      }
      :host([variant="tonal"]) .card {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
      :host([variant="glass"]) .card {
        background: var(--npt-glass-tint, color-mix(in oklab, var(--md-sys-color-surface) 70%, transparent));
        backdrop-filter: blur(var(--npt-glass-blur, 18px));
        -webkit-backdrop-filter: blur(var(--npt-glass-blur, 18px));
        border: 1px solid var(--md-sys-color-outline-variant);
      }
    `;
  }

  protected render(): string {
    return html`<div class="card" part="card"><slot></slot></div>`;
  }
}

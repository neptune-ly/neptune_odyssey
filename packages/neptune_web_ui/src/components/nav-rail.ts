// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — navigation rail & top app bar
// <npt-nav-rail> (reuses <npt-nav-item>), <npt-top-app-bar>.
// Custom-property driven only; logical layout → mirrors in RTL.
import { NptElement, css, html } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-nav-rail> with <npt-nav-item> children — the desktop/tablet side rail.
 * Vertical sibling of <npt-nav-bar>; reuses the same items.
 */
export class NptNavRail extends NptElement {
  protected styles(): string {
    return css`
      :host {
        display: block;
        block-size: 100%;
      }
      .rail {
        display: flex;
        flex-direction: column;
        align-items: stretch;
        gap: var(--npt-space-3, 12px);
        min-inline-size: 80px;
        block-size: 100%;
        padding-block: var(--npt-space-4, 16px);
        background: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface-variant);
      }
      .header {
        display: flex;
        justify-content: center;
        margin-block-end: var(--npt-space-2, 8px);
      }
    `;
  }

  protected render(): string {
    return html`<nav class="rail" part="rail" role="navigation">
      <div class="header"><slot name="leading"></slot></div>
      <slot></slot>
    </nav>`;
  }
}

/**
 * <npt-top-app-bar title="Accounts" variant="small|center|medium|large">
 *   …leading/trailing slots…
 * </npt-top-app-bar>
 * M3 top app bar. `medium`/`large` stack a larger headline below the action row.
 */
export class NptTopAppBar extends NptElement {
  static observedAttributes = ["title", "variant"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .bar {
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        min-height: 56px;
        padding-inline: var(--npt-space-4, 16px);
        background: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface);
      }
      .title {
        flex: 1 1 auto;
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-title-lg, 22px);
        font-weight: var(--npt-display-weight, 700);
        letter-spacing: var(--npt-display-tracking, -0.02em);
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      :host([variant="center"]) .title {
        text-align: center;
      }
      .large-title {
        display: none;
        font-family: var(--npt-font-display);
        font-weight: var(--npt-display-weight, 700);
        letter-spacing: var(--npt-display-tracking, -0.02em);
        color: var(--md-sys-color-on-surface);
        padding-inline: var(--npt-space-4, 16px);
        padding-block-end: var(--npt-space-6, 24px);
        margin: 0;
      }
      :host([variant="medium"]) .row-title,
      :host([variant="large"]) .row-title {
        visibility: hidden;
      }
      :host([variant="medium"]) .large-title {
        display: block;
        font-size: var(--npt-text-headline, 28px);
      }
      :host([variant="large"]) .large-title {
        display: block;
        font-size: var(--npt-text-display-md, 45px);
        line-height: var(--npt-leading-display-md, 52px);
      }
    `;
  }

  protected render(): string {
    const title = esc(this.getAttribute("title"));
    return html`<header part="bar">
      <div class="bar">
        <slot name="leading"></slot>
        <h1 class="title row-title">${title}</h1>
        <slot name="trailing"></slot>
      </div>
      <h2 class="large-title" aria-hidden="true">${title}</h2>
    </header>`;
  }
}

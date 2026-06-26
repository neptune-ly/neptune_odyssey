// Neptune Odyssey — navigation · © 2026 Neptune.Fintech (neptune.ly)
// <npt-app-bar>, <npt-nav-bar>. Logical layout → mirrors in RTL.
import { NptElement, css, html } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/** <npt-app-bar title="Accounts"> …trailing slot… </npt-app-bar> */
export class NptAppBar extends NptElement {
  static observedAttributes = ["title"];

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
    `;
  }

  protected render(): string {
    const title = esc(this.getAttribute("title"));
    return html`
      <header class="bar" part="bar">
        <slot name="leading"></slot>
        <h1 class="title">${title}</h1>
        <slot name="trailing"></slot>
      </header>
    `;
  }
}

/**
 * <npt-nav-bar> with <npt-nav-item> children (icon + label slots).
 * The mobile bottom navigation. Indicator uses secondary-container.
 */
export class NptNavBar extends NptElement {
  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .nav {
        display: flex;
        justify-content: space-around;
        align-items: center;
        min-height: 64px;
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface-variant);
        padding-inline: var(--npt-space-2, 8px);
      }
    `;
  }

  protected render(): string {
    return html`<nav class="nav" part="nav" role="navigation"><slot></slot></nav>`;
  }
}

/** <npt-nav-item label="Home" [active]>icon-glyph</npt-nav-item> */
export class NptNavItem extends NptElement {
  static observedAttributes = ["label", "active"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: inline-flex;
        flex: 1 1 0;
      }
      .item {
        flex: 1 1 0;
        min-height: 48px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 2px;
        border: none;
        background: transparent;
        color: inherit;
        cursor: pointer;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
      }
      .pill {
        min-inline-size: 56px;
        block-size: 28px;
        border-radius: var(--npt-corner-full, 999px);
        display: grid;
        place-items: center;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([active]) {
        color: var(--md-sys-color-on-surface);
      }
      :host([active]) .pill {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
    `;
  }

  protected render(): string {
    const label = esc(this.getAttribute("label"));
    const active = this.hasAttribute("active");
    return html`
      <button class="item" part="item" aria-current="${active ? "page" : "false"}" aria-label="${label}">
        <span class="pill"><slot></slot></span>
        <span>${label}</span>
      </button>
    `;
  }
}

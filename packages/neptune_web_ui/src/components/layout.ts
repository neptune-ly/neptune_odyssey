// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — containers & layout
// <npt-list>, <npt-list-item>, <npt-divider>, <npt-tabs>, <npt-tab>,
// <npt-accordion>, <npt-accordion-item>, <npt-avatar>.
// Custom-property driven only; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/** <npt-list> with <npt-list-item> children. */
export class NptList extends NptElement {
  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .list {
        display: block;
        background: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface);
      }
    `;
  }

  protected render(): string {
    return html`<div class="list" part="list" role="list"><slot></slot></div>`;
  }
}

/**
 * <npt-list-item [interactive] headline="Title" supporting="Sub">
 *   <span slot="leading">●</span><span slot="trailing">→</span>
 * </npt-list-item>
 */
export class NptListItem extends NptElement {
  static observedAttributes = ["interactive", "headline", "supporting"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .item {
        inline-size: 100%;
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        min-height: 56px;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-2, 8px);
        border: none;
        background: transparent;
        color: inherit;
        text-align: start;
        font-family: var(--npt-font-text);
        box-sizing: border-box;
      }
      :host([interactive]) .item {
        cursor: pointer;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([interactive]) .item:hover {
        background: var(--md-sys-color-surface-container-high);
      }
      .body {
        flex: 1 1 auto;
        min-inline-size: 0;
      }
      .headline {
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
        margin: 0;
      }
      .supporting {
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
      }
    `;
  }

  protected render(): string {
    const headline = esc(this.getAttribute("headline"));
    const supporting = esc(this.getAttribute("supporting"));
    const interactive = this.hasAttribute("interactive");
    const tag = interactive ? "button" : "div";
    const attrs = interactive ? html`role="listitem" type="button"` : html`role="listitem"`;
    return html`<${tag} class="item" part="item" ${attrs}>
      <slot name="leading"></slot>
      <div class="body">
        ${headline ? html`<p class="headline">${headline}</p>` : ""}
        ${supporting ? html`<p class="supporting">${supporting}</p>` : ""}
        <slot></slot>
      </div>
      <slot name="trailing"></slot>
    </${tag}>`;
  }
}

/** <npt-divider [inset]></npt-divider> */
export class NptDivider extends NptElement {
  static observedAttributes = ["inset"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .rule {
        border: none;
        block-size: 1px;
        background: var(--md-sys-color-outline-variant);
        margin-block: 0;
      }
      :host([inset]) .rule {
        margin-inline-start: var(--npt-space-4, 16px);
        margin-inline-end: var(--npt-space-4, 16px);
      }
    `;
  }

  protected render(): string {
    return html`<hr class="rule" part="divider" role="separator" />`;
  }
}

/**
 * <npt-tabs> with <npt-tab> children.
 * Click selects a tab (sets [active]); a sliding indicator follows.
 */
export class NptTabs extends NptElement {
  override connectedCallback(): void {
    super.connectedCallback();
    this.addEventListener("click", this.onClick);
  }

  disconnectedCallback(): void {
    this.removeEventListener("click", this.onClick);
  }

  private onClick = (e: Event): void => {
    const tab = (e.target as HTMLElement)?.closest("npt-tab");
    if (!tab) return;
    for (const t of this.querySelectorAll("npt-tab")) t.toggleAttribute("active", t === tab);
    this.dispatchEvent(new CustomEvent("change", { bubbles: true }));
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .row {
        display: flex;
        gap: var(--npt-space-2, 8px);
        border-bottom: 1px solid var(--md-sys-color-outline-variant);
      }
    `;
  }

  protected render(): string {
    return html`<div class="row" part="tabs" role="tablist"><slot></slot></div>`;
  }
}

/** <npt-tab [active]>Overview</npt-tab> */
export class NptTab extends NptElement {
  static observedAttributes = ["active"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-flex;
      }
      .tab {
        position: relative;
        min-height: 48px;
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        padding-inline: var(--npt-space-4, 16px);
        border: none;
        background: transparent;
        color: var(--md-sys-color-on-surface-variant);
        cursor: pointer;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
      }
      .tab::after {
        content: "";
        position: absolute;
        inset-block-end: 0;
        inset-inline: var(--npt-space-2, 8px);
        block-size: 3px;
        border-start-start-radius: var(--npt-corner-full, 999px);
        border-start-end-radius: var(--npt-corner-full, 999px);
        background: transparent;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([active]) .tab {
        color: var(--md-sys-color-primary);
      }
      :host([active]) .tab::after {
        background: var(--md-sys-color-primary);
      }
    `;
  }

  protected render(): string {
    const active = this.hasAttribute("active");
    return html`<button class="tab" part="tab" role="tab" aria-selected="${active}">
      <slot></slot>
    </button>`;
  }
}

/** <npt-accordion> with <npt-accordion-item> children. */
export class NptAccordion extends NptElement {
  protected styles(): string {
    return css`
      :host {
        display: block;
      }
    `;
  }

  protected render(): string {
    return html`<div part="accordion"><slot></slot></div>`;
  }
}

/**
 * <npt-accordion-item [open] summary="Section">…detail…</npt-accordion-item>
 * Native <details>/<summary> semantics under the hood.
 */
export class NptAccordionItem extends NptElement {
  static observedAttributes = ["open", "summary"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  override connectedCallback(): void {
    super.connectedCallback();
    this.root.addEventListener("toggle", this.onToggle, true);
  }

  disconnectedCallback(): void {
    this.root.removeEventListener("toggle", this.onToggle, true);
  }

  private onToggle = (e: Event): void => {
    const open = (e.target as HTMLDetailsElement).open;
    this.toggleAttribute("open", open);
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
        border-bottom: 1px solid var(--md-sys-color-outline-variant);
      }
      details {
        color: var(--md-sys-color-on-surface);
      }
      summary {
        list-style: none;
        min-height: 56px;
        display: flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-4, 16px);
        cursor: pointer;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        font-weight: 600;
      }
      summary::-webkit-details-marker {
        display: none;
      }
      .chevron {
        margin-inline-start: auto;
        transition: transform var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      details[open] .chevron {
        transform: rotate(180deg);
      }
      .detail {
        padding-inline: var(--npt-space-4, 16px);
        padding-block-end: var(--npt-space-4, 16px);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
      }
    `;
  }

  protected render(): string {
    const summary = esc(this.getAttribute("summary"));
    const open = this.hasAttribute("open") ? "open" : "";
    return html`<details part="item" ${open}>
      <summary part="summary">${summary}<span class="chevron" aria-hidden="true">⌄</span></summary>
      <div class="detail" part="detail"><slot></slot></div>
    </details>`;
  }
}

/** <npt-avatar src="" initials="MK" size="sm|md|lg" label="Mona"></npt-avatar> */
export class NptAvatar extends NptElement {
  static observedAttributes = ["src", "initials", "size", "label"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: inline-block;
      }
      .avatar {
        inline-size: 40px;
        block-size: 40px;
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
      :host([size="sm"]) .avatar {
        inline-size: 28px;
        block-size: 28px;
        font-size: var(--npt-text-caption, 12px);
      }
      :host([size="lg"]) .avatar {
        inline-size: 64px;
        block-size: 64px;
        font-size: var(--npt-text-title, 18px);
      }
      img {
        inline-size: 100%;
        block-size: 100%;
        object-fit: cover;
      }
    `;
  }

  protected render(): string {
    const src = esc(this.getAttribute("src"));
    const initials = esc(this.getAttribute("initials"));
    const label = esc(this.getAttribute("label")) || initials;
    const inner = src
      ? html`<img src="${src}" alt="${label}" />`
      : html`<span aria-hidden="true">${initials}</span>`;
    return html`<span class="avatar" part="avatar" role="img" aria-label="${label}">${inner}</span>`;
  }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — application shell & layout
// <npt-app-shell>, <npt-page-header>, <npt-section>, <npt-side-nav>,
// <npt-side-nav-item>, <npt-search-field>, <npt-toolbar>.
// Custom-property driven only; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-app-shell [rail]>
 *   <header slot="header">…</header>
 *   <npt-side-nav slot="nav">…</npt-side-nav>
 *   …content…
 * </npt-app-shell>
 * The application frame: a sticky `header` row, an inline-start `nav` sidebar
 * (collapses to a narrow rail via [rail]), and the default content region. The
 * nav hides under a compact breakpoint so the content takes the full width.
 */
export class NptAppShell extends NptElement {
  static observedAttributes = ["rail"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
        block-size: 100%;
        background: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface);
      }
      .shell {
        display: grid;
        grid-template-columns: auto 1fr;
        grid-template-rows: auto 1fr;
        grid-template-areas:
          "header header"
          "nav main";
        min-block-size: 100%;
        box-sizing: border-box;
      }
      .header {
        grid-area: header;
        position: sticky;
        inset-block-start: 0;
        z-index: 2;
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface);
      }
      .nav {
        grid-area: nav;
        inline-size: 280px;
        min-inline-size: 0;
        background: var(--md-sys-color-surface-container-low);
        border-inline-end: 1px solid var(--md-sys-color-outline-variant);
        overflow: auto;
        transition: inline-size var(--npt-dur-standard, 250ms) var(--npt-ease-emphasized, ease);
      }
      :host([rail]) .nav {
        inline-size: 88px;
      }
      .main {
        grid-area: main;
        min-inline-size: 0;
        padding: var(--npt-space-6, 24px);
        background: var(--md-sys-color-surface);
        box-sizing: border-box;
      }
      @media (max-width: 768px) {
        .shell {
          grid-template-columns: 1fr;
          grid-template-areas:
            "header"
            "main";
        }
        .nav {
          display: none;
        }
      }
    `;
  }

  protected render(): string {
    return html`<div class="shell" part="shell">
      <div class="header" part="header"><slot name="header"></slot></div>
      <aside class="nav" part="nav"><slot name="nav"></slot></aside>
      <main class="main" part="main"><slot></slot></main>
    </div>`;
  }
}

/**
 * <npt-page-header title="Accounts" subtitle="All your balances">
 *   <npt-breadcrumbs slot="breadcrumb">…</npt-breadcrumbs>
 *   <npt-button slot="actions">New</npt-button>
 * </npt-page-header>
 * The page-level masthead. Display font; optional breadcrumb above, actions
 * inline-end of the title row, optional supporting subtitle below.
 */
export class NptPageHeader extends NptElement {
  static observedAttributes = ["title", "subtitle"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .header {
        display: flex;
        flex-direction: column;
        gap: var(--npt-space-2, 8px);
        padding-block-end: var(--npt-space-5, 20px);
      }
      .crumbs {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        color: var(--md-sys-color-on-surface-variant);
      }
      .row {
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        flex-wrap: wrap;
      }
      .title {
        flex: 1 1 auto;
        min-inline-size: 0;
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-display-md, 45px);
        line-height: var(--npt-leading-display-md, 52px);
        font-weight: var(--npt-display-weight, 700);
        letter-spacing: var(--npt-display-tracking, -0.02em);
        color: var(--md-sys-color-on-surface);
        margin: 0;
      }
      .actions {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        flex: 0 0 auto;
      }
      .subtitle {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-title, 18px);
        line-height: var(--npt-leading-title, 24px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 0;
      }
    `;
  }

  protected render(): string {
    const title = esc(this.getAttribute("title"));
    const subtitle = esc(this.getAttribute("subtitle"));
    return html`<header class="header" part="header">
      <div class="crumbs" part="breadcrumb"><slot name="breadcrumb"></slot></div>
      <div class="row">
        <h1 class="title" part="title">${title}</h1>
        <div class="actions" part="actions"><slot name="actions"></slot></div>
      </div>
      ${subtitle ? html`<p class="subtitle" part="subtitle">${subtitle}</p>` : ""}
    </header>`;
  }
}

/**
 * <npt-section title="Recent activity" description="Last 30 days">…</npt-section>
 * A titled content section with an optional supporting description and a default
 * slot for the section body.
 */
export class NptSection extends NptElement {
  static observedAttributes = ["title", "description"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .section {
        display: block;
        margin-block-end: var(--npt-space-8, 40px);
      }
      .head {
        margin-block-end: var(--npt-space-4, 16px);
      }
      .title {
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-headline, 28px);
        line-height: var(--npt-leading-headline, 36px);
        font-weight: var(--npt-display-weight, 700);
        letter-spacing: var(--npt-display-tracking, -0.02em);
        color: var(--md-sys-color-on-surface);
        margin: 0;
      }
      .description {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        line-height: var(--npt-leading-body, 20px);
        color: var(--md-sys-color-on-surface-variant);
        margin: var(--npt-space-1, 4px) 0 0;
      }
      .body {
        display: block;
      }
    `;
  }

  protected render(): string {
    const title = esc(this.getAttribute("title"));
    const description = esc(this.getAttribute("description"));
    return html`<section class="section" part="section">
      ${title || description
        ? html`<div class="head" part="head">
            ${title ? html`<h2 class="title" part="title">${title}</h2>` : ""}
            ${description ? html`<p class="description" part="description">${description}</p>` : ""}
          </div>`
        : ""}
      <div class="body" part="body"><slot></slot></div>
    </section>`;
  }
}

/**
 * <npt-side-nav> with <npt-side-nav-item> children — the vertical sidebar nav.
 * Clicking an item activates it (sets [active] exclusively) and re-emits the
 * item's `select` event from the container.
 */
export class NptSideNav extends NptElement {
  override connectedCallback(): void {
    super.connectedCallback();
    this.addEventListener("select", this.onSelect);
  }

  disconnectedCallback(): void {
    this.removeEventListener("select", this.onSelect);
  }

  private onSelect = (e: Event): void => {
    const item = (e.target as HTMLElement)?.closest("npt-side-nav-item");
    if (!item || item === this) return;
    for (const i of this.querySelectorAll("npt-side-nav-item")) {
      i.toggleAttribute("active", i === item);
    }
  };

  protected styles(): string {
    return css`
      :host {
        display: block;
        block-size: 100%;
      }
      .nav {
        display: flex;
        flex-direction: column;
        gap: var(--npt-space-1, 4px);
        padding-block: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-3, 12px);
        block-size: 100%;
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface-variant);
        box-sizing: border-box;
      }
    `;
  }

  protected render(): string {
    return html`<nav class="nav" part="nav" role="navigation"><slot></slot></nav>`;
  }
}

/**
 * <npt-side-nav-item label="Dashboard" [active]>
 *   <span slot="icon">▦</span><npt-badge slot="leading">3</npt-badge>
 * </npt-side-nav-item>
 * One row of <npt-side-nav>. Emits `select` on activation. `icon` slots before
 * the label; `leading` slots inline-end (counts/badges).
 */
export class NptSideNavItem extends NptElement {
  static observedAttributes = ["label", "active", "disabled"];

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

  private activate(): void {
    if (this.hasAttribute("disabled")) return;
    this.dispatchEvent(new CustomEvent("select", { bubbles: true }));
  }

  private onClick = (): void => this.activate();
  private onKey = (e: KeyboardEvent): void => {
    if (e.key === " " || e.key === "Enter") {
      e.preventDefault();
      this.activate();
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      :host([disabled]) {
        pointer-events: none;
      }
      .item {
        inline-size: 100%;
        display: flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        min-height: 48px;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-2, 8px);
        border: none;
        border-radius: var(--npt-corner-full, 999px);
        background: transparent;
        color: inherit;
        text-align: start;
        cursor: pointer;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
        box-sizing: border-box;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .item:hover {
        background: var(--md-sys-color-surface-container-high);
        color: var(--md-sys-color-on-surface);
      }
      :host([active]) .item {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
      :host([disabled]) .item {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .icon {
        display: inline-flex;
        flex: 0 0 auto;
      }
      .label {
        flex: 1 1 auto;
        min-inline-size: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      ::slotted([slot="leading"]) {
        margin-inline-start: auto;
        flex: 0 0 auto;
      }
    `;
  }

  protected render(): string {
    const label = esc(this.getAttribute("label"));
    const active = this.hasAttribute("active");
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    return html`<button
      class="item"
      part="item"
      type="button"
      aria-current="${active ? "page" : "false"}"
      ${disabled}
    >
      <span class="icon" aria-hidden="true"><slot name="icon"></slot></span>
      <span class="label">${label}</span>
      <slot name="leading"></slot>
    </button>`;
  }
}

/**
 * <npt-search-field placeholder="Search accounts" value=""></npt-search-field>
 * A search input with a leading magnifier and a clear control. Emits a `search`
 * event (detail.value) on input, lightly debounced, and on clear.
 */
export class NptSearchField extends NptElement {
  static observedAttributes = ["placeholder", "value", "disabled"];
  private timer = 0;

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  get value(): string {
    return this.root.querySelector("input")?.value ?? this.getAttribute("value") ?? "";
  }

  override connectedCallback(): void {
    super.connectedCallback();
    this.root.addEventListener("input", this.onInput);
    this.root.addEventListener("click", this.onClick);
  }

  disconnectedCallback(): void {
    this.root.removeEventListener("input", this.onInput);
    this.root.removeEventListener("click", this.onClick);
    if (this.timer) clearTimeout(this.timer);
  }

  private emit(value: string): void {
    this.dispatchEvent(new CustomEvent("search", { detail: { value }, bubbles: true }));
  }

  private syncClear(value: string): void {
    const clear = this.root.querySelector(".clear") as HTMLElement | null;
    if (clear) clear.hidden = value.length === 0;
  }

  private onInput = (e: Event): void => {
    const input = e.target as HTMLInputElement;
    this.setAttribute("value", input.value);
    this.syncClear(input.value);
    if (this.timer) clearTimeout(this.timer);
    this.timer = setTimeout(() => this.emit(input.value), 180) as unknown as number;
  };

  private onClick = (e: Event): void => {
    if (!(e.target as HTMLElement)?.closest(".clear")) return;
    const input = this.root.querySelector("input");
    if (input) {
      input.value = "";
      input.focus();
    }
    this.setAttribute("value", "");
    this.syncClear("");
    if (this.timer) clearTimeout(this.timer);
    this.emit("");
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .field {
        display: flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        min-height: 48px;
        padding-inline: var(--npt-space-4, 16px);
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-surface-container-high);
        color: var(--md-sys-color-on-surface);
        border: 1px solid transparent;
        box-sizing: border-box;
        transition: border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .field:focus-within {
        border-color: var(--md-sys-color-primary);
      }
      :host([disabled]) .field {
        opacity: 0.38;
        pointer-events: none;
      }
      .glyph {
        flex: 0 0 auto;
        display: inline-flex;
        color: var(--md-sys-color-on-surface-variant);
        font-size: var(--npt-text-body-lg, 16px);
        line-height: 1;
      }
      input {
        flex: 1 1 auto;
        min-inline-size: 0;
        border: none;
        background: transparent;
        outline: none;
        color: inherit;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
      }
      input::placeholder {
        color: var(--md-sys-color-on-surface-variant);
        opacity: 0.7;
      }
      input::-webkit-search-cancel-button {
        display: none;
      }
      .clear {
        flex: 0 0 auto;
        inline-size: 28px;
        block-size: 28px;
        display: inline-grid;
        place-items: center;
        border: none;
        border-radius: var(--npt-corner-full, 999px);
        background: transparent;
        color: var(--md-sys-color-on-surface-variant);
        cursor: pointer;
        font-size: var(--npt-text-body, 14px);
        line-height: 1;
      }
      .clear:hover {
        background: var(--md-sys-color-surface-container-highest);
        color: var(--md-sys-color-on-surface);
      }
    `;
  }

  protected render(): string {
    const placeholder = esc(this.getAttribute("placeholder")) || "Search";
    const value = esc(this.getAttribute("value"));
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    const hideClear = value.length === 0 ? "hidden" : "";
    return html`<div class="field" part="field" role="search">
      <span class="glyph" aria-hidden="true">⌕</span>
      <input
        type="search"
        value="${value}"
        placeholder="${placeholder}"
        aria-label="${placeholder}"
        ${disabled}
      />
      <button class="clear" part="clear" type="button" aria-label="Clear search" ${hideClear}>✕</button>
    </div>`;
  }
}

/**
 * <npt-toolbar>
 *   <…slot="start"></…><…slot="center"></…><…slot="end"></…>
 * </npt-toolbar>
 * A horizontal toolbar surface with start / center / end regions. `start` and
 * `end` mirror in RTL via logical layout; `center` stays centred.
 */
export class NptToolbar extends NptElement {
  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .bar {
        display: flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        min-height: 56px;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-2, 8px);
        border-radius: var(--npt-corner-lg, 24px);
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface);
        box-sizing: border-box;
      }
      .start,
      .end {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
        flex: 0 0 auto;
      }
      .center {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--npt-space-2, 8px);
        flex: 1 1 auto;
        min-inline-size: 0;
      }
    `;
  }

  protected render(): string {
    return html`<div class="bar" part="bar" role="toolbar">
      <div class="start" part="start"><slot name="start"></slot></div>
      <div class="center" part="center"><slot name="center"></slot></div>
      <div class="end" part="end"><slot name="end"></slot></div>
    </div>`;
  }
}

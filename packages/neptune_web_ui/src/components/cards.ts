// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — payment-card components
// <npt-card-art>, <npt-card-row>, <npt-add-card>, <npt-card-controls>.
// Custom-property driven only; logical layout → mirrors in RTL. Money tabular.
import { NptElement, css, html, A11Y, define } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-card-art holder="A. KELLER" last4="4821" expiry="08/29" scheme="VISA"
 *   variant="virtual|physical|frozen"><span slot="brand">◈</span></npt-card-art>
 * Payment-card visual on the brand gradient. `scheme` is a plain label; provide a
 * brand mark via the `brand` slot (top-trailing). [frozen] dims and shows a frozen
 * affordance. Card number digits use tabular figures.
 */
export class NptCardArt extends NptElement {
  static observedAttributes = ["holder", "last4", "expiry", "scheme", "variant", "selected"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .card {
        position: relative;
        box-sizing: border-box;
        aspect-ratio: 1.586;
        inline-size: 100%;
        padding: var(--npt-space-6, 24px);
        border-radius: var(--npt-corner-lg, 24px);
        background: linear-gradient(135deg, var(--md-sys-color-primary), var(--md-sys-color-tertiary));
        color: var(--md-sys-color-on-primary);
        box-shadow: var(--npt-elevation-2, 0 2px 6px rgba(0, 0, 0, 0.18));
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        overflow: hidden;
        outline: 0 solid transparent;
        outline-offset: 3px;
        transition:
          filter var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          outline-color var(--npt-dur-2, 220ms) var(--npt-ease-emphasized, ease),
          outline-width var(--npt-dur-2, 220ms) var(--npt-ease-emphasized, ease);
      }
      /* Selected state — an accent ring lifts the chosen card out of a stack. */
      :host([selected]) .card {
        outline: 3px solid var(--md-sys-color-primary);
        box-shadow: var(--npt-glow-primary, 0 8px 22px rgba(0, 0, 0, 0.28));
      }
      :host([variant="virtual"]) .card {
        background: linear-gradient(
          135deg,
          var(--md-sys-color-tertiary),
          var(--md-sys-color-primary)
        );
      }
      .top {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: var(--npt-space-4, 16px);
      }
      .scheme {
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-label, 14px);
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        opacity: 0.92;
      }
      .brand {
        display: inline-flex;
        align-items: center;
        font-size: var(--npt-text-title, 18px);
        line-height: 1;
      }
      .number {
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-title, 18px);
        letter-spacing: 0.18em;
        margin: 0;
      }
      .dots {
        opacity: 0.7;
        margin-inline-end: var(--npt-space-2, 8px);
      }
      .bottom {
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        gap: var(--npt-space-4, 16px);
      }
      .holder {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        text-transform: uppercase;
        letter-spacing: 0.04em;
        margin: 0;
        min-inline-size: 0;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
      .meta {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        opacity: 0.85;
        margin: 0 0 var(--npt-space-1, 4px);
      }
      .expiry {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-label, 14px);
        text-align: end;
        margin: 0;
      }
      .frost {
        position: absolute;
        inset: 0;
        display: none;
        align-items: center;
        justify-content: center;
        gap: var(--npt-space-2, 8px);
        background: var(--md-sys-color-scrim);
        opacity: 0.42;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        color: var(--md-sys-color-on-primary);
        pointer-events: none;
      }
      :host([variant="frozen"]) .card {
        filter: grayscale(0.65) brightness(0.9);
      }
      :host([variant="frozen"]) .frost {
        display: flex;
      }
    `;
  }

  protected render(): string {
    const holder = esc(this.getAttribute("holder"));
    const last4 = esc(this.getAttribute("last4"));
    const expiry = esc(this.getAttribute("expiry"));
    const scheme = esc(this.getAttribute("scheme"));
    const frozen = this.getAttribute("variant") === "frozen";
    const label = `${scheme} card ending ${last4}${frozen ? ", frozen" : ""}`;
    return html`<div class="card" part="card" role="group" aria-label="${label}">
      <div class="top">
        <span class="scheme">${scheme}</span>
        <span class="brand"><slot name="brand"></slot></span>
      </div>
      <p class="number">
        <span class="dots" aria-hidden="true">•••• •••• ••••</span>${last4}
      </p>
      <div class="bottom">
        <p class="holder">${holder}</p>
        <div>
          <p class="meta">Expires</p>
          <p class="expiry">${expiry}</p>
        </div>
      </div>
      <div class="frost" aria-hidden="true"><span aria-hidden="true">❄</span> Frozen</div>
    </div>`;
  }
}

/**
 * <npt-card-row label="Salary card" last4="4821" scheme="VISA" [interactive]>
 *   <span slot="brand">◈</span></npt-card-row>
 * Saved-card list item. Leading `brand` slot, trailing chevron. [interactive] makes
 * the whole row a button (role/tabindex/hover) that emits a bubbling `select` event.
 */
export class NptCardRow extends NptElement {
  static observedAttributes = ["label", "last4", "scheme", "interactive"];

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
    if (!this.hasAttribute("interactive")) return;
    this.dispatchEvent(new CustomEvent("select", { bubbles: true }));
  }

  private onClick = (): void => this.activate();
  private onKey = (e: KeyboardEvent): void => {
    if (!this.hasAttribute("interactive")) return;
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
      .row {
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        min-height: 56px;
        padding-block: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-2, 8px);
        border-bottom: 1px solid var(--md-sys-color-outline-variant);
        border-radius: var(--npt-corner-sm, 12px);
        color: var(--md-sys-color-on-surface);
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([interactive]) {
        cursor: pointer;
      }
      :host([interactive]) .row:hover {
        background: var(--md-sys-color-surface-container);
      }
      .brand {
        inline-size: 40px;
        block-size: 40px;
        flex: 0 0 auto;
        border-radius: var(--npt-corner-xs, 8px);
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
        display: grid;
        place-items: center;
        font-family: var(--npt-font-display);
        font-weight: 700;
      }
      .body {
        flex: 1 1 auto;
        min-inline-size: 0;
      }
      .label {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      .sub {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-body, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 2px 0 0;
        display: flex;
        align-items: center;
        gap: var(--npt-space-2, 8px);
      }
      .scheme {
        text-transform: uppercase;
        letter-spacing: 0.04em;
        font-family: var(--npt-font-text);
      }
      .chevron {
        flex: 0 0 auto;
        color: var(--md-sys-color-on-surface-variant);
        font-size: var(--npt-text-title, 18px);
        line-height: 1;
        display: none;
      }
      :host([interactive]) .chevron {
        display: inline;
      }
    `;
  }

  protected render(): string {
    const label = esc(this.getAttribute("label"));
    const last4 = esc(this.getAttribute("last4"));
    const scheme = esc(this.getAttribute("scheme"));
    const initial = scheme.trim().charAt(0).toUpperCase() || label.trim().charAt(0).toUpperCase() || "•";
    const interactive = this.hasAttribute("interactive");
    const rowAttrs = interactive ? html`role="button" tabindex="0"` : html`role="group"`;
    return html`<div class="row" part="row" ${rowAttrs} aria-label="${label} ${scheme} ending ${last4}">
      <span class="brand" aria-hidden="true"><slot name="brand">${initial}</slot></span>
      <div class="body">
        <p class="label">${label}</p>
        <p class="sub">
          ${scheme ? html`<span class="scheme">${scheme}</span>` : ""}
          <span>•••• ${last4}</span>
        </p>
      </div>
      <span class="chevron" aria-hidden="true">›</span>
    </div>`;
  }
}

/**
 * <npt-add-card>Add a new card</npt-add-card>
 * Dashed call-to-action tile with a leading +. Behaves as a button (role/tabindex)
 * and emits a bubbling `add` event on click / Enter / Space.
 */
export class NptAddCard extends NptElement {
  static observedAttributes = ["disabled"];

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
    this.dispatchEvent(new CustomEvent("add", { bubbles: true }));
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
        cursor: pointer;
      }
      :host([disabled]) {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .tile {
        box-sizing: border-box;
        inline-size: 100%;
        min-height: 88px;
        display: flex;
        align-items: center;
        gap: var(--npt-space-4, 16px);
        padding-inline: var(--npt-space-5, 20px);
        padding-block: var(--npt-space-4, 16px);
        border: 2px dashed var(--md-sys-color-outline);
        border-radius: var(--npt-corner-lg, 24px);
        background: transparent;
        color: var(--md-sys-color-on-surface-variant);
        transition: border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host(:not([disabled])) .tile:hover {
        border-color: var(--md-sys-color-primary);
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
      }
      .plus {
        inline-size: 44px;
        block-size: 44px;
        flex: 0 0 auto;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
        display: grid;
        place-items: center;
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-title, 18px);
        font-weight: 700;
        line-height: 1;
      }
      .label {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
      }
    `;
  }

  protected render(): string {
    const disabled = this.hasAttribute("disabled");
    const tabindex = disabled ? "-1" : "0";
    return html`<div
      class="tile"
      part="tile"
      role="button"
      tabindex="${tabindex}"
      aria-disabled="${disabled}"
    >
      <span class="plus" aria-hidden="true">+</span>
      <span class="label"><slot>Add card</slot></span>
    </div>`;
  }
}

/**
 * <npt-card-controls [frozen]></npt-card-controls>
 * Row of toggle actions (Freeze, Limits, Details, PIN). Each press dispatches a
 * bubbling `control` event whose detail is { action }. [frozen] flips the first
 * action's label/affordance to Unfreeze.
 */
export class NptCardControls extends NptElement {
  static observedAttributes = ["frozen"];

  private static readonly ACTIONS: ReadonlyArray<{ action: string; label: string; glyph: string }> = [
    { action: "freeze", label: "Freeze", glyph: "❄" },
    { action: "limits", label: "Limits", glyph: "⚖" },
    { action: "details", label: "Details", glyph: "≣" },
    { action: "pin", label: "PIN", glyph: "⊞" },
  ];

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
    const btn = (e.target as HTMLElement)?.closest<HTMLElement>("[data-action]");
    if (!btn) return;
    const action = btn.dataset["action"];
    if (!action) return;
    this.dispatchEvent(new CustomEvent("control", { bubbles: true, detail: { action } }));
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .bar {
        display: flex;
        gap: var(--npt-space-2, 8px);
      }
      button {
        flex: 1 1 0;
        min-inline-size: 0;
        min-height: 64px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: var(--npt-space-1, 4px);
        padding-block: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-2, 8px);
        border: 1px solid var(--md-sys-color-outline-variant);
        border-radius: var(--npt-corner-md, 16px);
        background: var(--md-sys-color-surface-container-low);
        color: var(--md-sys-color-on-surface);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        cursor: pointer;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      button:hover {
        background: var(--md-sys-color-surface-container-high);
      }
      .glyph {
        font-size: var(--npt-text-title, 18px);
        line-height: 1;
      }
      button[data-action="freeze"][aria-pressed="true"] {
        background: var(--md-sys-color-primary-container);
        color: var(--md-sys-color-on-primary-container);
        border-color: transparent;
      }
    `;
  }

  protected render(): string {
    const frozen = this.hasAttribute("frozen");
    const buttons = NptCardControls.ACTIONS.map((a) => {
      const isFreeze = a.action === "freeze";
      const label = isFreeze && frozen ? "Unfreeze" : a.label;
      const pressed = isFreeze ? html`aria-pressed="${frozen}"` : "";
      return html`<button
        type="button"
        part="control"
        data-action="${esc(a.action)}"
        aria-label="${esc(label)}"
        ${pressed}
      >
        <span class="glyph" aria-hidden="true">${a.glyph}</span>
        <span>${esc(label)}</span>
      </button>`;
    }).join("");
    return html`<div class="bar" part="bar" role="group" aria-label="Card controls">${buttons}</div>`;
  }
}

void define;

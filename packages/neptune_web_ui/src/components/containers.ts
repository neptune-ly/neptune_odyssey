// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — overlay containers
// <npt-dialog>, <npt-bottom-sheet>, <npt-menu> + <npt-menu-item>.
// Custom-property driven only; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y } from "./base.js";

const FOCUSABLE =
  'a[href],button:not([disabled]),textarea,input,select,[tabindex]:not([tabindex="-1"]),npt-button,npt-icon-button';

/**
 * <npt-dialog [open] headline="Confirm">
 *   …content… <span slot="actions">…</span>
 * </npt-dialog>
 * Scrim + centred surface. ESC and backdrop close; focus-trap-lite.
 */
export class NptDialog extends NptElement {
  static observedAttributes = ["open", "headline"];

  attributeChangedCallback(name: string): void {
    if (this.isConnected) this.update();
    if (name === "open" && this.hasAttribute("open")) this.focusFirst();
  }

  override connectedCallback(): void {
    super.connectedCallback();
    this.root.addEventListener("click", this.onClick);
    this.addEventListener("keydown", this.onKey);
  }

  disconnectedCallback(): void {
    this.root.removeEventListener("click", this.onClick);
    this.removeEventListener("keydown", this.onKey);
  }

  /** Close the overlay and emit a `close` event. */
  close(): void {
    this.removeAttribute("open");
    this.dispatchEvent(new CustomEvent("close", { bubbles: true }));
  }

  private focusFirst(): void {
    queueMicrotask(() => {
      const el = this.querySelector<HTMLElement>(FOCUSABLE) ?? this.root.querySelector<HTMLElement>(".surface");
      el?.focus?.();
    });
  }

  private onClick = (e: Event): void => {
    const t = e.target as HTMLElement;
    if (t.classList.contains("scrim") || t.closest("[data-close]")) this.close();
  };

  private onKey = (e: KeyboardEvent): void => {
    if (e.key === "Escape") {
      e.preventDefault();
      this.close();
    } else if (e.key === "Tab") {
      const items = Array.from(this.querySelectorAll<HTMLElement>(FOCUSABLE)).filter(
        (el) => el.offsetParent !== null || el === document.activeElement,
      );
      if (items.length === 0) return;
      const first = items[0];
      const last = items[items.length - 1];
      const active = (this.getRootNode() as Document).activeElement;
      if (e.shiftKey && active === first) {
        e.preventDefault();
        last?.focus();
      } else if (!e.shiftKey && active === last) {
        e.preventDefault();
        first?.focus();
      }
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: none;
      }
      :host([open]) {
        display: block;
      }
      .scrim {
        position: fixed;
        inset: 0;
        z-index: var(--npt-z-modal, 70);
        background: color-mix(in oklab, var(--md-sys-color-scrim) 40%, transparent);
        display: grid;
        place-items: center;
        padding: var(--npt-space-4, 16px);
      }
      .surface {
        inline-size: min(560px, 100%);
        max-block-size: 90vh;
        overflow: auto;
        background: var(--md-sys-color-surface-container-high);
        color: var(--md-sys-color-on-surface);
        border-radius: var(--npt-corner-xl, 32px);
        padding: var(--npt-space-6, 24px);
        box-shadow: var(--npt-elevation-5, 0 28px 60px rgba(0, 0, 0, 0.3));
        box-sizing: border-box;
      }
      .headline {
        font-family: var(--npt-font-display);
        font-size: var(--npt-text-headline, 28px);
        font-weight: var(--npt-display-weight, 700);
        margin: 0 0 var(--npt-space-4, 16px);
      }
      .content {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface-variant);
      }
      .actions {
        display: flex;
        justify-content: flex-end;
        gap: var(--npt-space-2, 8px);
        margin-block-start: var(--npt-space-6, 24px);
      }
    `;
  }

  protected render(): string {
    const headline = (this.getAttribute("headline") ?? "").replace(/[<>]/g, "");
    return html`<div class="scrim" part="scrim">
      <div class="surface" part="surface" role="dialog" aria-modal="true" aria-label="${headline}" tabindex="-1">
        ${headline ? html`<h2 class="headline">${headline}</h2>` : ""}
        <div class="content"><slot></slot></div>
        <div class="actions"><slot name="actions"></slot></div>
      </div>
    </div>`;
  }
}

/**
 * <npt-bottom-sheet [open]>…content…</npt-bottom-sheet>
 * Bottom-anchored sheet with a drag affordance + scrim. Backdrop/ESC close.
 */
export class NptBottomSheet extends NptElement {
  static observedAttributes = ["open"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  override connectedCallback(): void {
    super.connectedCallback();
    this.root.addEventListener("click", this.onClick);
    this.addEventListener("keydown", this.onKey);
  }

  disconnectedCallback(): void {
    this.root.removeEventListener("click", this.onClick);
    this.removeEventListener("keydown", this.onKey);
  }

  /** Close the sheet and emit a `close` event. */
  close(): void {
    this.removeAttribute("open");
    this.dispatchEvent(new CustomEvent("close", { bubbles: true }));
  }

  private onClick = (e: Event): void => {
    const t = e.target as HTMLElement;
    if (t.classList.contains("scrim") || t.closest("[data-close]")) this.close();
  };

  private onKey = (e: KeyboardEvent): void => {
    if (e.key === "Escape") {
      e.preventDefault();
      this.close();
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: none;
      }
      :host([open]) {
        display: block;
      }
      .scrim {
        position: fixed;
        inset: 0;
        z-index: var(--npt-z-modal, 70);
        background: color-mix(in oklab, var(--md-sys-color-scrim) 40%, transparent);
        display: flex;
        align-items: flex-end;
        justify-content: center;
      }
      .sheet {
        inline-size: min(640px, 100%);
        max-block-size: 90vh;
        overflow: auto;
        background: var(--md-sys-color-surface-container-low);
        color: var(--md-sys-color-on-surface);
        border-start-start-radius: var(--npt-corner-xl, 32px);
        border-start-end-radius: var(--npt-corner-xl, 32px);
        padding: var(--npt-space-4, 16px) var(--npt-space-6, 24px) var(--npt-space-6, 24px);
        box-shadow: var(--npt-elevation-5, 0 28px 60px rgba(0, 0, 0, 0.3));
        box-sizing: border-box;
      }
      .grip {
        inline-size: 32px;
        block-size: 4px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-outline-variant);
        margin: 0 auto var(--npt-space-4, 16px);
      }
    `;
  }

  protected render(): string {
    return html`<div class="scrim" part="scrim">
      <div class="sheet" part="sheet" role="dialog" aria-modal="true">
        <div class="grip" part="grip" aria-hidden="true"></div>
        <slot></slot>
      </div>
    </div>`;
  }
}

/**
 * <npt-menu [open]> with <npt-menu-item> children.
 * Anchored popover. Place inside a positioned ancestor for anchoring.
 */
export class NptMenu extends NptElement {
  static observedAttributes = ["open"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: none;
        position: absolute;
        inset-block-start: 100%;
        inset-inline-start: 0;
        z-index: var(--npt-z-overlay, 60);
      }
      :host([open]) {
        display: block;
      }
      .menu {
        min-inline-size: 180px;
        padding-block: var(--npt-space-2, 8px);
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface);
        border-radius: var(--npt-corner-sm, 12px);
        box-shadow: var(--npt-elevation-3, 0 8px 20px rgba(0, 0, 0, 0.2));
      }
    `;
  }

  protected render(): string {
    return html`<div class="menu" part="menu" role="menu"><slot></slot></div>`;
  }
}

/** <npt-menu-item [disabled]>Settings</npt-menu-item> */
export class NptMenuItem extends NptElement {
  static observedAttributes = ["disabled"];

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
        min-height: 48px;
        display: flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        padding-inline: var(--npt-space-4, 16px);
        border: none;
        background: transparent;
        color: inherit;
        text-align: start;
        cursor: pointer;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .item:hover:not(:disabled) {
        background: var(--md-sys-color-surface-container-highest);
      }
      .item:disabled {
        cursor: not-allowed;
        opacity: 0.38;
      }
    `;
  }

  protected render(): string {
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    return html`<button class="item" part="item" role="menuitem" ${disabled}>
      <slot name="leading"></slot><slot></slot>
    </button>`;
  }
}

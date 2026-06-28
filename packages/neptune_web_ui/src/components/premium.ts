// Neptune Odyssey — premium app-shell pieces · © 2026 Neptune.Fintech (neptune.ly)
//
// A floating "dock" bottom navigation with a raised active indicator, and a
// full-screen onboarding / get-started hero. Both are custom-property driven
// only (no literal colours/radii/fonts), use logical properties so they mirror
// under RTL, and honour prefers-reduced-motion via the shared A11Y guard.
import { A11Y, NptElement, css, html } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/**
 * <npt-dock> — a floating, glassy bottom navigation that wraps <npt-dock-item>
 * children. The active item lifts into a filled accent circle that rises above
 * the bar. Place it fixed at the bottom of your app shell.
 */
export class NptDock extends NptElement {
  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .dock {
        display: flex;
        justify-content: space-around;
        align-items: center;
        gap: var(--npt-space-1, 4px);
        padding: var(--npt-space-3, 12px) var(--npt-space-4, 16px);
        background: color-mix(in oklab, var(--md-sys-color-surface-container) 86%, transparent);
        -webkit-backdrop-filter: blur(var(--npt-glass-blur, 14px));
        backdrop-filter: blur(var(--npt-glass-blur, 14px));
        border: 1px solid var(--md-sys-color-outline-variant);
        border-radius: var(--npt-corner-2xl, 28px);
        box-shadow: var(--npt-elev-3, 0 8px 24px rgba(0, 0, 0, 0.18));
        /* let the active item's raised circle pop above the bar */
        overflow: visible;
      }
    `;
  }

  protected render(): string {
    return html`<nav class="dock" part="dock" role="navigation"><slot></slot></nav>`;
  }
}

/** <npt-dock-item label="Home" [active]>icon</npt-dock-item> */
export class NptDockItem extends NptElement {
  static observedAttributes = ["label", "active", "disabled"];

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

  private onClick = (): void => {
    if (this.hasAttribute("disabled")) return;
    this.dispatchEvent(
      new CustomEvent("npt-select", {
        bubbles: true,
        composed: true,
        detail: { label: this.getAttribute("label") ?? "" },
      }),
    );
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-flex;
        flex: 1 1 0;
      }
      .item {
        flex: 1 1 0;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: var(--npt-space-1, 4px);
        min-block-size: 48px;
        padding: 0;
        border: none;
        background: transparent;
        color: var(--md-sys-color-on-surface-variant);
        cursor: pointer;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        line-height: var(--npt-leading-caption, 1.3);
      }
      .ic {
        inline-size: 44px;
        block-size: 44px;
        border-radius: var(--npt-corner-full, 999px);
        display: grid;
        place-items: center;
        transition:
          transform var(--npt-dur-2, 220ms) var(--npt-ease-emphasized, ease),
          background-color var(--npt-dur-2, 220ms) var(--npt-ease-emphasized, ease),
          box-shadow var(--npt-dur-2, 220ms) var(--npt-ease-emphasized, ease);
      }
      .lbl {
        opacity: 0.85;
        transition: opacity var(--npt-dur-1, 150ms) var(--npt-ease-standard, ease);
      }
      :host([active]) .item {
        color: var(--md-sys-color-primary);
        font-weight: 700;
      }
      :host([active]) .ic {
        background: var(--md-sys-color-primary);
        color: var(--md-sys-color-on-primary);
        transform: translateY(-14px);
        box-shadow: var(--npt-glow-primary, 0 6px 16px rgba(0, 0, 0, 0.28));
      }
      :host([active]) .lbl {
        margin-block-start: -10px;
        opacity: 1;
      }
      :host([disabled]) {
        opacity: 0.4;
        pointer-events: none;
      }
    `;
  }

  protected render(): string {
    const label = esc(this.getAttribute("label"));
    const active = this.hasAttribute("active");
    return html`
      <button class="item" part="item" aria-current="${active ? "page" : "false"}" aria-label="${label}">
        <span class="ic" part="indicator"><slot></slot></span>
        <span class="lbl">${label}</span>
      </button>
    `;
  }
}

/**
 * <npt-onboarding eyebrow="Welcome" supporting="…" steps="3" active-step="0">
 *   <div slot="media">…image / illustration…</div>
 *   <span slot="headline">Bank <b>anywhere</b>.</span>
 *   <npt-button slot="cta" variant="filled">Get started</npt-button>
 * </npt-onboarding>
 *
 * A full-height get-started hero: a media region on top, then headline,
 * supporting copy, page dots and a call to action. The headline accepts rich
 * markup so you can mix weights (regular + bold) like the reference designs.
 */
export class NptOnboarding extends NptElement {
  static observedAttributes = ["eyebrow", "supporting", "steps", "active-step"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
        block-size: 100%;
      }
      .wrap {
        display: flex;
        flex-direction: column;
        min-block-size: 100%;
        background: var(--md-sys-color-background);
        color: var(--md-sys-color-on-background);
      }
      .media {
        position: relative;
        flex: 1 1 auto;
        min-block-size: 220px;
        margin: var(--npt-space-3, 12px);
        border-radius: var(--npt-corner-xl, 28px);
        overflow: hidden;
        background:
          radial-gradient(120% 90% at 80% 0%, var(--md-sys-color-tertiary) 0%, transparent 55%),
          linear-gradient(160deg, var(--md-sys-color-primary), var(--md-sys-color-primary-container));
        display: grid;
        place-items: center;
      }
      .media ::slotted(*) {
        inline-size: 100%;
        block-size: 100%;
        object-fit: cover;
      }
      .content {
        display: flex;
        flex-direction: column;
        gap: var(--npt-space-4, 16px);
        padding: var(--npt-space-6, 24px) var(--npt-space-6, 24px) var(--npt-space-8, 32px);
        animation: rise var(--npt-dur-4, 500ms) var(--npt-ease-decelerate, ease) both;
      }
      @keyframes rise {
        from {
          opacity: 0;
          transform: translateY(12px);
        }
        to {
          opacity: 1;
          transform: none;
        }
      }
      .eyebrow {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: var(--md-sys-color-primary);
        margin: 0;
      }
      .headline {
        font-family: var(--npt-font-display);
        font-weight: var(--npt-display-weight, 400);
        letter-spacing: var(--npt-display-tracking, -0.02em);
        line-height: var(--npt-leading-display-md, 1.1);
        font-size: clamp(28px, 7vw, 40px);
        margin: 0;
      }
      .headline ::slotted(b),
      .headline ::slotted(strong) {
        font-weight: 800;
      }
      .supporting {
        color: var(--md-sys-color-on-surface-variant);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 15px);
        line-height: var(--npt-leading-body, 1.5);
        margin: 0;
        max-inline-size: 42ch;
      }
      .dots {
        display: flex;
        gap: var(--npt-space-2, 8px);
        margin-block: var(--npt-space-1, 4px);
      }
      .dot {
        inline-size: 8px;
        block-size: 8px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-outline-variant);
        transition: inline-size var(--npt-dur-2, 220ms) var(--npt-ease-emphasized, ease);
      }
      .dot[data-on] {
        inline-size: 22px;
        background: var(--md-sys-color-primary);
      }
      .cta {
        margin-block-start: var(--npt-space-2, 8px);
      }
      .cta ::slotted(*) {
        inline-size: 100%;
      }
    `;
  }

  protected render(): string {
    const eyebrow = esc(this.getAttribute("eyebrow"));
    const supporting = esc(this.getAttribute("supporting"));
    const steps = Math.max(0, Number(this.getAttribute("steps")) || 0);
    const activeStep = Number(this.getAttribute("active-step")) || 0;
    const dots = Array.from({ length: steps }, (_, i) =>
      i === activeStep ? `<span class="dot" data-on></span>` : `<span class="dot"></span>`,
    ).join("");
    return html`
      <section class="wrap" part="wrap">
        <div class="media" part="media"><slot name="media"></slot></div>
        <div class="content">
          ${eyebrow ? `<p class="eyebrow">${eyebrow}</p>` : ""}
          <h1 class="headline"><slot name="headline">Get started</slot></h1>
          ${supporting ? `<p class="supporting">${supporting}</p>` : ""}
          ${steps ? `<div class="dots" role="presentation">${dots}</div>` : ""}
          <div class="cta"><slot name="cta"></slot></div>
        </div>
      </section>
    `;
  }
}

/**
 * <npt-cta arrow>Get started</npt-cta> — a large, premium call-to-action with a
 * slow specular sheen sweep and an arrow that nudges (both reduced-motion safe).
 * `variant="tonal"` for the secondary tone; `disabled` to disable.
 */
export class NptCta extends NptElement {
  static observedAttributes = ["variant", "arrow", "disabled"];

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
    if (this.hasAttribute("disabled")) {
      e.stopImmediatePropagation();
      e.preventDefault();
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .cta {
        position: relative;
        overflow: hidden;
        box-sizing: border-box;
        inline-size: 100%;
        min-block-size: 54px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: var(--npt-space-2, 8px);
        padding-inline: var(--npt-space-6, 24px);
        border: none;
        border-radius: var(--npt-corner-2xl, 28px);
        background: var(--md-sys-color-primary);
        color: var(--md-sys-color-on-primary);
        font-family: var(--npt-font-display);
        font-weight: 700;
        font-size: var(--npt-text-title, 16px);
        letter-spacing: var(--npt-display-tracking, 0);
        cursor: pointer;
        box-shadow: var(--npt-glow-primary, 0 8px 22px rgba(0, 0, 0, 0.28));
        transition:
          transform var(--npt-dur-2, 220ms) var(--npt-ease-emphasized, ease),
          filter var(--npt-dur-2, 220ms) var(--npt-ease-standard, ease);
      }
      :host([variant="tonal"]) .cta {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
        box-shadow: none;
      }
      .cta:hover {
        filter: brightness(1.04);
      }
      .cta:active {
        transform: scale(0.98);
      }
      :host([disabled]) .cta {
        opacity: 0.5;
        pointer-events: none;
      }
      /* specular sheen — a token-tinted highlight, not a literal colour */
      .sheen {
        position: absolute;
        inset: 0;
        pointer-events: none;
        background: linear-gradient(
          110deg,
          transparent 32%,
          color-mix(in oklab, var(--md-sys-color-on-primary) 38%, transparent) 50%,
          transparent 68%
        );
        transform: translateX(-130%);
        animation: sheen 4.8s var(--npt-ease-standard, ease) infinite;
      }
      @keyframes sheen {
        0%,
        62% {
          transform: translateX(-130%);
        }
        82%,
        100% {
          transform: translateX(130%);
        }
      }
      .arrow {
        display: inline-flex;
        animation: nudge 2.4s ease-in-out infinite;
        transition: transform var(--npt-dur-2, 220ms) var(--npt-ease-spring, ease);
      }
      @keyframes nudge {
        0%,
        100% {
          transform: translateX(0);
        }
        50% {
          transform: translateX(4px);
        }
      }
      .cta:hover .arrow {
        transform: translateX(6px);
      }
      /* the arrow mirrors under RTL */
      :host(:dir(rtl)) .arrow {
        scale: -1 1;
      }
    `;
  }

  protected render(): string {
    const arrow = this.hasAttribute("arrow");
    const disabled = this.hasAttribute("disabled");
    return html`
      <button class="cta" part="cta" ${disabled ? "disabled" : ""}>
        <span class="sheen" part="sheen"></span>
        <span class="lbl"><slot></slot></span>
        ${arrow ? `<span class="arrow" aria-hidden="true">→</span>` : ""}
      </button>
    `;
  }
}

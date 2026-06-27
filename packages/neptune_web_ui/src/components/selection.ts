// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — selection controls
// <npt-checkbox>, <npt-radio>, <npt-switch>, <npt-slider>.
// Custom-property driven only; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/** <npt-checkbox [checked] [indeterminate] [disabled]>Label</npt-checkbox> */
export class NptCheckbox extends NptElement {
  static observedAttributes = ["checked", "indeterminate", "disabled"];

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

  private toggle(): void {
    if (this.hasAttribute("disabled")) return;
    this.removeAttribute("indeterminate");
    this.toggleAttribute("checked");
    this.dispatchEvent(new CustomEvent("change", { bubbles: true }));
  }

  private onClick = (): void => this.toggle();
  private onKey = (e: KeyboardEvent): void => {
    if (e.key === " " || e.key === "Enter") {
      e.preventDefault();
      this.toggle();
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        min-height: 48px;
        cursor: pointer;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
      }
      :host([disabled]) {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .box {
        inline-size: 20px;
        block-size: 20px;
        flex: 0 0 auto;
        border: 2px solid var(--md-sys-color-on-surface-variant);
        border-radius: var(--npt-corner-xs, 8px);
        display: grid;
        place-items: center;
        color: var(--md-sys-color-on-primary);
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([checked]) .box,
      :host([indeterminate]) .box {
        background: var(--md-sys-color-primary);
        border-color: var(--md-sys-color-primary);
      }
      .mark {
        font-size: 14px;
        line-height: 1;
      }
    `;
  }

  protected render(): string {
    const checked = this.hasAttribute("checked");
    const indeterminate = this.hasAttribute("indeterminate");
    const state = indeterminate ? "mixed" : checked ? "true" : "false";
    const mark = indeterminate ? "–" : checked ? "✓" : "";
    return html`<span
        class="box"
        part="box"
        role="checkbox"
        aria-checked="${state}"
        tabindex="0"
      ><span class="mark" aria-hidden="true">${mark}</span></span>
      <span><slot></slot></span>`;
  }
}

/** <npt-radio name="plan" value="pro" [checked] [disabled]>Pro</npt-radio> */
export class NptRadio extends NptElement {
  static observedAttributes = ["checked", "disabled", "name", "value"];

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

  private select(): void {
    if (this.hasAttribute("disabled") || this.hasAttribute("checked")) return;
    const name = this.getAttribute("name");
    if (name) {
      const scope = this.getRootNode() as Document | ShadowRoot;
      for (const r of scope.querySelectorAll(`npt-radio[name="${name}"]`)) {
        r.removeAttribute("checked");
      }
    }
    this.setAttribute("checked", "");
    this.dispatchEvent(new CustomEvent("change", { bubbles: true }));
  }

  private onClick = (): void => this.select();
  private onKey = (e: KeyboardEvent): void => {
    if (e.key === " " || e.key === "Enter") {
      e.preventDefault();
      this.select();
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        min-height: 48px;
        cursor: pointer;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body-lg, 16px);
        color: var(--md-sys-color-on-surface);
      }
      :host([disabled]) {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .ring {
        inline-size: 20px;
        block-size: 20px;
        flex: 0 0 auto;
        border: 2px solid var(--md-sys-color-on-surface-variant);
        border-radius: var(--npt-corner-full, 999px);
        display: grid;
        place-items: center;
        transition: border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([checked]) .ring {
        border-color: var(--md-sys-color-primary);
      }
      .dot {
        inline-size: 10px;
        block-size: 10px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-primary);
        transform: scale(0);
        transition: transform var(--npt-dur-fast, 200ms) var(--npt-ease-spring, ease);
      }
      :host([checked]) .dot {
        transform: scale(1);
      }
    `;
  }

  protected render(): string {
    const checked = this.hasAttribute("checked");
    return html`<span class="ring" part="ring" role="radio" aria-checked="${checked}" tabindex="0">
        <span class="dot" aria-hidden="true"></span>
      </span>
      <span><slot></slot></span>`;
  }
}

/** <npt-switch [checked] [disabled] label="Wi-Fi"></npt-switch> */
export class NptSwitch extends NptElement {
  static observedAttributes = ["checked", "disabled", "label"];

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

  private toggle(): void {
    if (this.hasAttribute("disabled")) return;
    this.toggleAttribute("checked");
    this.dispatchEvent(new CustomEvent("change", { bubbles: true }));
  }

  private onClick = (): void => this.toggle();
  private onKey = (e: KeyboardEvent): void => {
    if (e.key === " " || e.key === "Enter") {
      e.preventDefault();
      this.toggle();
    }
  };

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: inline-flex;
        align-items: center;
        min-height: 48px;
        cursor: pointer;
      }
      :host([disabled]) {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .track {
        inline-size: 52px;
        block-size: 32px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-surface-container-highest);
        border: 2px solid var(--md-sys-color-outline);
        position: relative;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
        box-sizing: border-box;
      }
      .thumb {
        position: absolute;
        inset-block-start: 50%;
        inset-inline-start: 6px;
        inline-size: 16px;
        block-size: 16px;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-outline);
        transform: translateY(-50%);
        transition: inset-inline-start var(--npt-dur-fast, 200ms) var(--npt-ease-spring, ease),
          inline-size var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([checked]) .track {
        background: var(--md-sys-color-primary);
        border-color: var(--md-sys-color-primary);
      }
      :host([checked]) .thumb {
        inset-inline-start: 26px;
        inline-size: 22px;
        block-size: 22px;
        background: var(--md-sys-color-on-primary);
      }
    `;
  }

  protected render(): string {
    const checked = this.hasAttribute("checked");
    const label = esc(this.getAttribute("label"));
    return html`<span
      class="track"
      part="track"
      role="switch"
      aria-checked="${checked}"
      aria-label="${label}"
      tabindex="0"
    ><span class="thumb" aria-hidden="true"></span></span>`;
  }
}

/** <npt-slider min="0" max="100" value="40" step="1" label="Amount"></npt-slider> */
export class NptSlider extends NptElement {
  static observedAttributes = ["min", "max", "value", "step", "disabled", "label"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  get value(): number {
    return Number(this.root.querySelector("input")?.value ?? this.getAttribute("value") ?? 0);
  }

  override connectedCallback(): void {
    super.connectedCallback();
    this.addEventListener("input", this.onInput);
  }

  disconnectedCallback(): void {
    this.removeEventListener("input", this.onInput);
  }

  private onInput = (e: Event): void => {
    const input = e.target as HTMLInputElement;
    this.setAttribute("value", input.value);
    const bubble = this.root.querySelector(".bubble");
    if (bubble) bubble.textContent = input.value;
    this.positionBubble();
  };

  private positionBubble(): void {
    const min = Number(this.getAttribute("min") ?? 0);
    const max = Number(this.getAttribute("max") ?? 100);
    const val = Number(this.getAttribute("value") ?? min);
    const pct = max > min ? ((val - min) / (max - min)) * 100 : 0;
    const bubble = this.root.querySelector(".bubble") as HTMLElement | null;
    if (bubble) bubble.style.insetInlineStart = `${pct}%`;
  }

  protected override update(): void {
    super.update();
    this.positionBubble();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .wrap {
        position: relative;
        padding-block-start: var(--npt-space-6, 24px);
      }
      input[type="range"] {
        inline-size: 100%;
        block-size: 44px;
        margin: 0;
        accent-color: var(--md-sys-color-primary);
        cursor: pointer;
      }
      input[type="range"]:disabled {
        cursor: not-allowed;
        opacity: 0.38;
      }
      .bubble {
        position: absolute;
        inset-block-start: 0;
        transform: translateX(-50%);
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-caption, 12px);
        padding-inline: var(--npt-space-2, 8px);
        padding-block: 2px;
        border-radius: var(--npt-corner-xs, 8px);
        background: var(--md-sys-color-primary);
        color: var(--md-sys-color-on-primary);
      }
    `;
  }

  protected render(): string {
    const min = esc(this.getAttribute("min")) || "0";
    const max = esc(this.getAttribute("max")) || "100";
    const value = esc(this.getAttribute("value")) || min;
    const step = esc(this.getAttribute("step")) || "1";
    const disabled = this.hasAttribute("disabled") ? "disabled" : "";
    const label = esc(this.getAttribute("label"));
    return html`<div class="wrap" part="wrap">
      <output class="bubble" part="bubble">${value}</output>
      <input
        type="range"
        min="${min}"
        max="${max}"
        value="${value}"
        step="${step}"
        aria-label="${label}"
        ${disabled}
      />
    </div>`;
  }
}

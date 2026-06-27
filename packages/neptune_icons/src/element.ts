// Neptune Odyssey — <npt-icon> custom element · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// A minimal, self-contained Shadow-DOM custom element that renders a Neptune
// icon. It mirrors the web-ui base pattern (a cached CSSStyleSheet per class,
// custom-property-driven styling, browser-only registration via define()), but
// carries no cross-package dependency so the icon set ships standalone.
//
// The element is colour-agnostic: the inner <svg> uses `currentColor`, so the
// icon inherits `color` — which itself defaults to whatever the surrounding
// theme resolves (e.g. --md-sys-color-on-surface). SSR-safe: nothing touches
// the DOM at import time; registerIcons() is a no-op outside the browser.

import { iconSvg, isIconName } from "./svg.js";

const TAG = "npt-icon";

let sheet: CSSStyleSheet | null = null;

function styleSheet(): CSSStyleSheet | null {
  if (typeof CSSStyleSheet === "undefined") return null;
  if (!sheet) {
    sheet = new CSSStyleSheet();
    sheet.replaceSync(
      `:host{display:inline-flex;align-items:center;justify-content:center;` +
        `color:var(--npt-icon-color, currentColor);line-height:0;vertical-align:middle}` +
        `:host([hidden]){display:none}` +
        `svg{display:block;width:var(--_size);height:var(--_size)}`,
    );
  }
  return sheet;
}

/**
 * <npt-icon name="card" size="24"></npt-icon>
 *
 * Reactive attributes:
 *  - `name`   — an IconName; unknown names render nothing.
 *  - `size`   — px, default 24.
 *  - `stroke` — viewBox-unit stroke width, default 1.8.
 */
export class NptIcon extends HTMLElement {
  static observedAttributes = ["name", "size", "stroke"];

  private root: ShadowRoot;

  constructor() {
    super();
    this.root = this.attachShadow({ mode: "open" });
  }

  connectedCallback(): void {
    this.update();
  }

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  get name(): string {
    return this.getAttribute("name") ?? "";
  }
  set name(v: string) {
    this.setAttribute("name", v);
  }

  get size(): number {
    return Number(this.getAttribute("size")) || 24;
  }
  set size(v: number) {
    this.setAttribute("size", String(v));
  }

  private update(): void {
    const s = styleSheet();
    if (s) this.root.adoptedStyleSheets = [s];

    const size = this.size;
    const strokeAttr = this.getAttribute("stroke");
    const stroke = strokeAttr ? Number(strokeAttr) || 1.8 : 1.8;
    (this.root.host as HTMLElement).style.setProperty("--_size", `${size}px`);

    const name = this.name;
    this.root.innerHTML = isIconName(name) ? iconSvg(name, { size, stroke }) : "";
  }
}

/** Register <npt-icon> in a browser, idempotently. SSR-safe (no-op on server). */
export function registerIcons(): void {
  if (typeof customElements === "undefined") return;
  if (!customElements.get(TAG)) customElements.define(TAG, NptIcon);
}

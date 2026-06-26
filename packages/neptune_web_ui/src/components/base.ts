// Neptune Odyssey — custom-element base · © 2026 Neptune.Fintech (neptune.ly)
//
// Standards-based custom elements. Styles live in a Shadow DOM stylesheet that
// reads ONLY CSS custom properties (--md-sys-color-*, --npt-*) — and custom
// properties inherit THROUGH the shadow boundary, so a component is encapsulated
// yet fully themed by whatever data-theme/data-mode is on an ancestor. No literal
// colors/radii/fonts; no runtime CSS-in-JS beyond a single cached stylesheet per
// component class. SSR-safe: nothing touches the DOM at import time.

const sheetCache = new WeakMap<typeof NptElement, CSSStyleSheet>();

export abstract class NptElement extends HTMLElement {
  /** Component CSS — custom-property driven only. Implemented per component. */
  protected abstract styles(): string;
  /** Shadow markup. Implemented per component. */
  protected abstract render(): string;

  protected root: ShadowRoot;

  constructor() {
    super();
    this.root = this.attachShadow({ mode: "open" });
  }

  connectedCallback(): void {
    this.update();
  }

  protected update(): void {
    const ctor = this.constructor as typeof NptElement;
    let sheet = sheetCache.get(ctor);
    if (!sheet) {
      sheet = new CSSStyleSheet();
      sheet.replaceSync(this.styles());
      sheetCache.set(ctor, sheet);
    }
    this.root.adoptedStyleSheets = [sheet];
    this.root.innerHTML = this.render();
  }
}

/** Identity tag for editor CSS highlighting; returns the string unchanged. */
export const css = (strings: TemplateStringsArray, ...values: unknown[]): string =>
  strings.reduce((acc, s, i) => acc + s + (i < values.length ? String(values[i]) : ""), "");

export const html = css;

/** Register a custom element only in a browser, idempotently. SSR-safe. */
export function define(tag: string, ctor: CustomElementConstructor): void {
  if (typeof customElements === "undefined") return;
  if (!customElements.get(tag)) customElements.define(tag, ctor);
}

/** Shared focus-visible ring + reduced-motion guard, reused by components. */
export const A11Y = css`
  :host {
    --_focus: var(--npt-focus-ring, 2px solid var(--md-sys-color-primary));
  }
  :host(:focus-visible),
  *:focus-visible {
    outline: var(--_focus);
    outline-offset: 2px;
  }
  @media (prefers-reduced-motion: reduce) {
    * {
      transition: none !important;
      animation: none !important;
    }
  }
`;

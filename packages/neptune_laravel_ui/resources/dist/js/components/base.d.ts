export declare abstract class NptElement extends HTMLElement {
    /** Component CSS — custom-property driven only. Implemented per component. */
    protected abstract styles(): string;
    /** Shadow markup. Implemented per component. */
    protected abstract render(): string;
    protected root: ShadowRoot;
    constructor();
    connectedCallback(): void;
    protected update(): void;
}
/** Identity tag for editor CSS highlighting; returns the string unchanged. */
export declare const css: (strings: TemplateStringsArray, ...values: unknown[]) => string;
export declare const html: (strings: TemplateStringsArray, ...values: unknown[]) => string;
/** Register a custom element only in a browser, idempotently. SSR-safe. */
export declare function define(tag: string, ctor: CustomElementConstructor): void;
/** Shared focus-visible ring + reduced-motion guard, reused by components. */
export declare const A11Y: string;
//# sourceMappingURL=base.d.ts.map
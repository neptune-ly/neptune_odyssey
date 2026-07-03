import { NptElement } from "./base.js";
/**
 * <npt-button variant="filled|elevated|tonal|outlined|text" [disabled]>Label</npt-button>
 * M3 Expressive button. Pill shape, brand-tinted, 48dp min target.
 */
export declare class NptButton extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=button.d.ts.map
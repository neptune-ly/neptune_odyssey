import { NptElement } from "./base.js";
/**
 * <npt-icon-button variant="standard|filled|tonal|outlined" [selected] [disabled]
 *   label="Favourite">★</npt-icon-button>
 * 48dp circular target. `selected` toggles the active treatment.
 */
export declare class NptIconButton extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-fab size="sm|md|lg" [extended] label="Compose" [disabled]>＋</npt-fab>
 * Primary-container floating action. `extended` reveals the text label.
 */
export declare class NptFab extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-segmented-button [multi]> with <npt-segmented-option> children.
 * Connected single- or multi-select group. Single-select is the default.
 */
export declare class NptSegmentedButton extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onClick;
    protected styles(): string;
    protected render(): string;
}
/** <npt-segmented-option value="day" [selected] [disabled]>Day</npt-segmented-option> */
export declare class NptSegmentedOption extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=actions.d.ts.map
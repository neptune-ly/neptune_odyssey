import { NptElement } from "./base.js";
/** <npt-checkbox [checked] [indeterminate] [disabled]>Label</npt-checkbox> */
export declare class NptCheckbox extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private toggle;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/** <npt-radio name="plan" value="pro" [checked] [disabled]>Pro</npt-radio> */
export declare class NptRadio extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private select;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/** <npt-switch [checked] [disabled] label="Wi-Fi"></npt-switch> */
export declare class NptSwitch extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private toggle;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/** <npt-slider min="0" max="100" value="40" step="1" label="Amount"></npt-slider> */
export declare class NptSlider extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    get value(): number;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onInput;
    private positionBubble;
    protected update(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=selection.d.ts.map
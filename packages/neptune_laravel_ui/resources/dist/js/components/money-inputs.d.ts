import { NptElement } from "./base.js";
/**
 * <npt-amount-input currency="LYD" value="" placeholder="0.00"></npt-amount-input>
 * Large amount entry with a currency affix. Big tabular figures. Numeric input
 * mode; dispatches `input` (bubbling) with the sanitized value on every change.
 */
export declare class NptAmountInput extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    get value(): string;
    set value(v: string);
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onInput;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-currency-field label="Amount" value="" currency="LYD"
 *   helper="Available 12,480.50" [error="msg"]></npt-currency-field>
 * Labelled outlined money field. Tabular figures; trailing currency code.
 */
export declare class NptCurrencyField extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    get value(): string;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onInput;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-iban-field label="IBAN" value="" country="LY"></npt-iban-field>
 * Formats the IBAN into groups of four as you type and reflects valid/invalid
 * state (ISO 7064 mod-97). Dispatches `input` and `change` with `{ value, valid }`.
 */
export declare class NptIbanField extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    /** Raw IBAN with no spaces. */
    get value(): string;
    get valid(): boolean;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private setState;
    private onInput;
    private onBlur;
    protected update(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-otp-input length="6" value="" [masked]></npt-otp-input>
 * N separate single-character boxes with auto-advance, backspace-rewind, and
 * paste-fill. Dispatches `input` on every change and `complete` (with
 * `{ value }`) once every box is filled.
 */
export declare class NptOtpInput extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected get inputType(): string;
    protected get isMasked(): boolean;
    protected get count(): number;
    protected get defaultLength(): number;
    get value(): string;
    set value(v: string);
    connectedCallback(): void;
    disconnectedCallback(): void;
    private boxes;
    private emit;
    private onFocus;
    private onInput;
    private onKey;
    private onPaste;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-pin-input length="4"></npt-pin-input>
 * Like the OTP input, but always masked with dots. Defaults to 4 boxes.
 */
export declare class NptPinInput extends NptOtpInput {
    static observedAttributes: string[];
    protected get defaultLength(): number;
    protected get isMasked(): boolean;
}
/**
 * <npt-amount-keypad value=""></npt-amount-keypad>
 * Numeric keypad (0–9, ., backspace). Dispatches `key` (with the pressed key)
 * on each press and `value` (with the running string) after applying it.
 */
export declare class NptAmountKeypad extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    get value(): string;
    set value(v: string);
    connectedCallback(): void;
    disconnectedCallback(): void;
    private apply;
    private onClick;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=money-inputs.d.ts.map
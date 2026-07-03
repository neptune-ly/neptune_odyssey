// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — money & secure-entry inputs
// <npt-amount-input>, <npt-currency-field>, <npt-iban-field>,
// <npt-otp-input>, <npt-pin-input>, <npt-amount-keypad>.
// Custom-property driven only; money uses tabular figures; logical layout → mirrors in RTL.
import { NptElement, css, html, A11Y } from "./base.js";
const esc = (v) => (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
/** Keep only digits and a single decimal point (first one wins). */
const sanitizeAmount = (raw) => {
    let seenDot = false;
    let out = "";
    for (const ch of raw) {
        if (ch >= "0" && ch <= "9") {
            out += ch;
        }
        else if ((ch === "." || ch === ",") && !seenDot) {
            seenDot = true;
            out += ".";
        }
    }
    return out;
};
/** Strip everything but A–Z and 0–9, uppercased — for IBANs. */
const cleanIban = (raw) => raw.toUpperCase().replace(/[^A-Z0-9]/g, "");
/** Space-group an IBAN into blocks of four. */
const groupIban = (raw) => cleanIban(raw).replace(/(.{4})/g, "$1 ").trim();
/**
 * ISO 7064 mod-97-10 validation of an IBAN. Returns true for a structurally
 * valid checksum (length 15–34, known country prefix length not enforced here).
 */
const isValidIban = (raw) => {
    const v = cleanIban(raw);
    if (v.length < 15 || v.length > 34)
        return false;
    if (!/^[A-Z]{2}[0-9]{2}[A-Z0-9]+$/.test(v))
        return false;
    const rearranged = v.slice(4) + v.slice(0, 4);
    let remainder = 0;
    for (const ch of rearranged) {
        const code = ch >= "A" && ch <= "Z" ? (ch.charCodeAt(0) - 55).toString() : ch;
        for (const d of code) {
            remainder = (remainder * 10 + (d.charCodeAt(0) - 48)) % 97;
        }
    }
    return remainder === 1;
};
/**
 * <npt-amount-input currency="LYD" value="" placeholder="0.00"></npt-amount-input>
 * Large amount entry with a currency affix. Big tabular figures. Numeric input
 * mode; dispatches `input` (bubbling) with the sanitized value on every change.
 */
export class NptAmountInput extends NptElement {
    constructor() {
        super(...arguments);
        this.onInput = (e) => {
            const input = e.target;
            const clean = sanitizeAmount(input.value);
            if (input.value !== clean)
                input.value = clean;
            // Reflect without re-rendering (keeps caret stable).
            this.setAttribute("value", clean);
            e.stopPropagation();
            this.dispatchEvent(new CustomEvent("input", { bubbles: true, detail: { value: clean } }));
        };
    }
    attributeChangedCallback() {
        if (this.isConnected)
            this.update();
    }
    get value() {
        return this.root.querySelector("input")?.value ?? this.getAttribute("value") ?? "";
    }
    set value(v) {
        this.setAttribute("value", v);
    }
    connectedCallback() {
        super.connectedCallback();
        this.root.addEventListener("input", this.onInput);
    }
    disconnectedCallback() {
        this.root.removeEventListener("input", this.onInput);
    }
    styles() {
        return css `
      ${A11Y}
      :host {
        display: block;
      }
      .field {
        display: flex;
        align-items: baseline;
        gap: var(--npt-space-2, 8px);
        min-height: 64px;
        box-sizing: border-box;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        background: var(--md-sys-color-surface-container-lowest);
        border: 1px solid var(--md-sys-color-outline);
        border-radius: var(--npt-corner-md, 16px);
        transition: border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          box-shadow var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .field:focus-within {
        border-color: var(--md-sys-color-primary);
        box-shadow: 0 0 0 1px var(--md-sys-color-primary);
      }
      :host([disabled]) .field {
        opacity: 0.38;
      }
      .affix {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-title, 18px);
        color: var(--md-sys-color-on-surface-variant);
        flex: 0 0 auto;
      }
      input {
        flex: 1 1 auto;
        min-inline-size: 0;
        inline-size: 100%;
        border: none;
        outline: none;
        background: transparent;
        color: var(--md-sys-color-on-surface);
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-feature-settings: "tnum" 1;
        font-size: var(--npt-text-display-md, 45px);
        line-height: var(--npt-leading-display-md, 52px);
        font-weight: var(--npt-display-weight, 700);
        letter-spacing: var(--npt-display-tracking, -0.02em);
        text-align: end;
      }
      input::placeholder {
        color: var(--md-sys-color-on-surface-variant);
        opacity: 0.5;
      }
    `;
    }
    render() {
        const currency = esc(this.getAttribute("currency"));
        const suffix = esc(this.getAttribute("suffix"));
        const value = esc(this.getAttribute("value"));
        const placeholder = esc(this.getAttribute("placeholder")) || "0.00";
        const disabled = this.hasAttribute("disabled") ? "disabled" : "";
        return html `<div class="field" part="field">
      ${currency ? html `<span class="affix" part="prefix" aria-hidden="true">${currency}</span>` : ""}
      <input
        type="text"
        inputmode="decimal"
        autocomplete="off"
        value="${value}"
        placeholder="${placeholder}"
        aria-label="Amount${currency ? html ` in ${currency}` : ""}"
        ${disabled}
      />
      ${suffix ? html `<span class="affix" part="suffix" aria-hidden="true">${suffix}</span>` : ""}
    </div>`;
    }
}
NptAmountInput.observedAttributes = ["currency", "value", "placeholder", "suffix", "disabled"];
/**
 * <npt-currency-field label="Amount" value="" currency="LYD"
 *   helper="Available 12,480.50" [error="msg"]></npt-currency-field>
 * Labelled outlined money field. Tabular figures; trailing currency code.
 */
export class NptCurrencyField extends NptElement {
    constructor() {
        super(...arguments);
        this.onInput = (e) => {
            const input = e.target;
            const clean = sanitizeAmount(input.value);
            if (input.value !== clean)
                input.value = clean;
            this.setAttribute("value", clean);
            e.stopPropagation();
            this.dispatchEvent(new CustomEvent("input", { bubbles: true, detail: { value: clean } }));
        };
    }
    attributeChangedCallback() {
        if (this.isConnected)
            this.update();
    }
    get value() {
        return this.root.querySelector("input")?.value ?? this.getAttribute("value") ?? "";
    }
    connectedCallback() {
        super.connectedCallback();
        this.root.addEventListener("input", this.onInput);
    }
    disconnectedCallback() {
        this.root.removeEventListener("input", this.onInput);
    }
    styles() {
        return css `
      ${A11Y}
      :host {
        display: block;
      }
      label {
        display: block;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin-block-end: var(--npt-space-2, 8px);
      }
      .field {
        display: flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        min-height: 48px;
        box-sizing: border-box;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        background: var(--md-sys-color-surface-container-lowest);
        border: 1px solid var(--md-sys-color-outline);
        border-radius: var(--npt-corner-sm, 12px);
        transition: border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          box-shadow var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .field:focus-within {
        border-color: var(--md-sys-color-primary);
        box-shadow: 0 0 0 1px var(--md-sys-color-primary);
      }
      :host([error]) .field {
        border-color: var(--md-sys-color-error);
      }
      :host([disabled]) .field {
        opacity: 0.38;
      }
      input {
        flex: 1 1 auto;
        min-inline-size: 0;
        border: none;
        outline: none;
        background: transparent;
        color: var(--md-sys-color-on-surface);
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-feature-settings: "tnum" 1;
        font-size: var(--npt-text-title, 18px);
        text-align: end;
      }
      input::placeholder {
        color: var(--md-sys-color-on-surface-variant);
        opacity: 0.6;
      }
      .currency {
        flex: 0 0 auto;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
        font-weight: 600;
        color: var(--md-sys-color-on-surface-variant);
      }
      .helper {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-caption, 12px);
        color: var(--md-sys-color-on-surface-variant);
        margin-block-start: var(--npt-space-2, 8px);
      }
      :host([error]) .helper {
        color: var(--md-sys-color-error);
      }
    `;
    }
    render() {
        const label = esc(this.getAttribute("label"));
        const value = esc(this.getAttribute("value"));
        const currency = esc(this.getAttribute("currency"));
        const helper = esc(this.getAttribute("helper"));
        const error = this.getAttribute("error");
        const placeholder = esc(this.getAttribute("placeholder")) || "0.00";
        const disabled = this.hasAttribute("disabled") ? "disabled" : "";
        const helperText = error ? esc(error) : helper;
        return html `
      ${label ? html `<label id="lbl">${label}</label>` : ""}
      <div class="field" part="field">
        <input
          type="text"
          inputmode="decimal"
          autocomplete="off"
          value="${value}"
          placeholder="${placeholder}"
          aria-labelledby="${label ? "lbl" : ""}"
          aria-label="${label || "Amount"}"
          aria-invalid="${error ? "true" : "false"}"
          ${disabled}
        />
        ${currency ? html `<span class="currency" part="currency">${currency}</span>` : ""}
      </div>
      ${helperText
            ? html `<p class="helper" part="helper" role="${error ? "alert" : "note"}">${helperText}</p>`
            : ""}
    `;
    }
}
NptCurrencyField.observedAttributes = ["label", "value", "currency", "helper", "placeholder", "error", "disabled"];
/**
 * <npt-iban-field label="IBAN" value="" country="LY"></npt-iban-field>
 * Formats the IBAN into groups of four as you type and reflects valid/invalid
 * state (ISO 7064 mod-97). Dispatches `input` and `change` with `{ value, valid }`.
 */
export class NptIbanField extends NptElement {
    constructor() {
        super(...arguments);
        this.onInput = (e) => {
            const input = e.target;
            const raw = cleanIban(input.value);
            const formatted = groupIban(raw);
            input.value = formatted;
            // Keep the caret at the end (typical for grouped entry).
            const end = formatted.length;
            input.setSelectionRange(end, end);
            this.setAttribute("value", raw);
            this.setState();
            e.stopPropagation();
            this.dispatchEvent(new CustomEvent("input", { bubbles: true, detail: { value: raw, valid: isValidIban(raw) } }));
        };
        this.onBlur = () => {
            const raw = this.value;
            this.dispatchEvent(new CustomEvent("change", { bubbles: true, detail: { value: raw, valid: isValidIban(raw) } }));
        };
    }
    attributeChangedCallback() {
        if (this.isConnected)
            this.update();
    }
    /** Raw IBAN with no spaces. */
    get value() {
        return cleanIban(this.getAttribute("value") ?? "");
    }
    get valid() {
        return isValidIban(this.value);
    }
    connectedCallback() {
        super.connectedCallback();
        this.root.addEventListener("input", this.onInput);
        this.root.addEventListener("blur", this.onBlur, true);
    }
    disconnectedCallback() {
        this.root.removeEventListener("input", this.onInput);
        this.root.removeEventListener("blur", this.onBlur, true);
    }
    setState() {
        const raw = this.value;
        const valid = raw.length >= 15 && isValidIban(raw);
        const invalid = raw.length >= 15 && !valid;
        this.toggleAttribute("data-valid", valid);
        this.toggleAttribute("data-invalid", invalid);
        return;
    }
    update() {
        super.update();
        this.setState();
    }
    styles() {
        return css `
      ${A11Y}
      :host {
        display: block;
      }
      label {
        display: block;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin-block-end: var(--npt-space-2, 8px);
      }
      .field {
        display: flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        min-height: 48px;
        box-sizing: border-box;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        background: var(--md-sys-color-surface-container-lowest);
        border: 1px solid var(--md-sys-color-outline);
        border-radius: var(--npt-corner-sm, 12px);
        transition: border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          box-shadow var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      .field:focus-within {
        border-color: var(--md-sys-color-primary);
        box-shadow: 0 0 0 1px var(--md-sys-color-primary);
      }
      :host([data-valid]) .field {
        border-color: var(--md-sys-color-success);
      }
      :host([data-invalid]) .field {
        border-color: var(--md-sys-color-error);
      }
      :host([disabled]) .field {
        opacity: 0.38;
      }
      input {
        flex: 1 1 auto;
        min-inline-size: 0;
        border: none;
        outline: none;
        background: transparent;
        color: var(--md-sys-color-on-surface);
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-body-lg, 16px);
        letter-spacing: 0.06em;
        text-transform: uppercase;
      }
      input::placeholder {
        color: var(--md-sys-color-on-surface-variant);
        opacity: 0.6;
        letter-spacing: normal;
      }
      .state {
        flex: 0 0 auto;
        font-size: var(--npt-text-body-lg, 16px);
        line-height: 1;
        display: none;
      }
      :host([data-valid]) .state.ok {
        display: inline;
        color: var(--md-sys-color-success);
      }
      :host([data-invalid]) .state.bad {
        display: inline;
        color: var(--md-sys-color-error);
      }
    `;
    }
    render() {
        const label = esc(this.getAttribute("label"));
        const country = cleanIban(this.getAttribute("country") ?? "");
        const value = groupIban(this.getAttribute("value") ?? "");
        const placeholder = esc(this.getAttribute("placeholder")) || `${country || "LY"}00 0000 0000 0000`;
        const disabled = this.hasAttribute("disabled") ? "disabled" : "";
        return html `
      ${label ? html `<label id="lbl">${label}</label>` : ""}
      <div class="field" part="field">
        <input
          type="text"
          inputmode="text"
          autocomplete="off"
          autocapitalize="characters"
          spellcheck="false"
          value="${esc(value)}"
          placeholder="${placeholder}"
          aria-labelledby="${label ? "lbl" : ""}"
          aria-label="${label || "IBAN"}"
          aria-invalid="${this.hasAttribute("data-invalid") ? "true" : "false"}"
          ${disabled}
        />
        <span class="state ok" part="valid-icon" aria-label="Valid" role="img">✓</span>
        <span class="state bad" part="invalid-icon" aria-label="Invalid" role="img">✕</span>
      </div>
    `;
    }
}
NptIbanField.observedAttributes = ["label", "value", "country", "placeholder", "disabled"];
/**
 * <npt-otp-input length="6" value="" [masked]></npt-otp-input>
 * N separate single-character boxes with auto-advance, backspace-rewind, and
 * paste-fill. Dispatches `input` on every change and `complete` (with
 * `{ value }`) once every box is filled.
 */
export class NptOtpInput extends NptElement {
    constructor() {
        super(...arguments);
        this.onFocus = (e) => {
            e.target.select?.();
        };
        this.onInput = (e) => {
            e.stopPropagation();
            const target = e.target;
            const digits = target.value.replace(/\D/g, "");
            target.value = digits.slice(-1);
            const boxes = this.boxes();
            const idx = boxes.indexOf(target);
            if (target.value && idx >= 0 && idx < boxes.length - 1) {
                boxes[idx + 1]?.focus();
            }
            this.emit();
        };
        this.onKey = (e) => {
            if (!(e instanceof KeyboardEvent))
                return;
            const target = e.target;
            const boxes = this.boxes();
            const idx = boxes.indexOf(target);
            if (idx < 0)
                return;
            if (e.key === "Backspace" && !target.value && idx > 0) {
                e.preventDefault();
                const prev = boxes[idx - 1];
                if (prev) {
                    prev.value = "";
                    prev.focus();
                    this.emit();
                }
            }
            else if (e.key === "ArrowLeft" && idx > 0) {
                e.preventDefault();
                boxes[idx - 1]?.focus();
            }
            else if (e.key === "ArrowRight" && idx < boxes.length - 1) {
                e.preventDefault();
                boxes[idx + 1]?.focus();
            }
        };
        this.onPaste = (e) => {
            if (!(e instanceof ClipboardEvent))
                return;
            e.preventDefault();
            const text = (e.clipboardData?.getData("text") ?? "").replace(/\D/g, "");
            if (!text)
                return;
            const boxes = this.boxes();
            for (let i = 0; i < boxes.length; i++) {
                const box = boxes[i];
                if (box)
                    box.value = text[i] ?? "";
            }
            const nextEmpty = boxes.find((b) => !b.value) ?? boxes[boxes.length - 1];
            nextEmpty?.focus();
            this.emit();
        };
    }
    attributeChangedCallback() {
        if (this.isConnected)
            this.update();
    }
    get inputType() {
        return "tel";
    }
    get isMasked() {
        return this.hasAttribute("masked");
    }
    get count() {
        const n = Number(this.getAttribute("length"));
        return Number.isFinite(n) && n > 0 ? Math.floor(n) : this.defaultLength;
    }
    get defaultLength() {
        return 6;
    }
    get value() {
        const boxes = this.root.querySelectorAll("input");
        if (boxes.length)
            return Array.from(boxes, (b) => b.value).join("");
        return (this.getAttribute("value") ?? "").replace(/\D/g, "").slice(0, this.count);
    }
    set value(v) {
        this.setAttribute("value", v);
    }
    connectedCallback() {
        super.connectedCallback();
        this.root.addEventListener("input", this.onInput);
        this.root.addEventListener("keydown", this.onKey);
        this.root.addEventListener("paste", this.onPaste);
        this.root.addEventListener("focus", this.onFocus, true);
    }
    disconnectedCallback() {
        this.root.removeEventListener("input", this.onInput);
        this.root.removeEventListener("keydown", this.onKey);
        this.root.removeEventListener("paste", this.onPaste);
        this.root.removeEventListener("focus", this.onFocus, true);
    }
    boxes() {
        return Array.from(this.root.querySelectorAll("input"));
    }
    emit() {
        const value = this.value;
        this.dispatchEvent(new CustomEvent("input", { bubbles: true, detail: { value } }));
        if (value.length === this.count) {
            this.dispatchEvent(new CustomEvent("complete", { bubbles: true, detail: { value } }));
        }
    }
    styles() {
        return css `
      ${A11Y}
      :host {
        display: block;
      }
      .group {
        display: flex;
        gap: var(--npt-space-2, 8px);
        direction: ltr;
      }
      input {
        inline-size: 48px;
        block-size: 56px;
        min-inline-size: 44px;
        box-sizing: border-box;
        text-align: center;
        border: 1px solid var(--md-sys-color-outline);
        border-radius: var(--npt-corner-sm, 12px);
        background: var(--md-sys-color-surface-container-lowest);
        color: var(--md-sys-color-on-surface);
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-headline, 24px);
        outline: none;
        transition: border-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          box-shadow var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      input:focus {
        border-color: var(--md-sys-color-primary);
        box-shadow: 0 0 0 1px var(--md-sys-color-primary);
      }
      :host([disabled]) input {
        opacity: 0.38;
      }
    `;
    }
    render() {
        const count = this.count;
        const masked = this.isMasked;
        const type = masked ? "password" : this.inputType;
        const value = (this.getAttribute("value") ?? "").replace(/\D/g, "").slice(0, count);
        const disabled = this.hasAttribute("disabled") ? "disabled" : "";
        let boxes = "";
        for (let i = 0; i < count; i++) {
            boxes += html `<input
        type="${type}"
        inputmode="numeric"
        autocomplete="${i === 0 ? "one-time-code" : "off"}"
        maxlength="1"
        value="${esc(value[i] ?? "")}"
        aria-label="Digit ${String(i + 1)} of ${String(count)}"
        ${disabled}
      />`;
        }
        return html `<div class="group" part="group" role="group" aria-label="Verification code">${boxes}</div>`;
    }
}
NptOtpInput.observedAttributes = ["length", "value", "masked", "disabled"];
/**
 * <npt-pin-input length="4"></npt-pin-input>
 * Like the OTP input, but always masked with dots. Defaults to 4 boxes.
 */
export class NptPinInput extends NptOtpInput {
    get defaultLength() {
        return 4;
    }
    get isMasked() {
        return true;
    }
}
NptPinInput.observedAttributes = ["length", "value", "disabled"];
/**
 * <npt-amount-keypad value=""></npt-amount-keypad>
 * Numeric keypad (0–9, ., backspace). Dispatches `key` (with the pressed key)
 * on each press and `value` (with the running string) after applying it.
 */
export class NptAmountKeypad extends NptElement {
    constructor() {
        super(...arguments);
        this.onClick = (e) => {
            if (this.hasAttribute("disabled"))
                return;
            const btn = e.target?.closest("button[data-key]");
            if (!btn)
                return;
            const key = btn.dataset["key"];
            if (!key)
                return;
            this.dispatchEvent(new CustomEvent("key", { bubbles: true, detail: { key } }));
            const next = this.apply(key);
            this.setAttribute("value", next);
            this.dispatchEvent(new CustomEvent("value", { bubbles: true, detail: { value: next } }));
        };
    }
    attributeChangedCallback() {
        if (this.isConnected)
            this.update();
    }
    get value() {
        return this.getAttribute("value") ?? "";
    }
    set value(v) {
        this.setAttribute("value", v);
    }
    connectedCallback() {
        super.connectedCallback();
        this.root.addEventListener("click", this.onClick);
    }
    disconnectedCallback() {
        this.root.removeEventListener("click", this.onClick);
    }
    apply(key) {
        const current = this.value;
        if (key === "back")
            return current.slice(0, -1);
        if (key === ".")
            return current.includes(".") ? current : current === "" ? "0." : current + ".";
        return current + key;
    }
    styles() {
        return css `
      ${A11Y}
      :host {
        display: block;
      }
      .pad {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: var(--npt-space-2, 8px);
      }
      button {
        min-height: 56px;
        border: none;
        border-radius: var(--npt-corner-md, 16px);
        background: var(--md-sys-color-surface-container-high);
        color: var(--md-sys-color-on-surface);
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-headline, 24px);
        cursor: pointer;
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      button:hover {
        background: var(--md-sys-color-surface-container-highest);
      }
      button:active {
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
      button.action {
        background: transparent;
        color: var(--md-sys-color-on-surface-variant);
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-title, 18px);
      }
      :host([disabled]) .pad {
        opacity: 0.38;
        pointer-events: none;
      }
    `;
    }
    render() {
        const keys = [
            { key: "1", label: "1", aria: "1" },
            { key: "2", label: "2", aria: "2" },
            { key: "3", label: "3", aria: "3" },
            { key: "4", label: "4", aria: "4" },
            { key: "5", label: "5", aria: "5" },
            { key: "6", label: "6", aria: "6" },
            { key: "7", label: "7", aria: "7" },
            { key: "8", label: "8", aria: "8" },
            { key: "9", label: "9", aria: "9" },
            { key: ".", label: ".", cls: "action", aria: "Decimal point" },
            { key: "0", label: "0", aria: "0" },
            { key: "back", label: "⌫", cls: "action", aria: "Backspace" },
        ];
        const disabled = this.hasAttribute("disabled") ? "disabled" : "";
        const buttons = keys
            .map((k) => html `<button
          type="button"
          class="${k.cls ?? ""}"
          data-key="${esc(k.key)}"
          aria-label="${esc(k.aria)}"
          ${disabled}
        >${esc(k.label)}</button>`)
            .join("");
        return html `<div class="pad" part="pad" role="group" aria-label="Numeric keypad">${buttons}</div>`;
    }
}
NptAmountKeypad.observedAttributes = ["value", "disabled"];
//# sourceMappingURL=money-inputs.js.map
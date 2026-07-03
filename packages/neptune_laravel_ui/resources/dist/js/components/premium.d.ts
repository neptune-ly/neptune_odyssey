import { NptElement } from "./base.js";
/**
 * <npt-dock> — a floating, glassy bottom navigation that wraps <npt-dock-item>
 * children. The active item lifts into a filled accent circle that rises above
 * the bar. Place it fixed at the bottom of your app shell.
 */
export declare class NptDock extends NptElement {
    protected styles(): string;
    protected render(): string;
}
/** <npt-dock-item label="Home" [active]>icon</npt-dock-item> */
export declare class NptDockItem extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onClick;
    protected styles(): string;
    protected render(): string;
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
export declare class NptOnboarding extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-cta arrow>Get started</npt-cta> — a large, premium call-to-action with a
 * slow specular sheen sweep and an arrow that nudges (both reduced-motion safe).
 * `variant="tonal"` for the secondary tone; `disabled` to disable.
 */
export declare class NptCta extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onClick;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=premium.d.ts.map
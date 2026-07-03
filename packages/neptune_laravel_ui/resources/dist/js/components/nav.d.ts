import { NptElement } from "./base.js";
/** <npt-app-bar title="Accounts"> …trailing slot… </npt-app-bar> */
export declare class NptAppBar extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-nav-bar> with <npt-nav-item> children (icon + label slots).
 * The mobile bottom navigation. Indicator uses secondary-container.
 */
export declare class NptNavBar extends NptElement {
    protected styles(): string;
    protected render(): string;
}
/** <npt-nav-item label="Home" [active]>icon-glyph</npt-nav-item> */
export declare class NptNavItem extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=nav.d.ts.map
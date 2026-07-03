import { NptElement } from "./base.js";
/**
 * <npt-nav-rail> with <npt-nav-item> children — the desktop/tablet side rail.
 * Vertical sibling of <npt-nav-bar>; reuses the same items.
 */
export declare class NptNavRail extends NptElement {
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-top-app-bar title="Accounts" variant="small|center|medium|large">
 *   …leading/trailing slots…
 * </npt-top-app-bar>
 * M3 top app bar. `medium`/`large` stack a larger headline below the action row.
 */
export declare class NptTopAppBar extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=nav-rail.d.ts.map
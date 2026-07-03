import { NptElement } from "./base.js";
/**
 * <npt-app-shell [rail]>
 *   <header slot="header">…</header>
 *   <npt-side-nav slot="nav">…</npt-side-nav>
 *   …content…
 * </npt-app-shell>
 * The application frame: a sticky `header` row, an inline-start `nav` sidebar
 * (collapses to a narrow rail via [rail]), and the default content region. The
 * nav hides under a compact breakpoint so the content takes the full width.
 */
export declare class NptAppShell extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-page-header title="Accounts" subtitle="All your balances">
 *   <npt-breadcrumbs slot="breadcrumb">…</npt-breadcrumbs>
 *   <npt-button slot="actions">New</npt-button>
 * </npt-page-header>
 * The page-level masthead. Display font; optional breadcrumb above, actions
 * inline-end of the title row, optional supporting subtitle below.
 */
export declare class NptPageHeader extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-section title="Recent activity" description="Last 30 days">…</npt-section>
 * A titled content section with an optional supporting description and a default
 * slot for the section body.
 */
export declare class NptSection extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-side-nav> with <npt-side-nav-item> children — the vertical sidebar nav.
 * Clicking an item activates it (sets [active] exclusively) and re-emits the
 * item's `select` event from the container.
 */
export declare class NptSideNav extends NptElement {
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onSelect;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-side-nav-item label="Dashboard" [active]>
 *   <span slot="icon">▦</span><npt-badge slot="leading">3</npt-badge>
 * </npt-side-nav-item>
 * One row of <npt-side-nav>. Emits `select` on activation. `icon` slots before
 * the label; `leading` slots inline-end (counts/badges).
 */
export declare class NptSideNavItem extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private activate;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-search-field placeholder="Search accounts" value=""></npt-search-field>
 * A search input with a leading magnifier and a clear control. Emits a `search`
 * event (detail.value) on input, lightly debounced, and on clear.
 */
export declare class NptSearchField extends NptElement {
    static observedAttributes: string[];
    private timer;
    attributeChangedCallback(): void;
    get value(): string;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private emit;
    private syncClear;
    private onInput;
    private onClick;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-toolbar>
 *   <…slot="start"></…><…slot="center"></…><…slot="end"></…>
 * </npt-toolbar>
 * A horizontal toolbar surface with start / center / end regions. `start` and
 * `end` mirror in RTL via logical layout; `center` stays centred.
 */
export declare class NptToolbar extends NptElement {
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=shell-layout.d.ts.map
import { NptElement } from "./base.js";
/** <npt-list> with <npt-list-item> children. */
export declare class NptList extends NptElement {
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-list-item [interactive] headline="Title" supporting="Sub">
 *   <span slot="leading">●</span><span slot="trailing">→</span>
 * </npt-list-item>
 */
export declare class NptListItem extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/** <npt-divider [inset]></npt-divider> */
export declare class NptDivider extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-tabs> with <npt-tab> children.
 * Click selects a tab (sets [active]); a sliding indicator follows.
 */
export declare class NptTabs extends NptElement {
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onClick;
    protected styles(): string;
    protected render(): string;
}
/** <npt-tab [active]>Overview</npt-tab> */
export declare class NptTab extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/** <npt-accordion> with <npt-accordion-item> children. */
export declare class NptAccordion extends NptElement {
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-accordion-item [open] summary="Section">…detail…</npt-accordion-item>
 * Native <details>/<summary> semantics under the hood.
 */
export declare class NptAccordionItem extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onToggle;
    protected styles(): string;
    protected render(): string;
}
/** <npt-avatar src="" initials="MK" size="sm|md|lg" label="Mona"></npt-avatar> */
export declare class NptAvatar extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=layout.d.ts.map
import { NptElement } from "./base.js";
/**
 * <npt-card variant="standard|elevated|tonal|glass"> … </npt-card>
 * Brand-shaped surface. `glass` is the optional translucent material — use only
 * on approved surfaces (nav, hero, auth, modals), never on tables/forms (docs/06 §3).
 */
export declare class NptCard extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=card.d.ts.map
import { NptElement } from "./base.js";
/**
 * <npt-data-table caption="Recent" sticky>… light-DOM <table> …</npt-data-table>
 * Or drive it from data:
 *   <npt-data-table columns='[{"key":"name","label":"Name"},{"key":"amt","label":"Amount","numeric":true}]'
 *                   rows='[{"name":"Coffee","amt":"4.50"}]'></npt-data-table>
 * Dense, sticky header, zebra rows via surface-container, row hover.
 */
export declare class NptDataTable extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-stat-card label="Revenue" value="48,210" unit="LYD" delta="+12.4%">
 *   <npt-sparkline slot="chart" points="3,5,4,7,8"></npt-sparkline>
 * </npt-stat-card>
 * A metric tile. `delta` colours by leading sign (+/−); slot `chart` for a spark.
 */
export declare class NptStatCard extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-sparkline points="3,5,4,7,8,6" label="7-day"></npt-sparkline>
 * Inline SVG line, no axes. Stroke = currentColor (inherits primary from host).
 */
export declare class NptSparkline extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-donut segments='[{"value":60,"role":"primary"},{"value":40,"role":"surface-container-highest"}]'
 *   thickness="14"><strong slot="center">60%</strong></npt-donut>
 * SVG ring. `role` on each segment maps to an allow-listed --md-sys-color-* role.
 */
export declare class NptDonut extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-limit-meter label="Card spend" value="82" amount="820 / 1,000 LYD" warn>
 * </npt-limit-meter>
 * Labelled progress meter (value 0–100). `warn` flips near-full to error colour.
 */
export declare class NptLimitMeter extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-trend value="+2.4%"></npt-trend>  ·  <npt-trend value="-1.1%" down></npt-trend>
 * Small up/down chip. `down` (or a leading − in value) uses error, else success.
 */
export declare class NptTrend extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=data-viz.d.ts.map
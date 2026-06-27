// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
// Neptune Odyssey — data visualisation
// <npt-data-table>, <npt-stat-card>, <npt-sparkline>, <npt-donut>,
// <npt-limit-meter>, <npt-trend>.
// Custom-property driven only; logical layout → mirrors in RTL. Money/metrics
// use tabular figures. SVG charts read currentColor / themed M3 roles only.
import { NptElement, css, html, A11Y } from "./base.js";

const esc = (v: string | null): string =>
  (v ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]!);

/** Parse a JSON attribute, returning the fallback on any malformed input. */
const parseJson = <T>(raw: string | null, fallback: T): T => {
  if (!raw) return fallback;
  try {
    return JSON.parse(raw) as T;
  } catch {
    return fallback;
  }
};

/** Parse a comma list of numbers, dropping anything non-finite. */
const parsePoints = (raw: string | null): number[] =>
  (raw ?? "")
    .split(",")
    .map((s) => Number(s.trim()))
    .filter((n) => Number.isFinite(n));

/**
 * Allow-listed M3 colour roles a chart segment may reference by name. Keeps
 * untrusted `role` strings from injecting arbitrary CSS into a var() call.
 */
const SEGMENT_ROLES = new Set([
  "primary",
  "secondary",
  "tertiary",
  "error",
  "success",
  "primary-container",
  "secondary-container",
  "tertiary-container",
  "surface-container-highest",
  "outline",
  "outline-variant",
]);

/** Map a segment role name to a themed M3 colour, or a neutral fallback. */
const roleColor = (role: unknown): string => {
  const name = typeof role === "string" && SEGMENT_ROLES.has(role) ? role : "outline-variant";
  return `var(--md-sys-color-${name})`;
};

interface Column {
  key: string;
  label?: string;
  numeric?: boolean;
}

interface Segment {
  value: number;
  role?: string;
}

/**
 * <npt-data-table caption="Recent" sticky>… light-DOM <table> …</npt-data-table>
 * Or drive it from data:
 *   <npt-data-table columns='[{"key":"name","label":"Name"},{"key":"amt","label":"Amount","numeric":true}]'
 *                   rows='[{"name":"Coffee","amt":"4.50"}]'></npt-data-table>
 * Dense, sticky header, zebra rows via surface-container, row hover.
 */
export class NptDataTable extends NptElement {
  static observedAttributes = ["columns", "rows", "caption", "sticky", "dense"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
        overflow: auto;
        border-radius: var(--npt-corner-md, 16px);
        background: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface);
      }
      .wrap {
        inline-size: 100%;
      }
      ::slotted(table),
      table.grid {
        inline-size: 100%;
        border-collapse: collapse;
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-body, 14px);
      }
      ::slotted(table) {
        color: var(--md-sys-color-on-surface);
      }
      table.grid caption,
      ::slotted(table) caption {
        text-align: start;
        font-weight: 600;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        color: var(--md-sys-color-on-surface);
      }
      table.grid th,
      table.grid td {
        text-align: start;
        padding-inline: var(--npt-space-4, 16px);
        padding-block: var(--npt-space-3, 12px);
        border-bottom: 1px solid var(--md-sys-color-outline-variant);
        white-space: nowrap;
      }
      :host([dense]) table.grid th,
      :host([dense]) table.grid td {
        padding-block: var(--npt-space-2, 8px);
      }
      table.grid thead th {
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
        color: var(--md-sys-color-on-surface-variant);
        background: var(--md-sys-color-surface-container);
      }
      :host([sticky]) table.grid thead th {
        position: sticky;
        inset-block-start: 0;
        z-index: 1;
      }
      table.grid tbody tr:nth-child(even) {
        background: var(--md-sys-color-surface-container-low);
      }
      table.grid tbody tr {
        transition: background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      table.grid tbody tr:hover {
        background: var(--md-sys-color-surface-container-high);
      }
      td.num,
      th.num {
        text-align: end;
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
      }
    `;
  }

  protected render(): string {
    const columns = parseJson<Column[]>(this.getAttribute("columns"), []);
    const rows = parseJson<Array<Record<string, unknown>>>(this.getAttribute("rows"), []);
    const caption = esc(this.getAttribute("caption"));

    // Light-DOM <table> mode: just project it and style ::slotted.
    if (columns.length === 0) {
      return html`<div class="wrap" part="wrap"><slot></slot></div>`;
    }

    const head = columns
      .map((c) => {
        const cls = c.numeric ? "num" : "";
        return html`<th class="${cls}" scope="col">${esc(c.label ?? c.key)}</th>`;
      })
      .join("");

    const body = rows
      .map((row) => {
        const cells = columns
          .map((c) => {
            const raw = row[c.key];
            const value = esc(raw == null ? "" : String(raw));
            const cls = c.numeric ? "num" : "";
            return html`<td class="${cls}">${value}</td>`;
          })
          .join("");
        return html`<tr>${cells}</tr>`;
      })
      .join("");

    return html`<div class="wrap" part="wrap">
      <table class="grid" part="table">
        ${caption ? html`<caption part="caption">${caption}</caption>` : ""}
        <thead><tr>${head}</tr></thead>
        <tbody>${body}</tbody>
      </table>
    </div>`;
  }
}

/**
 * <npt-stat-card label="Revenue" value="48,210" unit="LYD" delta="+12.4%">
 *   <npt-sparkline slot="chart" points="3,5,4,7,8"></npt-sparkline>
 * </npt-stat-card>
 * A metric tile. `delta` colours by leading sign (+/−); slot `chart` for a spark.
 */
export class NptStatCard extends NptElement {
  static observedAttributes = ["label", "value", "unit", "delta"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: block;
      }
      .tile {
        border-radius: var(--npt-corner-lg, 24px);
        padding: var(--npt-space-5, 20px);
        background: var(--md-sys-color-surface-container);
        color: var(--md-sys-color-on-surface);
        box-sizing: border-box;
        display: flex;
        flex-direction: column;
        gap: var(--npt-space-2, 8px);
      }
      .label {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        color: var(--md-sys-color-on-surface-variant);
        margin: 0;
      }
      .value {
        font-family: var(--npt-font-num);
        font-feature-settings: "tnum" 1;
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-headline, 28px);
        line-height: var(--npt-leading-headline, 36px);
        font-weight: 700;
        letter-spacing: var(--npt-display-tracking, -0.02em);
        margin: 0;
        display: flex;
        align-items: baseline;
        gap: var(--npt-space-2, 8px);
      }
      .unit {
        font-size: var(--npt-text-title, 18px);
        color: var(--md-sys-color-on-surface-variant);
      }
      .foot {
        display: flex;
        align-items: center;
        gap: var(--npt-space-3, 12px);
        margin-block-start: var(--npt-space-1, 4px);
      }
      .delta {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-label, 14px);
        font-weight: 600;
      }
      .delta.up {
        color: var(--md-sys-color-success);
      }
      .delta.down {
        color: var(--md-sys-color-error);
      }
      .chart {
        margin-inline-start: auto;
        display: inline-flex;
        color: var(--md-sys-color-primary);
        min-inline-size: 0;
      }
    `;
  }

  protected render(): string {
    const label = esc(this.getAttribute("label"));
    const value = esc(this.getAttribute("value"));
    const unit = esc(this.getAttribute("unit"));
    const delta = esc(this.getAttribute("delta"));
    const down = delta.trim().startsWith("-");
    const deltaCls = down ? "delta down" : "delta up";
    return html`<div class="tile" part="tile" role="group" aria-label="${label} ${value} ${unit}">
      ${label ? html`<p class="label">${label}</p>` : ""}
      <p class="value">${value}${unit ? html`<span class="unit">${unit}</span>` : ""}</p>
      <div class="foot">
        ${delta ? html`<span class="${deltaCls}" part="delta">${delta}</span>` : ""}
        <span class="chart"><slot name="chart"></slot></span>
      </div>
    </div>`;
  }
}

/**
 * <npt-sparkline points="3,5,4,7,8,6" label="7-day"></npt-sparkline>
 * Inline SVG line, no axes. Stroke = currentColor (inherits primary from host).
 */
export class NptSparkline extends NptElement {
  static observedAttributes = ["points", "label"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: inline-block;
        inline-size: var(--npt-sparkline-w, 88px);
        block-size: var(--npt-sparkline-h, 28px);
        color: var(--md-sys-color-primary);
      }
      svg {
        display: block;
        inline-size: 100%;
        block-size: 100%;
        overflow: visible;
      }
      .line {
        fill: none;
        stroke: currentColor;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        vector-effect: non-scaling-stroke;
      }
    `;
  }

  protected render(): string {
    const pts = parsePoints(this.getAttribute("points"));
    const label = esc(this.getAttribute("label")) || "sparkline";
    const w = 100;
    const h = 32;
    const pad = 2;
    if (pts.length < 2) {
      return html`<svg viewBox="0 0 ${w} ${h}" role="img" aria-label="${label}" preserveAspectRatio="none">
        <line class="line" x1="${pad}" y1="${h / 2}" x2="${w - pad}" y2="${h / 2}"></line>
      </svg>`;
    }
    const min = Math.min(...pts);
    const max = Math.max(...pts);
    const span = max - min || 1;
    const stepX = (w - pad * 2) / (pts.length - 1);
    const d = pts
      .map((v, i) => {
        const x = pad + i * stepX;
        const y = pad + (h - pad * 2) * (1 - (v - min) / span);
        return `${i === 0 ? "M" : "L"}${x.toFixed(2)} ${y.toFixed(2)}`;
      })
      .join(" ");
    return html`<svg viewBox="0 0 ${w} ${h}" role="img" aria-label="${label}" preserveAspectRatio="none">
      <path class="line" d="${d}"></path>
    </svg>`;
  }
}

/**
 * <npt-donut segments='[{"value":60,"role":"primary"},{"value":40,"role":"surface-container-highest"}]'
 *   thickness="14"><strong slot="center">60%</strong></npt-donut>
 * SVG ring. `role` on each segment maps to an allow-listed --md-sys-color-* role.
 */
export class NptDonut extends NptElement {
  static observedAttributes = ["segments", "thickness", "label"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: inline-block;
        inline-size: var(--npt-donut-size, 120px);
        block-size: var(--npt-donut-size, 120px);
        position: relative;
      }
      svg {
        display: block;
        inline-size: 100%;
        block-size: 100%;
        transform: rotate(-90deg);
      }
      circle {
        fill: none;
      }
      .track {
        stroke: var(--md-sys-color-surface-container-highest);
      }
      .center {
        position: absolute;
        inset: 0;
        display: grid;
        place-items: center;
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        color: var(--md-sys-color-on-surface);
        text-align: center;
      }
    `;
  }

  protected render(): string {
    const segments = parseJson<Segment[]>(this.getAttribute("segments"), []).filter(
      (s) => s && Number.isFinite(s.value) && s.value > 0,
    );
    const label = esc(this.getAttribute("label")) || "donut chart";
    const size = 42;
    const cx = size / 2;
    const r = 18;
    const circ = 2 * Math.PI * r;
    const thickness = Math.max(1, Number(this.getAttribute("thickness")) || 6);
    const total = segments.reduce((sum, s) => sum + s.value, 0) || 1;

    let offset = 0;
    const arcs = segments
      .map((s) => {
        const len = (s.value / total) * circ;
        const dash = `${len.toFixed(3)} ${(circ - len).toFixed(3)}`;
        const dashoffset = (-offset).toFixed(3);
        offset += len;
        return html`<circle
          cx="${cx}"
          cy="${cx}"
          r="${r}"
          stroke="${roleColor(s.role)}"
          stroke-width="${thickness}"
          stroke-dasharray="${dash}"
          stroke-dashoffset="${dashoffset}"
        ></circle>`;
      })
      .join("");

    return html`<svg viewBox="0 0 ${size} ${size}" role="img" aria-label="${label}">
        <circle class="track" cx="${cx}" cy="${cx}" r="${r}" stroke-width="${thickness}"></circle>
        ${arcs}
      </svg>
      <div class="center" part="center"><slot name="center"></slot></div>`;
  }
}

/**
 * <npt-limit-meter label="Card spend" value="82" amount="820 / 1,000 LYD" warn>
 * </npt-limit-meter>
 * Labelled progress meter (value 0–100). `warn` flips near-full to error colour.
 */
export class NptLimitMeter extends NptElement {
  static observedAttributes = ["value", "label", "amount", "warn"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      ${A11Y}
      :host {
        display: block;
      }
      .head {
        display: flex;
        align-items: baseline;
        justify-content: space-between;
        gap: var(--npt-space-3, 12px);
        margin-block-end: var(--npt-space-2, 8px);
      }
      .label {
        font-family: var(--npt-font-text);
        font-size: var(--npt-text-label, 14px);
        color: var(--md-sys-color-on-surface);
      }
      .amount {
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-label, 14px);
        color: var(--md-sys-color-on-surface-variant);
      }
      .track {
        block-size: 8px;
        inline-size: 100%;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-surface-container-highest);
        overflow: hidden;
      }
      .bar {
        block-size: 100%;
        border-radius: var(--npt-corner-full, 999px);
        background: var(--md-sys-color-primary);
        transition: inline-size var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease),
          background-color var(--npt-dur-fast, 200ms) var(--npt-ease-standard, ease);
      }
      :host([warn]) .bar.hot {
        background: var(--md-sys-color-error);
      }
    `;
  }

  protected render(): string {
    const value = Math.max(0, Math.min(100, Number(this.getAttribute("value") ?? 0)));
    const label = esc(this.getAttribute("label"));
    const amount = esc(this.getAttribute("amount"));
    const hot = this.hasAttribute("warn") && value >= 90 ? "bar hot" : "bar";
    return html`<div class="head">
        ${label ? html`<span class="label">${label}</span>` : ""}
        ${amount ? html`<span class="amount" part="amount">${amount}</span>` : ""}
      </div>
      <div
        class="track"
        part="track"
        role="meter"
        aria-label="${label || "limit"}"
        aria-valuenow="${value}"
        aria-valuemin="0"
        aria-valuemax="100"
      >
        <div class="${hot}" style="inline-size:${value}%"></div>
      </div>`;
  }
}

/**
 * <npt-trend value="+2.4%"></npt-trend>  ·  <npt-trend value="-1.1%" down></npt-trend>
 * Small up/down chip. `down` (or a leading − in value) uses error, else success.
 */
export class NptTrend extends NptElement {
  static observedAttributes = ["value", "down"];

  attributeChangedCallback(): void {
    if (this.isConnected) this.update();
  }

  protected styles(): string {
    return css`
      :host {
        display: inline-flex;
      }
      .chip {
        display: inline-flex;
        align-items: center;
        gap: var(--npt-space-1, 4px);
        padding-inline: var(--npt-space-2, 8px);
        padding-block: 2px;
        border-radius: var(--npt-corner-full, 999px);
        font-family: var(--npt-font-num);
        font-variant-numeric: tabular-nums;
        font-size: var(--npt-text-caption, 12px);
        font-weight: 600;
        line-height: var(--npt-leading-caption, 16px);
        background: var(--md-sys-color-secondary-container);
        color: var(--md-sys-color-on-secondary-container);
      }
      .chip.up {
        color: var(--md-sys-color-success);
      }
      .chip.down {
        color: var(--md-sys-color-error);
      }
      .arrow {
        font-size: var(--npt-text-label, 14px);
        line-height: 1;
      }
    `;
  }

  protected render(): string {
    const value = esc(this.getAttribute("value"));
    const down = this.hasAttribute("down") || value.trim().startsWith("-");
    const cls = down ? "chip down" : "chip up";
    const arrow = down ? "↓" : "↑";
    return html`<span class="${cls}" part="chip" role="status">
      <span class="arrow" aria-hidden="true">${arrow}</span>${value}
    </span>`;
  }
}

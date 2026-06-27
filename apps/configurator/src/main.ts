// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Neptune Odyssey theme configurator — client-only. Pick theme inputs, see a live
// banking preview re-skin, and copy a NO1- brandprint that reproduces the exact
// theme in any Odyssey library. No backend: encode/decode are pure client-side.

import {
  BRAND_CONFIG,
  encode,
  decode,
  buildTheme,
  oklchToHex,
  FONTS,
  LOGIN,
  HERO,
  TONE,
  GLASS,
  MOTION,
  type BrandprintConfig,
} from "@neptune-odyssey/tokens";
import {
  applyTheme,
  registerAll,
  type ModeOption,
  type DirOption,
} from "@neptune-odyssey/web-ui";
import "@neptune-odyssey/web-ui/styles.css";

import "./styles.css";
import { evaluateContrast } from "./contrast.js";

registerAll();

type Brand = "neptune" | "andalus" | "nuran" | "fglb";
const BRANDS: Brand[] = ["neptune", "andalus", "nuran", "fglb"];
const CORNER_KEYS = ["xs", "sm", "md", "lg", "xl", "xxl"] as const;

interface AppState {
  config: BrandprintConfig;
  mode: ModeOption;
  dir: DirOption;
}

/** Deep-clone a brandprint config so editing controls never mutate BRAND_CONFIG. */
function cloneConfig(c: BrandprintConfig): BrandprintConfig {
  return {
    primary: { ...c.primary },
    tertiary: { ...c.tertiary },
    corners: { ...c.corners },
    displayWeight: c.displayWeight,
    displayTracking: c.displayTracking,
    fonts: { ...c.fonts },
    loginShell: c.loginShell,
    dashboardHero: c.dashboardHero,
    contentTone: c.contentTone,
    glassTint: c.glassTint,
    motion: c.motion,
    defaultDark: c.defaultDark,
    defaultRtl: c.defaultRtl,
  };
}

const state: AppState = {
  config: cloneConfig(BRAND_CONFIG.neptune!),
  mode: "light",
  dir: "ltr",
};

// ── DOM helpers ────────────────────────────────────────────────────────────
function el<K extends keyof HTMLElementTagNameMap>(
  tag: K,
  attrs?: Record<string, string>,
  children?: (Node | string)[],
): HTMLElementTagNameMap[K];
function el(
  tag: string,
  attrs?: Record<string, string>,
  children?: (Node | string)[],
): HTMLElement;
function el(
  tag: string,
  attrs: Record<string, string> = {},
  children: (Node | string)[] = [],
): HTMLElement {
  const node = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === "class") node.className = v;
    else node.setAttribute(k, v);
  }
  for (const c of children) node.append(c);
  return node;
}

function option(value: string, label = value): HTMLOptionElement {
  const o = document.createElement("option");
  o.value = value;
  o.textContent = label;
  return o;
}

function selectFrom(
  values: readonly string[],
  current: string,
  onChange: (v: string) => void,
): HTMLSelectElement {
  const sel = el("select");
  for (const v of values) sel.append(option(v));
  sel.value = current;
  sel.addEventListener("change", () => onChange(sel.value));
  return sel;
}

function field(label: string, control: HTMLElement): HTMLElement {
  return el("div", { class: "field" }, [
    el("label", {}, [label]),
    control,
  ]);
}

// ── Seed (OKLCH) editor ─────────────────────────────────────────────────────
interface SeedRefs {
  swatch: HTMLElement;
  redraw: () => void;
}

function seedEditor(which: "primary" | "tertiary"): { node: HTMLElement; refs: SeedRefs } {
  const swatch = el("div", { class: "seed__swatch", "aria-hidden": "true" });
  const sliders = el("div", { class: "seed__sliders" });

  const channels: { key: "L" | "C" | "H"; min: number; max: number; step: number }[] = [
    { key: "L", min: 0, max: 1, step: 0.01 },
    { key: "C", min: 0, max: 0.4, step: 0.005 },
    { key: "H", min: 0, max: 360, step: 1 },
  ];

  const outputs: Record<string, HTMLOutputElement> = {};
  const inputs: Record<string, HTMLInputElement> = {};

  const redraw = () => {
    const seed = state.config[which];
    swatch.style.background = oklchToHex(seed);
    for (const { key } of channels) {
      inputs[key]!.value = String(seed[key]);
      outputs[key]!.textContent =
        key === "H" ? String(Math.round(seed[key])) : seed[key].toFixed(key === "L" ? 2 : 3);
    }
  };

  for (const ch of channels) {
    const input = el("input", {
      type: "range",
      min: String(ch.min),
      max: String(ch.max),
      step: String(ch.step),
      "aria-label": `${which} ${ch.key}`,
    });
    const out = el("output");
    input.addEventListener("input", () => {
      state.config[which][ch.key] = Number(input.value);
      out.textContent =
        ch.key === "H"
          ? String(Math.round(Number(input.value)))
          : Number(input.value).toFixed(ch.key === "L" ? 2 : 3);
      swatch.style.background = oklchToHex(state.config[which]);
      update();
    });
    inputs[ch.key] = input;
    outputs[ch.key] = out;
    sliders.append(
      el("div", { class: "slider" }, [
        el("span", { class: "slider__key" }, [ch.key]),
        input,
        out,
      ]),
    );
  }

  const node = el("div", { class: "seed" }, [swatch, sliders]);
  redraw();
  return { node, refs: { swatch, redraw } };
}

// ── Control panel ───────────────────────────────────────────────────────────
const primarySeed = seedEditor("primary");
const tertiarySeed = seedEditor("tertiary");

// references that need repopulating after a brand load / paste
const repopulators: (() => void)[] = [primarySeed.refs.redraw, tertiarySeed.refs.redraw];

function buildControls(): HTMLElement {
  const panel = el("div", { class: "panel panel--controls" });

  // Reference brand
  const brandSel = selectFrom(BRANDS, "neptune", (v) => {
    state.config = cloneConfig(BRAND_CONFIG[v]!);
    state.mode = state.config.defaultDark ? "dark" : "light";
    state.dir = state.config.defaultRtl ? "rtl" : "ltr";
    repopulateAll();
    update();
  });
  brandSel.id = "brand-select";
  panel.append(
    group(
      "Reference brand",
      true,
      field("Start from", brandSel),
    ),
  );

  // Seeds
  panel.append(
    group(
      "Colour seeds (OKLCH)",
      true,
      el("div", { class: "field" }, [el("span", { class: "field__label" }, ["Primary seed"]), primarySeed.node]),
      el("div", { class: "field" }, [el("span", { class: "field__label" }, ["Tertiary seed"]), tertiarySeed.node]),
    ),
  );

  // Corners
  const cornerInputs: Record<string, HTMLInputElement> = {};
  const cornerGrid = el("div", { class: "grid-3" });
  for (const k of CORNER_KEYS) {
    const input = el("input", { type: "number", min: "0", max: "255", step: "1" });
    input.addEventListener("input", () => {
      state.config.corners[k] = clampInt(Number(input.value), 0, 255);
      update();
    });
    cornerInputs[k] = input;
    cornerGrid.append(field(k, input));
  }
  repopulators.push(() => {
    for (const k of CORNER_KEYS) cornerInputs[k]!.value = String(state.config.corners[k]);
  });
  panel.append(group("Corner family (px)", false, cornerGrid));

  // Fonts
  const fontGrid = el("div", { class: "grid-3" });
  const fontSels: Record<"display" | "text" | "num", HTMLSelectElement> = {
    display: selectFrom(FONTS, state.config.fonts.display, (v) => {
      state.config.fonts.display = v as BrandprintConfig["fonts"]["display"];
      update();
    }),
    text: selectFrom(FONTS, state.config.fonts.text, (v) => {
      state.config.fonts.text = v as BrandprintConfig["fonts"]["text"];
      update();
    }),
    num: selectFrom(FONTS, state.config.fonts.num, (v) => {
      state.config.fonts.num = v as BrandprintConfig["fonts"]["num"];
      update();
    }),
  };
  fontGrid.append(field("Display", fontSels.display), field("Text", fontSels.text), field("Numerals", fontSels.num));
  repopulators.push(() => {
    fontSels.display.value = state.config.fonts.display;
    fontSels.text.value = state.config.fonts.text;
    fontSels.num.value = state.config.fonts.num;
  });

  // Type expression
  const weightInput = el("input", { type: "range", min: "100", max: "900", step: "100", "aria-label": "Display weight" });
  const weightOut = el("output");
  weightInput.addEventListener("input", () => {
    state.config.displayWeight = Number(weightInput.value);
    weightOut.textContent = weightInput.value;
    update();
  });
  const trackInput = el("input", { type: "range", min: "-0.05", max: "0.05", step: "0.005", "aria-label": "Display tracking" });
  const trackOut = el("output");
  trackInput.addEventListener("input", () => {
    state.config.displayTracking = Number(trackInput.value);
    trackOut.textContent = `${Number(trackInput.value).toFixed(3)}em`;
    update();
  });
  repopulators.push(() => {
    weightInput.value = String(state.config.displayWeight);
    weightOut.textContent = String(state.config.displayWeight);
    trackInput.value = String(state.config.displayTracking);
    trackOut.textContent = `${state.config.displayTracking.toFixed(3)}em`;
  });

  panel.append(
    group(
      "Typography",
      false,
      fontGrid,
      el("div", { class: "field" }, [
        el("span", { class: "field__label" }, ["Display weight"]),
        el("div", { class: "field__row" }, [weightInput, weightOut]),
      ]),
      el("div", { class: "field" }, [
        el("span", { class: "field__label" }, ["Display tracking"]),
        el("div", { class: "field__row" }, [trackInput, trackOut]),
      ]),
    ),
  );

  // Levers
  const leverGrid = el("div", { class: "grid-2" });
  const leverDefs: { key: keyof BrandprintConfig; label: string; values: readonly string[] }[] = [
    { key: "loginShell", label: "Login shell", values: LOGIN },
    { key: "dashboardHero", label: "Dashboard hero", values: HERO },
    { key: "contentTone", label: "Content tone", values: TONE },
    { key: "glassTint", label: "Glass tint", values: GLASS },
    { key: "motion", label: "Motion", values: MOTION },
  ];
  const leverSels: Partial<Record<keyof BrandprintConfig, HTMLSelectElement>> = {};
  for (const def of leverDefs) {
    const sel = selectFrom(def.values, String(state.config[def.key]), (v) => {
      (state.config[def.key] as unknown) = v;
      update();
    });
    leverSels[def.key] = sel;
    leverGrid.append(field(def.label, sel));
  }
  repopulators.push(() => {
    for (const def of leverDefs) leverSels[def.key]!.value = String(state.config[def.key]);
  });
  panel.append(group("Expression levers", false, leverGrid));

  // Mode / direction
  const modeSeg = segmented(
    "Mode",
    ["light", "dark", "system"],
    () => state.mode,
    (v) => {
      state.mode = v as ModeOption;
      update();
    },
  );
  const dirSeg = segmented(
    "Direction",
    ["ltr", "rtl", "auto"],
    () => state.dir,
    (v) => {
      state.dir = v as DirOption;
      update();
    },
  );
  repopulators.push(() => {
    modeSeg.sync();
    dirSeg.sync();
  });

  // Flags
  const darkChk = el("input", { type: "checkbox", id: "flag-dark" });
  darkChk.addEventListener("change", () => {
    state.config.defaultDark = darkChk.checked;
    update();
  });
  const rtlChk = el("input", { type: "checkbox", id: "flag-rtl" });
  rtlChk.addEventListener("change", () => {
    state.config.defaultRtl = rtlChk.checked;
    update();
  });
  repopulators.push(() => {
    darkChk.checked = state.config.defaultDark;
    rtlChk.checked = state.config.defaultRtl;
  });

  panel.append(
    group(
      "Mode, direction & baked flags",
      true,
      modeSeg.node,
      dirSeg.node,
      el("div", { class: "toggles" }, [
        el("label", { class: "toggle", for: "flag-dark" }, [darkChk, "defaultDark"]),
        el("label", { class: "toggle", for: "flag-rtl" }, [rtlChk, "defaultRtl"]),
      ]),
    ),
  );

  return panel;
}

function group(title: string, open: boolean, ...body: HTMLElement[]): HTMLElement {
  const d = el("details", { class: "group" });
  if (open) d.setAttribute("open", "");
  d.append(el("summary", {}, [title]));
  d.append(el("div", { class: "group__body" }, body));
  return d;
}

function segmented(
  label: string,
  values: string[],
  get: () => string,
  set: (v: string) => void,
): { node: HTMLElement; sync: () => void } {
  const seg = el("div", { class: "segmented", role: "group", "aria-label": label });
  const buttons: HTMLButtonElement[] = [];
  for (const v of values) {
    const b = el("button", { type: "button" }, [v]);
    b.addEventListener("click", () => {
      set(v);
      sync();
    });
    buttons.push(b);
    seg.append(b);
  }
  const sync = () => {
    const cur = get();
    buttons.forEach((b, i) => b.setAttribute("aria-pressed", String(values[i] === cur)));
  };
  sync();
  return {
    node: el("div", { class: "field" }, [el("span", { class: "field__label" }, [label]), seg]),
    sync,
  };
}

function repopulateAll(): void {
  const brandSel = document.getElementById("brand-select") as HTMLSelectElement | null;
  for (const r of repopulators) r();
  // Keep the brand dropdown reflecting whatever was loaded; default keeps its value.
  if (brandSel) {
    // no-op: brand select is the source for loads; leave as-is.
  }
}

function clampInt(n: number, lo: number, hi: number): number {
  if (Number.isNaN(n)) return lo;
  return Math.max(lo, Math.min(hi, Math.round(n)));
}

// ── Brandprint output / paste ───────────────────────────────────────────────
let brandprintStringEl: HTMLElement;
let copyStatusEl: HTMLElement;
let pasteInput: HTMLInputElement;
let pasteErrorEl: HTMLElement;

function buildBrandprintPanel(): HTMLElement {
  brandprintStringEl = el("div", {
    class: "brandprint__string",
    role: "textbox",
    "aria-readonly": "true",
    "aria-label": "Current brandprint",
  });

  const copyBtn = el("button", { class: "btn", type: "button" }, ["Copy"]);
  copyStatusEl = el("span", { class: "ok-text", role: "status", "aria-live": "polite" });
  copyBtn.addEventListener("click", async () => {
    const text = brandprintStringEl.textContent ?? "";
    try {
      await navigator.clipboard.writeText(text);
      copyStatusEl.textContent = "Copied ✓";
    } catch {
      // Fallback: select for manual copy.
      const range = document.createRange();
      range.selectNodeContents(brandprintStringEl);
      const sel = window.getSelection();
      sel?.removeAllRanges();
      sel?.addRange(range);
      copyStatusEl.textContent = "Selected — press ⌘/Ctrl+C";
    }
    window.setTimeout(() => (copyStatusEl.textContent = ""), 2200);
  });

  pasteInput = el("input", {
    type: "text",
    placeholder: "Paste a NO1-… brandprint to load",
    "aria-label": "Paste a brandprint to load",
    spellcheck: "false",
    autocapitalize: "off",
    autocomplete: "off",
  });
  const loadBtn = el("button", { class: "btn btn--ghost", type: "button" }, ["Load"]);
  pasteErrorEl = el("p", { class: "error-text", role: "alert", "aria-live": "assertive" });
  const doLoad = () => loadBrandprint(pasteInput.value.trim());
  loadBtn.addEventListener("click", doLoad);
  pasteInput.addEventListener("keydown", (e) => {
    if ((e as KeyboardEvent).key === "Enter") doLoad();
  });

  return el("div", { class: "panel" }, [
    el("h2", { class: "preview__section-title" }, ["Brandprint"]),
    brandprintStringEl,
    el("div", { class: "row" }, [copyBtn, copyStatusEl]),
    el("div", { class: "field" }, [
      el("span", { class: "field__label" }, ["Load from string"]),
      el("div", { class: "row" }, [pasteInput, loadBtn]),
      pasteErrorEl,
    ]),
  ]);
}

function loadBrandprint(str: string): void {
  pasteErrorEl.textContent = "";
  if (!str) {
    pasteErrorEl.textContent = "Enter a NO1-… brandprint.";
    return;
  }
  try {
    const decoded = decode(str);
    // decoded includes a `version` field; strip it back to a BrandprintConfig.
    const { version: _v, ...cfg } = decoded;
    void _v;
    state.config = cloneConfig(cfg);
    state.mode = cfg.defaultDark ? "dark" : "light";
    state.dir = cfg.defaultRtl ? "rtl" : "ltr";
    repopulateAll();
    update();
    // Round-trip sanity: a valid brandprint must re-encode to the SAME canonical string.
    const reencoded = encode(state.config);
    if (reencoded !== str) {
      pasteErrorEl.classList.remove("error-text");
      pasteErrorEl.classList.add("ok-text");
      pasteErrorEl.textContent = `Loaded (canonical form: ${reencoded})`;
    } else {
      pasteErrorEl.classList.remove("error-text");
      pasteErrorEl.classList.add("ok-text");
      pasteErrorEl.textContent = "Loaded ✓";
    }
    window.setTimeout(() => {
      pasteErrorEl.textContent = "";
      pasteErrorEl.classList.remove("ok-text");
      pasteErrorEl.classList.add("error-text");
    }, 2600);
  } catch (err) {
    pasteErrorEl.classList.remove("ok-text");
    pasteErrorEl.classList.add("error-text");
    pasteErrorEl.textContent = `Invalid brandprint: ${(err as Error).message}`;
  }
}

// ── Live preview ────────────────────────────────────────────────────────────
let previewRoot: HTMLElement;

function buildPreview(): HTMLElement {
  previewRoot = el("div", { class: "preview" });
  const frame = el("div", { class: "preview-frame" }, [previewRoot]);
  return el("div", { class: "panel panel--preview" }, [
    el("h2", { class: "preview__section-title" }, ["Live preview"]),
    frame,
    buildContrastPanel(),
  ]);
}

function renderPreview(): void {
  previewRoot.textContent = "";

  const appBar = el("npt-app-bar", { title: "Accounts" });
  appBar.append(el("npt-badge", { tone: "neutral", slot: "trailing" }, ["LYD"]));

  const balance = el("npt-balance-card", {
    label: "Available balance",
    amount: "12,480.50",
    currency: "LYD",
    account: "•••• 4821",
    hero: "",
  });

  const quick = el("div", { class: "preview__quick" }, [
    btn("Send", "filled"),
    btn("Request", "tonal"),
    btn("Top up", "outlined"),
  ]);

  const chips = el("div", { class: "preview__quick" }, [
    chip("All", true),
    chip("Income"),
    chip("Spending"),
  ]);

  const txns = el("div", { class: "preview__list" });
  const data: [string, string, string, boolean][] = [
    ["Salary — Andalus Bank", "Today · Transfer", "+3,200.00", true],
    ["Tazweed Market", "Today · Card", "-46.25", false],
    ["Almadar Top-up", "Yesterday · Bill", "-30.00", false],
    ["Refund — Souq", "Mon · Card", "+18.90", true],
  ];
  for (const [title, subtitle, amount, credit] of data) {
    const row = el("npt-transaction-row", { title, subtitle, amount, currency: "LYD" });
    if (credit) row.setAttribute("credit", "");
    txns.append(row);
  }

  const tf = el("npt-text-field", {
    label: "Send to IBAN",
    placeholder: "LY.. .... .... ....",
  });

  const nav = el("npt-nav-bar");
  for (const [label, glyph, active] of [
    ["Home", "⌂", true],
    ["Cards", "▭", false],
    ["Pay", "↗", false],
    ["More", "⋯", false],
  ] as const) {
    const item = el("npt-nav-item", { label }, [glyph]);
    if (active) item.setAttribute("active", "");
    nav.append(item);
  }

  const scroll = el("div", { class: "preview__scroll" }, [
    balance,
    quick,
    el("p", { class: "preview__section-title" }, ["Activity"]),
    chips,
    txns,
    el("p", { class: "preview__section-title" }, ["Quick transfer"]),
    tf,
  ]);

  previewRoot.append(appBar, scroll, nav);
}

function btn(label: string, variant: string): HTMLElement {
  return el("npt-button", { variant }, [label]);
}
function chip(label: string, selected = false): HTMLElement {
  const c = el("npt-chip", {}, [label]);
  if (selected) c.setAttribute("selected", "");
  return c;
}

// ── Contrast (AA) report ────────────────────────────────────────────────────
let contrastBodyEl: HTMLElement;
let contrastWarnEl: HTMLElement;

function buildContrastPanel(): HTMLElement {
  contrastWarnEl = el("div", { class: "contrast__warn", role: "status", "aria-live": "polite" });
  contrastBodyEl = el("div", { class: "contrast" });
  return el("div", { class: "panel" }, [
    el("h2", { class: "preview__section-title" }, ["AA contrast (resolved palette)"]),
    contrastWarnEl,
    contrastBodyEl,
  ]);
}

function renderContrast(): void {
  // Resolve in the mode actually shown (system → use the painted root's mode).
  const resolvedMode = (previewRoot.dataset.mode as "light" | "dark") || "light";
  const colors = buildTheme(state.config, { mode: resolvedMode }).colors;
  const results = evaluateContrast(colors as unknown as Record<string, string>);

  const anyFail = results.some((r) => !r.pass);
  contrastWarnEl.classList.toggle("contrast__warn--ok", !anyFail);
  contrastWarnEl.textContent = anyFail
    ? "⚠ One or more pairs fail WCAG AA — adjust your seeds for legible contrast."
    : "✓ All key pairs pass WCAG AA at the current seeds.";

  contrastBodyEl.textContent = "";
  for (const r of results) {
    contrastBodyEl.append(
      el("div", { class: "contrast__row" }, [
        el("span", {}, [`${r.label}`]),
        el("span", {}, [`${r.ratio.toFixed(2)}:1 (≥${r.threshold})`]),
        el("span", { class: `badge ${r.pass ? "badge--pass" : "badge--fail"}` }, [
          r.pass ? "PASS" : "FAIL",
        ]),
      ]),
    );
  }
}

// ── Update cycle ────────────────────────────────────────────────────────────
function update(): void {
  // 1. Re-skin the preview root from the live config.
  applyTheme(previewRoot, state.config, { mode: state.mode, dir: state.dir });
  // 2. Re-render preview markup (so direction/structure refreshes).
  renderPreview();
  // 3. Brandprint string.
  brandprintStringEl.textContent = encode(state.config);
  // 4. Contrast report.
  renderContrast();
}

// ── Bootstrap ───────────────────────────────────────────────────────────────
function main(): void {
  const app = el("div", { class: "app" });

  const logo = el("a", { class: "app__logo", href: "../", "aria-label": "Neptune Odyssey home" }, [
    el("span", { class: "app__logo-word" }, ["Neptune"]),
    el("span", { class: "app__logo-dot" }, []),
  ]);
  app.append(
    el("header", { class: "app__header" }, [
      logo,
      el("div", { class: "app__title" }, [
        el("h1", {}, ["Theme Configurator"]),
        el("p", {}, ["Pick inputs, preview live, copy a brandprint that rebuilds it anywhere."]),
      ]),
      el("a", { class: "app__back", href: "../" }, ["← Back to the design system"]),
    ]),
  );

  // Left column: controls + brandprint. Right column (sticky): the live preview.
  const controls = buildControls();
  const brandprint = buildBrandprintPanel();
  const preview = buildPreview();
  app.append(
    el("div", { class: "col col--left" }, [controls, brandprint]),
    el("div", { class: "col col--right" }, [preview]),
  );

  document.getElementById("app")!.append(app);

  // First paint.
  renderPreview();
  update();
}

main();

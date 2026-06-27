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
} from "@neptune.fintech/tokens";
import {
  applyTheme,
  registerAll,
  type ModeOption,
  type DirOption,
} from "@neptune.fintech/web-ui";
import "@neptune.fintech/web-ui/styles.css";

import "./styles.css";
import { evaluateContrast } from "./contrast.js";
import { srgbToOklch } from "./oklch-inverse.js";

registerAll();

type Brand = "neptune" | "triton" | "nereid" | "proteus";
const BRANDS: Brand[] = ["neptune", "triton", "nereid", "proteus"];
const BRAND_LABELS: Record<Brand, string> = {
  neptune: "Neptune",
  triton: "Triton",
  nereid: "Nereid",
  proteus: "Proteus",
};
const CORNER_KEYS = ["xs", "sm", "md", "lg", "xl", "xxl"] as const;

type PreviewScreen = "retail" | "wallet" | "cards";

interface AppState {
  config: BrandprintConfig;
  mode: ModeOption;
  dir: DirOption;
  activeBrand: Brand | null;
  screen: PreviewScreen;
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
  activeBrand: "neptune",
  screen: "retail",
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

/**
 * Wire a button so that clicking it copies `getText()` to the clipboard and
 * flashes a transient "Copied ✓" confirmation in `status`. Reused by every
 * copy affordance (brandprint + each snippet).
 */
function wireCopy(button: HTMLElement, status: HTMLElement, getText: () => string): void {
  button.addEventListener("click", async () => {
    const text = getText();
    try {
      await navigator.clipboard.writeText(text);
      status.textContent = "Copied ✓";
      status.classList.add("copied-flash");
    } catch {
      status.textContent = "Press ⌘/Ctrl+C";
    }
    window.setTimeout(() => {
      status.textContent = "";
      status.classList.remove("copied-flash");
    }, 1800);
  });
}

// ── Seed (OKLCH) editor with two-way colour picker ──────────────────────────
interface SeedRefs {
  swatch: HTMLElement;
  redraw: () => void;
}

function seedEditor(which: "primary" | "tertiary"): { node: HTMLElement; refs: SeedRefs } {
  const colorInput = el("input", {
    type: "color",
    class: "seed__picker",
    "aria-label": `${which} colour picker`,
  }) as HTMLInputElement;
  const swatch = el("label", { class: "seed__swatch" }, [colorInput]);
  const sliders = el("div", { class: "seed__sliders" });

  const channels: { key: "L" | "C" | "H"; min: number; max: number; step: number }[] = [
    { key: "L", min: 0, max: 1, step: 0.01 },
    { key: "C", min: 0, max: 0.4, step: 0.005 },
    { key: "H", min: 0, max: 360, step: 1 },
  ];

  const outputs: Record<string, HTMLOutputElement> = {};
  const inputs: Record<string, HTMLInputElement> = {};

  const fmt = (key: "L" | "C" | "H", v: number) =>
    key === "H" ? String(Math.round(v)) : v.toFixed(key === "L" ? 2 : 3);

  const redraw = () => {
    const seed = state.config[which];
    const hex = oklchToHex(seed);
    swatch.style.background = hex;
    colorInput.value = hex;
    for (const { key } of channels) {
      inputs[key]!.value = String(seed[key]);
      outputs[key]!.textContent = fmt(key, seed[key]);
    }
  };

  // Colour picker → seed (hex → OKLCH), moves the sliders.
  colorInput.addEventListener("input", () => {
    const o = srgbToOklch(colorInput.value);
    state.config[which] = { L: o.L, C: o.C, H: o.H };
    state.activeBrand = null;
    redraw();
    update();
  });

  for (const ch of channels) {
    const input = el("input", {
      type: "range",
      min: String(ch.min),
      max: String(ch.max),
      step: String(ch.step),
      "aria-label": `${which} ${ch.key}`,
    }) as HTMLInputElement;
    const out = el("output") as HTMLOutputElement;
    input.addEventListener("input", () => {
      const v = Number(input.value);
      state.config[which][ch.key] = v;
      out.textContent = fmt(ch.key, v);
      // Slider → colour picker (OKLCH → hex), two-way sync.
      const hex = oklchToHex(state.config[which]);
      swatch.style.background = hex;
      colorInput.value = hex;
      state.activeBrand = null;
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

let brandChipsEl: HTMLElement;

/** Load a reference brand into state and refresh every control. */
function loadBrand(b: Brand): void {
  state.config = cloneConfig(BRAND_CONFIG[b]!);
  state.mode = state.config.defaultDark ? "dark" : "light";
  state.dir = state.config.defaultRtl ? "rtl" : "ltr";
  state.activeBrand = b;
  repopulateAll();
  update();
}

function buildBrandChips(): HTMLElement {
  brandChipsEl = el("div", { class: "brand-chips", role: "group", "aria-label": "Brand presets" });
  for (const b of BRANDS) {
    const dot = el("span", { class: "brand-chip__dot", "aria-hidden": "true" });
    dot.style.background = oklchToHex(BRAND_CONFIG[b]!.primary);
    const chip = el("button", {
      type: "button",
      class: "brand-chip",
      "data-brand": b,
    }, [dot, BRAND_LABELS[b]]);
    chip.addEventListener("click", () => loadBrand(b));
    brandChipsEl.append(chip);
  }
  return brandChipsEl;
}

function syncBrandChips(): void {
  if (!brandChipsEl) return;
  for (const chip of Array.from(brandChipsEl.children) as HTMLElement[]) {
    const isActive = chip.dataset.brand === state.activeBrand;
    chip.setAttribute("aria-pressed", String(isActive));
  }
}
repopulators.push(syncBrandChips);

function buildControls(): HTMLElement {
  const panel = el("div", { class: "panel panel--controls" });

  // Brand preset chips + randomize at the very top.
  const randomizeBtn = el("button", { type: "button", class: "btn btn--surprise" }, ["🎲 Surprise me"]);
  randomizeBtn.addEventListener("click", randomize);
  panel.append(
    el("div", { class: "controls__top" }, [
      buildBrandChips(),
      randomizeBtn,
    ]),
  );

  // Seeds + colour pickers
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
    const input = el("input", { type: "number", min: "0", max: "255", step: "1" }) as HTMLInputElement;
    input.addEventListener("input", () => {
      state.config.corners[k] = clampInt(Number(input.value), 0, 255);
      state.activeBrand = null;
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
      state.activeBrand = null;
      update();
    }),
    text: selectFrom(FONTS, state.config.fonts.text, (v) => {
      state.config.fonts.text = v as BrandprintConfig["fonts"]["text"];
      state.activeBrand = null;
      update();
    }),
    num: selectFrom(FONTS, state.config.fonts.num, (v) => {
      state.config.fonts.num = v as BrandprintConfig["fonts"]["num"];
      state.activeBrand = null;
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
  const weightInput = el("input", { type: "range", min: "100", max: "900", step: "100", "aria-label": "Display weight" }) as HTMLInputElement;
  const weightOut = el("output");
  weightInput.addEventListener("input", () => {
    state.config.displayWeight = Number(weightInput.value);
    weightOut.textContent = weightInput.value;
    state.activeBrand = null;
    update();
  });
  const trackInput = el("input", { type: "range", min: "-0.05", max: "0.05", step: "0.005", "aria-label": "Display tracking" }) as HTMLInputElement;
  const trackOut = el("output");
  trackInput.addEventListener("input", () => {
    state.config.displayTracking = Number(trackInput.value);
    trackOut.textContent = `${Number(trackInput.value).toFixed(3)}em`;
    state.activeBrand = null;
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
      state.activeBrand = null;
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
  const darkChk = el("input", { type: "checkbox", id: "flag-dark" }) as HTMLInputElement;
  darkChk.addEventListener("change", () => {
    state.config.defaultDark = darkChk.checked;
    state.activeBrand = null;
    update();
  });
  const rtlChk = el("input", { type: "checkbox", id: "flag-rtl" }) as HTMLInputElement;
  rtlChk.addEventListener("change", () => {
    state.config.defaultRtl = rtlChk.checked;
    state.activeBrand = null;
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
    const b = el("button", { type: "button" }, [v]) as HTMLButtonElement;
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
  for (const r of repopulators) r();
}

function clampInt(n: number, lo: number, hi: number): number {
  if (Number.isNaN(n)) return lo;
  return Math.max(lo, Math.min(hi, Math.round(n)));
}

// ── Randomize ───────────────────────────────────────────────────────────────
function pick<T>(arr: readonly T[]): T {
  return arr[Math.floor(Math.random() * arr.length)]!;
}
function rand(lo: number, hi: number): number {
  return lo + Math.random() * (hi - lo);
}

/** A few pleasant corner families to draw from when randomizing. */
const CORNER_PRESETS: BrandprintConfig["corners"][] = [
  { xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32 }, // soft modern
  { xs: 2, sm: 4, md: 8, lg: 12, xl: 16, xxl: 20 }, // crisp
  { xs: 8, sm: 12, md: 18, lg: 28, xl: 40, xxl: 999 }, // rounded/pill
  { xs: 0, sm: 2, md: 4, lg: 8, xl: 12, xxl: 16 }, // architectural
];

/** Pick pleasant random seeds + levers + fonts and re-render. */
function randomize(): void {
  const hP = rand(0, 360);
  // complementary-ish tertiary hue (±150..210° from primary).
  const hT = (hP + rand(150, 210)) % 360;
  state.config.primary = { L: rand(0.45, 0.6), C: rand(0.08, 0.2), H: Math.round(hP) };
  state.config.tertiary = { L: rand(0.45, 0.6), C: rand(0.08, 0.2), H: Math.round(hT) };
  state.config.corners = { ...pick(CORNER_PRESETS) };
  state.config.fonts = { display: pick(FONTS), text: pick(FONTS), num: pick(FONTS) };
  state.config.loginShell = pick(LOGIN);
  state.config.dashboardHero = pick(HERO);
  state.config.contentTone = pick(TONE);
  state.config.glassTint = pick(GLASS);
  state.config.motion = pick(MOTION);
  state.config.displayWeight = pick([400, 500, 600, 700, 800]);
  state.config.displayTracking = Number(rand(-0.03, 0.01).toFixed(3));
  state.activeBrand = null;
  repopulateAll();
  update();
}

// ── Brandprint output / paste ───────────────────────────────────────────────
let brandprintStringEl: HTMLElement;
let pasteInput: HTMLInputElement;
let pasteErrorEl: HTMLElement;

function buildBrandprintPanel(): HTMLElement {
  brandprintStringEl = el("div", {
    class: "brandprint__string",
    role: "textbox",
    "aria-readonly": "true",
    "aria-label": "Current brandprint",
  });

  const copyBtn = el("button", { class: "btn btn--copy", type: "button" }, ["Copy brandprint"]);
  const copyStatus = el("span", { class: "ok-text", role: "status", "aria-live": "polite" });
  wireCopy(copyBtn, copyStatus, () => brandprintStringEl.textContent ?? "");

  pasteInput = el("input", {
    type: "text",
    placeholder: "Paste a NO1-… brandprint to load",
    "aria-label": "Paste a brandprint to load",
    spellcheck: "false",
    autocapitalize: "off",
    autocomplete: "off",
  }) as HTMLInputElement;
  const loadBtn = el("button", { class: "btn btn--ghost", type: "button" }, ["Load"]);
  pasteErrorEl = el("p", { class: "error-text", role: "alert", "aria-live": "assertive" });
  const doLoad = () => loadBrandprint(pasteInput.value.trim());
  loadBtn.addEventListener("click", doLoad);
  pasteInput.addEventListener("keydown", (e) => {
    if ((e as KeyboardEvent).key === "Enter") doLoad();
  });

  return el("div", { class: "panel panel--brandprint" }, [
    el("h2", { class: "panel__title" }, ["Your brandprint"]),
    el("p", { class: "panel__hint" }, ["This string rebuilds the exact theme in any Odyssey library."]),
    el("div", { class: "brandprint__hero" }, [
      brandprintStringEl,
      el("div", { class: "brandprint__actions" }, [copyBtn, copyStatus]),
    ]),
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
    state.activeBrand = null;
    repopulateAll();
    update();
    // Round-trip sanity: a valid brandprint must re-encode to the SAME canonical string.
    const reencoded = encode(state.config);
    pasteErrorEl.classList.remove("error-text");
    pasteErrorEl.classList.add("ok-text");
    pasteErrorEl.textContent =
      reencoded !== str ? `Loaded (canonical form: ${reencoded})` : "Loaded ✓";
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

// ── "Use this theme" code snippets ───────────────────────────────────────────
interface SnippetDef {
  id: string;
  label: string;
  code: (bp: string) => string;
}

const SNIPPETS: SnippetDef[] = [
  {
    id: "web",
    label: "Web (vanilla)",
    code: (bp) =>
      `import { applyTheme } from "@neptune.fintech/web-ui";\n\napplyTheme(document.documentElement, "${bp}");`,
  },
  {
    id: "react",
    label: "React",
    code: (bp) =>
      `import { NeptuneProvider } from "@neptune.fintech/react-ui";\n\n<NeptuneProvider input="${bp}">\n  <App />\n</NeptuneProvider>`,
  },
  {
    id: "vue",
    label: "Vue",
    code: (bp) =>
      `import { NeptuneProvider } from "@neptune.fintech/vue-ui";\n\n<NeptuneProvider theme="${bp}">\n  <App />\n</NeptuneProvider>`,
  },
  {
    id: "svelte",
    label: "Svelte",
    code: (bp) =>
      `import { theme } from "@neptune.fintech/svelte-ui";\n\n<div use:theme={{ input: "${bp}" }}>\n  <App />\n</div>`,
  },
  {
    id: "flutter",
    label: "Flutter",
    code: (bp) =>
      `import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';\n\nfinal theme = NeptuneTheme.fromBrandprint('${bp}');`,
  },
];

interface SnippetRefs {
  node: HTMLElement;
  redraw: (bp: string) => void;
}

function buildSnippetsPanel(): SnippetRefs {
  const tabs = el("div", { class: "segmented snippets__tabs", role: "tablist", "aria-label": "Framework" });
  const codeEl = el("pre", { class: "snippet__code" }, [el("code", {}, [""])]);
  const code = codeEl.firstElementChild as HTMLElement;
  const copyBtn = el("button", { class: "btn btn--copy snippet__copy", type: "button" }, ["Copy"]);
  const copyStatus = el("span", { class: "ok-text", role: "status", "aria-live": "polite" });
  wireCopy(copyBtn, copyStatus, () => code.textContent ?? "");

  let active = SNIPPETS[0]!.id;
  let currentBp = "";
  const tabButtons: HTMLButtonElement[] = [];

  const paint = () => {
    const def = SNIPPETS.find((s) => s.id === active)!;
    code.textContent = def.code(currentBp);
    tabButtons.forEach((b) => b.setAttribute("aria-pressed", String(b.dataset.id === active)));
  };

  for (const s of SNIPPETS) {
    const b = el("button", { type: "button", "data-id": s.id, role: "tab" }, [s.label]) as HTMLButtonElement;
    b.addEventListener("click", () => {
      active = s.id;
      paint();
    });
    tabButtons.push(b);
    tabs.append(b);
  }

  const node = el("div", { class: "panel panel--snippets" }, [
    el("h2", { class: "panel__title" }, ["Use this theme"]),
    el("p", { class: "panel__hint" }, ["Drop your brandprint into any Neptune Odyssey library."]),
    tabs,
    el("div", { class: "snippet__frame" }, [
      codeEl,
      el("div", { class: "snippet__actions" }, [copyBtn, copyStatus]),
    ]),
  ]);

  return {
    node,
    redraw: (bp: string) => {
      currentBp = bp;
      paint();
    },
  };
}

let snippets: SnippetRefs;

// ── Live preview ────────────────────────────────────────────────────────────
let previewRoot: HTMLElement;
let screenSeg: { node: HTMLElement; sync: () => void };

function buildPreview(): HTMLElement {
  previewRoot = el("div", { class: "preview" });
  const frame = el("div", { class: "preview-frame" }, [previewRoot]);

  screenSeg = segmented(
    "Preview screen",
    ["retail", "wallet", "cards"],
    () => state.screen,
    (v) => {
      state.screen = v as PreviewScreen;
      renderPreview();
    },
  );
  screenSeg.node.classList.add("preview__switcher");

  return el("div", { class: "panel panel--preview" }, [
    el("div", { class: "preview__head" }, [
      el("h2", { class: "panel__title" }, ["Live preview"]),
      screenSeg.node,
    ]),
    frame,
    buildContrastPanel(),
  ]);
}

function btn(label: string, variant: string): HTMLElement {
  return el("npt-button", { variant }, [label]);
}
function chip(label: string, selected = false): HTMLElement {
  const c = el("npt-chip", {}, [label]);
  if (selected) c.setAttribute("selected", "");
  return c;
}
function navBar(active: "Home" | "Cards" | "Pay" | "More"): HTMLElement {
  const nav = el("npt-nav-bar");
  for (const [label, glyph] of [
    ["Home", "⌂"],
    ["Cards", "▭"],
    ["Pay", "↗"],
    ["More", "⋯"],
  ] as const) {
    const item = el("npt-nav-item", { label }, [glyph]);
    if (active === label) item.setAttribute("active", "");
    nav.append(item);
  }
  return nav;
}

/** Retail banking: balance, quick actions, activity feed, quick transfer. */
function retailScreen(): { bar: HTMLElement; scroll: HTMLElement; nav: HTMLElement } {
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
    ["Salary — Triton Bank", "Today · Transfer", "+3,200.00", true],
    ["Tazweed Market", "Today · Card", "-46.25", false],
    ["Mobile A Top-up", "Yesterday · Bill", "-30.00", false],
    ["Refund — Souq", "Mon · Card", "+18.90", true],
  ];
  for (const [title, subtitle, amount, credit] of data) {
    const row = el("npt-transaction-row", { title, subtitle, amount, currency: "LYD" });
    if (credit) row.setAttribute("credit", "");
    txns.append(row);
  }

  const tf = el("npt-text-field", { label: "Send to IBAN", placeholder: "LY.. .... .... ...." });

  const scroll = el("div", { class: "preview__scroll" }, [
    balance,
    quick,
    el("p", { class: "preview__section-title" }, ["Activity"]),
    chips,
    txns,
    el("p", { class: "preview__section-title" }, ["Quick transfer"]),
    tf,
  ]);
  return { bar: appBar, scroll, nav: navBar("Home") };
}

/** Wallet: balance hero, Add money/Send/Request, pay merchants row. */
function walletScreen(): { bar: HTMLElement; scroll: HTMLElement; nav: HTMLElement } {
  const appBar = el("npt-app-bar", { title: "Wallet" });
  appBar.append(el("npt-badge", { tone: "primary", slot: "trailing" }, ["LYD"]));

  const balance = el("npt-balance-card", {
    label: "Wallet balance",
    amount: "842.00",
    currency: "LYD",
    account: "@yusra.lyd",
    hero: "",
  });

  const actions = el("div", { class: "preview__quick" }, [
    btn("Add money", "filled"),
    btn("Send", "tonal"),
    btn("Request", "outlined"),
  ]);

  const merchants = el("div", { class: "preview__merchants" });
  for (const [name, glyph] of [
    ["Mobile A", "📱"],
    ["Mobile B", "📶"],
    ["GECOL", "💡"],
    ["Water", "💧"],
  ] as const) {
    merchants.append(
      el("npt-card", { variant: "tonal", class: "preview__merchant" }, [
        el("span", { class: "preview__merchant-glyph", "aria-hidden": "true" }, [glyph]),
        el("span", { class: "preview__merchant-name" }, [name]),
      ]),
    );
  }

  const recent = el("div", { class: "preview__list" });
  for (const [title, subtitle, amount, credit] of [
    ["Top-up — Mobile A", "Today · Wallet", "-15.00", false],
    ["From Hana", "Today · Request", "+50.00", true],
    ["Coffee — Casa", "Yesterday · QR", "-8.50", false],
  ] as [string, string, string, boolean][]) {
    const row = el("npt-transaction-row", { title, subtitle, amount, currency: "LYD" });
    if (credit) row.setAttribute("credit", "");
    recent.append(row);
  }

  const scroll = el("div", { class: "preview__scroll" }, [
    balance,
    actions,
    el("p", { class: "preview__section-title" }, ["Pay a merchant"]),
    merchants,
    el("p", { class: "preview__section-title" }, ["Recent"]),
    recent,
  ]);
  return { bar: appBar, scroll, nav: navBar("Pay") };
}

/** Cards: a virtual card hero, controls, and recent card spend. */
function cardsScreen(): { bar: HTMLElement; scroll: HTMLElement; nav: HTMLElement } {
  const appBar = el("npt-app-bar", { title: "Cards" });
  appBar.append(el("npt-badge", { tone: "success", slot: "trailing" }, ["Active"]));

  const card = el("npt-card", { variant: "elevated", class: "preview__plastic" }, [
    el("div", { class: "preview__plastic-top" }, [
      el("span", { class: "preview__plastic-brand" }, ["Neptune"]),
      el("span", { class: "preview__plastic-chip", "aria-hidden": "true" }),
    ]),
    el("div", { class: "preview__plastic-num" }, ["4821  ••••  ••••  3390"]),
    el("div", { class: "preview__plastic-row" }, [
      el("span", {}, ["YUSRA A."]),
      el("span", {}, ["08/29"]),
    ]),
  ]);

  const controls = el("div", { class: "preview__quick" }, [
    btn("Freeze", "filled"),
    btn("Limits", "tonal"),
    btn("Details", "outlined"),
  ]);

  const chips = el("div", { class: "preview__quick" }, [
    chip("Virtual", true),
    chip("Online"),
    chip("Contactless"),
  ]);

  const spend = el("div", { class: "preview__list" });
  for (const [title, subtitle, amount] of [
    ["Tazweed Market", "Today · Contactless", "-46.25"],
    ["Souq Online", "Yesterday · Online", "-129.00"],
    ["Casa Coffee", "Mon · Contactless", "-8.50"],
  ] as [string, string, string][]) {
    spend.append(el("npt-transaction-row", { title, subtitle, amount, currency: "LYD" }));
  }

  const scroll = el("div", { class: "preview__scroll" }, [
    card,
    controls,
    el("p", { class: "preview__section-title" }, ["Card type"]),
    chips,
    el("p", { class: "preview__section-title" }, ["Recent spend"]),
    spend,
  ]);
  return { bar: appBar, scroll, nav: navBar("Cards") };
}

function renderPreview(): void {
  previewRoot.textContent = "";
  screenSeg?.sync();
  const compose =
    state.screen === "wallet" ? walletScreen : state.screen === "cards" ? cardsScreen : retailScreen;
  const { bar, scroll, nav } = compose();
  previewRoot.append(bar, scroll, nav);
}

// ── Contrast (AA) report ────────────────────────────────────────────────────
let contrastBodyEl: HTMLElement;
let contrastWarnEl: HTMLElement;

function buildContrastPanel(): HTMLElement {
  contrastWarnEl = el("div", { class: "contrast__warn", role: "status", "aria-live": "polite" });
  contrastBodyEl = el("div", { class: "contrast" });
  return el("div", { class: "panel panel--contrast" }, [
    el("h2", { class: "panel__title" }, ["AA contrast (resolved palette)"]),
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
  const bp = encode(state.config);
  brandprintStringEl.textContent = bp;
  // 4. Snippets reflect the current brandprint.
  snippets.redraw(bp);
  // 5. Active-brand chip highlight.
  syncBrandChips();
  // 6. Contrast report.
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

  // Left column: controls + brandprint + snippets. Right column (sticky): preview.
  const controls = buildControls();
  const brandprint = buildBrandprintPanel();
  snippets = buildSnippetsPanel();
  const preview = buildPreview();
  app.append(
    el("div", { class: "col col--left" }, [controls, brandprint, snippets.node]),
    el("div", { class: "col col--right" }, [preview]),
  );

  document.getElementById("app")!.append(app);

  // First paint.
  renderPreview();
  update();
}

main();

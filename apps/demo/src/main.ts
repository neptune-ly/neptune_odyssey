// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Neptune Odyssey — demo gallery. The public white-label showcase. Built only
// from the REAL shipped components (@neptune-odyssey/web-ui), themed purely via
// CSS variables: each frame in the grid sets its own data-theme/data-mode/dir,
// and the custom-property cascade re-skins everything inside it. No mockups.

import {
  registerAll,
  applyTheme,
  decode,
  buildTheme,
} from "@neptune-odyssey/web-ui";
import "@neptune-odyssey/web-ui/styles.css";

import { brandprintFor, type DecodedBrandprint } from "@neptune-odyssey/tokens";
import { listTenants, themeInputForTenant } from "@neptune-odyssey/brand-configs";

import { summarizeBrandprint } from "./brandprint-summary.js";
import "./styles.css";

registerAll();

// ── Types & constants ───────────────────────────────────────────────────
type Brand = "neptune" | "andalus" | "nuran" | "fglb";
type Mode = "light" | "dark" | "system";
type Dir = "ltr" | "rtl" | "auto";
type Archetype = "retail" | "wallet" | "web" | "corporate";

const BRANDS: Brand[] = ["neptune", "andalus", "nuran", "fglb"];

/** Display labels for the reference brands (reference tenants only). */
const BRAND_LABEL: Record<Brand, string> = {
  neptune: "Neptune",
  andalus: "Andalus",
  nuran: "Nuran",
  fglb: "FGLB",
};

/** A representative accent swatch per brand for the selector chips (cosmetic). */
const BRAND_SWATCH: Record<Brand, string> = {
  neptune: "oklch(0.48 0.15 258)",
  andalus: "oklch(0.55 0.13 150)",
  nuran: "oklch(0.6 0.16 300)",
  fglb: "oklch(0.52 0.16 25)",
};

interface State {
  brand: Brand;
  mode: Mode;
  dir: Dir;
  archetype: Archetype;
  matrixDir: "ltr" | "rtl";
}

const state: State = {
  brand: "neptune",
  mode: "light",
  dir: "ltr",
  archetype: "retail",
  matrixDir: "ltr",
};

// ── Small DOM helpers ───────────────────────────────────────────────────
function el<K extends keyof HTMLElementTagNameMap>(
  tag: K,
  attrs: Record<string, string> = {},
  children: (Node | string)[] = [],
): HTMLElementTagNameMap[K] {
  const node = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) node.setAttribute(k, v);
  for (const c of children) node.append(typeof c === "string" ? document.createTextNode(c) : c);
  return node;
}

/** Make a raw element from an HTML string (used for the real <npt-*> markup). */
function fromHTML(markup: string): DocumentFragment {
  const tpl = document.createElement("template");
  tpl.innerHTML = markup.trim();
  return tpl.content;
}

/** Wrap any markup in an independently-themed frame element. */
function themedFrame(
  brand: Brand,
  mode: "light" | "dark",
  dir: "ltr" | "rtl",
  classes: string,
  inner: Node,
): HTMLElement {
  const frame = el("div", { class: `frame ${classes}` });
  frame.dataset.theme = brand;
  frame.dataset.mode = mode;
  frame.setAttribute("dir", dir);
  frame.append(inner);
  return frame;
}

function resolveMode(mode: Mode): "light" | "dark" {
  if (mode === "system") {
    return matchMedia?.("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }
  return mode;
}

function resolveDir(dir: Dir): "ltr" | "rtl" {
  if (dir === "auto") return "ltr";
  return dir;
}

// ── Screen builders (real components) ───────────────────────────────────

/** Compact mobile screen used by the brand matrix (app bar + hero + rows + button). */
function compactScreen(): Node {
  return fromHTML(`
    <div class="screen">
      <npt-app-bar title="Accounts">
        <span slot="leading" class="avatar" aria-hidden="true">A</span>
        <button slot="trailing" class="icon-btn" aria-label="Notifications">◔</button>
      </npt-app-bar>
      <div class="scroll">
        <div class="pad">
          <npt-balance-card hero label="Available balance" amount="12,480.50" currency="LYD" account="•••• 4821"></npt-balance-card>
          <div class="row-actions">
            <npt-button variant="filled">Send</npt-button>
            <npt-button variant="tonal">Top up</npt-button>
          </div>
          <div class="tx-list">
            <npt-transaction-row title="Salary" subtitle="Today · Transfer" amount="+3,200.00" currency="LYD" credit></npt-transaction-row>
            <npt-transaction-row title="Grocery Market" subtitle="Yesterday · Card" amount="-86.40" currency="LYD"></npt-transaction-row>
            <npt-transaction-row title="Mobile top-up" subtitle="Mon · Wallet" amount="-15.00" currency="LYD"></npt-transaction-row>
          </div>
        </div>
      </div>
    </div>
  `);
}

/** Retail mobile — account-led full screen with bottom nav. */
function retailScreen(): Node {
  return fromHTML(`
    <div class="screen">
      <npt-app-bar title="Good morning, Lina">
        <span slot="leading" class="avatar" aria-hidden="true">L</span>
        <button slot="trailing" class="icon-btn" aria-label="Notifications">◔</button>
      </npt-app-bar>
      <div class="scroll">
        <div class="pad">
          <npt-balance-card hero label="Total balance" amount="48,920.75" currency="LYD" account="Current · •••• 4821"></npt-balance-card>
          <div class="chip-row">
            <npt-chip selected>All</npt-chip>
            <npt-chip>Income</npt-chip>
            <npt-chip>Spending</npt-chip>
            <npt-chip>Bills</npt-chip>
          </div>
          <div class="row-actions">
            <npt-button variant="filled">Transfer</npt-button>
            <npt-button variant="tonal">Pay bills</npt-button>
            <npt-button variant="outlined">Cards</npt-button>
          </div>
          <p class="section-label">Recent activity</p>
          <div class="tx-list">
            <npt-transaction-row title="Salary — Acme Co." subtitle="Today · Transfer" amount="+3,200.00" currency="LYD" credit></npt-transaction-row>
            <npt-transaction-row title="Grocery Market" subtitle="Today · Card" amount="-86.40" currency="LYD"></npt-transaction-row>
            <npt-transaction-row title="Electric bill" subtitle="Yesterday · Direct debit" amount="-142.10" currency="LYD"></npt-transaction-row>
            <npt-transaction-row title="Coffee House" subtitle="Yesterday · Card" amount="-9.50" currency="LYD"></npt-transaction-row>
          </div>
        </div>
      </div>
      <npt-nav-bar>
        <npt-nav-item label="Home" active>⌂</npt-nav-item>
        <npt-nav-item label="Cards">▭</npt-nav-item>
        <npt-nav-item label="Payments">⇄</npt-nav-item>
        <npt-nav-item label="More">⋯</npt-nav-item>
      </npt-nav-bar>
    </div>
  `);
}

/** Wallet — payment-led, lighter/faster than banking. */
function walletScreen(): Node {
  return fromHTML(`
    <div class="screen">
      <npt-app-bar title="Wallet">
        <span slot="leading" class="avatar" aria-hidden="true">W</span>
        <button slot="trailing" class="icon-btn" aria-label="Scan to pay">⊡</button>
      </npt-app-bar>
      <div class="scroll">
        <div class="pad">
          <npt-balance-card hero label="Wallet balance" amount="312.80" currency="LYD" account="Tap to pay ready"></npt-balance-card>
          <div class="row-actions">
            <npt-button variant="filled">Add money</npt-button>
            <npt-button variant="tonal">Send</npt-button>
            <npt-button variant="tonal">Request</npt-button>
          </div>
          <npt-card variant="glass">
            <div style="display:flex;align-items:center;gap:12px;">
              <span class="avatar" aria-hidden="true">☕</span>
              <div style="flex:1;min-width:0;">
                <div style="font-weight:700;">Pay a merchant</div>
                <div class="muted" style="font-size:13px;">Scan a QR or pick a recent store</div>
              </div>
              <npt-button variant="text">Pay</npt-button>
            </div>
          </npt-card>
          <p class="section-label">Activity</p>
          <div class="tx-list">
            <npt-transaction-row title="Received · Omar" subtitle="2m ago" amount="+25.00" currency="LYD" credit></npt-transaction-row>
            <npt-transaction-row title="Blue Bottle Coffee" subtitle="20m ago · QR" amount="-6.25" currency="LYD"></npt-transaction-row>
            <npt-transaction-row title="Sent · Sara" subtitle="1h ago" amount="-40.00" currency="LYD"></npt-transaction-row>
          </div>
        </div>
      </div>
      <npt-nav-bar>
        <npt-nav-item label="Wallet" active>◉</npt-nav-item>
        <npt-nav-item label="Pay">⊡</npt-nav-item>
        <npt-nav-item label="Activity">≡</npt-nav-item>
        <npt-nav-item label="Me">☻</npt-nav-item>
      </npt-nav-bar>
    </div>
  `);
}

/** Web banking (retail) — desktop frame: sidebar + topbar + dashboard + table. */
function webScreen(): Node {
  return fromHTML(`
    <div>
      <div class="browser-bar">
        <div class="browser-dots"><span></span><span></span><span></span></div>
        <div class="browser-url">https://bank.example.ly/dashboard</div>
      </div>
      <div class="scroll-x">
        <div class="web-body">
          <aside class="web-sidebar">
            <div class="web-brand"><span class="glyph" aria-hidden="true">◈</span>Online Banking</div>
            <div class="side-link" aria-current="page"><span class="ic" aria-hidden="true">⌂</span>Overview</div>
            <div class="side-link"><span class="ic" aria-hidden="true">▭</span>Accounts</div>
            <div class="side-link"><span class="ic" aria-hidden="true">⇄</span>Transfers</div>
            <div class="side-link"><span class="ic" aria-hidden="true">≣</span>Payments</div>
            <div class="side-link"><span class="ic" aria-hidden="true">◷</span>Statements</div>
            <div class="side-link"><span class="ic" aria-hidden="true">⚙</span>Settings</div>
          </aside>
          <main class="web-main">
            <div class="web-topbar">
              <h3>Overview</h3>
              <div class="right">
                <npt-chip>This month</npt-chip>
                <npt-button variant="filled">New transfer</npt-button>
                <span class="avatar" aria-hidden="true">L</span>
              </div>
            </div>
            <div class="card-grid">
              <npt-balance-card hero label="Current account" amount="48,920.75" currency="LYD" account="•••• 4821"></npt-balance-card>
              <npt-balance-card label="Savings" amount="120,400.00" currency="LYD" account="•••• 7730"></npt-balance-card>
              <npt-balance-card label="Credit card" amount="-1,240.55" currency="LYD" account="•••• 9912"></npt-balance-card>
            </div>
            <npt-card variant="elevated">
              <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;">
                <strong style="font-size:16px;">Recent transactions</strong>
                <npt-button variant="text">Export</npt-button>
              </div>
              <table class="tbl">
                <thead>
                  <tr><th>Description</th><th>Date</th><th>Status</th><th style="text-align:end;">Amount</th></tr>
                </thead>
                <tbody>
                  <tr><td colspan="4" style="padding:0;">
                    <npt-transaction-row title="Salary — Acme Co." subtitle="Cleared" amount="+3,200.00" currency="LYD" credit></npt-transaction-row>
                  </td></tr>
                  <tr><td colspan="4" style="padding:0;">
                    <npt-transaction-row title="Supplier payment" subtitle="Cleared" amount="-1,450.00" currency="LYD"></npt-transaction-row>
                  </td></tr>
                  <tr><td colspan="4" style="padding:0;">
                    <npt-transaction-row title="Electric bill" subtitle="Pending" amount="-142.10" currency="LYD"></npt-transaction-row>
                  </td></tr>
                  <tr><td colspan="4" style="padding:0;">
                    <npt-transaction-row title="Card refund" subtitle="Cleared" amount="+58.00" currency="LYD" credit></npt-transaction-row>
                  </td></tr>
                </tbody>
              </table>
            </npt-card>
          </main>
        </div>
      </div>
    </div>
  `);
}

/** Corporate — dense workflow: approval queue + bulk-payment batch, maker-checker. */
function corporateScreen(): Node {
  return fromHTML(`
    <div>
      <div class="browser-bar">
        <div class="browser-dots"><span></span><span></span><span></span></div>
        <div class="browser-url">https://corporate.example.ly/approvals</div>
      </div>
      <div class="scroll-x">
        <div class="web-body">
          <aside class="web-sidebar">
            <div class="web-brand"><span class="glyph" aria-hidden="true">◈</span>Corporate</div>
            <div class="side-link"><span class="ic" aria-hidden="true">⌂</span>Dashboard</div>
            <div class="side-link" aria-current="page"><span class="ic" aria-hidden="true">✓</span>Approvals</div>
            <div class="side-link"><span class="ic" aria-hidden="true">≣</span>Bulk payments</div>
            <div class="side-link"><span class="ic" aria-hidden="true">⇄</span>Transfers</div>
            <div class="side-link"><span class="ic" aria-hidden="true">◷</span>Audit trail</div>
          </aside>
          <main class="web-main">
            <div class="web-topbar">
              <h3>Approval queue</h3>
              <div class="right">
                <span class="muted" style="font-size:13px;">Maker-checker · you are a <strong>checker</strong></span>
                <npt-badge tone="error">4</npt-badge>
              </div>
            </div>

            <npt-card variant="elevated">
              <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:16px;flex-wrap:wrap;margin-bottom:16px;">
                <div>
                  <strong style="font-size:16px;">Payroll batch · March</strong>
                  <div class="muted" style="font-size:13px;margin-top:4px;">Submitted by Maker · 142 beneficiaries</div>
                </div>
                <npt-badge tone="neutral">Awaiting approval</npt-badge>
              </div>
              <div class="batch-totals">
                <div class="kv"><div class="k">Total amount</div><div class="v">LYD 486,200.00</div></div>
                <div class="kv"><div class="k">Payments</div><div class="v">142</div></div>
                <div class="kv"><div class="k">Required approvals</div><div class="v">2 of 3</div></div>
              </div>
              <div class="row-actions" style="margin-top:18px;">
                <npt-button variant="filled">Approve</npt-button>
                <npt-button variant="outlined">Return to maker</npt-button>
                <npt-button variant="text">View detail</npt-button>
              </div>
            </npt-card>

            <p class="section-label" style="margin-top:4px;">Pending items</p>
            <div class="queue">
              <div class="queue-item">
                <div class="grow">
                  <div class="qtitle">Supplier payment · Falcon Trading</div>
                  <div class="qsub">LYD 28,400.00 · Maker: A. Hadi · 1 of 2 approvals</div>
                </div>
                <npt-badge tone="primary">Review</npt-badge>
              </div>
              <div class="queue-item">
                <div class="grow">
                  <div class="qtitle">FX settlement · EUR purchase</div>
                  <div class="qsub">LYD 96,750.00 · Maker: S. Noor · 0 of 2 approvals</div>
                </div>
                <npt-badge tone="error">Escalated</npt-badge>
              </div>
              <div class="queue-item">
                <div class="grow">
                  <div class="qtitle">Vendor refund · Delta Logistics</div>
                  <div class="qsub">LYD 4,120.00 · Maker: A. Hadi · 1 of 2 approvals</div>
                </div>
                <npt-badge tone="success">Ready</npt-badge>
              </div>
            </div>
          </main>
        </div>
      </div>
    </div>
  `);
}

// ── Sections ────────────────────────────────────────────────────────────

function buildControls(): HTMLElement {
  const bar = el("div", { class: "controls" });
  const inner = el("div", { class: "controls-inner" });

  // Brand selector
  const brandSeg = el("div", { class: "seg", role: "group", "aria-label": "Brand" });
  for (const b of BRANDS) {
    const btn = el("button", { type: "button", "data-brand": b }, [
      (() => {
        const sw = el("span", { class: "swatch" });
        sw.style.background = BRAND_SWATCH[b];
        return sw;
      })(),
      BRAND_LABEL[b],
    ]);
    btn.setAttribute("aria-pressed", String(state.brand === b));
    btn.addEventListener("click", () => {
      state.brand = b;
      syncSegPressed(brandSeg, "data-brand", b);
      renderShowcaseArea();
    });
    brandSeg.append(btn);
  }

  // Mode toggle
  const modeSeg = makeSeg<Mode>("Mode", ["light", "dark", "system"], state.mode, (m) => {
    state.mode = m;
    renderShowcaseArea();
  });

  // Direction toggle
  const dirSeg = makeSeg<Dir>("Direction", ["ltr", "rtl", "auto"], state.dir, (d) => {
    state.dir = d;
    renderShowcaseArea();
  });

  inner.append(
    group("Brand", brandSeg),
    group("Mode", modeSeg),
    group("Direction", dirSeg),
  );
  bar.append(inner);
  return bar;
}

function group(label: string, control: HTMLElement): HTMLElement {
  return el("div", { class: "ctl-group" }, [
    el("span", { class: "ctl-label" }, [label]),
    control,
  ]);
}

function makeSeg<T extends string>(
  label: string,
  options: T[],
  current: T,
  onPick: (v: T) => void,
): HTMLElement {
  const seg = el("div", { class: "seg", role: "group", "aria-label": label });
  for (const opt of options) {
    const btn = el("button", { type: "button", "data-val": opt }, [opt.toUpperCase()]);
    btn.setAttribute("aria-pressed", String(current === opt));
    btn.addEventListener("click", () => {
      onPick(opt);
      syncSegPressed(seg, "data-val", opt);
    });
    seg.append(btn);
  }
  return seg;
}

function syncSegPressed(seg: HTMLElement, attr: string, active: string): void {
  for (const btn of Array.from(seg.querySelectorAll("button"))) {
    btn.setAttribute("aria-pressed", String(btn.getAttribute(attr) === active));
  }
}

function buildHero(): HTMLElement {
  const hero = el("header", { class: "hero" });
  hero.innerHTML = `
    <div class="wrap">
      <span class="brandmark"><span class="dot"></span>Neptune Odyssey</span>
      <h1>One core. Every bank wears it as a theme.</h1>
      <p class="lede">
        A vendor-neutral, white-label banking design system by
        <a href="https://neptune.ly" target="_blank" rel="noopener">Neptune.Fintech</a>.
        This gallery proves the range — every reference brand, light &amp; dark, LTR &amp; RTL,
        across product archetypes — rendered live from the real shipped components.
      </p>
      <div class="pills">
        <span class="pill-note">4 reference brands</span>
        <span class="pill-note">Light · Dark</span>
        <span class="pill-note">LTR · RTL</span>
        <span class="pill-note">Real components, no mockups</span>
      </div>
      <p class="lede" style="font-size:13.5px;margin-top:18px;">
        Neptune, Andalus, Nuran and FGLB are <strong>reference tenants only</strong> —
        illustrative skins that exercise the system, not real institutions.
      </p>
    </div>
  `;
  return hero;
}

function buildMatrix(): HTMLElement {
  const block = el("section", { class: "block", id: "matrix" });
  const wrap = el("div", { class: "wrap" });

  wrap.append(
    blockHead(
      "The headline view",
      "Brand matrix",
      "The same compact mobile screen, rendered once per brand × light/dark — eight independently-themed device frames on one page. Same components, same markup; only the theme variables change.",
    ),
  );

  const toolbar = el("div", { class: "matrix-toolbar" });
  const dirToggle = makeSeg<"ltr" | "rtl">("Matrix direction", ["ltr", "rtl"], state.matrixDir, (d) => {
    state.matrixDir = d;
    renderMatrixGrid(grid);
  });
  toolbar.append(
    el("span", { class: "muted", style: "color:var(--gallery-text-dim);font-size:13.5px;" }, [
      "Flip the whole matrix:",
    ]),
    dirToggle,
  );

  const grid = el("div", { class: "matrix" });
  renderMatrixGrid(grid);

  wrap.append(toolbar, grid);
  block.append(wrap);
  return block;
}

function renderMatrixGrid(grid: HTMLElement): void {
  grid.replaceChildren();
  for (const brand of BRANDS) {
    for (const mode of ["light", "dark"] as const) {
      const cell = el("div", { class: "matrix-cell" });
      const cap = el("div", { class: "matrix-cap" }, [
        el("span", { class: "brand" }, [BRAND_LABEL[brand]]),
        el("span", { class: "mode-tag" }, [mode]),
      ]);
      const frame = themedFrame(brand, mode, state.matrixDir, "phone", compactScreen());
      cell.append(cap, frame);
      grid.append(cell);
    }
  }
}

function buildArchetypes(): HTMLElement {
  const block = el("section", { class: "block", id: "archetypes" });
  const wrap = el("div", { class: "wrap" });
  wrap.append(
    blockHead(
      "Product archetypes",
      "Four ways to wear the system",
      "Each archetype is composed from the same component kit, rendered for the brand, mode and direction you pick in the control bar above.",
    ),
  );

  const tabs = el("div", { class: "tabs", role: "tablist", "aria-label": "Screen archetypes" });
  const defs: { id: Archetype; label: string }[] = [
    { id: "retail", label: "Retail mobile" },
    { id: "wallet", label: "Wallet" },
    { id: "web", label: "Web banking" },
    { id: "corporate", label: "Corporate" },
  ];
  for (const d of defs) {
    const tab = el("button", { type: "button", role: "tab", "data-arch": d.id }, [d.label]);
    tab.setAttribute("aria-selected", String(state.archetype === d.id));
    tab.addEventListener("click", () => {
      state.archetype = d.id;
      for (const t of Array.from(tabs.querySelectorAll("button"))) {
        t.setAttribute("aria-selected", String(t.getAttribute("data-arch") === d.id));
      }
      renderArchetypeStage(stage, note);
    });
    tabs.append(tab);
  }

  const stage = el("div", { class: "archetype-stage" });
  const note = el("p", { class: "archetype-note" });
  renderArchetypeStage(stage, note);

  wrap.append(tabs, stage, note);
  block.append(wrap);
  return block;
}

const ARCHETYPE_NOTE: Record<Archetype, string> = {
  retail: "Account-led: app bar, hero balance, quick actions, transaction list and bottom navigation.",
  wallet: "Payment-led and deliberately lighter than banking — add money, send, request, scan-to-pay, fast activity.",
  web: "Desktop retail: a left sidebar, a top bar and an overview dashboard with account cards and a transactions table.",
  corporate: "Dense workflow: an approval queue with status badges and a bulk-payment batch with totals and required approvals — maker-checker framing.",
};

function renderArchetypeStage(stage: HTMLElement, note: HTMLElement): void {
  const mode = resolveMode(state.mode);
  const dir = resolveDir(state.dir);
  let frameClasses = "phone";
  let inner: Node;
  switch (state.archetype) {
    case "retail":
      inner = retailScreen();
      break;
    case "wallet":
      inner = walletScreen();
      break;
    case "web":
      frameClasses = "web";
      inner = webScreen();
      break;
    case "corporate":
      frameClasses = "web";
      inner = corporateScreen();
      break;
  }
  const frame = themedFrame(state.brand, mode, dir, frameClasses, inner!);
  stage.replaceChildren(frame);
  note.textContent = ARCHETYPE_NOTE[state.archetype];
}

function buildShowcase(): HTMLElement {
  const block = el("section", { class: "block", id: "components" });
  const wrap = el("div", { class: "wrap" });
  wrap.append(
    blockHead(
      "Component showcase",
      "The kit, under the current theme",
      "Buttons, chips, badges, text fields and cards — re-skinned by the brand/mode/direction selected above.",
    ),
  );
  const frame = el("div", { class: "showcase-frame", id: "showcase-frame" });
  renderShowcaseInner(frame);
  wrap.append(frame);
  block.append(wrap);
  return block;
}

function renderShowcaseInner(frame: HTMLElement): void {
  const mode = resolveMode(state.mode);
  const dir = resolveDir(state.dir);
  frame.dataset.theme = state.brand;
  frame.dataset.mode = mode;
  frame.setAttribute("dir", dir);
  frame.innerHTML = `
    <div class="showcase-grid">
      <div class="showcase-item">
        <h4>Buttons</h4>
        <div class="inline">
          <npt-button variant="filled">Filled</npt-button>
          <npt-button variant="tonal">Tonal</npt-button>
          <npt-button variant="outlined">Outlined</npt-button>
          <npt-button variant="text">Text</npt-button>
        </div>
      </div>
      <div class="showcase-item">
        <h4>Chips</h4>
        <div class="inline">
          <npt-chip selected>Selected</npt-chip>
          <npt-chip>Default</npt-chip>
          <npt-chip>Bills</npt-chip>
          <npt-chip selected>Income</npt-chip>
        </div>
      </div>
      <div class="showcase-item">
        <h4>Badges</h4>
        <div class="inline">
          <npt-badge tone="primary">3</npt-badge>
          <npt-badge tone="success">OK</npt-badge>
          <npt-badge tone="error">!</npt-badge>
          <npt-badge tone="neutral">12</npt-badge>
        </div>
      </div>
      <div class="showcase-item">
        <h4>Text fields</h4>
        <div class="stack">
          <npt-text-field label="Beneficiary IBAN" value="LY83 0021 0000 0004 8210" placeholder="LY.."></npt-text-field>
          <npt-text-field label="Amount" value="9999999999" error="Exceeds your daily limit"></npt-text-field>
        </div>
      </div>
      <div class="showcase-item">
        <h4>Cards</h4>
        <div class="stack">
          <npt-card variant="standard"><strong>Standard</strong><div class="muted" style="font-size:13px;">Default surface container.</div></npt-card>
          <npt-card variant="elevated"><strong>Elevated</strong><div class="muted" style="font-size:13px;">Raised with brand-tinted shadow.</div></npt-card>
        </div>
      </div>
      <div class="showcase-item">
        <h4>Cards · tonal &amp; glass</h4>
        <div class="stack">
          <npt-card variant="tonal"><strong>Tonal</strong><div style="font-size:13px;opacity:.85;">Secondary container.</div></npt-card>
          <npt-card variant="glass"><strong>Glass</strong><div class="muted" style="font-size:13px;">Translucent material.</div></npt-card>
        </div>
      </div>
    </div>
  `;
}

function buildBrandprint(): HTMLElement {
  const block = el("section", { class: "block", id: "brandprint" });
  const wrap = el("div", { class: "wrap" });
  wrap.append(
    blockHead(
      "Portable themes",
      "Brandprint loader",
      "A whole theme is one short, portable string. Paste a NO1- brandprint to decode it and re-skin the showcase below — the same string reproduces the exact theme in any Odyssey library, on any platform.",
    ),
  );

  const layout = el("div", { class: "bp-layout" });

  // ── Left: loader ──
  const loaderPanel = el("div", { class: "panel" });
  loaderPanel.innerHTML = `
    <h3>Load a brandprint</h3>
    <p class="hint">Paste a <code>NO1-…</code> string and apply it to the live preview.</p>
    <div class="bp-input-row">
      <input id="bp-input" type="text" spellcheck="false" autocomplete="off"
        placeholder="NO1-…" aria-label="Brandprint string" />
      <button class="btn" id="bp-apply" type="button">Apply</button>
    </div>
    <p class="bp-error" id="bp-error" role="alert"></p>
    <div class="bp-summary" id="bp-summary" aria-live="polite"></div>
  `;

  // ── Right: canonical for current brand + preview ──
  const canonicalPanel = el("div", { class: "panel" });
  canonicalPanel.innerHTML = `
    <h3>Current brand's brandprint</h3>
    <p class="hint" id="bp-canonical-hint"></p>
    <p class="bp-canonical" id="bp-canonical"></p>
    <button class="btn ghost" id="bp-copy" type="button">Copy brandprint<span class="copied-flash" id="bp-copied"></span></button>
    <a class="btn block cfg-link" href="./configurator/">Make your own theme →</a>
  `;

  layout.append(loaderPanel, canonicalPanel);

  // Live preview frame (the brandprint loader re-skins THIS via applyTheme).
  const previewWrap = el("div", { style: "margin-top:28px;" });
  previewWrap.append(
    el("p", { class: "section-label", style: "color:var(--gallery-text-dim);margin:0 0 12px;" }, [
      "Live preview",
    ]),
  );
  const preview = el("div", { class: "showcase-frame", id: "bp-preview" });
  preview.innerHTML = `
    <div class="card-grid">
      <npt-balance-card hero label="Available balance" amount="12,480.50" currency="LYD" account="•••• 4821"></npt-balance-card>
      <div class="stack" style="display:flex;flex-direction:column;gap:12px;">
        <div class="inline" style="display:flex;gap:12px;flex-wrap:wrap;">
          <npt-button variant="filled">Send</npt-button>
          <npt-button variant="tonal">Top up</npt-button>
          <npt-button variant="outlined">Cards</npt-button>
        </div>
        <div class="inline" style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;">
          <npt-chip selected>Income</npt-chip>
          <npt-chip>Spending</npt-chip>
          <npt-badge tone="success">OK</npt-badge>
          <npt-badge tone="error">!</npt-badge>
        </div>
      </div>
    </div>
  `;
  previewWrap.append(preview);

  wrap.append(layout, previewWrap);
  block.append(wrap);

  // Default-theme the preview to the selected brand.
  applyTheme(preview, state.brand, { mode: resolveMode(state.mode), dir: resolveDir(state.dir) });

  // Wire interactions.
  queueMicrotask(() => wireBrandprint(loaderPanel, canonicalPanel, preview));
  return block;
}

function wireBrandprint(loader: HTMLElement, canonical: HTMLElement, preview: HTMLElement): void {
  const input = loader.querySelector<HTMLInputElement>("#bp-input")!;
  const applyBtn = loader.querySelector<HTMLButtonElement>("#bp-apply")!;
  const errorEl = loader.querySelector<HTMLElement>("#bp-error")!;
  const summaryEl = loader.querySelector<HTMLElement>("#bp-summary")!;

  const doApply = () => {
    const raw = input.value.trim();
    errorEl.textContent = "";
    summaryEl.replaceChildren();
    if (!raw) {
      errorEl.textContent = "Paste a NO1- brandprint string first.";
      return;
    }
    let decoded: DecodedBrandprint;
    try {
      decoded = decode(raw);
    } catch (err) {
      errorEl.textContent = `Could not decode: ${(err as Error).message}.`;
      return;
    }
    const theme = buildTheme(raw, {
      mode: resolveMode(state.mode),
      dir: resolveDir(state.dir),
    });
    applyTheme(preview, raw, { mode: state.mode, dir: state.dir });
    renderSummary(summaryEl, decoded, theme);
  };

  applyBtn.addEventListener("click", doApply);
  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") doApply();
  });

  // Canonical brandprint + copy.
  refreshCanonical(canonical);
}

function renderSummary(
  container: HTMLElement,
  decoded: DecodedBrandprint,
  theme: ReturnType<typeof buildTheme>,
): void {
  container.replaceChildren();
  for (const line of summarizeBrandprint(decoded, theme)) {
    container.append(
      el("div", { class: "line" }, [
        el("span", { class: "k" }, [line.k]),
        el("span", { class: "v" }, [line.v]),
      ]),
    );
  }
}

function refreshCanonical(canonical: HTMLElement): void {
  const hint = canonical.querySelector<HTMLElement>("#bp-canonical-hint")!;
  const code = canonical.querySelector<HTMLElement>("#bp-canonical")!;
  const copyBtn = canonical.querySelector<HTMLButtonElement>("#bp-copy")!;
  const flash = canonical.querySelector<HTMLElement>("#bp-copied")!;

  const bp = brandprintFor(state.brand);
  hint.textContent = `The canonical NO1- string for ${BRAND_LABEL[state.brand]} (a reference tenant).`;
  code.textContent = bp;

  copyBtn.onclick = async () => {
    try {
      await navigator.clipboard.writeText(bp);
      flash.textContent = "Copied";
    } catch {
      flash.textContent = "Press ⌘/Ctrl+C";
    }
    setTimeout(() => (flash.textContent = ""), 1600);
  };
}

function buildFooter(): HTMLElement {
  const footer = el("footer", { class: "site" });
  footer.innerHTML = `
    <div class="wrap foot-inner">
      <div>
        <strong>Neptune Odyssey</strong> · © 2026 Neptune.Fintech (neptune.ly)<br />
        Neptune Odyssey Community License v1.0 — see the LICENSE in the repository.
      </div>
      <div class="links">
        <a href="https://github.com/neptune-ly/neptune_odyssey" target="_blank" rel="noopener">GitHub repo</a>
        <a href="https://neptune.ly" target="_blank" rel="noopener">neptune.ly</a>
        <a href="./configurator/">Configurator</a>
      </div>
    </div>
  `;
  return footer;
}

function blockHead(eyebrow: string, title: string, body: string): HTMLElement {
  const head = el("div", { class: "block-head" });
  head.append(
    el("div", { class: "eyebrow" }, [eyebrow]),
    el("h2", {}, [title]),
    el("p", {}, [body]),
  );
  return head;
}

// ── Re-render the brand/mode/dir-driven areas on control changes ────────
function renderShowcaseArea(): void {
  const stage = document.querySelector<HTMLElement>(".archetype-stage");
  const note = document.querySelector<HTMLElement>(".archetype-note");
  if (stage && note) renderArchetypeStage(stage, note);

  const showcaseFrame = document.querySelector<HTMLElement>("#showcase-frame");
  if (showcaseFrame) renderShowcaseInner(showcaseFrame);

  const preview = document.querySelector<HTMLElement>("#bp-preview");
  if (preview) {
    applyTheme(preview, state.brand, { mode: state.mode, dir: state.dir });
  }
  const canonical = document.querySelector<HTMLElement>("#brandprint .panel:last-child");
  if (canonical) refreshCanonical(canonical);
}

// ── Boot ────────────────────────────────────────────────────────────────
function main(): void {
  const app = document.getElementById("app")!;
  app.append(
    buildControls(),
    buildHero(),
    buildMatrix(),
    buildArchetypes(),
    buildShowcase(),
    buildBrandprint(),
    buildFooter(),
  );

  // Touch the brand-configs surface so the showcase honours the reference set.
  // (Reference tenants are illustrative skins; we surface them in the console
  // for anyone inspecting the page, and use them to validate brand ↔ tenant.)
  if (import.meta.env?.DEV) {
    // eslint-disable-next-line no-console
    console.info(
      "Neptune Odyssey reference tenants:",
      listTenants().map((t) => `${t.displayName} (${t.brand}) → ${themeInputForTenant(t.id)}`),
    );
  }
}

main();

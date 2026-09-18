// Neptune Odyssey — shipped component contract drift check
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const root = process.cwd();
const contract = JSON.parse(fs.readFileSync(path.join(root, "contracts/odyssey-component-contract.json"), "utf8"));
const read = (p) => fs.readFileSync(path.join(root, p), "utf8");
const registerSource = read("packages/neptune_web_ui/src/register.ts");
const reactSource = read("packages/neptune_react_ui/src/index.tsx");
const vueSource = read("packages/neptune_vue_ui/src/index.ts");
const svelteSource = read("packages/neptune_svelte_ui/src/index.ts");
const reactNativeSource = read("packages/neptune_react_native_ui/src/index.ts");

const registered = [...registerSource.matchAll(/define\("([^"]+)"/g)].map((m) => m[1]).sort();
const contracted = contract.components.map((c) => c.web.tag).sort();
const reactWrapped = [...reactSource.matchAll(/passthrough\("([^"]+)"/g)].map((m) => m[1]).sort();
const vueWrapped = [...vueSource.matchAll(/passthrough\("([^"]+)"/g)].map((m) => m[1]).sort();
const contractReact = contract.components.filter((c) => c.platforms?.react?.status === "typed-wrapper").map((c) => c.web.tag).sort();
const contractVue = contract.components.filter((c) => c.platforms?.vue?.status === "typed-wrapper").map((c) => c.web.tag).sort();

const errors = [];
const same = (a, b) => a.length === b.length && a.every((x, i) => x === b[i]);
const missing = registered.filter((x) => !contracted.includes(x));
const stale = contracted.filter((x) => !registered.includes(x));
if (missing.length) errors.push("Registered but missing from contract: " + missing.join(", "));
if (stale.length) errors.push("Contracted but not registered: " + stale.join(", "));
if (new Set(contracted).size !== contracted.length) errors.push("Duplicate web.tag values in contract.");
if (!same(reactWrapped, contractReact)) errors.push("React typed-wrapper drift: source=[" + reactWrapped.join(", ") + "], contract=[" + contractReact.join(", ") + "]");
if (!same(vueWrapped, contractVue)) errors.push("Vue typed-wrapper drift: source=[" + vueWrapped.join(", ") + "], contract=[" + contractVue.join(", ") + "]");
if (!svelteSource.includes("@neptune.fintech/web-ui")) errors.push("Svelte no longer exposes the canonical web custom-element surface.");

for (const c of contract.components) {
  if (!c.id || !c.category || !c.web?.tag) errors.push("Incomplete contract entry: " + JSON.stringify(c));
  if (!c.flutter?.kind) errors.push(c.web.tag + ": missing Flutter parity kind");
  if (!c.figma?.status) errors.push(c.web.tag + ": missing Figma status");
  if (!["canonical", "host-api"].includes(c.figma.status)) errors.push(c.web.tag + ": invalid Figma status " + c.figma.status);
  if (c.figma.status === "canonical" && (!c.figma.nodeId || !c.figma.name)) errors.push(c.web.tag + ": canonical Figma mapping requires nodeId + name");
  if (c.figma.status === "host-api" && (c.figma.nodeId || c.figma.name)) errors.push(c.web.tag + ": host-api must not pretend to have a visual Figma node");
  if (c.contract?.theme !== "tokens-only") errors.push(c.web.tag + ": theme contract must remain tokens-only");
  if (!c.platforms?.react || !c.platforms?.vue || !c.platforms?.svelte || !c.platforms?.reactNative || !c.platforms?.kmp) errors.push(c.web.tag + ": incomplete cross-framework platform contract");
}

const canonicalCount = contract.components.filter((c) => c.figma.status === "canonical").length;
const hostApiCount = contract.components.filter((c) => c.figma.status === "host-api").length;
const missingCount = contract.components.length - canonicalCount - hostApiCount;
const rnExpected = contract.components.filter((c) => c.platforms?.reactNative?.status === "native-wrapper");

if (contract.counts.webRegistered !== registered.length) errors.push("counts.webRegistered=" + contract.counts.webRegistered + ", actual=" + registered.length);
if (contract.counts.figmaCanonical !== canonicalCount) errors.push("counts.figmaCanonical=" + contract.counts.figmaCanonical + ", actual=" + canonicalCount);
if (contract.counts.figmaHostApi !== hostApiCount) errors.push("counts.figmaHostApi=" + contract.counts.figmaHostApi + ", actual=" + hostApiCount);
if (contract.counts.figmaMissing !== missingCount) errors.push("counts.figmaMissing=" + contract.counts.figmaMissing + ", actual=" + missingCount);
if (missingCount !== 0) errors.push("Figma contract has " + missingCount + " unclassified shipped components");
if (contract.counts.reactTypedWrappers !== reactWrapped.length) errors.push("counts.reactTypedWrappers mismatch");
if (contract.counts.vueTypedWrappers !== vueWrapped.length) errors.push("counts.vueTypedWrappers mismatch");
if (contract.counts.svelteNativeWebSurface !== registered.length) errors.push("counts.svelteNativeWebSurface mismatch");
if (contract.counts.reactNativeMappedWebComponents !== rnExpected.length) errors.push("counts.reactNativeMappedWebComponents mismatch");

for (const entry of rnExpected) {
  const symbol = entry.platforms.reactNative.symbol;
  if (!reactNativeSource.includes("export { " + symbol + " }")) errors.push("React Native export missing for " + entry.web.tag + ": " + symbol);
}

if (errors.length) {
  console.error("Odyssey component contract drift detected:\n- " + errors.join("\n- "));
  process.exit(1);
}

const figmaStatus = contract.components.reduce((acc, c) => { acc[c.figma.status] = (acc[c.figma.status] || 0) + 1; return acc; }, {});
console.log("Odyssey component contract OK: " + registered.length + " registered web components.");
console.log("Figma status:", figmaStatus);
console.log("React typed wrappers:", reactWrapped.length, "Vue:", vueWrapped.length, "React Native mapped:", rnExpected.length);

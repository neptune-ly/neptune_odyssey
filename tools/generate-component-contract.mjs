#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseRegisteredSurface } from "./lib/component-surface.mjs";

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), "..");
const check = process.argv.includes("--check");
const contractPath = path.join(root, "contracts/odyssey-component-contract.json");
const prior = JSON.parse(fs.readFileSync(contractPath, "utf8"));
const audit = JSON.parse(fs.readFileSync(path.join(root, "contracts/odyssey-figma-audit.json"), "utf8"));
const surface = parseRegisteredSurface(root);
const priorByTag = new Map(prior.components.map((item) => [item.web.tag, item]));
const auditByTag = new Map(audit.nodes.map((item) => [item.webTag, item]));

const kotlinFiles = listFiles("packages/neptune_kmp_ui", ".kt");
const dartFiles = listFiles("packages/neptune_flutter_ui/lib", ".dart");
const flutterTests = listFiles("packages/neptune_flutter_ui/test", ".dart");
const kmpGallery = listFiles("packages/neptune_kmp_ui/gallery", ".kt");
const kotlinSymbols = symbolIndex(kotlinFiles, /public\s+(?:fun\s+(?:<[^>]+>\s*)?|(?:data\s+)?class\s+|object\s+|enum\s+class\s+|interface\s+)([A-Za-z0-9_]+)/g);
const dartSymbols = symbolIndex(dartFiles, /(?:class|enum|mixin|typedef|extension)\s+([A-Za-z0-9_]+)/g);

const components = surface.map((entry) => {
  const old = priorByTag.get(entry.tag);
  if (!old) throw new Error(`${entry.tag}: missing prior contract metadata (id/category/parity).`);
  const audited = auditByTag.get(entry.tag);
  const hostApi = old.figma.status === "host-api";
  if (!hostApi && !audited) throw new Error(`${entry.tag}: canonical Figma node missing from live audit.`);

  const sourceText = fs.readFileSync(path.join(root, entry.source), "utf8");
  const classText = extractClass(sourceText, entry.className);
  const attributes = [...classText.matchAll(/static\s+observedAttributes\s*=\s*\[([\s\S]*?)\]/g)]
    .flatMap((match) => [...match[1].matchAll(/["']([^"']+)["']/g)].map((item) => item[1]));
  const tokens = [...new Set([...classText.matchAll(/var\((--(?:md-sys|npt)-[a-z0-9-]+)/g)].map((match) => match[1]))].sort();
  const stateSignals = [
    ["disabled", /disabled/], ["focus", /:focus|focus-visible/], ["loading", /loading/],
    ["error", /error|invalid/], ["pending", /pending/], ["rtl", /:dir\(rtl\)|\[dir=["']rtl/],
    ["reduced-motion", /prefers-reduced-motion/],
  ].filter(([, pattern]) => pattern.test(classText)).map(([name]) => name);

  const exactKmp = `Neptune${entry.className.replace(/^Npt/, "")}`;
  const kmpSource = kotlinSymbols.get(exactKmp);
  const kmp = kmpSource
    ? { status: "verified-native-symbol", symbol: exactKmp, source: kmpSource }
    : {
        status: "no-verified-one-to-one-symbol",
        source: "packages/neptune_kmp_ui/README.md",
        note: "No exact public Compose declaration matching the web component was found; no equivalent is inferred.",
      };

  const flutterBase = old.platforms?.flutter ?? old.flutter;
  const flutterLabel = flutterBase?.symbol;
  const flutterExact = /^[A-Za-z_$][A-Za-z0-9_$]*$/.test(flutterLabel ?? "")
    ? dartSymbols.get(flutterLabel)
    : undefined;
  const flutter = {
    ...flutterBase,
    status: flutterExact ? "verified-symbol" : "verified-equivalent",
    source: flutterExact ?? "packages/neptune_flutter_ui/COVERAGE.md",
  };

  return {
    id: old.id,
    category: old.category,
    web: {
      tag: entry.tag,
      className: entry.className,
      source: entry.source,
      registrationSource: "packages/neptune_web_ui/src/register.ts",
      exported: true,
    },
    figma: hostApi ? {
      status: "host-api",
      note: old.figma.note ?? "Intentionally non-visual host API; no canonical visual node.",
    } : {
      status: "canonical",
      nodeId: audited.nodeId,
      name: audited.name,
      nodeType: audited.nodeType,
      page: audited.page,
      variantAxes: audited.variantAxes,
      tokenBindings: audited.tokenBindings,
    },
    platforms: {
      react: { status: "typed-wrapper", symbol: entry.className, source: "packages/neptune_react_ui/src/index.tsx", generatedBy: "tools/generate-framework-wrappers.mjs" },
      vue: { status: "typed-wrapper", symbol: entry.className, source: "packages/neptune_vue_ui/src/index.ts", generatedBy: "tools/generate-framework-wrappers.mjs" },
      svelte: { status: "native-web-custom-element", strategy: "consume-registered-custom-element-directly", source: "packages/neptune_svelte_ui/src/index.ts" },
      flutter,
      kmp,
      reactNative: old.platforms.reactNative,
    },
    requirements: {
      theme: "tokens-only",
      rtl: "required",
      dark: "required",
      reducedMotion: "required-where-animated",
      targetSize: "48px/dp minimum where interactive",
      observedAttributes: [...new Set(attributes)].sort(),
      semanticTokens: tokens,
      sourceStateSignals: stateSignals,
    },
    tests: {
      webSurface: "packages/neptune_web_ui/test/components.test.ts",
      webVisual: "tools/web-shots.mjs",
      react: "packages/neptune_react_ui/test/react-ui.test.tsx",
      vue: "packages/neptune_vue_ui/test/vue-ui.test.ts",
      svelte: "packages/neptune_svelte_ui/test/svelte-ui.test.ts",
      reactNative: old.platforms.reactNative.status === "native-wrapper" ? "packages/neptune_react_native_ui/test/rn.test.ts" : null,
      flutter: occurrences(flutterTests, flutterLabel),
      kmpGallery: kmpSource ? occurrences(kmpGallery, exactKmp) : [],
      kmpVerification: kmpSource ? ":odyssey-compose-ui:jvmTest" : null,
    },
  };
});

const verifiedKmp = components.filter((item) => item.platforms.kmp.status === "verified-native-symbol").length;
const next = {
  ...prior,
  schemaVersion: "2.0.0",
  generatedAt: "2026-09-18",
  counts: {
    webRegistered: surface.length,
    figmaCanonical: components.filter((item) => item.figma.status === "canonical").length,
    figmaHostApi: components.filter((item) => item.figma.status === "host-api").length,
    figmaMissing: 0,
    reactTypedWrappers: surface.length,
    vueTypedWrappers: surface.length,
    svelteNativeWebSurface: surface.length,
    reactNativeMappedWebComponents: components.filter((item) => item.platforms.reactNative.status === "native-wrapper").length,
    kmpVerifiedOneToOneSymbols: verifiedKmp,
    kmpUnverifiedOrEquivalent: surface.length - verifiedKmp,
  },
  sources: {
    ...prior.sources,
    generator: "tools/generate-component-contract.mjs",
    figmaAudit: "contracts/odyssey-figma-audit.json",
    wrapperGenerator: "tools/generate-framework-wrappers.mjs",
  },
  components,
};

const rendered = `${JSON.stringify(next, null, 2)}\n`;
const current = fs.readFileSync(contractPath, "utf8");
if (check && current !== rendered) {
  console.error("Component contract drift detected. Run: pnpm contract:generate");
  process.exit(1);
}
if (!check) fs.writeFileSync(contractPath, rendered);
console.log(`Component contract ${check ? "matches" : "generated"}: ${surface.length} web tags, ${verifiedKmp} verified KMP symbols.`);

function listFiles(relative, extension) {
  const start = path.join(root, relative);
  const output = [];
  for (const entry of fs.readdirSync(start, { withFileTypes: true })) {
    const child = path.join(start, entry.name);
    if (entry.isDirectory()) output.push(...listFiles(path.relative(root, child), extension));
    else if (entry.name.endsWith(extension)) output.push(path.relative(root, child).split(path.sep).join("/"));
  }
  return output.sort();
}

function symbolIndex(files, pattern) {
  const output = new Map();
  for (const file of files) {
    const source = fs.readFileSync(path.join(root, file), "utf8");
    for (const match of source.matchAll(pattern)) if (!output.has(match[1])) output.set(match[1], file);
  }
  return output;
}

function extractClass(source, className) {
  const start = source.search(new RegExp(`export\\s+class\\s+${className}\\b`));
  if (start < 0) throw new Error(`${className}: exported class declaration not found in exact source.`);
  const remainder = source.slice(start);
  const next = remainder.slice(1).search(/\nexport\s+class\s+/);
  return next < 0 ? remainder : remainder.slice(0, next + 1);
}

function occurrences(files, symbol) {
  if (!symbol) return [];
  return files.filter((file) => fs.readFileSync(path.join(root, file), "utf8").includes(symbol));
}

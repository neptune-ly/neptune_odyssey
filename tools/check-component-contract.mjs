// Neptune Odyssey — shipped component contract drift check
// Fails when the registered web component surface changes without updating the
// machine-readable component contract used by Figma/agent handoff.

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const root = process.cwd();
const contractPath = path.join(root, "contracts/odyssey-component-contract.json");
const registerPath = path.join(root, "packages/neptune_web_ui/src/register.ts");

const contract = JSON.parse(fs.readFileSync(contractPath, "utf8"));
const registerSource = fs.readFileSync(registerPath, "utf8");
const registered = [...registerSource.matchAll(/define\("([^"]+)"/g)].map((m) => m[1]).sort();
const contracted = contract.components.map((c) => c.web.tag).sort();

const errors = [];
const missing = registered.filter((x) => !contracted.includes(x));
const stale = contracted.filter((x) => !registered.includes(x));

if (missing.length) errors.push(`Registered but missing from contract: ${missing.join(", ")}`);
if (stale.length) errors.push(`Contracted but not registered: ${stale.join(", ")}`);
if (new Set(contracted).size !== contracted.length) errors.push("Duplicate web.tag values in contract.");

for (const c of contract.components) {
  if (!c.id || !c.category || !c.web?.tag) errors.push(`Incomplete contract entry: ${JSON.stringify(c)}`);
  if (!c.flutter?.kind) errors.push(`${c.web.tag}: missing Flutter parity kind`);
  if (!c.figma?.status) errors.push(`${c.web.tag}: missing Figma status`);
  if (!["canonical", "host-api"].includes(c.figma.status)) {
    errors.push(`${c.web.tag}: invalid Figma status ${c.figma.status}; expected canonical or host-api`);
  }
  if (c.figma.status === "canonical" && (!c.figma.nodeId || !c.figma.name)) {
    errors.push(`${c.web.tag}: canonical Figma mapping requires nodeId + name`);
  }
  if (c.figma.status === "host-api" && (c.figma.nodeId || c.figma.name)) {
    errors.push(`${c.web.tag}: host-api must not pretend to have a visual Figma node`);
  }
  if (c.contract?.theme !== "tokens-only") errors.push(`${c.web.tag}: theme contract must remain tokens-only`);
}

if (contract.counts.webRegistered !== registered.length) {
  errors.push(`counts.webRegistered=${contract.counts.webRegistered}, actual=${registered.length}`);
}
const canonicalCount = contract.components.filter((c) => c.figma.status === "canonical").length;
const hostApiCount = contract.components.filter((c) => c.figma.status === "host-api").length;
const missingCount = contract.components.length - canonicalCount - hostApiCount;
if (contract.counts.figmaCanonical !== canonicalCount) errors.push(`counts.figmaCanonical=${contract.counts.figmaCanonical}, actual=${canonicalCount}`);
if (contract.counts.figmaHostApi !== hostApiCount) errors.push(`counts.figmaHostApi=${contract.counts.figmaHostApi}, actual=${hostApiCount}`);
if (contract.counts.figmaMissing !== missingCount) errors.push(`counts.figmaMissing=${contract.counts.figmaMissing}, actual=${missingCount}`);
if (missingCount !== 0) errors.push(`Figma contract has ${missingCount} unclassified shipped components`);

if (errors.length) {
  console.error("Odyssey component contract drift detected:\n- " + errors.join("\n- "));
  process.exit(1);
}

const statusCounts = contract.components.reduce((acc, c) => {
  acc[c.figma.status] = (acc[c.figma.status] || 0) + 1;
  return acc;
}, {});

console.log(`Odyssey component contract OK: ${registered.length} registered web components.`);
console.log("Figma status:", statusCounts);

// Neptune Odyssey — build the docs-site browser bundle · © 2026 Neptune.Fintech (neptune.ly)
// Bundles @neptune.fintech/web-ui + /icons (and their tokens dep) into a single IIFE
// (global "Neptune") at site/assets/neptune.js, so the static docs pages render live
// components + icons with no framework. Run: node site/bundle/build.mjs
import { build } from "esbuild";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "../..");
const p = (rel) => resolve(root, rel);

await build({
  entryPoints: [resolve(here, "entry.ts")],
  bundle: true,
  format: "iife",
  globalName: "Neptune",
  minify: true,
  sourcemap: false,
  target: ["es2021"],
  outfile: resolve(root, "site/assets/neptune.js"),
  alias: {
    "@neptune.fintech/web-ui": p("packages/neptune_web_ui/dist/index.js"),
    "@neptune.fintech/icons": p("packages/neptune_icons/dist/index.js"),
    "@neptune.fintech/tokens": p("packages/neptune_tokens/dist/index.js"),
  },
});

console.log("✓ built site/assets/neptune.js");

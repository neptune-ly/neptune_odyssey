import fs from "node:fs";
import path from "node:path";

export function parseRegisteredSurface(root) {
  const registerPath = path.join(root, "packages/neptune_web_ui/src/register.ts");
  const source = fs.readFileSync(registerPath, "utf8");
  const classSources = new Map();

  for (const match of source.matchAll(/import\s+{([\s\S]*?)}\s+from\s+"(\.\/components\/[^"]+)\.js";/g)) {
    const imported = match[1]
      .split(",")
      .map((name) => name.trim())
      .filter(Boolean);
    const relative = match[2].replace(/^\.\//, "");
    for (const className of imported) {
      classSources.set(className, `packages/neptune_web_ui/src/${relative.replace(/^components\//, "components/")}.ts`);
    }
  }

  const entries = [];
  for (const match of source.matchAll(/define\("([^"]+)",\s*([A-Za-z0-9_]+)\);/g)) {
    const [, tag, className] = match;
    const sourcePath = classSources.get(className);
    if (!sourcePath) throw new Error(`No source import found for ${className} (${tag})`);
    entries.push({ tag, className, source: sourcePath });
  }

  const tags = new Set(entries.map((entry) => entry.tag));
  if (tags.size !== entries.length) throw new Error("Duplicate registered web tags.");
  return entries;
}

export function replaceGeneratedBlock(source, rendered) {
  const block = /\/\*\* Typed thin wrappers[\s\S]*?\*\/[\s\S]*?(?=\nexport \{ applyTheme, registerAll \})/;
  if (!block.test(source)) throw new Error("Could not locate wrapper export block.");
  return source.replace(block, rendered);
}

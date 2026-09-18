// Regenerate the lab's browser module from the same tested TypeScript source.
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { mkdirSync } from 'node:fs';
const root = new URL('../', import.meta.url);
const out = fileURLToPath(new URL('site/product-worlds/', root));
mkdirSync(out, { recursive: true });
const source = fileURLToPath(new URL('packages/neptune_product_configs/src/experience.ts', root));
const result = spawnSync(process.platform === 'win32' ? 'tsc.cmd' : 'tsc', [source, '--target', 'ES2022', '--module', 'ES2022', '--moduleResolution', 'Bundler', '--strict', '--skipLibCheck', '--outDir', out], { stdio: 'inherit' });
if (result.error) { console.error(result.error); process.exitCode = 1; }
else process.exitCode = result.status ?? 1;
if (process.exitCode === 0) {
  const { readFileSync, writeFileSync } = await import('node:fs');
  const { join } = await import('node:path');
  const names = ['orbit-departure','move-street','market-studio'];
  const artwork = Object.fromEntries(names.map(name => [name, readFileSync(join(out,'assets',name+'.svg'),'utf8')]));
  const policy = readFileSync(join(out,'experience.js'),'utf8').replace(/^export /gm, '');
  const app = readFileSync(join(out,'app.mjs'),'utf8').replace(/^import [^\n]+\n/, '');
  const code = `globalThis.ODYSSEY_LOCAL_ART=${JSON.stringify(artwork)};\n${policy}\n${app}`.replace(/<\/script/gi,'<\\/script');
  const html = readFileSync(join(out,'index.html'),'utf8')
    .replace('<link rel="stylesheet" href="recipes.css">', `<style>${readFileSync(join(out,'recipes.css'),'utf8')}</style>`)
    .replace('<script type="module" src="app.mjs"></script>', `<script type="module">${code}</script>`);
  writeFileSync(join(out,'standalone.html'), html);
}

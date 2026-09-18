// Compile the canonical policies, then build a dependency-free offline review artifact.
// No generated JS is checked in; no package or application is published by this tool.
import {spawnSync} from 'node:child_process';
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
const root=new URL('../',import.meta.url),dir=new URL('site/product-worlds/',root);
const out=fileURLToPath(new URL('_servicing/',dir));mkdirSync(out,{recursive:true});
const result=spawnSync(process.platform==='win32'?'tsc.cmd':'tsc',[
 fileURLToPath(new URL('packages/neptune_product_configs/src/servicing.ts',root)),
 '--target','ES2022','--module','ES2022','--moduleResolution','Bundler','--strict','--skipLibCheck','--outDir',out
],{stdio:'inherit'});
if(result.error)throw result.error;
if(result.status!==0)process.exit(result.status??1);
const read=p=>readFileSync(new URL(p,dir),'utf8');
const exportsOf=s=>[...s.matchAll(/^export (?:async )?(?:function|const|class) (\w+)/gm)].map(m=>m[1]);
const wrap=(name,s,imports='')=>`const ${name}=(()=>{${imports}\n${s.replace(/^import[\s\S]*?;\s*/gm,'').replace(/^export /gm,'')}\nreturn {${exportsOf(s).join(',')}};})();`;
const policy=read('_servicing/experience.js'),servicing=read('_servicing/servicing.js');
const session=read('servicing-session.mjs');
const compiled=wrap('Policy',policy)+wrap('Servicing',servicing,'const {sumMoney,transitionJourney}=Policy;')+
 wrap('Session',session,`const {${exportsOf(servicing).join(',')}}=Servicing;`);
const assets=Object.fromEntries(['orbit-aftercare','move-driver-onboarding'].map(name=>[name,read(`assets/${name}.svg`)]));
const ui=read('servicing-lab.mjs').replace(/^import[^\n]*\n/gm,'');
const script=`globalThis.ODYSSEY_SERVICING_ART=${JSON.stringify(assets)};\n${compiled}\nconst {createServicingSession,REQUIREMENTS}=Session;const {formatMoney}=Policy;\n${ui}`.replace(/<\/script/gi,'<\\/script');
const html=read('servicing.html').replace('<link rel="stylesheet" href="recipes.css">',`<style>${read('recipes.css')}</style>`)
 .replace('<link rel="stylesheet" href="servicing.css">',`<style>${read('servicing.css')}</style>`)
 .replace('<script type="module" src="servicing-lab.mjs"></script>',`<script type="module">${script}</script>`);
writeFileSync(new URL('servicing-standalone.html',dir),html);
console.log('Servicing modules compiled; offline HTML built from canonical policy and original assets.');

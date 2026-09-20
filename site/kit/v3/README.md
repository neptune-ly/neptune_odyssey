# Neptune Odyssey 3.0.0 — portable design kit

Vivid fields, warm paper, confident ink, expressive display type and professional illustration. One shared language supports lively everyday products and composed institutional services. This edition starts at 3.x because earlier 2.x packages belonged to the first standard.

Start with [Visual compass](visual-compass.md), [Expression system](expression-system.md) and [Designer / agent instructions](DESIGNER-AGENT.md). The [native Figma identity board](https://www.figma.com/design/0Z2HlDHC3VKVujjzqDCDqP?node-id=294-2) is the editable design source; access follows the file's sharing permissions.

| Content | Actual format and use |
| --- | --- |
| `tokens/` | Six DTCG JSON files: Core, Drive and Orbit in light/dark |
| `odyssey.css` | CSS variables; `data-odyssey-mode` selects light/dark |
| `adapters/` | JSON, TypeScript, Dart and Kotlin expression values; foundation constants, not widgets |
| `fonts/` | Baloo 2, Hanken Grotesk and Beiruti variable TTFs with OFL licences |
| `icons/` | 94 editable 24×24 outline SVGs |
| `navigation/` | Four additional dock shell snapshots, each LTR/RTL; native component variants remain in Figma |
| `illustrations/` | Four image-model PNG studies and prompts; raster, internally reviewed, no individual user signoff recorded |
| `components/manifest.json` | Native Figma inventory and per-family SDK status; no editable masters exported |

Register fonts in the host application. Numbers use Hanken Grotesk and isolated LTR runs. Source-backed product typography can override defaults. Keep semantics separate from decorative colours and check actual foreground/background contrast.

For Figma, use native components and variables. Other tools can consume JSON, SVG, CSS and PNG; native Claude Design import has not been verified. A `.fig` backup requires Figma's own export. This public package excludes client bank names, marks and private journeys.

The SDK adoption guide is [on GitHub](https://github.com/neptune-ly/neptune_odyssey/blob/main/docs/ODYSSEY_3.md). The existing widget catalogue is retained; full new-design widget parity is not claimed.

Neptune Odyssey Community License applies; bundled fonts retain their included SIL Open Font Licences. Illustration provenance and approval status travel with the assets.

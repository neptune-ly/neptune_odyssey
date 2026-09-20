# Neptune Odyssey 3.0

A shared design language for expressive everyday products and composed institutions, by [Neptune.Fintech](https://neptune.ly). Vivid colour, warm paper, confident typography and professional illustration — with product identity preserved through composition, type and navigation.

**[Explore the live standard](https://neptune-ly.github.io/neptune_odyssey/)** · **[Download the 3.0.0 kit](https://github.com/neptune-ly/neptune_odyssey/releases/download/v3.0.0/odyssey-3.0.0-kit.zip)** · **[Adopt the SDK foundation](docs/ODYSSEY_3.md)** · **[Release notes](CHANGELOG.md)**

![Odyssey illustration language](site/kit/v3/illustrations/everyday-exchange-v1.png)

## Start with the system

Read the [visual compass](site/kit/v3/visual-compass.md), [expression rules](site/kit/v3/expression-system.md) and [designer/agent contract](site/kit/v3/DESIGNER-AGENT.md). The [native Figma library](https://www.figma.com/design/0Z2HlDHC3VKVujjzqDCDqP?node-id=294-2) holds editable masters and variables; access follows the file's sharing permissions.

The [portable kit](site/kit/v3/README.md) includes six light/dark DTCG token files, CSS and typed adapters, three licensed font families, 94 SVG icons, dock snapshots and four illustration studies with prompts/provenance. The studies are raster and internally reviewed; individual production signoff is not implied. Client bank assets are excluded from this public release.

## Develop

| Surface | 3.0 adoption |
| --- | --- |
| Web / TypeScript | `applyTheme(root, brand, { edition: 'odyssey3', product: 'wallet' })` |
| Flutter | `NeptuneTheme.odyssey3(base, product: NeptuneOdyssey3Product.wallet)` |
| Kotlin Multiplatform | `NeptuneTheme(brand = "neptune", odyssey3 = NeptuneOdyssey3Product.Wallet)` |
| Design tools / agents | Portable JSON, SVG, CSS, fonts, illustration guidelines and native Figma links |

Use the `v3.0.0` Git tag for the release source. Package metadata starts at 3.0.0 because prior 2.x releases belonged to the first standard. **GitHub source/kit publication is separate from npm, pub.dev and Maven Central availability.** See [publishing](PUBLISHING.md).

Existing NO1 brandprints and theme defaults remain compatible; the new foundation is explicit. The existing widget catalogue is retained. Full 3.0 widget parity and runtime integrations are not claimed. [Migration and usage](docs/ODYSSEY_3.md) · [Classic reference documentation](docs/README_CLASSIC.md) · [Classic gallery](https://neptune-ly.github.io/neptune_odyssey/classic.html).

```sh
pnpm install --frozen-lockfile
pnpm build
pnpm test
pnpm codegen:check
pnpm contrast
```

## Licence

Source-available under the [Neptune Odyssey Community License v1.0](LICENSE). Bundled fonts retain their included SIL Open Font Licences. The project is public; third-party marks and private client assets are not granted by this release.

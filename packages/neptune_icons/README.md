# @neptune.fintech/icons

The **Neptune Odyssey icon family** — an original, hand-authored SVG icon set
built for banking & fintech surfaces. ~60 glyphs, one coherent style, themeable
everywhere via `currentColor`.

- **24×24** viewBox on a 24px grid with ~2px visual padding.
- **Outlined / stroke-based**: `stroke="currentColor"`, `stroke-width="1.8"`,
  round caps & joins, `fill="none"` (a few solid dots use `fill="currentColor"`).
- **Themeable by inheritance** — every icon paints with `currentColor`, so it
  picks up `color` (e.g. `--md-sys-color-on-surface`) with zero per-icon config.
- Usable from **plain web** (string builder) or as the **`<npt-icon>`** custom
  element. SSR-safe.

## Install

```sh
pnpm add @neptune.fintech/icons
# or: npm i @neptune.fintech/icons
```

## Plain web — `iconSvg()`

`iconSvg(name, opts?)` returns a complete, ready-to-inline `<svg>` string.

```ts
import { iconSvg } from "@neptune.fintech/icons";

document.querySelector("#slot")!.innerHTML = iconSvg("card");

// options: size (px), stroke (viewBox units), class
iconSvg("send", { size: 32, stroke: 2, class: "cta-icon" });
```

Colour follows CSS — set `color` on an ancestor and the icon matches:

```html
<span style="color: var(--md-sys-color-primary)">
  <!-- iconSvg("transfer") inserted here paints in the primary colour -->
</span>
```

## Custom element — `<npt-icon>`

```ts
import { registerIcons } from "@neptune.fintech/icons";
registerIcons(); // browser-only, idempotent
```

```html
<npt-icon name="qr-code" size="28"></npt-icon>
<npt-icon name="security-shield"></npt-icon>
```

Reactive attributes: `name`, `size` (px, default 24), `stroke` (default 1.8).
Override colour with the `--npt-icon-color` custom property or plain `color`.

## Theming

There is nothing to configure. Because each glyph uses `currentColor`, it
inherits the resolved text colour. Inside a Neptune Odyssey theme that means it
tracks `--md-sys-color-*` automatically — light/dark and per-brand reskins come
for free.

## API

| Export           | Description                                                        |
| ---------------- | ----------------------------------------------------------------- |
| `iconSvg`        | `(name, opts?) => string` — full `<svg>` string. Throws on bad name. |
| `isIconName`     | `(name) => boolean` type guard for `IconName`.                    |
| `ICONS`          | `Record<IconName, string>` — inner markup per icon.               |
| `ICON_NAMES`     | `IconName[]` — the full roster, in catalogue order.               |
| `IconName`       | Union type of every icon name.                                    |
| `NptIcon`        | The `<npt-icon>` custom-element class.                            |
| `registerIcons`  | Registers `<npt-icon>` (browser-only, idempotent).               |
| `ICONS_VERSION`  | `"2.0.0"`.                                                        |

## Icon list

`home`, `accounts`, `card`, `card-add`, `wallet`, `transfer`, `send`,
`receive`, `request`, `swap-exchange`, `qr-code`, `contactless`, `bill`,
`receipt`, `statement`, `pdf`, `download`, `upload`, `search`, `filter`,
`settings`, `user`, `users`, `security-shield`, `lock`, `unlock`, `key`,
`fingerprint`, `face-id`, `bell`, `eye`, `eye-off`, `info`, `success-check`,
`warning`, `error`, `close`, `plus`, `minus`, `chart-line`, `chart-pie`,
`trending-up`, `trending-down`, `savings`, `calendar`, `clock`, `location`,
`phone`, `mail`, `support`, `chevron-right`, `chevron-down`, `arrow-right`,
`arrow-left`, `menu`, `more-horizontal`, `more-vertical`, `copy`, `share`,
`logout`, `language`, `moon`, `sun`.

## License

Neptune Odyssey Community License v1.0 — see [LICENSE](./LICENSE).

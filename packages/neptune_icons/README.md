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

## Brand marks (third-party trademarks)

> **Trademark notice.** The payment-network & fintech brand marks
> (Visa, Mastercard, Amex, Discover, UnionPay, Western Union, MoneyGram,
> Apple Pay, Google Pay, PayPal, SWIFT, mada, NUMO, Moamalat, LyPay, OnePay,
> Sadad, Tadawul, …) are **third-party trademarks of their respective owners**,
> provided here as **simplified identification marks / placeholders only**. They
> are original, clean geometric placeholders (**never traced** from official
> artwork) and are **NOT** licensed under the Neptune Odyssey Community License.
> In production, register each brand's **official asset** with
> [`registerBrandMark()`](#use-your-own-official-logos) per that brand's brand
> guidelines. The Libyan/local marks are neutral placeholders to be replaced with
> official assets. See [`NOTICE-brand-marks.md`](./NOTICE-brand-marks.md).

Brand marks live in a separate module — they return a **complete** `<svg>` (with
their own `viewBox`), not inner markup, and are NOT in `ICONS` / `IconName`. The
bundled marks are **original, simplified geometric placeholders** (never traced
from official artwork).

### Three variants

Every mark renders in three variants via `brandMarkSvg(name, { variant })`:

| Variant   | What it is                                                              |
| --------- | ---------------------------------------------------------------------- |
| `color`   | Multicolour brand colours. **The default.** Not themeable.             |
| `mono`    | A single flat silhouette in `currentColor` — themeable like an icon.   |
| `outline` | Line style: `stroke="currentColor"`, `fill="none"`, round joins — themeable. |

```ts
import { brandMarkSvg, BRAND_MARK_NAMES, register } from "@neptune.fintech/icons";

// full <svg> string, sized to a height (width preserves aspect ratio)
document.querySelector("#pm")!.innerHTML = brandMarkSvg("visa", { height: 24 });

// mono / outline track `currentColor`, so they theme like the icon set
brandMarkSvg("mastercard", { variant: "mono", height: 24 });
brandMarkSvg("onepay", { variant: "outline", height: 24, class: "pm" });

// custom element — register() wires up BOTH <npt-icon> and <npt-brand-mark>
register();
```

```html
<npt-brand-mark name="mastercard" height="24"></npt-brand-mark>
<npt-brand-mark name="apple-pay" height="20" variant="mono"></npt-brand-mark>
<npt-brand-mark name="lypay" height="24" variant="outline"></npt-brand-mark>
```

### Use your own official logos

The bundled marks are **identification placeholders**. If you are licensed to use
a brand's official logo, drop it in with `registerBrandMark()` — after that,
`brandMarkSvg(name, { variant })` (and `<npt-brand-mark>`) return **your**
approved artwork:

```ts
import { registerBrandMark, brandMarkSvg } from "@neptune.fintech/icons";

// one SVG covers all three variants
registerBrandMark("visa", officialVisaSvg);

// …or supply a per-variant set (missing variants fall back across the others)
registerBrandMark("mastercard", {
  color: officialMastercardColorSvg,
  mono: officialMastercardMonoSvg,
  outline: officialMastercardOutlineSvg,
});

brandMarkSvg("visa", { height: 24 });            // → your official Visa SVG
brandMarkSvg("mastercard", { variant: "mono" }); // → your mono Mastercard SVG
```

`registerBrandMark(name, svg)` also accepts an arbitrary `name` string, so you can
register brands that aren't bundled (then render them with `brandMarkSvg(name)`).
**Licensed users SHOULD register official assets** and follow each brand's usage
guidelines; the bundled marks are placeholders only.

| Export             | Description                                                       |
| ------------------ | ---------------------------------------------------------------- |
| `brandMarkSvg`     | `(name, { variant?, height?, class? }) => string` — full `<svg>`. Throws on unknown name with no override. |
| `registerBrandMark`| `(name, svg \| { color?, mono?, outline? }) => void` — install an official/own override. |
| `unregisterBrandMark` | `(name) => void` — remove a registered override.             |
| `hasBrandMarkOverride` | `(name) => boolean` — true when an override is registered.   |
| `isBrandMarkName`  | `(name) => boolean` type guard for `BrandMarkName`.              |
| `BRAND_MARKS`      | `Record<BrandMarkName, string>` — complete `color`-variant `<svg>` per mark. |
| `BRAND_MARK_NAMES` | `BrandMarkName[]` — the roster, in catalogue order.             |
| `BrandMarkName`    | Union type of every brand-mark name.                            |
| `BrandMarkVariant` | `"color" \| "mono" \| "outline"`.                              |
| `NptBrandMark`     | The `<npt-brand-mark>` custom-element class.                    |
| `registerBrandMarks` / `register` | Register `<npt-brand-mark>` (and `register()` both elements). |

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
| `ICONS_VERSION`  | `"2.2.0"`.                                                        |

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
`logout`, `language`, `moon`, `sun`, `atm`, `pos-terminal`, `coins`,
`cash-stack`, `invoice`, `pie-budget`, `exchange-rate`, `crypto`, `loan`,
`insurance`, `split-bill`, `tap-to-pay`.

## License

Neptune Odyssey Community License v1.0 — see [LICENSE](./LICENSE).

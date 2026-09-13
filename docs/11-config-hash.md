# 11 · Config Hash — the Brandprint

> A **brandprint** is a short, deterministic, shareable string (`NO1-…`) that encodes a tenant's theme choices. Pick colours, type, shape and the lever set in the online configurator → get a brandprint → paste it into any Odyssey library (Flutter, web, …) and it rebuilds the **identical** theme. It is the portable, copy-pasteable form of a tenant config.

Reference implementation: **`tools/brandprint.js`** (UMD — Node + browser). Proven: idempotent, deterministic, enum/structure-exact, seeds within 1-byte tolerance, tamper-detected via checksum, unique per brand.

## What it encodes

The **inputs** a theme is generated from — not the resolved palette (that's regenerated deterministically, see "Determinism" below):

- **Seeds** — `primary` and `tertiary` as OKLCH `{L, C, H}`.
- **Shape** — the six corner values `xs sm md lg xl xxl` (px).
- **Type** — `display / text / num` font (registry index) + `displayWeight` + `displayTracking`.
- **Levers (enums)** — `loginShell`, `dashboardHero`, `contentTone`, `glassTint`, `motion`, `motif` (2.24.0; `auto` = derive from `glassTint`).
- **Flags** — default dark, default RTL, accent-on-tertiary (2.24.0), white ground (2.25.0), `navShell` / `actionRow` (2.28.0, two bits each in the flags byte's high nibble).
- **Extension flags** (2.28.0, byte 27, only present on a 29-byte payload) — `ruledRegister`.

## Wire format

`NO1-` + base64url( payload ). Version-tagged, fixed offsets, **last byte is always the checksum.**

There are two payload lengths, and the version byte names which one you are holding:

| version byte | payload | layout |
|---:|---:|---|
| `1` | 28 bytes | the original. Byte 27 is the checksum. |
| `2` | 29 bytes | 2.28.0. Bytes 0-26 unchanged, byte 27 is the **extension flags** byte, byte 28 is the checksum. |

`encode` emits the 29-byte form **only when the extension byte would carry something**, so a config
that sets no extension flag produces the identical 28 bytes it produced in 2.27.0 — every brandprint
already in the wild, the three banks in production included, is byte-for-byte unchanged
(`packages/neptune_flutter_ui/test/brandprint_production_test.dart` asserts exactly that against
their real strings). A version byte that disagrees with the length is rejected, so a truncated or
padded payload cannot decode as a plausible neighbour.

The `NO1-` prefix is the codec **family**, not the layout. It changes only for a genuinely breaking
change — a reordered or removed registry — which is what `NO2-` is reserved for. Additive growth
that leaves old strings decoding unchanged is a version byte, not a new prefix.

| Off | Bytes | Field | Encoding |
|----:|------:|-------|----------|
| 0 | 1 | version | `1` |
| 1 | 1 | primary L | `round(L×255)` |
| 2 | 1 | primary C | `min(255, round(C×1000))` |
| 3 | 2 | primary H | uint16 BE (0–359) |
| 5 | 1 | tertiary L | `round(L×255)` |
| 6 | 1 | tertiary C | `min(255, round(C×1000))` |
| 7 | 2 | tertiary H | uint16 BE |
| 9 | 6 | corners xs…xxl | uint8 px each |
| 15 | 1 | displayWeight | `weight/100` (e.g. 7 = 700) |
| 16 | 1 | displayTracking | int8, `round(em×1000)` (e.g. −0.02em = −20) |
| 17 | 3 | fonts display/text/num | FONTS index each |
| 20 | 1 | loginShell | LOGIN index |
| 21 | 1 | dashboardHero | HERO index |
| 22 | 1 | contentTone | TONE index |
| 23 | 1 | glassTint | GLASS index |
| 24 | 1 | motion | MOTION index |
| 25 | 1 | flags | bit0 defaultDark, bit1 defaultRtl, bit2 accentOnTertiary (2.24.0), bit3 whiteGround (2.25.0), bits **4-5** navShell, bits **6-7** actionRow (2.28.0 — index 0 on both, so every older string decodes unchanged). **This byte is now FULL.** |
| 26 | 1 | motif | MOTIF index (`0` = `auto`, derive from glassTint — the byte was reserved and always `0` before 2.24.0, so every older string decodes unchanged) |
| 27 | 1 | checksum (v1) | `sum(bytes[0..26]) mod 256` |
| 27 | 1 | extension flags (v2) | bit0 `ruledRegister` (2.28.0); bits 1-7 reserved, written `0` |
| 28 | 1 | checksum (v2) | `sum(bytes[0..27]) mod 256` |

Result is ~42 characters. Seeds are quantised (L ±1/255 ≈ 0.4%, C ±0.001, tracking ±0.001em) — imperceptible for a seed, and the codec is **idempotent** (`encode(decode(x)) === x`).

## Registries (APPEND-ONLY)

The enum indices **are** the wire format. Never reorder or remove an entry — only append. A removed/reordered registry is a breaking change and needs a new version byte (`NO2-`).

```
FONTS  = [Hanken Grotesk, Bricolage Grotesque, Space Grotesk, Sora,
          IBM Plex Sans Arabic, Reem Kufi, Tajawal, Readex Pro, Noto Kufi Arabic]
LOGIN  = [depth-emblem, arcade-arches, light-grid-spark, shield-guilloche,
          paper-lockup, lockup-rule]
HERO   = [balance-cards, warm-balance-cards, wallet-hero, restrained-balance,
          statement-ledger, chevron-summary]
TONE   = [clear-calm, warm-hospitable, light-instant, formal-authoritative]
GLASS  = [oceanic, warm-amber, violet-luminous, navy-steel]
MOTION = [smooth-fluid, calm-graceful, light-quick-crisp, stable-minimal-authoritative]
MOTIF  = [auto, sonar-rings, coastal-arcs, grid-spark, guilloche, none]
NAV_SHELL  = [raised-dock, register-bar, rule-bar]      # flags bits 4-5 — FOUR ENTRIES MAX
ACTION_ROW = [filled-circles, register-rows, rule-grid]  # flags bits 6-7 — FOUR ENTRIES MAX
```

`NAV_SHELL` and `ACTION_ROW` are **two bits each, not a byte**. A fifth entry in either needs a
format change, not a list append — that is the cost of having spent the last free nibble.

## Determinism — the contract that makes it work

A brandprint stores **seeds**, not the 37 resolved roles. Two implementations agree **only if they generate the palette from the seed the same way.** Therefore:

1. **One palette algorithm, specified once.** Generate the M3 tonal palette from each seed with the same method everywhere (M3 HCT tonal palettes, or Odyssey's documented OKLCH ramp). Pin it in `neptune_tokens`; every platform calls the same logic (or a faithful port with a golden test).
2. **Golden test.** The four reference brands' brandprints must regenerate palettes equal to `build/tokens.resolved.json`. That test is the cross-platform guarantee.
3. **Version on change.** Any change to the algorithm, layout, or a registry bumps the version prefix; old brandprints keep resolving via the old path.

## Usage

```js
const BP = require('./tools/brandprint');           // or window.NeptuneBrandprint
const hash = BP.encode(config);                      // "NO1-AYygAQ…"
const config = BP.decode("NO1-AYygAQ…");             // throws on bad prefix/length/checksum/version
// then: theme = generateTheme(config)  // deterministic palette gen + lever application
```

```dart
// Flutter: port the 28-byte layout + base64url + checksum into neptune_tokens,
// golden-tested against tools/brandprint.js output for the 4 reference brands.
final cfg = Brandprint.decode('NO1-AYygAQ…');
final theme = NeptuneTheme.fromConfig(cfg);          // same palette algorithm as web
```

## The configurator (online)

A small web app over `tools/brandprint.js`: pick seeds (colour wheel), corner family, fonts, and the five lever enums; preview live against the reference screens; copy the `NO1-…` string. No backend needed — encode/decode are pure client-side. A brandprint *is* the saved theme.

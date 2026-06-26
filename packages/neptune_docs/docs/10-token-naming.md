# 10 · Token Naming

> Tokens are the public API of Neptune Odyssey. Their names are a contract — stable, predictable, and platform-portable. This is how they're named and namespaced.

## Two namespaces

| Prefix | Owns | Source |
|--------|------|--------|
| `--md-sys-color-*` | Material 3 **colour roles**. Standard M3 names, unchanged, so the system maps 1:1 to Flutter's `ColorScheme` and any M3 tool. | `tokens/themes.css` |
| `--npt-*` | Neptune additions M3 doesn't define: the per-brand **shape family**, **type set**, **display tuning**, and **brand-expression** (motif/emblem) tokens. | `tokens/themes.css` |

Rule: if Material 3 already names it, use the M3 name. Only reach for `--npt-` when M3 has no role for the concept.

## Colour roles (`--md-sys-color-*`)

Standard M3 role set. Every role has an `on-` pair for content placed on it.

```
primary / on-primary / primary-container / on-primary-container
secondary / … / tertiary / … / error / … / success / …      (success is a Neptune addition)
background / on-background / surface / on-surface
surface-variant / on-surface-variant
surface-container-lowest … surface-container-highest          (the 5-step tonal elevation ramp)
outline / outline-variant
inverse-surface / inverse-on-surface / inverse-primary
scrim
```

- **Never** use a raw palette tone in product code — always a role.
- Each brand redefines **every** role for light and `[data-mode="dark"]`.

## Neptune tokens (`--npt-*`)

### Shape — per-brand corner family
```
--npt-corner-xs-base   --npt-corner-sm-base   --npt-corner-md-base
--npt-corner-lg-base   --npt-corner-xl-base   --npt-corner-2xl-base
--npt-corner-full      (9999)
```
Components map to the *token*, not a pixel: chips/inputs → `sm`, cards → `md`, sheets/heros → `xl`, pills/FAB → `lg`/`full`. The `-base` suffix marks the raw per-brand value; a global `--npt-shape-scale` can multiply the family for density experiments.

### Type
```
--npt-font-display     --npt-font-text     --npt-font-num
--npt-font-display-ar  --npt-font-text-ar              (Arabic faces, swapped in under [dir="rtl"])
--npt-display-weight   --npt-display-tracking          (per-brand display tuning)
```

### Brand expression
```
--npt-motif            CSS background-image pattern (gradients only, uses currentColor)
--npt-motif-size       background-size for the pattern
--npt-motif-strength   opacity multiplier 0–1
--npt-hero-emblem      larger corner "emblem" gradient — the brand's hero gesture
```

## Conventions

- **Lower-kebab-case**, `namespace-category-role-variant` order: `--md-sys-color-on-primary-container`, `--npt-corner-lg-base`.
- The `on-` prefix always means "content drawn on the matching surface."
- `-container` = a lower-emphasis filled surface; `-variant` = a subtler sibling of the base role.
- No semantic meaning encoded in a *value* — meaning lives in the *name*. Two roles may share a value in one theme and diverge in another.

## Portability (codegen)

`tokens/tokens.json` is the structured (DTCG-ish) export. Target mappings:

| Target | Mapping |
|--------|---------|
| **Flutter** | `--md-sys-color-*` → `ColorScheme` members; `--npt-corner-*` → `ShapeThemeData` / `BorderRadius`; fonts → `TextTheme`. OKLCH → ARGB at build. See `04-flutter-implementation.md`. |
| **Web** | Consume the CSS custom properties directly; set `data-theme` / `data-mode` / `dir` on a wrapper. |
| **Other** | Style Dictionary / DTCG consumes `tokens.json`. |

## Don't

- ❌ Invent a parallel naming scheme (`--color-blue-500`, `--radius-2`). Use roles and the shape family.
- ❌ Hard-code a value where a token exists.
- ❌ Rename a token without a deprecation alias (it's a breaking change — see `09-governance-and-versioning.md`).

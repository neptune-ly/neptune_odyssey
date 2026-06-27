<!-- © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0 -->

# Neptune Odyssey — Theme Configurator

A small, **client-only** web app for the [Neptune Odyssey](https://neptune.ly)
vendor-neutral white-label banking design system. Pick theme inputs, watch a
realistic mini banking screen re-skin **live**, and copy a `NO1-…` _brandprint_
string that reproduces the exact theme in any Odyssey library (web, Flutter, …).

There is **no backend**. Brandprint encode/decode and palette resolution are pure
client-side, powered by `@neptune.fintech/tokens` and `@neptune.fintech/web-ui`.

## Run it

From the repo root (workspace already installed):

```bash
pnpm --filter @neptune.fintech/configurator run dev      # Vite dev server
pnpm --filter @neptune.fintech/configurator run build    # type-check + static build → dist/
pnpm --filter @neptune.fintech/configurator run preview  # preview the built bundle
pnpm --filter @neptune.fintech/configurator run test     # contrast unit tests
```

Or, inside `apps/configurator/`: `pnpm dev`.

## The brandprint workflow

1. **Start from a reference brand** (`neptune` / `triton` / `nereid` / `proteus`) to
   load its config into the controls.
2. **Tune** the inputs:
   - Primary & tertiary **OKLCH seeds** (L / C / H sliders, live swatch).
   - **Corner family** (`xs…xxl`), **fonts** (display / text / numerals),
     **display weight & tracking**.
   - Five **expression levers** — login shell, dashboard hero, content tone,
     glass tint, motion.
   - **Mode** (light / dark / system), **direction** (ltr / rtl / auto), and the
     baked `defaultDark` / `defaultRtl` flags.
3. **Watch the live preview** re-skin on every change.
4. **Copy** the `NO1-…` brandprint (top of the output panel) and paste it into any
   Odyssey app: `applyTheme(root, "NO1-…")`.
5. **Load** an existing brandprint back into the controls via the paste box — bad
   strings are caught and reported. A loaded brandprint round-trips:
   `encode(decode(x)) === x` for canonical strings.

## Accessibility (docs/08)

The app computes the **WCAG contrast ratio** for the key role pairs of the
**resolved** palette (primary/on-primary, secondary-container/on-secondary-container,
surface/on-surface, error/on-error, success/on-success) and shows each with a
PASS/FAIL badge against 4.5:1, plus a top-level warning if any pair fails. The
contrast math lives in [`src/contrast.ts`](./src/contrast.ts) and is unit-tested.

The configurator honours `prefers-reduced-motion` and shows visible focus rings.

## License

Neptune Odyssey Community License v1.0 — see [`LICENSE`](./LICENSE).

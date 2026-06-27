# @neptune-odyssey/demo

The **public demo gallery** for [Neptune Odyssey](https://github.com/neptune-ly/neptune_odyssey) —
a vendor-neutral, white-label banking design system by
[Neptune.Fintech](https://neptune.ly).

It is the showcase that ships to GitHub Pages. Everything you see is rendered
from the **real shipped components** (`@neptune-odyssey/web-ui`) — no mockups —
and re-skinned purely through CSS variables.

## What's inside

- **Global controls** — pick a brand, light/dark/system mode, and LTR/RTL/auto
  direction; they drive the showcase, archetypes and brandprint preview.
- **Brand matrix** — the same compact mobile screen, rendered once per
  brand × {light, dark} as eight independently-themed device frames, with a
  whole-matrix LTR↔RTL flip. This is the white-label range at a glance.
- **Product archetypes** — Retail mobile, Wallet, Web banking (desktop), and
  Corporate (approval queue + bulk-payment batch, maker-checker), each composed
  from the component kit.
- **Component showcase** — buttons, chips, badges, text fields (incl. an error
  state) and cards (standard/elevated/tonal/glass) under the selected theme.
- **Brandprint loader** — paste a `NO1-…` string to decode and apply a whole
  theme; copy the canonical brandprint for the selected brand; jump to the
  **configurator** to make your own.

The four brands — Neptune, Andalus, Nuran and FGLB — are **reference tenants
only**: illustrative skins that exercise the system, not real institutions.

## Develop

```bash
pnpm install          # from the repo root
pnpm --filter @neptune-odyssey/demo run dev      # vite dev server
pnpm --filter @neptune-odyssey/demo run build    # typecheck + production build
pnpm --filter @neptune-odyssey/demo run preview  # serve the built dist/
```

## Deployment

The gallery deploys to **GitHub Pages** from a subpath, so
`vite.config.ts` sets `base: "./"` — all asset URLs in the build are relative
(`./assets/…`). The configurator deploys as a sibling at `./configurator/`,
which is where the "Make your own theme" link points.

## License

© 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0 —
see [`LICENSE`](./LICENSE).

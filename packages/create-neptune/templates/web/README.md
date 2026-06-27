# {{PROJECT_TITLE}}

A [Neptune Odyssey](https://neptune-ly.github.io/neptune_odyssey/) starter — **web** (TypeScript + Vite), themed with the **{{BRAND}}** brand.

## Run

```bash
npm install
npm run dev
```

## How it's wired

`src/main.ts`:

```ts
import { applyTheme, registerAll } from "@neptune.fintech/web-ui";
import { registerIcons } from "@neptune.fintech/icons";
import "@neptune.fintech/web-ui/styles.css";

registerAll();   // define all <npt-*> components
registerIcons(); // define <npt-icon>
applyTheme(document.documentElement, "{{BRAND}}", { mode: "{{MODE}}", dir: "{{DIR}}" });
```

- **Theme** — swap `"{{BRAND}}"` for `neptune` / `triton` / `nereid` / `proteus`, or pass a
  `NO1-…` brandprint string from the [theme builder](https://neptune-ly.github.io/neptune_odyssey/apps/configurator/).
- **Components** — the dashboard in `src/dashboard.ts` uses `<npt-balance-card>`,
  `<npt-stat-card>`, `<npt-transaction-row>`, `<npt-quick-actions>` and `<npt-nav-bar>`.
  Browse them all in the [component gallery](https://neptune-ly.github.io/neptune_odyssey/components.html).
- **No literal colours** — components read `--md-sys-color-*`; the app styles do too.

© {{YEAR}} — built on Neptune Odyssey by Neptune.Fintech.

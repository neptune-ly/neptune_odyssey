# @neptune.fintech/create-neptune

Scaffold a themed **Neptune Odyssey** starter app — provider wired, a sample
dashboard screen, design-system styles imported, and a brandprint set — for any
of six frameworks.

```bash
# interactive
npx @neptune.fintech/create-neptune

# or one-liner
npx @neptune.fintech/create-neptune my-bank --framework react --brand triton
```

> `npm create @neptune.fintech/neptune my-bank` works too (npm rewrites the
> initializer to `@neptune.fintech/create-neptune`).

## Frameworks

| id             | stack                                            | built around                    |
| -------------- | ------------------------------------------------ | ------------------------------- |
| `web`          | TypeScript + Vite, web components, `applyTheme()` | `@neptune.fintech/web-ui`       |
| `react`        | React 18 + Vite, `<NeptuneProvider>` + `Npt*`     | `@neptune.fintech/react-ui`     |
| `vue`          | Vue 3 + Vite, `<NeptuneProvider>`                 | `@neptune.fintech/vue-ui`       |
| `svelte`       | Svelte 5 + Vite, `use:theme`                       | `@neptune.fintech/svelte-ui`    |
| `react-native` | Expo + React Native, `<NeptuneProvider>`          | `@neptune.fintech/react-native-ui` |
| `flutter`      | Flutter + Material 3, `NeptuneTheme`              | `neptune_flutter_ui`            |

Each scaffolded app depends on the **published** `@neptune.fintech/*` packages.

## Options

```
-f, --framework <id>   web | react | vue | svelte | react-native | flutter
-b, --brand <id>       neptune | triton | nereid | proteus   (default: neptune)
    --name <slug>      npm package name (default: from directory)
    --title <text>     display title (default: from name)
-m, --mode <mode>      light | dark | system                 (default: system)
-d, --dir <dir>        ltr | rtl | auto                       (default: ltr)
-y, --yes              accept defaults, no prompts
    --force            scaffold into a non-empty directory
-h, --help             show help
-v, --version          print version
```

`system` mode and `auto` direction are downgraded automatically for runtimes
that don't support them (React Native, Flutter).

## What you get

A single themed dashboard screen wired end-to-end: a balance card, stat tiles,
quick actions, a transaction list and a bottom navigation bar — every surface
reading Neptune design tokens, themed by the brand you pick. Swap the brand for a
`NO1-…` brandprint string from the
[theme builder](https://neptune-ly.github.io/neptune_odyssey/apps/configurator/)
to wear any tenant's skin.

- **Docs:** https://neptune-ly.github.io/neptune_odyssey/
- **Components:** https://neptune-ly.github.io/neptune_odyssey/components.html

## Programmatic use

```ts
import { scaffold } from "@neptune.fintech/create-neptune";

await scaffold({
  framework: "react",
  projectName: "my-bank",
  projectTitle: "My Bank",
  brand: "triton",
  mode: "system",
  dir: "ltr",
  targetDir: "/abs/path/my-bank",
});
```

© 2026 Neptune.Fintech (neptune.ly). Licensed under the Neptune Odyssey Community License v1.0.

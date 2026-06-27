// Neptune Odyssey — published package versions injected into scaffolded apps.
// © 2026 Neptune.Fintech (neptune.ly)
//
// Each scaffolded app depends on the PUBLISHED @neptune.fintech/* packages from
// npm (not workspace links). Bump these when a new line ships so freshly
// scaffolded apps pin a compatible range. Values are caret ranges of the
// versions live on npm.

/** Caret ranges for the @neptune.fintech/* packages a starter can depend on. */
export const NEPTUNE_VERSIONS = {
  tokens: "^2.0.0",
  webUi: "^2.2.0",
  icons: "^2.2.0",
  reactUi: "^2.0.0",
  vueUi: "^2.0.0",
  svelteUi: "^2.0.0",
  reactNativeUi: "^2.0.0",
  /** Flutter package — published to pub.dev; pinned by caret in pubspec. */
  flutter: "^2.0.0",
} as const;

/** Third-party tool versions used by the starter toolchains. */
export const TOOLING_VERSIONS = {
  vite: "^5.4.11",
  typescript: "^5.6.3",
  react: "^18.3.1",
  reactDom: "^18.3.1",
  reactTypes: "^18.3.12",
  reactDomTypes: "^18.3.1",
  viteReact: "^4.3.4",
  vue: "^3.5.13",
  viteVue: "^5.2.1",
  vueTsc: "^2.1.10",
  svelte: "^5.16.0",
  // v4 of the plugin supports Svelte 5 on Vite 5 (v5 of the plugin needs Vite 6).
  viteSvelte: "^4.0.0",
  svelteCheck: "^4.1.1",
  expo: "~52.0.0",
  expoStatusBar: "~2.0.0",
} as const;

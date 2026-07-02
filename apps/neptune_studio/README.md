# Neptune Odyssey Studio

The desktop GUI for the client-demo factory (R5c) — a point-and-click
counterpart to `tools/client-demo/generate.mjs`. Drop a bank's logo, watch
its brand seeds get extracted live, tune the tone, preview the real
`NeptuneWelcome` screen in a phone frame, then **Generate & run** builds and
launches a fully branded `NeptuneDemoShellApp` on macOS.

This is internal dev tooling, not a published package. It is never
Mac-App-Store distributed, which is why its `Runner.entitlements` disable
App Sandbox — Studio needs to write into the sibling
`packages/neptune_flutter_ui/example` directory and shell `flutter build`/
`open`, neither of which App Sandbox permits.

## Run it

```sh
cd apps/neptune_studio
flutter pub get
flutter run -d macos
```

## What it does

1. Pick a logo (PNG/JPG/PDF). PDFs rasterize via `sips`; any image is then
   colour-matched to sRGB via `sips -m` before decoding — design-tool
   exports are routinely tagged Display P3, and reading P3 bytes as sRGB
   shifts hues badly (see `ODYSSEY_RULEBOOK.md` §9).
2. `extractSeedsFromRgba` (from `neptune_flutter_ui`) finds the dominant
   primary/accent colours — the same algorithm as the CLI's
   `extract_colors.py`, ported to Dart so Studio needs no Python.
3. Override either seed by hex, pick a tone preset, toggle dark/Arabic.
4. The right pane is a live `NeptuneWelcome` themed with the current
   `BrandprintConfig` — what you see is what ships.
5. **Generate & run** writes gitignored `client_config.dart`/
   `client_main.dart` into `packages/neptune_flutter_ui/example/lib/` (the
   same files the CLI writes) and builds/launches the example app.

See `tools/client-demo/README.md` for the CLI path, and
`ODYSSEY_RULEBOOK.md` §8 for the full client-prototype playbook.

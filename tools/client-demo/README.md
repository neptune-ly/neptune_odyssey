# Client-demo factory

Turn a client's logo into a running, branded, bilingual (EN/AR) demo app in
one command.

```sh
node tools/client-demo/generate.mjs \
  --logo "path/to/logo.pdf" \
  --name "Bank Name" \
  --name-ar "اسم المصرف" \
  --tone formal \
  --run
```

## What it does

1. **`extract_colors.py`** rasterizes PDFs (`sips`) and finds the two most
   saturated, sufficiently-distinct dominant colours in the logo — the
   primary mark colour and an accent.
2. **`generate.mjs`** converts both hexes to OKLCH seeds (the same colour
   space every Odyssey brand is built from), picks a fitting set of identity
   levers from a `--tone` preset (`formal | friendly | modern | calm`), and
   writes a `BrandprintConfig`.
3. It emits two gitignored files into `packages/neptune_flutter_ui/example/`:
   `lib/client_config.dart` (the config + logo widget) and
   `lib/client_main.dart` (a five-line entrypoint that hands the config to
   [`NeptuneDemoShellApp`](../../packages/neptune_flutter_ui/lib/src/templates/neptune_demo_shell.dart)
   — the public library widget that turns any brandprint into a full
   Welcome-screen-then-5-tab-app demo).
4. With `--run`, it builds the macOS app and opens it.

## Options

| Flag | Default | Notes |
|---|---|---|
| `--logo <path>` | — | PDF/PNG/JPG, required |
| `--name <text>` | — | English bank name, required |
| `--name-ar <text>` | `--name` | Arabic bank name |
| `--primary <#hex>` | auto-extracted | Override if the logo's dominant colour isn't the brand colour |
| `--tertiary <#hex>` | auto-extracted | Override the accent |
| `--tone <preset>` | `formal` | `formal` (navy-steel/Sora), `friendly` (warm-amber/Bricolage), `modern` (violet/Space Grotesk), `calm` (oceanic/Hanken) |
| `--run` | off | Build + `open` the macOS app after generating |

## Client material never enters the repo

`ODYSSEY_RULEBOOK.md` §7: pub.dev bundles `example/`, and this is a public
repo. `client_config.dart`, `client_main.dart` and `assets/client_logo.png`
match the `**/lib/client_*` / `**/assets/client_*` patterns in `.gitignore`
— they're never staged, never published. Regenerate them any time; nothing
is lost by deleting them.

## Requirements

- Python 3 with Pillow (`pip3 install pillow`) — used for colour extraction.
- macOS `sips` (built-in) — used to rasterize PDF logos.
- The Flutter SDK, for `--run`.

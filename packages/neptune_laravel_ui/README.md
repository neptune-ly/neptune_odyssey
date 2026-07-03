# neptune-fintech/laravel-ui

Neptune Odyssey for Laravel — Blade components over `@neptune.fintech/web-ui`
(the framework-agnostic custom-element kit), the same relationship the Vue
layer (`packages/neptune_vue_ui`) has to it. The custom elements do the
actual rendering (themed entirely by CSS variables); this package's job is
to make them feel native to write in Blade, and to get their JS/CSS into a
Laravel app **with no Node/npm build step required** for the four reference
brands.

## Why a real package, not just a styles.css import

React/Vue/Svelte each get an npm package because their apps already have a
JS bundler that resolves `node_modules` imports. Laravel apps often don't
want (or need) one just to render server-side HTML — so this package
vendors the web kit's *already-built* JS/CSS (`resources/dist/`, synced via
`tools/sync-assets.mjs`) and publishes it straight into your `public/`
directory. Write `<x-neptune::cta arrow>Get started</x-neptune::cta>` in a
Blade view; get real `<npt-cta>` markup with zero build tooling on the PHP
side.

## Install

```sh
composer require neptune-fintech/laravel-ui
php artisan vendor:publish --tag=neptune-ui-assets
```

Add once, near the end of your layout's `<head>` (or before `</body>`):

```blade
<html data-theme="triton" data-mode="light" dir="ltr">
  <head>
    ...
    <x-neptune::assets />
  </head>
```

The `data-theme`/`data-mode`/`dir` attributes on `<html>` are the *entire*
theming mechanism for the four reference brands (`neptune`, `triton`,
`nereid`, `proteus`) — pure CSS variables, already defined in the vendored
`themes.css`. No JS call needed to re-skin; change the attribute, the whole
page re-themes.

## Use the components

```blade
<x-neptune::balance-card label="Available balance" amount="12,480.50"
    currency="LYD" account="•••• 4821" hero />

<x-neptune::cta arrow>Send money</x-neptune::cta>

<x-neptune::alert tone="warning" title="Heads up" dismissible>
    Your session will expire in 5 minutes.
</x-neptune::alert>

<x-neptune::dialog :open="$showConfirm" headline="Confirm transfer">
    Send {{ $amount }} to {{ $payee }}?
    <x-slot:actions>
        <x-neptune::button variant="text">Cancel</x-neptune::button>
        <x-neptune::button>Confirm</x-neptune::button>
    </x-slot:actions>
</x-neptune::dialog>
```

Shipped today: `button`, `cta`, `card`, `alert`, `badge`, `chip`, `switch`,
`checkbox`, `text-field`, `dialog`, `balance-card`, `transaction-row`,
`skeleton`, `dock` + `dock-item`. The web kit has ~89 components total (see
`packages/neptune_web_ui/src/components/`) — every one already works as raw
`<npt-*>` markup once `<x-neptune::assets />` has run `registerAll()`; the
Blade wrappers above just make the common ones feel native to write. Adding
a wrapper for any other one is mechanical:

1. Read its doc-comment in `neptune_web_ui/src/components/*.ts` for the
   exact attribute names (e.g. `<npt-progress value="60" max="100">`).
2. Copy an existing `.blade.php` in `resources/views/components/`, rename it,
   swap the `@props` list and the emitted attributes.
3. It's usable immediately as `<x-neptune::your-new-component>` — no
   registration step (`Blade::anonymousComponentPath` picks up every file in
   that directory).

## Custom brandprints (beyond the 4 reference brands)

The vendored `register.js` only imports *relative* paths, so it works as a
plain static ES module with no bundler. Full theming (`buildTheme`,
`applyTheme` for a client's own OKLCH seeds) needs
`@neptune.fintech/tokens`, which `register.js` deliberately does NOT import
— that's a real npm dependency needing real module resolution. If you need
that, wire `@neptune.fintech/web-ui` + `@neptune.fintech/tokens` through your
app's own Vite build (Laravel ships Vite by default since Laravel 9) rather
than through this package's static assets — this package's job is "zero
build step for the reference brands," not "replace your bundler."

## Keeping the vendored assets in sync

```sh
cd packages/neptune_web_ui && npm run build   # rebuild the web kit
cd ../neptune_laravel_ui && node tools/sync-assets.mjs
```

Bump this package's version alongside `@neptune.fintech/web-ui`'s when you do.

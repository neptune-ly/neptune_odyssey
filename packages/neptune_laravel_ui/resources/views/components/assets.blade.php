{{--
    © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

    Loads the vendored Odyssey CSS + registers every <npt-*> custom element.
    Put this once, near the end of <head> or before </body>:

        <x-neptune::assets />

    Requires `php artisan vendor:publish --tag=neptune-ui-assets` to have been
    run at least once (copies resources/dist into public/vendor/neptune-ui).
--}}
@props(['theme' => 'neptune', 'mode' => 'light', 'dir' => 'ltr'])

<link rel="stylesheet" href="{{ asset('vendor/neptune-ui/neptune-odyssey.css') }}">
<link rel="stylesheet" href="{{ asset('vendor/neptune-ui/themes.css') }}">
<script type="module">
    import { registerAll } from "{{ asset('vendor/neptune-ui/js/register.js') }}";
    registerAll();
</script>
{{--
    Reference-brand theming needs no further JS — set these three attributes
    on <html> (or any ancestor) and the CSS variables in themes.css do the
    rest: data-theme="{{ $theme }}" data-mode="{{ $mode }}" dir="{{ $dir }}"

    A custom brandprint (not one of the 4 reference brands) needs
    @neptune.fintech/tokens + web-ui's `buildTheme`/`applyTheme`, which import
    a bare module specifier this vendored copy can't resolve on its own —
    wire that through your app's own Vite build (Laravel ships Vite by
    default) rather than through this package's static assets.
--}}

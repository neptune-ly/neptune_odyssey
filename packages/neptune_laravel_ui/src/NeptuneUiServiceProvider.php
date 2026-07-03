<?php

namespace Neptune\Ui;

use Illuminate\Support\Facades\Blade;
use Illuminate\Support\ServiceProvider;

/**
 * © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
 *
 * Registers the `<x-neptune::*>` anonymous Blade component namespace (thin
 * wrappers that emit the same `<npt-*>` custom-element markup the web kit's
 * other framework layers target — Vue's src/index.ts is the sibling to read
 * alongside this) and publishes the vendored JS/CSS so a consuming app can
 * copy them into its own `public/` directory with zero Node/npm step.
 */
class NeptuneUiServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        Blade::anonymousComponentPath(__DIR__ . '/../resources/views/components', 'neptune');

        $this->publishes([
            __DIR__ . '/../resources/dist' => public_path('vendor/neptune-ui'),
        ], 'neptune-ui-assets');
    }

    public function register(): void
    {
        //
    }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Pinned M3 colour schemes for the four reference brands — resolved from the
// single source of truth (packages/neptune_tokens/assets/themes.css) by
// `node tools/codegen.mjs`. Do not hand-edit colours; edit themes.css and
// regenerate. `node tools/codegen.mjs --check` is the CI drift gate.

import 'package:flutter/material.dart';

import 'generated/brand_data.g.dart';

/// Brand id → (light, dark) ColorScheme for the four reference brands.
final Map<String, (ColorScheme light, ColorScheme dark)> neptuneSchemes =
    genSchemes;

// Named accessors kept for API compatibility.
ColorScheme get neptuneLight => genSchemes['neptune']!.$1;
ColorScheme get neptuneDark => genSchemes['neptune']!.$2;
ColorScheme get tritonLight => genSchemes['triton']!.$1;
ColorScheme get tritonDark => genSchemes['triton']!.$2;
ColorScheme get nereidLight => genSchemes['nereid']!.$1;
ColorScheme get nereidDark => genSchemes['nereid']!.$2;
ColorScheme get proteusLight => genSchemes['proteus']!.$1;
ColorScheme get proteusDark => genSchemes['proteus']!.$2;

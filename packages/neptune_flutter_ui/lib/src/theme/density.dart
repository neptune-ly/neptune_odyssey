// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The density lever (R6): comfortable (default, unchanged from pre-R6
// spacing) vs compact — a single scale factor applied to padding/min-heights
// at the density-aware call sites. Scoped rollout: NeptuneListTile and the
// NeptuneCta/button family are density-aware today (the highest-frequency
// layout-affecting widgets); see ODYSSEY_RULEBOOK.md §"Density" for the
// current coverage list before assuming a widget responds to this lever.

import 'package:flutter/material.dart';

enum NeptuneDensityMode { comfortable, compact }

/// A single spacing-scale multiplier, read by density-aware widgets to scale
/// their padding/min-heights. 1.0 leaves pre-R6 spacing exactly as it was.
@immutable
class NptDensity extends ThemeExtension<NptDensity> {
  final double scale;

  const NptDensity(this.scale);

  factory NptDensity.of(NeptuneDensityMode mode) => NptDensity(
      mode == NeptuneDensityMode.compact ? 0.82 : 1.0);

  double s(double v) => v * scale;

  @override
  NptDensity copyWith({double? scale}) => NptDensity(scale ?? this.scale);

  @override
  NptDensity lerp(ThemeExtension<NptDensity>? other, double t) {
    if (other is! NptDensity) return this;
    return NptDensity(scale + (other.scale - scale) * t);
  }
}

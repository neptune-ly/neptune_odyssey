// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Haptic + sound tokens (R6). Haptics are wired to the real platform API
// (Flutter's HapticFeedback — no asset needed, works today on iOS/Android).
// Sound is a HOOK, not bundled audio: Neptune Odyssey ships no .wav/.mp3
// files, so NptSound exposes a named-cue callback a host app wires to its
// own audio playback. Calling code should always go through NptFeedback so
// both levers can be disabled together (accessibility, silent-mode UX).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Named feedback moments — brands can tune weight/cue per moment without
/// call sites needing to know the mapping.
enum NptFeedbackCue { tap, success, warning, error }

/// How firmly haptics land for a brand (web-adjacent to `contentTone`:
/// formal/authoritative brands land lighter, warm/playful brands heavier).
enum NptHapticWeight { light, medium, heavy }

/// Haptic + sound levers, resolved per brand. Read via
/// `Theme.of(context).extension<NptFeedback>()!.trigger(cue)`.
@immutable
class NptFeedback extends ThemeExtension<NptFeedback> {
  final bool hapticsEnabled;
  final NptHapticWeight hapticWeight;

  /// Sound hook — null (the default) means silent. A host app assigns this
  /// to play its own audio cues; Neptune Odyssey never plays sound itself.
  final void Function(NptFeedbackCue cue)? onSoundCue;

  const NptFeedback({
    this.hapticsEnabled = true,
    this.hapticWeight = NptHapticWeight.medium,
    this.onSoundCue,
  });

  /// Fire [cue]: real haptic impact (if enabled) + the sound hook (if wired).
  void trigger(NptFeedbackCue cue) {
    if (hapticsEnabled) _haptic(cue);
    onSoundCue?.call(cue);
  }

  void _haptic(NptFeedbackCue cue) {
    final weight = switch (cue) {
      NptFeedbackCue.error => NptHapticWeight.heavy,
      NptFeedbackCue.warning => NptHapticWeight.medium,
      _ => hapticWeight,
    };
    switch (weight) {
      case NptHapticWeight.light:
        HapticFeedback.selectionClick();
      case NptHapticWeight.medium:
        HapticFeedback.mediumImpact();
      case NptHapticWeight.heavy:
        HapticFeedback.heavyImpact();
    }
  }

  @override
  NptFeedback copyWith({
    bool? hapticsEnabled,
    NptHapticWeight? hapticWeight,
    void Function(NptFeedbackCue cue)? onSoundCue,
  }) =>
      NptFeedback(
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        hapticWeight: hapticWeight ?? this.hapticWeight,
        onSoundCue: onSoundCue ?? this.onSoundCue,
      );

  @override
  NptFeedback lerp(ThemeExtension<NptFeedback>? other, double t) {
    if (other is! NptFeedback) return this;
    return t < 0.5 ? this : other;
  }
}

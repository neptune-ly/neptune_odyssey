// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The optional sound half of the R6 feedback lever. neptune_flutter_ui ships
// NptFeedback.onSoundCue as a hook and nothing else — no bundled audio, no
// audio-plugin dependency in the core UI package. This package is that hook's
// natural implementation: four short, synthesized (see tools/synthesize.mjs —
// sine partials + an ADSR envelope, not recordings) chimes played via
// `audioplayers`. Kept separate so apps that don't want sound (or don't want
// the native audio-plugin dependency) never pay for it.

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

/// The cue -> bundled asset mapping, as full `AssetSource` paths (this
/// package's assets need the Flutter `packages/<name>/` prefix). Public so a
/// host app can swap in its own chimes without forking this package — a
/// custom map just needs paths [AssetSource] can resolve directly, which for
/// the host app's OWN assets means no `packages/` prefix at all.
const Map<NptFeedbackCue, String> neptuneSoundAssets = {
  NptFeedbackCue.tap: 'packages/neptune_sound_kit/assets/sfx/tap.wav',
  NptFeedbackCue.success: 'packages/neptune_sound_kit/assets/sfx/success.wav',
  NptFeedbackCue.warning: 'packages/neptune_sound_kit/assets/sfx/warning.wav',
  NptFeedbackCue.error: 'packages/neptune_sound_kit/assets/sfx/error.wav',
};

/// Plays the bundled cue chimes and exposes an [NptFeedback.onSoundCue]-
/// compatible callback.
///
/// ```dart
/// final sound = NeptuneSoundKit();
/// NeptuneTheme.light('proteus', feedback: NptFeedback(onSoundCue: sound.play));
/// ```
class NeptuneSoundKit {
  final AudioPlayer _player;
  final Map<NptFeedbackCue, String> _assetByCue;
  bool muted;

  /// [assetByCue] defaults to the bundled chimes; pass a custom map (any
  /// asset path, any package) to re-skin the sound set without forking.
  NeptuneSoundKit({
    AudioPlayer? player,
    Map<NptFeedbackCue, String> assetByCue = neptuneSoundAssets,
    this.muted = false,
  })  : _player = player ?? AudioPlayer(playerId: 'neptune_sound_kit'),
        _assetByCue = assetByCue;

  /// Play the chime for [cue]. Matches the `void Function(NptFeedbackCue)`
  /// shape [NptFeedback.onSoundCue] expects — pass this method directly.
  void play(NptFeedbackCue cue) {
    if (muted) return;
    final asset = _assetByCue[cue];
    if (asset == null) return;
    // Fire-and-forget: a feedback cue should never block the interaction
    // that triggered it, and a playback failure (no audio device, etc.)
    // shouldn't surface as an app error.
    unawaited(_player.play(AssetSource(asset)).catchError((_) {}));
  }

  Future<void> dispose() => _player.dispose();
}

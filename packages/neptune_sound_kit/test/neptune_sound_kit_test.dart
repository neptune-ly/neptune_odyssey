// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';
import 'package:neptune_sound_kit/neptune_sound_kit.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  // audioplayers talks to real platform channels even just to construct an
  // AudioPlayer (it calls a "global" init method) — stub both channels so
  // the kit can be exercised in a VM test without a real audio backend.
  for (final channel in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      MethodChannel(channel),
      (call) async => null,
    );
  }

  test('every NptFeedbackCue has a bundled asset', () {
    for (final cue in NptFeedbackCue.values) {
      expect(neptuneSoundAssets.containsKey(cue), isTrue, reason: '$cue has no asset mapped');
    }
  });

  // Bundled asset paths carry the Flutter `packages/neptune_sound_kit/`
  // prefix (needed by AssetSource at runtime); strip it to check the file
  // on disk relative to this package's own root.
  String localPath(String assetSourcePath) =>
      assetSourcePath.replaceFirst('packages/neptune_sound_kit/', '');

  test('every bundled asset exists on disk', () {
    for (final asset in neptuneSoundAssets.values) {
      final path = localPath(asset);
      expect(File(path).existsSync(), isTrue, reason: 'missing $path');
    }
  });

  test('a valid 44-byte WAV header (RIFF/WAVE) for each asset', () {
    for (final asset in neptuneSoundAssets.values) {
      final bytes = File(localPath(asset)).readAsBytesSync();
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
    }
  });

  test('muted kit never touches the player', () {
    final kit = NeptuneSoundKit(muted: true);
    expect(() => kit.play(NptFeedbackCue.success), returnsNormally);
  });

  test('a custom asset map lets a host app re-skin the chimes', () {
    final custom = NeptuneSoundKit(assetByCue: const {NptFeedbackCue.tap: 'sfx/custom-tap.wav'});
    // Cues absent from a custom map are silently ignored (no throw).
    expect(() => custom.play(NptFeedbackCue.error), returnsNormally);
  });
}

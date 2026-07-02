# neptune_sound_kit

The sound half of Neptune Odyssey's R6 feedback lever. `neptune_flutter_ui`
ships `NptFeedback.onSoundCue` as a hook and **no bundled audio** — the core
UI package stays lightweight and has no audio-plugin dependency. This package
is the natural implementation of that hook: four short chimes, synthesized
(not recorded — see `tools/synthesize.mjs`, sine partials + an ADSR envelope,
the same technique behind most platform system sounds), played via
[`audioplayers`](https://pub.dev/packages/audioplayers).

## Why a separate package

- Apps that don't want sound (or don't want a native audio-plugin dependency)
  never pay for it — `neptune_flutter_ui` has zero audio code.
- Matches this monorepo's existing pattern: optional concerns (web framework
  adapters, the client-demo CLI, this) live in their own package, not bolted
  onto the core.
- `NptFeedback.onSoundCue` is a plain callback, so wiring in your own sound
  design instead of this one is just as easy as using it.

## Use it

```dart
import 'package:neptune_sound_kit/neptune_sound_kit.dart';

final sound = NeptuneSoundKit();

MaterialApp(
  theme: NeptuneTheme.light('proteus', feedback: NptFeedback(onSoundCue: sound.play)),
  // ...
);
```

Every `NeptuneCta` press, `NeptuneSwitch`/`NeptuneCheckbox` toggle, etc.
already calls `NptFeedback.trigger(...)` — wiring `onSoundCue` here is the
only step required to hear it.

## The four cues

| Cue | Feel | File |
| --- | --- | --- |
| `tap` | a very quiet, short click — fires on every interaction | `assets/sfx/tap.wav` (50ms) |
| `success` | a rising two-note chime (E5 → C6) | `assets/sfx/success.wav` (440ms) |
| `warning` | a soft double pulse at one pitch (G5) | `assets/sfx/warning.wav` (250ms) |
| `error` | a gentle downward slide (D5 → G4) — flags without buzzing | `assets/sfx/error.wav` (420ms) |

Regenerate with `node tools/synthesize.mjs` after tuning the pitches/envelopes
in that file — no audio-editing tools required, everything is generated math.

## Re-skinning

Pass a custom `assetByCue` map to use your own chimes instead:

```dart
NeptuneSoundKit(assetByCue: {
  NptFeedbackCue.success: 'assets/my_chime.wav', // your own app's asset — no `packages/` prefix needed
  // cues you omit are silently ignored (no playback, no error)
});
```

## Status

Not yet published to pub.dev (`publish_to: none`) — the synthesized chimes
haven't been listened-to-and-approved yet. Depend on it via a path/git
dependency until then.

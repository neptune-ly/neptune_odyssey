import 'package:flutter_test/flutter_test.dart';
import 'package:neptune_flutter_ui/src/color/oklch.dart';
import 'package:neptune_flutter_ui/src/color/palette.dart';

/// THE GROUND LEVER MAY NOT REACH A RESERVED ROLE.
///
/// `warmGround` is fed the brand's tertiary seed. On a brand that also sets
/// `accentOnTertiary` that seed is the ACCENT, and the accent's whole contract
/// is that it feeds `NptColors.accent` and no Material role — so it cannot
/// collide with an error state and cannot be spent twice on one screen.
///
/// `primary-container` and `on-primary-container` were tinted to the ground's
/// hue, which on such a brand meant the accent's: FGLB's light scheme drew a
/// pink square with near-black-red ink on every account row while its primary
/// was navy. It was invisible in dark, because the ground lever resolves to
/// the PRIMARY hue there — the same line of code, correct in one brightness
/// and wrong in the other.
///
/// This is the guard. It compares the generated role against the SAME palette
/// generated with no warm ground at all: if the ground lever is reaching the
/// role, the two differ.
void main() {
  // FGLB, verbatim from the app's brandprints.dart: a navy primary and a
  // vermilion accent 232 degrees away, which is what makes the leak legible
  // rather than a rounding difference.
  const primary = Oklch(0.40, 0.125, 264);
  const accent = Oklch(0.615, 0.205, 32);

  const reserved = ['primary-container', 'on-primary-container'];

  for (final mode in const ['light', 'dark']) {
    test('warmGround does not reach the primary container roles — $mode', () {
      final warmed =
          generatePalette(primary, accent, mode, warmSeed: accent);
      final plain = generatePalette(primary, accent, mode);

      for (final role in reserved) {
        expect(
          warmed[role],
          plain[role],
          reason: '$role must ramp from the PRIMARY seed whatever the ground '
              'is. A brand that declares an accent has said that colour means '
              'one thing; a Material role wearing it means two.',
        );
      }
    });
  }

  test('the ground lever still reaches the ground', () {
    // The inverse assertion, so a future fix for the above cannot be "stop
    // warming anything" — that would silently undo the lever this test's
    // subject exists alongside.
    final warmed = generatePalette(primary, accent, 'light', warmSeed: accent);
    final plain = generatePalette(primary, accent, 'light');
    expect(warmed['surface'], isNot(plain['surface']),
        reason: 'warmGround is what makes the page a cream rather than a '
            'blue-grey; if this passes, the lever has become a no-op');
  });

  test('a brand with no warm ground is untouched by any of this', () {
    // Andalus's seeds. Neither it nor Nuran sets `warmGround`, so the whole
    // mechanism must be inert for them — stated here rather than left to be
    // rediscovered by diffing screenshots.
    const andalusPrimary = Oklch(0.562, 0.209, 261);
    const andalusTertiary = Oklch(0.44, 0.16, 285);
    for (final mode in const ['light', 'dark']) {
      expect(
        generatePalette(andalusPrimary, andalusTertiary, mode),
        generatePalette(andalusPrimary, andalusTertiary, mode, warmSeed: null),
        reason: 'no warm seed, no difference, in $mode',
      );
    }
  });
}

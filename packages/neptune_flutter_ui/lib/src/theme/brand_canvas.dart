// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The pre-login brand canvas: the one surface that does NOT follow the theme
// brightness. Derived from the LIGHT scheme inside `NeptuneTheme._assemble`
// and carried on every ThemeData the library builds, dark included.
// Flutter-only for now — there is no web/Studio token for it yet.

import 'package:flutter/material.dart';

/// The colours of the **brand canvas** — the full-bleed brand surface a
/// customer meets before they are signed in: splash, welcome, login, unlock.
///
/// ## Why this exists, and why it ignores the theme brightness
///
/// `colorScheme.primary` is a Material *role*, not a brand colour. Material 3
/// deliberately re-tones roles for dark mode, so the same brandprint yields:
///
/// | role        | light     | dark      |
/// |-------------|-----------|-----------|
/// | `primary`   | `#0050D0` | `#508EFD` |
/// | `onPrimary` | `#F4FCFF` | `#000153` |
///
/// Painting a brand canvas with `primary` therefore turned a bank's blue into
/// a washed-out `#508EFD` in dark mode, and flipped the headline, the bank
/// name and the CTA label from near-white to near-black — dark text on a light
/// field, which is what made the whole surface look broken.
///
/// That re-toning is correct for *chrome* (buttons, chips, links inside a dark
/// app) and wrong for *identity*. A bank's blue is the same blue at midnight.
/// Every splash screen in the wild works this way: Viator, Strava, Substack
/// and Too Good To Go all hold their brand colour regardless of system theme.
///
/// So these colours are computed from the brandprint's **light** scheme and
/// used unchanged in both brightnesses — the same rule the card-art roles on
/// [ThemeExtension] `NptColors` already follow. The pre-login ritual is one
/// fixed brand moment; the themed app begins after the customer is inside.
///
/// A host's native splash colour should be [canvas], so the native → Flutter
/// handover is a cut and not a colour jump.
@immutable
class NptBrandCanvas extends ThemeExtension<NptBrandCanvas> {
  /// The bank's colour. The SAME value in light and dark.
  final Color canvas;

  /// Content on [canvas] — near-white, so it reads in both themes.
  final Color onCanvas;

  /// Secondary content on [canvas]: subtitles, helper copy.
  final Color onCanvasMuted;

  /// A card floating on the canvas — the surface that holds input fields.
  ///
  /// Also fixed. A card whose fill follows the theme while its canvas does not
  /// is exactly how "white text on white" happens.
  final Color card;

  /// Content inside [card].
  final Color onCard;

  /// Secondary content inside [card] — hints, labels, helper text.
  final Color onCardMuted;

  /// Hairlines and field outlines inside [card].
  final Color cardOutline;

  /// THE CANVAS WITH A BELOW: the brand's ground taken deep enough that the
  /// brand's OWN objects can float on it.
  ///
  /// It exists because of a specific, repeatable failure. A card's gradient
  /// starts at the brand's primary, and [canvas] IS the brand's primary — so
  /// the moment a scene puts a real card face on the brand ground, the card is
  /// the ground and disappears. Every brand hits this, not one, because both
  /// values come from the same role by design.
  ///
  /// The rule is a lerp toward the scheme's own `scrim`, at 0.70. A lerp to
  /// black leaves hue and chroma untouched and moves only lightness, so this
  /// is still unmistakably the bank's colour and not a second, invented
  /// navy — the same kind of stated relationship as [onCanvasMuted]'s 82%. It
  /// is FIXED ACROSS BRIGHTNESS like everything else here: a ground that got
  /// lighter at night would be the inversion this class exists to prevent.
  ///
  /// [onCanvas] is the ink for it too. It is near-white and already had to
  /// clear [canvas]; a darker ground can only improve that, never worsen it.
  ///
  /// WHAT IT DOES NOT PROMISE, and this matters more than what it does. For a
  /// brand whose primary is ALREADY dark, no amount of darkening will separate
  /// the ground from that brand's own card by luminance: both are the same
  /// deep colour, and the ratio asymptotes below 2:1 however far down the
  /// ground goes. That is not a tuning failure, it is arithmetic, and reaching
  /// for a lighter ground to "fix" it would mean inventing a colour the bank
  /// does not own — the exact mistake [NptBrandScheme] exists to stop. A dark
  /// object on a dark ground reads the way a dark object reads in a dark room:
  /// by its EDGE and its shadow. A scene placing one here owes it a rim and a
  /// contact shadow; this role owes it a ground that is unmistakably behind
  /// it, and a ground that near-white ink can still be set on.
  final Color deep;

  /// Error ink for content INSIDE [card] — a field's error ring and its
  /// label. Taken from the brandprint's LIGHT scheme, because the card is a
  /// light surface whatever the app brightness is.
  ///
  /// There is deliberately no matching colour for errors on [canvas]. Material
  /// defines no "error on primary" role, and none of the tones in the error
  /// family reaches 4.5:1 against a saturated primary: measured on `#0050D0`,
  /// the dark scheme's `error` is 3.2:1 and every darker tone is worse. So an
  /// error MESSAGE, which renders below the field and therefore outside the
  /// card, is drawn in [onCanvas] at full strength — brighter and heavier
  /// than the 82% [onCanvasMuted] helper text beside it — and the red is spent
  /// where it can be seen: on the ring and label inside the card.
  final Color onCardError;

  /// The rule behind [deep], in one place so no factory can disagree with
  /// another about how far down the brand's ground goes.
  static Color deepen(Color canvas, Color scrim) =>
      Color.lerp(canvas, scrim, 0.70)!;

  const NptBrandCanvas({
    required this.canvas,
    required this.onCanvas,
    required this.onCanvasMuted,
    required this.card,
    required this.onCard,
    required this.onCardMuted,
    required this.cardOutline,
    required this.onCardError,
    required this.deep,
  });

  /// The PAPER canvas: the same eight roles for a pre-login shell that puts
  /// the lockup on a plain ground (`loginShell` `paper-lockup` /
  /// `lockup-rule`) instead of on the bank's colour.
  ///
  /// Unlike [fromLightScheme] this one DOES re-tone with brightness - that is
  /// the point of the paper shell: it is a surface, not an identity moment,
  /// so it follows the theme the way every other surface does. Pass the
  /// ambient `colorScheme`. Every login helper that takes an [NptBrandCanvas]
  /// then renders on paper with no change of its own.
  factory NptBrandCanvas.paper(ColorScheme scheme) {
    return NptBrandCanvas(
      canvas: scheme.surface,
      onCanvas: scheme.onSurface,
      onCanvasMuted: scheme.onSurfaceVariant,
      card: scheme.surfaceContainerLow,
      onCard: scheme.onSurface,
      onCardMuted: scheme.onSurfaceVariant,
      cardOutline: scheme.outlineVariant,
      onCardError: scheme.error,
      deep: deepen(scheme.surface, scheme.scrim),
    );
  }

  /// The paper canvas of a FINISHED theme: [paper] over its colour scheme,
  /// with the ground taken from the theme's own `scaffoldBackgroundColor`
  /// rather than from `surface` - which differ under the white register
  /// (`BrandprintConfig.whiteGround`). A pre-login shell built from this sits
  /// on exactly the ground every screen after sign-in sits on.
  factory NptBrandCanvas.paperOf(ThemeData theme) =>
      NptBrandCanvas.paper(theme.colorScheme)
          .copyWith(canvas: theme.scaffoldBackgroundColor);

  /// Derives the canvas from a brandprint's LIGHT scheme, whatever brightness
  /// the surrounding theme is in. `NeptuneTheme` calls this with the light
  /// scheme when assembling BOTH brightnesses.
  factory NptBrandCanvas.fromLightScheme(ColorScheme light) {
    return NptBrandCanvas(
      canvas: light.primary,
      onCanvas: light.onPrimary,
      onCanvasMuted: light.onPrimary.withValues(alpha: 0.82),
      card: light.surface,
      onCard: light.onSurface,
      onCardMuted: light.onSurfaceVariant,
      cardOutline: light.outlineVariant,
      onCardError: light.error,
      deep: deepen(light.primary, light.scrim),
    );
  }

  @override
  NptBrandCanvas copyWith({
    Color? canvas,
    Color? onCanvas,
    Color? onCanvasMuted,
    Color? card,
    Color? onCard,
    Color? onCardMuted,
    Color? cardOutline,
    Color? onCardError,
    Color? deep,
  }) {
    return NptBrandCanvas(
      canvas: canvas ?? this.canvas,
      onCanvas: onCanvas ?? this.onCanvas,
      onCanvasMuted: onCanvasMuted ?? this.onCanvasMuted,
      card: card ?? this.card,
      onCard: onCard ?? this.onCard,
      onCardMuted: onCardMuted ?? this.onCardMuted,
      cardOutline: cardOutline ?? this.cardOutline,
      onCardError: onCardError ?? this.onCardError,
      deep: deep ?? this.deep,
    );
  }

  @override
  NptBrandCanvas lerp(ThemeExtension<NptBrandCanvas>? other, double t) {
    if (other is! NptBrandCanvas) return this;
    return NptBrandCanvas(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      onCanvas: Color.lerp(onCanvas, other.onCanvas, t)!,
      onCanvasMuted: Color.lerp(onCanvasMuted, other.onCanvasMuted, t)!,
      card: Color.lerp(card, other.card, t)!,
      onCard: Color.lerp(onCard, other.onCard, t)!,
      onCardMuted: Color.lerp(onCardMuted, other.onCardMuted, t)!,
      cardOutline: Color.lerp(cardOutline, other.cardOutline, t)!,
      onCardError: Color.lerp(onCardError, other.onCardError, t)!,
      deep: Color.lerp(deep, other.deep, t)!,
    );
  }
}

/// The brand canvas for the current subtree.
///
/// Falls back to the colour scheme when a widget renders under a `ThemeData`
/// the library did not assemble — a host's legacy theme, a bare `MaterialApp`
/// in a test — so this can never throw on a surface a customer is looking at.
extension BrandCanvasAccess on BuildContext {
  NptBrandCanvas brandCanvas() {
    final theme = Theme.of(this);
    final canvas = theme.extension<NptBrandCanvas>();
    if (canvas != null) return canvas;
    final scheme = theme.colorScheme;
    return NptBrandCanvas(
      canvas: scheme.primary,
      onCanvas: scheme.onPrimary,
      onCanvasMuted: scheme.onPrimary.withValues(alpha: 0.82),
      card: scheme.surface,
      onCard: scheme.onSurface,
      onCardMuted: scheme.onSurfaceVariant,
      cardOutline: scheme.outlineVariant,
      // The fallback path has only the ambient scheme; `error` is at least
      // guaranteed to be legible on that scheme's own surfaces.
      onCardError: scheme.error,
      deep: NptBrandCanvas.deepen(scheme.primary, scheme.scrim),
    );
  }
}

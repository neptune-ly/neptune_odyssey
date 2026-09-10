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

  const NptBrandCanvas({
    required this.canvas,
    required this.onCanvas,
    required this.onCanvasMuted,
    required this.card,
    required this.onCard,
    required this.onCardMuted,
    required this.cardOutline,
    required this.onCardError,
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
    );
  }

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
    );
  }
}

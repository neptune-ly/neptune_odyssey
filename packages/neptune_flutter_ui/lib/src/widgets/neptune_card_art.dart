// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/identity.dart';
import '../theme/accessibility.dart';
import '../theme/neptune_theme.dart';
import 'neptune_numeral.dart';

/// A payment-card visual — the Flutter counterpart of web `<npt-card-art>`.
///
/// Renders a 1.586 aspect-ratio card on the brand gradient (the card-art
/// `cardGradientStart` → `cardGradientEnd` roles; [virtual] flips the order).
/// The top row shows the [scheme] label (display font) and an optional
/// [brandMark] in the top-trailing corner; the bottom shows a masked number
/// ending in [last4], then the [holder] and [expiry]. When [selected], an
/// accent ring + glow lift the card out of a stack. Reads colour, shape and
/// type from the active theme only — no literals. RTL-safe.
///
/// The card face is brightness-INVARIANT by design: it always renders the
/// brand's light-mode gradient + text colour, even under a dark [ThemeData].
/// A payment card depicts a physical instrument, not a themed UI surface, so
/// it doesn't invert the way a M3 filled button does in dark mode. The
/// [selected] ring below is UI chrome, not part of the card face, and
/// correctly still adapts to theme brightness.
class NeptuneCardArt extends StatelessWidget {
  /// Cardholder name, e.g. "A. KELLER".
  final String holder;

  /// The last four digits of the card number, e.g. "4821".
  final String last4;

  /// Expiry label, e.g. "08/29".
  final String? expiry;

  /// Scheme label, e.g. "VISA". Shown uppercase in the display font.
  final String? scheme;

  /// When true, the gradient runs tertiary → primary (a virtual-card accent).
  final bool virtual;

  /// When true, draws an accent ring + glow to mark the chosen card.
  final bool selected;

  /// Optional brand mark, placed in the top-trailing corner.
  final Widget? brandMark;

  /// Tap handler; when non-null the whole card becomes an [InkWell].
  final VoidCallback? onTap;

  const NeptuneCardArt({
    super.key,
    required this.holder,
    required this.last4,
    this.expiry,
    this.scheme,
    this.virtual = false,
    this.selected = false,
    this.brandMark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final type = Theme.of(context).extension<NptType>()!;
    final textTheme = Theme.of(context).textTheme;
    final npt = Theme.of(context).extension<NptColors>()!;
    final onCard = npt.onCard;

    // Gradient runs cardGradientStart → cardGradientEnd (135°); virtual cards
    // flip the order. Brightness-invariant on purpose — see the class doc.
    final gradientColors = virtual
        ? <Color>[npt.cardGradientEnd, npt.cardGradientStart]
        : <Color>[npt.cardGradientStart, npt.cardGradientEnd];

    // The masked number: 12 dots + the real last four (tabular figures).
    final numberStyle = NeptuneTheme.moneyStyle(
      context,
      base: textTheme.titleMedium,
    ).copyWith(color: onCard, letterSpacing: 3);

    final schemeStyle = textTheme.labelLarge?.copyWith(
      color: onCard.withValues(alpha: 0.92),
      fontFamily: type.display,
      fontWeight: type.displayFontWeight,
      letterSpacing: 1.2,
    );

    final identity = Theme.of(context).extension<NptIdentity>()!;

    final card = AspectRatio(
      aspectRatio: 1.586,
      child: DecoratedBox(
        // Elevation-2 at rest (web box-shadow) — outside the ink clip.
        decoration: BoxDecoration(
          borderRadius: shape.rLg,
          boxShadow: identity.elevation2(scheme),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: shape.rLg,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: shape.rLg,
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: gradientColors,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  // No brand-motif TEXTURE here (there was a tiled repeating
                  // pattern before) — every reference card in the category
                  // (Mercury, Chase, Monzo, N26, Chime, Airwallex, Brex,
                  // PayPal, Revolut Business) uses a clean flat/gradient
                  // face with zero repeating texture, at most one large soft
                  // glow. A tiled micro-pattern on a compact card reads as
                  // busy/cheap, not premium — the brand's gradient + type do
                  // the identity work here.
                  //
                  // "At most one large soft glow" is the other half of that
                  // finding, and 2.30.0 takes it. A brand that declared a
                  // direction ACCENT (`accentOnTertiary`) keeps the accent out
                  // of every Material role on purpose, which also kept it off
                  // the one surface in the app that is a physical object: the
                  // gradient then ran primary → primary and the card was a
                  // flat navy rectangle. One bloom of the brand's own accent,
                  // in the top-trailing corner, is the difference between a
                  // card and a placeholder — and it is ONE element, not a
                  // field of them. A brand with no declared accent gets
                  // nothing new: `accent` equals `primary` there, and the
                  // bloom would be invisible anyway.
                  if (npt.accent != npt.cardGradientStart)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _CardKeyLight(
                            accent: npt.accent,
                            rtl: Directionality.of(context) ==
                                TextDirection.rtl,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsetsDirectional.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: scheme label + brand mark (top-trailing).
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                this.scheme?.toUpperCase() ?? '',
                                style: schemeStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (brandMark != null) ...[
                              const SizedBox(width: 16),
                              IconTheme.merge(
                                data: IconThemeData(color: onCard),
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(color: onCard),
                                  child: brandMark!,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Masked card number. ISOLATED, not a bare `Text`: a
                        // card number is a Latin-order string, and in an
                        // RTL paragraph the bidi algorithm reorders the runs
                        // around the bullets — the real last four moved to
                        // the FRONT of the line, so an Arabic customer read
                        // "4471 •••• •••• ••••" and the one part of the
                        // number that means anything was in the wrong place.
                        NeptuneNumeral(
                          '•••• •••• •••• $last4',
                          style: numberStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          semanticsLabel: NeptuneAccessibility.maskedNumber(
                              context, '•••• •••• •••• $last4'),
                        ),
                        // Bottom row: holder + expiry block.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                holder.toUpperCase(),
                                style: textTheme.labelMedium?.copyWith(
                                  color: onCard,
                                  letterSpacing: 0.6,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (expiry != null) ...[
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Expires',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: onCard.withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    expiry!,
                                    style: NeptuneTheme.moneyStyle(
                                      context,
                                      base: textTheme.labelLarge,
                                    ).copyWith(color: onCard),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!selected) return card;

    // Selected: an accent ring sits *outside* the card (outer padding) plus a
    // glow that lifts the chosen card out of a stack.
    final ringRadius = BorderRadius.circular(shape.lg + 3);
    return Container(
      padding: const EdgeInsetsDirectional.all(3),
      decoration: BoxDecoration(
        borderRadius: ringRadius,
        border: Border.all(color: scheme.primary, width: 3),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: card,
    );
  }
}

/// The card's single key light: ONE soft accent bloom in the top-trailing
/// corner. Nothing else.
///
/// It had a second element for one build — an oversized brand chevron leaving
/// the frame — on the theory that a shape running off the edge reads as an
/// object rather than as texture. On a real card at real size it did not: at
/// 9% ink and a 15dp stroke it read as a grey swoosh someone had forgotten to
/// delete, which is the SAME failure as the tiled micro-pattern this face
/// removed, arrived at from the other direction. The reference set's finding
/// was "at most one large soft GLOW", and a glow is a light, not a drawing.
/// The brand is already on this card twice — in the gradient and in the
/// accent of the light itself.
class _CardKeyLight extends CustomPainter {
  final Color accent;

  /// The gradient already mirrors (it is `AlignmentDirectional`); a chevron
  /// that did not would point back at the start edge on an Arabic screen.
  final bool rtl;

  const _CardKeyLight({required this.accent, required this.rtl});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    // Off the corner, not in it: a bloom whose centre is ON the card has a
    // visible hot spot, and a hot spot on a flat gradient looks like a
    // rendering artifact. Centred just outside the trailing edge, only the
    // falloff is on the face.
    final origin = Offset(size.width * 1.02, -size.height * 0.10);
    final r = size.width * 0.78;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          // 0.34, with a mid stop: a two-stop radial falls off linearly and
          // reads as a flat cone. The third stop is what makes it light.
          colors: [
            accent.withValues(alpha: 0.34),
            accent.withValues(alpha: 0.10),
            accent.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: origin, radius: r)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CardKeyLight old) =>
      old.accent != accent || old.rtl != rtl;
}

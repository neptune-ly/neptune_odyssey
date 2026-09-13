// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/brand_canvas.dart';
import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// THE DEPTH REGISTER — surfaces that have a *below*.
///
/// Odyssey could already draw a brand two ways: a flat brand colour
/// (`NptBrandCanvas`, one `canvas` value) or paper with structure ruled on it
/// (`NeptuneRegister*`). Both are opaque planes. A brand whose identity is
/// LUMINOSITY — light arriving from somewhere, colour changing across the
/// surface, a mark made of layered translucent planes — could only be
/// approximated by picking one of its colours and filling with it, which is
/// exactly how a vivid identity ends up looking like a duller version of the
/// bank next door.
///
/// The depth register is the third option: one field whose colour travels from
/// a deep tone to a bright one, a bloom where the light enters, and a single
/// arc that frames what sits on it. It is not decoration and it is not a
/// texture — take the arc away and the composition loses its frame, take the
/// travel away and the surface loses the direction it reads in.
///
/// Reusable, not one bank's: every colour comes from the theme, so a navy bank
/// gets navy depth and an emerald bank gets emerald depth. What the lever
/// chooses is the REGISTER, never the hue.

/// A luminous depth field: a brand gradient that travels, the bloom where the
/// light enters it, and one framing arc.
///
/// The three colours default to the theme's own — `primary` shaded down for
/// [depth], `primary` for [mid], and the brightest of `tertiary`/`primary` for
/// [glow] — so a host that names nothing still gets ITS brand's depth rather
/// than a hard-coded blue.
///
/// DIRECTION IS LOGICAL, NOT LEFT/RIGHT. The gradient runs top-end → bottom-
/// start and the arc is anchored at the start edge, both through
/// [AlignmentDirectional], so the whole field mirrors under RTL instead of
/// reading as a design drawn for English and flipped by hand.
class NeptuneTideField extends StatelessWidget {
  /// Painted over the field. Laid out full-size; the field owns no padding.
  final Widget? child;

  /// The deep end of the travel. Defaults to the brand canvas, darkened and
  /// turned toward blue.
  final Color? depth;

  /// The middle of the travel. Defaults to the theme's primary.
  final Color? mid;

  /// The bright end, and the colour of the bloom. Defaults to the lighter of
  /// the theme's tertiary and primary.
  final Color? glow;

  /// Draw the framing arc. The banner device: one large circle, struck in the
  /// on-canvas ink at low opacity, anchored off-canvas at the start edge, so
  /// the content block sits INSIDE it and the field beyond it reads as
  /// continuing past the frame.
  ///
  /// False on a field too short to hold an arc — under about 180dp it stops
  /// being a frame and becomes a stray curve, which is ornament.
  final bool arc;

  /// Where the light enters, as a fraction of the field. Defaults to the
  /// lower start corner, which is where the brand's own material puts it.
  final AlignmentGeometry bloom;

  /// How far DOWN this field sits, 0..1 — the whole derived travel taken
  /// toward black by this much.
  ///
  /// IT IS WHAT LETS TWO TIDE SURFACES STACK. A card made of the same field
  /// as the page behind it has no edge: same colours, same curve, and the
  /// card disappears into the ground. Sinking the PAGE rather than lifting the
  /// card keeps the card on the brand's real colours and puts the separation
  /// where a shadow would go, which is also what the mark does — the planes
  /// nearer the front are the bright ones.
  ///
  /// Ignored when a colour is passed explicitly: a caller that named a value
  /// meant it.
  final double sink;

  const NeptuneTideField({
    super.key,
    this.child,
    this.depth,
    this.mid,
    this.glow,
    this.arc = true,
    this.bloom = const AlignmentDirectional(-0.75, 0.72),
    this.sink = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final direction = Directionality.of(context);

    Color down(Color c) =>
        sink <= 0 ? c : Color.lerp(c, Colors.black, sink.clamp(0, 1))!;

    final base = theme.extension<NptBrandCanvas>()?.canvas ?? scheme.primary;
    final hsl = HSLColor.fromColor(base);
    final deep = depth ??
        down(hsl
            // +26 degrees, and only 26: enough that the foot of the field is
            // a recognisably different colour from its head, not so much that
            // it leaves the brand. A bank whose canvas is already deep blue
            // lands in indigo; one whose canvas is cyan lands in ocean.
            .withHue((hsl.hue + 26) % 360)
            .withLightness((hsl.lightness * 0.46).clamp(0.0, 1.0))
            .toColor());
    final middle = mid ?? down(base);
    final bright = glow ??
        down(hsl
            .withLightness((hsl.lightness * 1.9 + 0.10).clamp(0.0, 1.0))
            .withSaturation((hsl.saturation * 0.86).clamp(0.0, 1.0))
            .toColor());

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topEnd.resolve(direction),
          end: AlignmentDirectional.bottomStart.resolve(direction),
          // Three stops, not two: a two-stop ramp between a near-black navy
          // and a cyan passes through a dead grey-blue in the middle, which
          // is the muddy band that makes a generated gradient look generated.
          // The middle stop is the brand's own primary, so the travel stays
          // inside the brand's hue family the whole way across.
          colors: [deep, middle, bright],
          stops: const [0.0, 0.58, 1.0],
        ),
      ),
      child: CustomPaint(
        // Bloom and arc are painted, not stacked: a Stack of two more
        // DecoratedBoxes costs two extra layers on a surface that is behind
        // every pre-login frame, and neither needs to be a hit target.
        painter: _TidePainter(
          glow: bright,
          ink: _inkOn(theme),
          bloom: bloom.resolve(direction),
          arc: arc,
          rtl: direction == TextDirection.rtl,
        ),
        child: child,
      ),
    );
  }
}

/// The ink that reads on a tide field, in BOTH brightnesses.
///
/// `colorScheme.onPrimary` is the trap and it is not a near-miss: in a dark
/// scheme `primary` is a LIGHT tone, so its on-colour is near-black — and the
/// field underneath it has not re-toned, because the brand canvas never does.
/// The card's own label came out near-black on deep teal at night. The brand
/// canvas carries the on-colour that goes with the ground it defines, which is
/// the only pair guaranteed to have been checked together.
Color _inkOn(ThemeData theme) =>
    theme.extension<NptBrandCanvas>()?.onCanvas ?? theme.colorScheme.onPrimary;

class _TidePainter extends CustomPainter {
  final Color glow;
  final Color ink;
  final Alignment bloom;
  final bool arc;
  final bool rtl;

  const _TidePainter({
    required this.glow,
    required this.ink,
    required this.bloom,
    required this.arc,
    required this.rtl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final centre = bloom.withinRect(Offset.zero & size);
    final reach = size.longestSide * 0.78;
    canvas.drawCircle(
      centre,
      reach,
      Paint()
        ..shader = RadialGradient(
          colors: [glow.withValues(alpha: 0.55), glow.withValues(alpha: 0.0)],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: centre, radius: reach)),
    );

    if (!arc || size.height < 180) return;

    // One stroke, struck thin. The radius is set to the field, not typed: the
    // frame has to hold the content block at any height the host gives it,
    // and a fixed radius becomes a tiny circle on a tall field and a flat
    // line on a short one.
    final radius = math.max(size.width, size.height) * 0.86;
    final cx = rtl ? size.width + radius * 0.34 : -radius * 0.34;
    canvas.drawCircle(
      Offset(cx, size.height * 0.46),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = ink.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(_TidePainter old) =>
      old.glow != glow ||
      old.ink != ink ||
      old.bloom != bloom ||
      old.arc != arc ||
      old.rtl != rtl;
}

/// An account card in the depth register: the same travel as
/// [NeptuneTideField], layered wave planes struck across it, and a lighter
/// band along the bottom that carries a second figure.
///
/// THE BAND IS A SLOT, NOT A FLOURISH. It exists because an account has two
/// numbers a customer looks for — what is there now, and what moved — and a
/// card that shows only the first sends them to a second screen for the
/// second. A host with nothing to put in it passes no [bandLabel] and the
/// band is not drawn; the card does not keep an empty shape for symmetry.
class NeptuneTideCard extends StatelessWidget {
  final String label;
  final String amount;

  /// The number under the balance — the account's own reference, masked.
  final String? caption;

  /// The band's two halves. Both or neither.
  final String? bandLabel;
  final String? bandValue;

  final VoidCallback? onTap;

  const NeptuneTideCard({
    super.key,
    required this.label,
    required this.amount,
    this.caption,
    this.bandLabel,
    this.bandValue,
    this.onTap,
  }) : assert(
          (bandLabel == null) == (bandValue == null),
          'NeptuneTideCard: the band carries a label AND a value, or is not '
          'drawn at all.',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = theme.extension<NptShape>()!;
    final text = theme.textTheme;
    final ink = _inkOn(theme);
    final hasBand = bandLabel != null;

    return Semantics(
      button: onTap != null,
      label: '$label $amount',
      child: Material(
        color: Colors.transparent,
        borderRadius: shape.rXl,
        clipBehavior: Clip.antiAlias,
        // The card floats; the page it floats on is sunk. Both, because a
        // shadow alone is invisible on a dark ground and a tone difference
        // alone reads as a patch rather than an object.
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.45),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const NeptuneTideField(
                // No arc on the card. The arc is the PAGE's frame; repeating
                // it inside a 160dp card is the same device at two scales
                // arguing with each other, and at card size it reads as a
                // scratch.
                arc: false,
                bloom: AlignmentDirectional(0.85, -0.6),
              ),
              CustomPaint(painter: _WavePainter(ink: ink)),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                    20, 18, 20, hasBand ? 52 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: text.labelLarge
                          ?.copyWith(color: ink.withValues(alpha: 0.82)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          amount,
                          style: NeptuneTheme.moneyStyle(context,
                                  base: text.headlineMedium)
                              .copyWith(color: ink),
                          maxLines: 1,
                        ),
                        if (caption != null)
                          Text(
                            caption!,
                            style: NeptuneTheme.moneyStyle(context,
                                    base: text.labelMedium)
                                .copyWith(color: ink.withValues(alpha: 0.72)),
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasBand)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: _TideBand(
                      label: bandLabel!, value: bandValue!, ink: ink),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The lighter plane along the foot of the card, with the wave edge along its
/// top — the one place the card's own geometry becomes a container.
class _TideBand extends StatelessWidget {
  final String label;
  final String value;
  final Color ink;

  const _TideBand(
      {required this.label, required this.value, required this.ink});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ClipPath(
      clipper: const _BandClipper(),
      child: Container(
        height: 48,
        color: ink.withValues(alpha: 0.16),
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: text.labelMedium
                    ?.copyWith(color: ink.withValues(alpha: 0.86)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              value,
              style: NeptuneTheme.moneyStyle(context, base: text.labelLarge)
                  .copyWith(color: ink),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _BandClipper extends CustomClipper<Path> {
  const _BandClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, size.height * 0.34)
    ..quadraticBezierTo(
        size.width * 0.42, -size.height * 0.10, size.width, size.height * 0.22)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_BandClipper old) => false;
}

/// The layered planes of the mark, at card scale: three sweeps of the same
/// curve at falling opacity, so the card has the same "one shape seen through
/// another" reading the brand's own logo has.
class _WavePainter extends CustomPainter {
  final Color ink;

  const _WavePainter({required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    const alphas = [0.16, 0.10, 0.06];
    const lifts = [0.18, 0.42, 0.66];
    for (var i = 0; i < alphas.length; i++) {
      final y = size.height * lifts[i];
      canvas.drawPath(
        Path()
          ..moveTo(size.width, y)
          ..quadraticBezierTo(
              size.width * 0.55, y - size.height * 0.34, 0, y + size.height * 0.2)
          ..lineTo(0, -size.height)
          ..lineTo(size.width, -size.height)
          ..close(),
        Paint()..color = ink.withValues(alpha: alphas[i]),
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.ink != ink;
}

/// The raised circular centre action a host stacks over
/// `NeptuneDock(centerGap: true)`.
///
/// THE DOCK DOES NOT OWN IT, ON PURPOSE. A bank's primary verb is a product
/// decision — transfer for one, pay for another, scan for a wallet — and a
/// dock that owned the button would own the route behind it. The dock
/// reserves the hole; this draws the button; the host says what it does.
class NeptuneCentreAction extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  /// Diameter. 60 rather than Material's 56: the circle is the one control
  /// carrying a brand's primary verb and it sits between two 22dp glyphs, so
  /// it has to win that row without the label under it having to shout.
  final double size;

  const NeptuneCentreAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: scheme.primary,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: scheme.primary.withValues(alpha: 0.5),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: IconTheme.merge(
                  data: IconThemeData(color: scheme.onPrimary, size: 26),
                  child: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

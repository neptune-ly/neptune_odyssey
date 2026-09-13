// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The POCKET composition (2.30.0) — what the `pocket-balance` dashboard hero
// and the `pocket-drift` login shell draw, plus the flat spot-art family
// those surfaces and the empty states are illustrated with.
//
// It exists because every hero in `kDashboardHeroes` before it answered "what
// do I have" by enumerating accounts, and every pre-login shell before it was
// a document: a lockup on paper, or a lockup on a rule. Both are correct for a
// bank whose product is a branch. A bank whose product is a POCKET opens on
// one figure and a row of verbs, and the first thing a customer sees moves.
//
// Web counterparts: `site/wallet.html`'s pocket hero and drift auth ground.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/accessibility.dart';
import '../theme/extensions.dart';
import '../theme/brand_canvas.dart';
import '../theme/neptune_theme.dart';
import 'neptune_identity_surfaces.dart';

// ---------------------------------------------------------------------------
// Spot art
// ---------------------------------------------------------------------------

/// The flat spot drawings. One hand, one vocabulary: see [NeptuneSpotArt].
enum NptSpotArtKind {
  /// A pocket/wallet seen face on, its flap open and nothing inside.
  emptyPocket,

  /// A calm horizon with one chevron resting on it — nothing has moved.
  quiet,

  /// A chevron leaving a trail, clearing the frame. Money went out.
  sent,

  /// A card mid-flight, tilted, with a motion trail behind it.
  cardOnTheWay,

  /// A shield built from two chevrons meeting — the security surfaces.
  guarded,

  /// A magnifier over a ruled sheet — nothing matched.
  nothingFound,
}

/// Flat spot illustration, drawn from the theme rather than shipped as an
/// asset — so it recolours with the brand, mirrors under RTL and stays crisp
/// at any size. Web counterpart: `site/assets/spot/*.svg`.
///
/// THE VOCABULARY IS THE POINT, not any one drawing. Every kind here obeys the
/// same four rules, which is what makes six unrelated pictures look like one
/// hand rather than six stock downloads:
///
/// 1. **Two flat fills and one ink.** A tonal ground shape (`primary` at low
///    alpha), one accent shape, and a single ink contour at 2.6dp with round
///    caps. No gradient, no third colour, no outline around a fill.
/// 2. **An off-register echo.** Every drawing carries one shape repeated
///    behind itself, offset on the reading diagonal at ~8% alpha. It is what
///    gives flat art depth without a shadow, and it is the signature.
/// 3. **The chevron is the only character.** The brand's mark appears in every
///    drawing, doing something different each time — resting, leaving,
///    shielding. A mascot the brand already owns beats an invented one.
/// 4. **Nothing is drawn that a label already says.** The picture carries the
///    MOOD; the text under it carries the fact.
///
/// It is an EXPRESSIVE surface, so it belongs on empty states, heroes and
/// outcomes — never inside a data surface. A row, a figure or a status has no
/// budget for a drawing.
class NeptuneSpotArt extends StatelessWidget {
  final NptSpotArtKind kind;

  /// The square edge, in logical pixels. Drawings are composed on a 100x100
  /// grid and scaled, so they stay proportionate at any size.
  final double size;

  /// Overrides the ink. Defaults to `onSurface` — pass `onPrimary` when the
  /// drawing sits on the brand canvas.
  final Color? ink;

  /// Overrides the accent shape. Defaults to the theme accent role.
  final Color? accent;

  /// A short description for assistive technology. Null marks the drawing
  /// decorative, which is right whenever the copy beside it already says what
  /// the picture says — the usual case for an empty state.
  final String? semanticLabel;

  const NeptuneSpotArt(
    this.kind, {
    super.key,
    this.size = 132,
    this.ink,
    this.accent,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = theme.extension<NptColors>();
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final art = CustomPaint(
      size: Size.square(size),
      painter: _SpotArtPainter(
        kind: kind,
        ink: ink ?? scheme.onSurface,
        accent: accent ?? colors?.accent ?? scheme.primary,
        // `secondaryContainer`, not `primary` at low alpha. A navy at 16% on a
        // warm page is a cold LILAC, and six drawings in a colour that is on
        // no other surface read as clip art someone pasted in. The tonal chip
        // role already follows the ground.
        tonal: scheme.secondaryContainer,
        rtl: rtl,
      ),
    );
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: SizedBox.square(dimension: size, child: art),
    );
  }
}

class _SpotArtPainter extends CustomPainter {
  final NptSpotArtKind kind;
  final Color ink;
  final Color accent;
  final Color tonal;
  final bool rtl;

  const _SpotArtPainter({
    required this.kind,
    required this.ink,
    required this.accent,
    required this.tonal,
    required this.rtl,
  });

  // The composition grid every drawing is authored on.
  static const double _grid = 100;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final s = size.shortestSide / _grid;
    canvas.scale(s, s);
    if (rtl) {
      canvas.translate(_grid, 0);
      canvas.scale(-1, 1);
    }
    switch (kind) {
      case NptSpotArtKind.emptyPocket:
        _emptyPocket(canvas);
      case NptSpotArtKind.quiet:
        _quiet(canvas);
      case NptSpotArtKind.sent:
        _sent(canvas);
      case NptSpotArtKind.cardOnTheWay:
        _card(canvas);
      case NptSpotArtKind.guarded:
        _guarded(canvas);
      case NptSpotArtKind.nothingFound:
        _nothingFound(canvas);
    }
    canvas.restore();
  }

  Paint get _fillTonal => Paint()..color = tonal;
  Paint get _fillAccent => Paint()..color = accent;
  Paint get _echo => Paint()..color = ink.withValues(alpha: 0.08);
  Paint get _line => Paint()
    ..color = ink.withValues(alpha: 0.92)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.6
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// One chevron, centred on [c], half-width [w], half-height [h].
  Path _chevron(Offset c, double w, double h) => Path()
    ..moveTo(c.dx - w, c.dy - h)
    ..lineTo(c.dx + w, c.dy)
    ..lineTo(c.dx - w, c.dy + h);

  RRect _rr(Rect r, double radius) =>
      RRect.fromRectAndRadius(r, Radius.circular(radius));

  /// Nothing in it: a wallet seen face on, its flap folded back, the chevron
  /// that would have been money rising out of the opening.
  ///
  /// The flap was a straight triangle above the body on the first pass, which
  /// at this size reads as a HANGING SIGN on a rope — a shop sign, not a
  /// wallet. Folded back INSIDE the top edge as a curve it reads as an
  /// opening, and the whole shape stays one object instead of two.
  void _emptyPocket(Canvas canvas) {
    const body = Rect.fromLTWH(16, 34, 68, 52);
    canvas.drawRRect(_rr(body.shift(const Offset(7, 7)), 12), _echo);
    canvas.drawRRect(_rr(body, 12), _fillTonal);
    canvas.drawRRect(_rr(body, 12), _line);
    // The flap, folded back over the top third — a curve, not a roof.
    canvas.drawPath(
      Path()
        ..moveTo(16, 48)
        ..quadraticBezierTo(50, 30, 84, 48),
      _line,
    );
    // LEAVING, as a trail rather than a single mark. One chevron rotated on
    // the diagonal reads as a tick or a numeral — the arms go asymmetric and
    // the eye resolves it as a glyph, not as an arrow. Two of them losing ink
    // along the same line can only be read as movement.
    for (var i = 0; i < 2; i++) {
      canvas.save();
      canvas.translate(62.0 + i * 13, 24.0 - i * 11);
      canvas.rotate(-0.7853981633974483); // 45 degrees: up and away
      canvas.drawPath(
        _chevron(Offset.zero, 7, 6.5),
        Paint()
          ..color = accent.withValues(alpha: 0.45 + i * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.restore();
    }
  }

  /// Nothing moved: a list with nothing in it.
  ///
  /// The first attempt was a circle over a horizon with two short lines on it,
  /// and at 120dp that is a FACE with a mouth — a sleeping emoji, which is a
  /// joke about the customer's empty account. The picture has to say "there is
  /// a list here and it has no rows", so it draws the list.
  void _quiet(Canvas canvas) {
    const card = Rect.fromLTWH(16, 26, 68, 52);
    canvas.drawRRect(_rr(card.shift(const Offset(7, 7)), 10), _echo);
    canvas.drawRRect(_rr(card, 10), _fillTonal);
    canvas.drawRRect(_rr(card, 10), _line);
    // Three rows that are not there: hairlines shortening down the card.
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(28, 42.0 + i * 13),
        Offset(72.0 - i * 12, 42.0 + i * 13),
        Paint()
          ..color = ink.withValues(alpha: 0.22 - i * 0.06)
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }
    // The chevron is the last ROW of the list, not a glyph parked under it:
    // below the card it read as a stray caret that had escaped some other
    // drawing. Inside, at row scale, it is the one entry there is.
    canvas.drawPath(
      _chevron(const Offset(28, 68), 5, 5),
      _fillAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _sent(Canvas canvas) {
    // The trail: three chevrons losing ink as they leave.
    for (var i = 0; i < 3; i++) {
      final p = Paint()
        // 0.34 up, not 0.18: at the old floor the two faint chevrons were
        // invisible on a dark ground and read as smudges rather than a trail.
        ..color = accent.withValues(alpha: 0.34 + i * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4 + i * 0.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(_chevron(Offset(30.0 + i * 18, 50), 8, 9), p);
    }
    canvas.drawCircle(const Offset(50, 50), 38, _echo);
    final ring = Paint()
      ..color = ink.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    // An opening ring, not a closed one: the money has left the frame.
    canvas.drawArc(
        Rect.fromCircle(center: const Offset(50, 50), radius: 34),
        -math.pi * 0.62,
        math.pi * 1.24,
        false,
        ring);
  }

  void _card(Canvas canvas) {
    canvas.save();
    canvas.translate(50, 52);
    canvas.rotate(-0.26);
    final face = Rect.fromCenter(center: Offset.zero, width: 74, height: 48);
    canvas.drawRRect(_rr(face.shift(const Offset(7, 7)), 10), _echo);
    canvas.drawRRect(_rr(face, 10), _fillTonal);
    canvas.drawRRect(_rr(face, 10), _line);
    canvas.drawRRect(
      _rr(const Rect.fromLTWH(-28, -8, 18, 14), 3),
      _fillAccent..style = PaintingStyle.fill,
    );
    canvas.drawLine(const Offset(-28, 14), const Offset(4, 14), _line);
    canvas.restore();
    // Motion trail behind it.
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(6.0, 74.0 + i * 7),
        Offset(30.0 - i * 6, 74.0 + i * 7),
        Paint()
          ..color = ink.withValues(alpha: 0.28 - i * 0.07)
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _guarded(Canvas canvas) {
    final shield = Path()
      ..moveTo(50, 14)
      ..lineTo(84, 30)
      ..lineTo(84, 56)
      ..quadraticBezierTo(84, 78, 50, 90)
      ..quadraticBezierTo(16, 78, 16, 56)
      ..lineTo(16, 30)
      ..close();
    canvas.save();
    canvas.translate(6, 6);
    canvas.drawPath(shield, _echo);
    canvas.restore();
    canvas.drawPath(shield, _fillTonal);
    canvas.drawPath(shield, _line);
    // ONE mark on the shield. Two chevrons facing each other read as a
    // mathematical operator, not as a lock — a drawing has to be guessable in
    // half a second and that one needed explaining.
    canvas.save();
    canvas.translate(50, 52);
    canvas.rotate(-1.5707963267948966); // pointing up: held, not travelling
    canvas.drawPath(
      _chevron(Offset.zero, 13, 12),
      _fillAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  void _nothingFound(Canvas canvas) {
    const sheet = Rect.fromLTWH(16, 16, 56, 68);
    canvas.drawRRect(_rr(sheet.shift(const Offset(6, 6)), 8), _echo);
    canvas.drawRRect(_rr(sheet, 8), _fillTonal);
    canvas.drawRRect(_rr(sheet, 8), _line);
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(28, 34.0 + i * 14),
        Offset(i == 2 ? 48 : 60, 34.0 + i * 14),
        Paint()
          ..color = ink.withValues(alpha: 0.32)
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(
      const Offset(66, 62),
      18,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(79, 75),
      const Offset(90, 86),
      Paint()
        ..color = accent
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpotArtPainter old) =>
      old.kind != kind ||
      old.ink != ink ||
      old.accent != accent ||
      old.tonal != tonal ||
      old.rtl != rtl;
}

// ---------------------------------------------------------------------------
// The verb row
// ---------------------------------------------------------------------------

/// One verb in [NeptunePocketBalance]'s row. Web counterpart: `<npt-verb>`.
///
/// [iconWidget] takes precedence over [icon] — a client bank ships its own
/// designed marks, and an `IconData`-only API makes every bank's chrome
/// identical (the same contract as `NeptuneQuickAction`).
@immutable
class NeptunePocketVerb {
  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onTap;

  /// Marks this the LEAD verb — the one that moves the customer forward. It
  /// carries the brand accent, and exactly one verb in a row may set it: the
  /// accent is spent, not sprayed.
  final bool lead;

  const NeptunePocketVerb({
    required this.label,
    this.icon,
    this.iconWidget,
    this.onTap,
    this.lead = false,
  });
}

/// The pressable verb tile. Separate so the press spring lives in one place.
class _VerbTile extends StatefulWidget {
  final NeptunePocketVerb verb;
  const _VerbTile(this.verb);

  @override
  State<_VerbTile> createState() => _VerbTileState();
}

class _VerbTileState extends State<_VerbTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final motion = theme.extension<NptMotion>()!;
    final colors = theme.extension<NptColors>();
    final verb = widget.verb;
    final lead = verb.lead;
    // THE TILES ARE PAPER, NOT CHROME. `secondaryContainer` is ramped from
    // the primary, so on a brand that warms its own ground the page was cream,
    // the account chip was warm and the four tiles were BLUE — three tints on
    // one screen, and the eye reads that as an accident rather than a scheme.
    // `surfaceContainerHighest` keeps them in the ground's own family; the
    // hairline below is what stops them dissolving into it, which is the
    // problem `secondaryContainer` was reached for in the first place.
    final fill = lead
        ? (colors?.accent ?? scheme.primary)
        : scheme.surfaceContainerHighest;
    final on = lead
        ? (colors?.onAccent ?? scheme.onPrimary)
        : scheme.onSurface;
    // Press feedback only. A tile that animates on its own is decoration.
    final reduced = NeptuneAccessibility.reducedMotion(context);
    final scale = _down && !reduced ? 0.94 : 1.0;

    final glyph = verb.iconWidget != null
        ? IconTheme.merge(
            data: IconThemeData(color: on, size: 22),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: on),
              child: verb.iconWidget!,
            ),
          )
        : Icon(verb.icon, color: on, size: 22);

    return Semantics(
      button: true,
      label: verb.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: verb.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: scale,
          duration: motion.fast,
          curve: motion.spring,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: fill,
                  border: lead
                      ? null
                      : Border.all(color: scheme.outlineVariant),
                  // `rMd`, not `rLg`. Flutter clamps a radius to half the box,
                  // so on a 58dp tile every brand whose `lg` is 30 or more
                  // gets a CIRCLE — which is `filled-circles`, another bank's
                  // quick-action treatment, arrived at by accident. The md
                  // corner is the one that still reads as the brand's own
                  // rectangle at this size.
                  borderRadius: shape.rMd,
                  // The ACCENT's glow, not the primary's. `glowPrimary` puts a
                  // navy halo under a vermilion tile, which reads as a
                  // shadow somebody tinted by mistake; a light under a lit
                  // object is the colour of the object.
                  boxShadow: lead
                      ? [
                          BoxShadow(
                            color: fill.withValues(alpha: 0.34),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: glyph,
              ),
              const SizedBox(height: 8),
              Text(
                verb.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The hero
// ---------------------------------------------------------------------------

/// The `pocket-balance` dashboard hero: ONE figure at display scale, a reveal
/// control beside it, and a row of verbs under it. Web counterpart:
/// `site/wallet.html` `.pocket-hero`.
///
/// It draws NO container. Every other hero in `kDashboardHeroes` puts the
/// money inside something — a card, a carousel, a ruled statement — and a
/// container is a promise that there is more than one of them. There is one
/// balance; a box around it is furniture.
///
/// The reveal is the screen's motion moment, and it is feedback for exactly
/// one thing: the customer asked to see a real number and the real number
/// arrived. It is NOT ambient — nothing on this surface moves until a finger
/// touches it — and it collapses to an instant swap under
/// `MediaQuery.disableAnimationsOf`.
class NeptunePocketBalance extends StatefulWidget {
  /// The small label over the figure (`NeptuneEyebrow`), e.g. "TOTAL".
  final String eyebrow;

  /// The formatted figure, currency included. Pre-formatted by the host so
  /// the widget never guesses a locale's grouping.
  final String amount;

  /// The obscured stand-in shown before a reveal. Defaults to a run of
  /// bullets sized to [amount] so the layout does not jump on reveal.
  final String? obscured;

  /// Whether the figure is currently shown. The host owns the state, because
  /// on most apps it outlives the screen.
  final bool revealed;

  /// Called when the reveal control is used. Null hides the control entirely —
  /// a control that does nothing is worse than no control.
  final ValueChanged<bool>? onRevealChanged;

  /// The accessible name of the reveal control, localized by the host. The
  /// library's own `NeptuneA11yStrings` table is a fixed EN/AR pair and this
  /// string belongs to the host's own locale set, so it is passed, not
  /// looked up. Required whenever [onRevealChanged] is set.
  final String? revealLabel;

  /// An optional line under the figure: what moved today, the account name,
  /// an as-of time. One line, never two.
  final String? caption;

  /// An optional control between the figure and the verbs — the usual case is
  /// the account the figure belongs to, as one tappable pill.
  ///
  /// It sits ABOVE the verbs because it qualifies the FIGURE. Below them it
  /// read as a fifth action, and a customer who taps it expecting to do
  /// something gets a list of their own accounts.
  final Widget? qualifier;

  /// 3 to 5 verbs. Fewer than three is a button, more than five is a menu.
  final List<NeptunePocketVerb> verbs;

  const NeptunePocketBalance({
    super.key,
    required this.eyebrow,
    required this.amount,
    required this.verbs,
    this.obscured,
    this.revealed = true,
    this.onRevealChanged,
    this.revealLabel,
    this.caption,
    this.qualifier,
  }) : assert(onRevealChanged == null || revealLabel != null,
            'a reveal control needs an accessible name');

  @override
  State<NeptunePocketBalance> createState() => _NeptunePocketBalanceState();
}

class _NeptunePocketBalanceState extends State<NeptunePocketBalance> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final motion = theme.extension<NptMotion>()!;
    final reduced = NeptuneAccessibility.reducedMotion(context);

    final figureStyle = NeptuneTheme.moneyStyle(
      context,
      base: theme.textTheme.displaySmall,
    ).copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w700,
      height: 1.05,
    );

    final hidden = widget.obscured ??
        '•' * math.max(4, widget.amount.replaceAll(' ', '').length - 2);

    final figure = AnimatedSwitcher(
      duration: reduced ? Duration.zero : motion.durationStandard,
      switchInCurve: motion.emphasized,
      switchOutCurve: motion.standard,
      transitionBuilder: (child, anim) {
        // Up from under a clip, like a figure being dealt. Two properties,
        // one direction — a reveal that also rotates or bounces reads as a
        // celebration, and a balance is not good news by definition.
        return ClipRect(
          child: FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.42),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
        );
      },
      child: Text(
        widget.revealed ? widget.amount : hidden,
        key: ValueKey<bool>(widget.revealed),
        style: figureStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final rows = <Widget>[
      NeptuneEyebrow(widget.eyebrow),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: figure),
          if (widget.onRevealChanged != null) ...[
            // No spacer. The control's own 48dp target already carries more
            // than a type gap's worth of padding on each side, and adding to
            // it pushed the eye a thumb's width clear of the figure it acts
            // on — two objects instead of one line.
            Semantics(
              button: true,
              label: widget.revealLabel,
              child: IconButton(
                onPressed: () => widget.onRevealChanged!(!widget.revealed),
                iconSize: 22,
                color: scheme.onSurfaceVariant,
                // 48dp of TARGET, 20 of padding: the tap area stays legal
                // while the glyph sits close enough to read as part of the
                // figure's line.
                constraints:
                    const BoxConstraints.tightFor(width: 48, height: 48),
                padding: EdgeInsets.zero,
                icon: Icon(widget.revealed
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
              ),
            ),
          ],
        ],
      ),
      if (widget.caption != null) ...[
        const SizedBox(height: 2),
        Text(
          widget.caption!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
      if (widget.qualifier != null) ...[
        const SizedBox(height: 14),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: widget.qualifier,
        ),
      ],
      const SizedBox(height: 22),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final v in widget.verbs)
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: _VerbTile(v),
              ),
            ),
        ],
      ),
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The pre-login ground
// ---------------------------------------------------------------------------

/// The `pocket-drift` login shell's ground: the bank's OWN PAPER, with its
/// signature motif drifting slowly across it. Web counterpart:
/// `site/templates.html` `.auth-drift`.
///
/// IT SHIPPED ONCE AS A GRADIENT AND THAT WAS WRONG THREE TIMES OVER. Two
/// slow colour blooms over a cool canvas resolve to MAUVE — the screen was a
/// blue-to-purple gradient, which is the single most recognisable "a machine
/// made this" signature in the category. It shared no material with the
/// signed-in app, so a customer met one product and signed into another. And
/// it was the only surface in the set carrying none of the three things that
/// made the brand legible. A pre-login screen is the same bank at a different
/// moment; it is made of the same things.
///
/// What moves is the brand's own MARK, not a colour. The motif translates
/// along its own reading diagonal on a 34s loop — slow enough that a customer
/// reading a phone-number field never catches it, present enough that the
/// screen is never twice the same. It is still the one deliberate piece of
/// ambient motion in the system, for the same reason: a pre-login screen has
/// no data to give feedback about, and "this is alive" is the only message it
/// has to carry. Under `MediaQuery.disableAnimationsOf` the field holds still
/// and the ticker is never started.
class NeptuneDriftCanvas extends StatefulWidget {
  final Widget child;

  /// Strength multiplier on the brand motif. Zero for a brand whose motif is
  /// `none` — which is a brand that should not be on this shell at all, since
  /// the motif IS the composition here.
  ///
  /// 0.22, not the 0.55 this shipped with for one build. A motif is a WASH:
  /// at half strength across a full screen it stops being a texture behind
  /// the type and becomes wallpaper the type is sitting on, and the mark
  /// stops reading as the brand's because there are ninety of it.
  final double motifStrength;

  const NeptuneDriftCanvas({
    super.key,
    required this.child,
    this.motifStrength = 0.22,
  });

  @override
  State<NeptuneDriftCanvas> createState() => _NeptuneDriftCanvasState();
}

class _NeptuneDriftCanvasState extends State<NeptuneDriftCanvas>
    with SingleTickerProviderStateMixin {
  AnimationController? _drift;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Started here, not in initState: reduced motion is a MediaQuery, and a
    // ticker created before it is read runs for the whole session on a device
    // that asked for no animation.
    if (NeptuneAccessibility.reducedMotion(context)) {
      _drift?.stop();
      return;
    }
    _drift ??= AnimationController(
        vsync: this, duration: const Duration(seconds: 34))
      ..repeat();
  }

  @override
  void dispose() {
    _drift?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // THE THEME'S OWN GROUND, not `NptBrandCanvas.canvas`.
    //
    // `pocket-drift` is a PAPER shell — that is the whole correction it exists
    // to carry: pre-login is the same bank at a different moment, so it stands
    // on the same ground the signed-in app does. Reading the brand canvas put
    // the widget back on the bank's colour, which is how the gallery rendered
    // a blue pre-login while the host app rendered the cream one. A widget
    // whose ground depends on the caller remembering to swap an extension is
    // a widget with two answers.
    final ground = scheme.surface;
    final ink = scheme.onSurface;

    return Container(
      color: ground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.motifStrength > 0)
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _drift ?? const AlwaysStoppedAnimation<double>(0),
                builder: (context, _) {
                  // ONE TILE OF TRAVEL, then back to zero. The motif is a
                  // periodic field, so shifting its ORIGIN by exactly one tile
                  // makes the loop point invisible — a fade or a reset would
                  // be the only thing on the screen that announced itself.
                  //
                  // The origin moves, not the widget. Translating the widget
                  // leaves a bare wedge at the trailing edge, and the usual
                  // fix — an `OverflowBox` with infinite constraints — hands
                  // unbounded width to a `CustomPaint` sized `Size.infinite`,
                  // which does not render, it hangs. That cost a test run.
                  final t = _drift?.value ?? 0;
                  return NeptuneMotifLayer(
                    color: ink,
                    strength: widget.motifStrength,
                    offset: Offset(-44 * t, 38 * t),
                    // Attenuated from where the drift enters, so the field is
                    // densest in the corner nothing is set in and thinnest
                    // under the headline and the actions. An even field over
                    // a whole screen gives the type nowhere to be quiet.
                    fade: true,
                  );
                },
              ),
            ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// The card flip
// ---------------------------------------------------------------------------

/// Turns a card over. Web counterpart: `site/wallet.html` `.card-flip`.
///
/// It is the third motion moment of the pocket composition, and like the other
/// two it is FEEDBACK, not decoration: a payment card is a physical object
/// with two faces, and the only honest way to show the second one is to turn
/// the first one over. A crossfade would say the card was replaced.
///
/// The rotation is a real perspective transform rather than a scale, because a
/// flat width-squash reads as a closing door. The back face is pre-rotated
/// half a turn so its content is not mirrored when it arrives — the trap this
/// widget exists to stop a caller falling into, since the mirrored text is
/// legible enough at a glance to survive review and unreadable in the hand.
///
/// Under `MediaQuery.disableAnimationsOf` the faces swap instantly: a card
/// number is information, and a customer who asked for no motion still has to
/// be able to read it.
class NeptuneCardFlip extends StatelessWidget {
  final Widget front;
  final Widget back;

  /// Which face is showing. The host owns it — a card usually flips back on
  /// navigation, and only the host knows that.
  final bool showBack;

  /// Tap handler. Null leaves the flip to the host's own control.
  final VoidCallback? onTap;

  /// Accessible name for the tap target, localized by the host.
  final String? semanticLabel;

  const NeptuneCardFlip({
    super.key,
    required this.front,
    required this.back,
    this.showBack = false,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final motion = Theme.of(context).extension<NptMotion>()!;
    final reduced = NeptuneAccessibility.reducedMotion(context);

    final body = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: showBack ? 1 : 0),
      duration: reduced ? Duration.zero : motion.slow,
      curve: motion.emphasized,
      builder: (context, t, _) {
        final angle = t * math.pi;
        // Past the quarter turn the far face is what the eye should see.
        final showingBack = t > 0.5;
        final child = showingBack
            // Pre-rotated the other half turn, so the content lands upright.
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: back,
              )
            : front;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0011)
            ..rotateY(angle),
          child: child,
        );
      },
    );

    if (onTap == null) return body;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: body,
      ),
    );
  }
}

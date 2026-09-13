// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The POCKET composition (2.30.0) — what the `pocket-balance` dashboard hero
// and the `pocket-aurora` login shell draw, plus the flat spot-art family
// those surfaces and the empty states are illustrated with.
//
// It exists because every hero in `kDashboardHeroes` before it answered "what
// do I have" by enumerating accounts, and every pre-login shell before it was
// a document: a lockup on paper, or a lockup on a rule. Both are correct for a
// bank whose product is a branch. A bank whose product is a POCKET opens on
// one figure and a row of verbs, and the first thing a customer sees moves.
//
// Web counterparts: `site/wallet.html`'s pocket hero and aurora auth ground.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/accessibility.dart';
import '../theme/extensions.dart';
import '../theme/brand_canvas.dart';
import '../theme/identity.dart';
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
        tonal: scheme.primary,
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

  Paint get _fillTonal =>
      Paint()..color = tonal.withValues(alpha: 0.16);
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

  void _emptyPocket(Canvas canvas) {
    const body = Rect.fromLTWH(14, 38, 72, 46);
    canvas.drawRRect(_rr(body.shift(const Offset(6, 6)), 12), _echo);
    canvas.drawRRect(_rr(body, 12), _fillTonal);
    // The flap, lifted: an empty pocket is an OPEN one.
    final flap = Path()
      ..moveTo(14, 44)
      ..lineTo(50, 20)
      ..lineTo(86, 44);
    canvas.drawPath(flap, _line);
    canvas.drawRRect(_rr(body, 12), _line);
    // The one accent note: the chevron that would have been money, resting
    // on the floor of the pocket.
    canvas.drawPath(
      _chevron(const Offset(50, 66), 9, 8),
      _fillAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _quiet(Canvas canvas) {
    canvas.drawCircle(const Offset(56, 46), 30, _echo);
    canvas.drawCircle(const Offset(50, 42), 30, _fillTonal);
    // The horizon.
    canvas.drawLine(const Offset(10, 76), const Offset(90, 76), _line);
    // The chevron lying down on it — nothing is travelling.
    canvas.drawPath(
      _chevron(const Offset(50, 76), 10, 0.01),
      _fillAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(const Offset(34, 40), const Offset(46, 40), _line);
    canvas.drawLine(const Offset(34, 52), const Offset(60, 52), _line);
  }

  void _sent(Canvas canvas) {
    // The trail: three chevrons losing ink as they leave.
    for (var i = 0; i < 3; i++) {
      final p = Paint()
        ..color = accent.withValues(alpha: 0.18 + i * 0.16)
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
    // Two chevrons meeting: the mark, used as a lock.
    final p = _fillAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_chevron(const Offset(44, 46), 8, 9), p);
    canvas.save();
    canvas.translate(100, 0);
    canvas.scale(-1, 1);
    canvas.drawPath(_chevron(const Offset(44, 60), 8, 9), p);
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
    // `secondaryContainer`, not `surfaceContainerHigh`: on a brand that
    // declares its own ground the container tones sit within a few percent of
    // the page and the unfilled tiles vanished into it.
    final fill = lead
        ? (colors?.accent ?? scheme.primary)
        : scheme.secondaryContainer;
    final on = lead
        ? (colors?.onAccent ?? scheme.onPrimary)
        : scheme.onSecondaryContainer;
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
                  // `rMd`, not `rLg`. Flutter clamps a radius to half the box,
                  // so on a 58dp tile every brand whose `lg` is 30 or more
                  // gets a CIRCLE — which is `filled-circles`, another bank's
                  // quick-action treatment, arrived at by accident. The md
                  // corner is the one that still reads as the brand's own
                  // rectangle at this size.
                  borderRadius: shape.rMd,
                  boxShadow: lead
                      ? theme.extension<NptIdentity>()!.glowPrimary(scheme)
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
            const SizedBox(width: 4),
            Semantics(
              button: true,
              label: widget.revealLabel,
              child: IconButton(
                onPressed: () => widget.onRevealChanged!(!widget.revealed),
                iconSize: 22,
                color: scheme.onSurfaceVariant,
                constraints:
                    const BoxConstraints.tightFor(width: 48, height: 48),
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

/// The `pocket-aurora` login shell's ground: the brand canvas with two slow
/// colour blooms drifting behind it, the brand motif at wash strength, and
/// the host's content on top. Web counterpart: `site/templates.html`
/// `.auth-aurora`.
///
/// The blooms are the ONE piece of ambient motion in the system, and they are
/// deliberate: the pre-login screen has no data to give feedback about, and a
/// bank's first impression is the one moment where "this is alive" is the
/// message. They run at 22/27s — slow enough that a customer reading a phone
/// number field never sees them move, fast enough that the screen is never
/// the same twice. Under `MediaQuery.disableAnimationsOf` the blooms hold at
/// their starting position and the ticker is never started at all.
class NeptuneAuroraCanvas extends StatefulWidget {
  final Widget child;

  /// Strength multiplier on the brand motif wash. Zero for a brand whose
  /// motif is `none`; the default is the page-wash level.
  final double motifStrength;

  const NeptuneAuroraCanvas({
    super.key,
    required this.child,
    this.motifStrength = 0.5,
  });

  @override
  State<NeptuneAuroraCanvas> createState() => _NeptuneAuroraCanvasState();
}

class _NeptuneAuroraCanvasState extends State<NeptuneAuroraCanvas>
    with TickerProviderStateMixin {
  AnimationController? _a;
  AnimationController? _b;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Started here, not in initState: reduced-motion is a MediaQuery, and a
    // ticker created before it is read runs for the whole session on a device
    // that asked for no animation.
    final reduced = NeptuneAccessibility.reducedMotion(context);
    if (reduced) {
      _a?.stop();
      _b?.stop();
      return;
    }
    _a ??= AnimationController(
        vsync: this, duration: const Duration(seconds: 22))
      ..repeat();
    _b ??= AnimationController(
        vsync: this, duration: const Duration(seconds: 27))
      ..repeat();
  }

  @override
  void dispose() {
    _a?.dispose();
    _b?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = theme.extension<NptColors>();
    final canvas = theme.extension<NptBrandCanvas>();
    final ground = canvas?.canvas ?? scheme.primary;
    final onGround = canvas?.onCanvas ?? scheme.onPrimary;
    final accent = colors?.accent ?? scheme.tertiary;

    final listenable = Listenable.merge([_a, _b]);

    return Container(
      color: ground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: listenable,
              builder: (context, _) => CustomPaint(
                painter: _AuroraPainter(
                  t1: _a?.value ?? 0,
                  t2: _b?.value ?? 0,
                  // The accent bloom is the smaller and the hotter of the
                  // two: on a navy ground a large warm field stops being a
                  // light and becomes a background colour.
                  warm: accent,
                  cool: Color.lerp(ground, onGround, 0.34)!,
                ),
              ),
            ),
          ),
          if (widget.motifStrength > 0)
            Positioned.fill(
              child: NeptuneMotifLayer(
                color: onGround,
                strength: widget.motifStrength,
                fade: true,
              ),
            ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t1;
  final double t2;
  final Color warm;
  final Color cool;

  const _AuroraPainter({
    required this.t1,
    required this.t2,
    required this.warm,
    required this.cool,
  });

  void _bloom(Canvas canvas, Size size, Offset at, double r, Color c,
      double alpha) {
    final rect = Rect.fromCircle(center: at, radius: r);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [c.withValues(alpha: alpha), c.withValues(alpha: 0)],
        stops: const [0, 1],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Two independent Lissajous drifts. Different periods and different
    // phases, so the pair never returns to the same arrangement within a
    // session — the cheapest way to stop a loop reading as a loop.
    final a1 = t1 * 2 * math.pi;
    final a2 = t2 * 2 * math.pi;
    _bloom(
      canvas,
      size,
      Offset(w * (0.26 + 0.16 * math.cos(a1)),
          h * (0.22 + 0.10 * math.sin(a1 * 1.6))),
      w * 0.82,
      cool,
      0.55,
    );
    _bloom(
      canvas,
      size,
      Offset(w * (0.80 + 0.14 * math.sin(a2)),
          h * (0.66 + 0.12 * math.cos(a2 * 1.3))),
      w * 0.58,
      warm,
      0.40,
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.t1 != t1 || old.t2 != t2 || old.warm != warm || old.cool != cool;
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

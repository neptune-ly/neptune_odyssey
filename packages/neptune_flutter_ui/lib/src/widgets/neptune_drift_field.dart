// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/accessibility.dart';
import '../theme/extensions.dart';

/// One object suspended in a [NeptuneDriftField].
///
/// [depth] is the whole model: 0 is the far plane, 1 is nearest the glass.
/// Everything else about how the object reads — how big it is drawn, how
/// strongly it drifts, how far it swings when the customer drags, how solid it
/// looks — is derived from it, so a caller cannot place an object that is
/// small and blurred but moves like it is in front. Getting those out of step
/// is what makes a parallax scene read as stickers on a wall.
@immutable
class NeptuneDriftObject {
  /// What is suspended. A brand's own artwork, a card face, a glyph.
  final Widget child;

  /// Where the object's CENTRE sits, as a fraction of the field: (-1,-1) is
  /// the top-left corner, (0,0) the middle, (1,1) the bottom-right.
  ///
  /// IT POSITIONS THE CENTRE, WHICH IS NOT WHAT [Alignment] NORMALLY DOES.
  /// Material's alignment insets an object so it never leaves its box, so the
  /// same alignment lands two objects of different sizes in different places —
  /// which is exactly how a scene composed by eye collapses into a pile the
  /// moment one object is resized. Here the centre is where you said and the
  /// size is irrelevant to it, so a composition can be reasoned about. An
  /// object whose centre is near an edge is CROPPED by it, and that is a
  /// feature: something continuing past the viewport is one of the strongest
  /// cues that a scene is bigger than the screen.
  ///
  /// IT DOES NOT MIRROR UNDER RTL, and that is deliberate. A scene of physical
  /// objects is a picture, not a layout: reading order mirrors, columns of
  /// text mirror, a photograph does not. The same rule governs what is drawn
  /// INSIDE an object — a card's chip, an embossed mark, a magnetic stripe are
  /// all `Alignment`, never `AlignmentDirectional`, because a card in an
  /// Arabic speaker's wallet has its chip in the same corner as anyone
  /// else's.
  final Alignment at;

  /// The object's plane, 0 (far) to 1 (near).
  final double depth;

  /// Its longest edge, in logical pixels, BEFORE the depth scale.
  final double size;

  /// Its resting tilt, in turns. A scene where everything is axis-aligned
  /// reads as a grid; one where everything is tilted reads as a mess.
  final double turns;

  /// Seconds for one full drift cycle. Left to the field to stagger when null
  /// — see [NeptuneDriftField.build], which spaces the periods with an
  /// irrational step so the objects never resynchronise into a visible pulse.
  final double? periodSeconds;

  /// A label for assistive technology, if this object carries meaning. Most
  /// do not: a drifting card behind a headline is decoration, and decoration
  /// that announces itself is noise in a screen reader. Leave it null and the
  /// object is excluded from semantics entirely.
  final String? semanticLabel;

  const NeptuneDriftObject({
    required this.child,
    required this.at,
    required this.depth,
    required this.size,
    this.turns = 0,
    this.periodSeconds,
    this.semanticLabel,
  })  : assert(depth >= 0 && depth <= 1, 'depth is 0 (far) to 1 (near)'),
        assert(size > 0);
}

/// A ground with physical objects suspended in it at different depths, drifting.
///
/// THE FIELD IS THE INTRODUCTION, NOT AN ORNAMENT. It exists for the one screen
/// a customer meets before they have an account: there is no data to show, so
/// the screen has to say what kind of institution this is. A still hero says it
/// once; objects that hang in space and move say it for as long as the customer
/// looks, and they say something a gradient cannot — that the things this bank
/// deals in are objects, with weight and a near and a far.
///
/// DEPTH IS EXPRESSED THREE WAYS AT ONCE, and that is what sells it. A nearer
/// object is drawn LARGER, moves FURTHER for the same gesture, and sits at full
/// opacity while the far plane is carried toward the ground colour. Any one of
/// those alone reads as a sticker sliding about; together they read as space.
///
/// IT IS NOT BLURRED. Depth-of-field would be the fourth cue and it is the one
/// this widget refuses: an `ImageFiltered` per object is a full-screen blur per
/// object per frame, and at 120Hz on a ProMotion display that is the difference
/// between a scene that floats and a scene that stutters. Scale, travel and
/// tone carry the depth; the frame budget carries the illusion.
///
/// MOTION HAS TWO SOURCES. An ambient drift that runs on its own, so the screen
/// is alive before it is touched; and a drag parallax, so the screen answers
/// when it is. The drag is a real interaction rather than a device-tilt sensor
/// reading: a sensor makes the scene move while the phone is on a table in a
/// moving car, needs a permission story on one platform, and cannot be tested.
///
/// UNDER REDUCED MOTION THE SCENE STILL EXISTS. Every object renders at its
/// resting position, scale and tilt — the composition is unchanged and nothing
/// is missing, it simply does not move, and the drag does nothing. A reduced-
/// motion customer gets the still photograph, never an empty ground.
class NeptuneDriftField extends StatefulWidget {
  /// The objects, back to front. Order is drawing order; [NeptuneDriftObject.depth]
  /// is appearance. They are usually the same and the widget does not enforce
  /// it — a brand may want a near object behind a far one for one composition.
  final List<NeptuneDriftObject> objects;

  /// The ground the objects hang in. Defaults to the theme's surface.
  final Color? ground;

  /// What a far object's tone is mixed with: the colour of the air between the
  /// customer and it.
  ///
  /// Defaults to [ground], which is right when the ground is the brand's own
  /// colour. It is a SEPARATE knob from the ground because of a specific
  /// failure: on a near-black ground, mixing a white object toward the ground
  /// desaturates it, and a white tile carried a third of the way to black is
  /// simply a GREY BOX — the thing every one of these surfaces is trying not
  /// to be. Atmosphere is coloured. A scene on a deep ground should haze
  /// toward the brand's mid tone instead, and then a far object reads as being
  /// behind the brand's own air rather than as a desaturated near one.
  final Color? haze;

  /// Content drawn over the field — the headline, the call to action. It is a
  /// sibling of the objects, not a child of one, so it never inherits a drift
  /// transform: type that moves is type that cannot be read.
  final Widget? child;

  /// How far the nearest plane travels for a full-width drag, in logical
  /// pixels. The far plane travels [parallaxExtent] * 0.25 of it.
  final double parallaxExtent;

  /// Whether a drag moves the scene. A field behind an interactive surface
  /// (a form, a scrollable) passes false so the two gestures never compete.
  final bool interactive;

  const NeptuneDriftField({
    super.key,
    required this.objects,
    this.ground,
    this.haze,
    this.child,
    this.parallaxExtent = 28,
    this.interactive = true,
  });

  @override
  State<NeptuneDriftField> createState() => _NeptuneDriftFieldState();
}

class _NeptuneDriftFieldState extends State<NeptuneDriftField>
    with SingleTickerProviderStateMixin {
  // ONE controller for the whole scene. Per-object controllers would each
  // schedule their own frame callback; the phases are what differ, and a phase
  // is arithmetic on a shared clock.
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  );

  /// Drag offset in logical pixels, before the per-object depth scale.
  Offset _drag = Offset.zero;

  @override
  void initState() {
    super.initState();
    _clock.repeat();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      // Clamped rather than accumulated without limit: a customer who drags
      // ten times in one direction must not push the scene off the screen.
      _drag = Offset(
        (_drag.dx + d.delta.dx * 0.4).clamp(-1.0 * widget.parallaxExtent, widget.parallaxExtent),
        (_drag.dy + d.delta.dy * 0.4).clamp(-1.0 * widget.parallaxExtent, widget.parallaxExtent),
      );
    });
  }

  void _settle() {
    // The scene returns to rest rather than staying where it was left. A
    // composition that a stray thumb can permanently decentre is not a
    // composition.
    setState(() => _drag = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = theme.extension<NptMotion>();
    final ground = widget.ground ?? theme.colorScheme.surface;
    final haze = widget.haze ?? ground;
    final still = NeptuneAccessibility.reducedMotion(context);

    final scene = Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.objects.length; i++)
          _DriftedObject(
            object: widget.objects[i],
            clock: _clock,
            // Periods are staggered by an irrational step so that however many
            // objects a brand places, no two ever come back into phase and the
            // scene never develops a beat.
            period: widget.objects[i].periodSeconds ?? (11.0 + i * math.e),
            phase: i * 0.37,
            haze: haze,
            drag: still ? Offset.zero : _drag,
            parallaxExtent: widget.parallaxExtent,
            still: still,
          ),
        if (widget.child != null) widget.child!,
      ],
    );

    return ColoredBox(
      color: ground,
      child: widget.interactive && !still
          ? GestureDetector(
              // The drag must not steal from anything the child puts on top:
              // a button's tap wins because it is a deeper hit target, and
              // this recogniser only claims a pan.
              behavior: HitTestBehavior.translucent,
              onPanUpdate: _onDragUpdate,
              onPanEnd: (_) => _settle(),
              onPanCancel: _settle,
              child: AnimatedContainer(
                duration: motion?.durationStandard ?? const Duration(milliseconds: 240),
                curve: motion?.standard ?? Curves.easeOutCubic,
                child: scene,
              ),
            )
          : scene,
    );
  }
}

class _DriftedObject extends StatelessWidget {
  final NeptuneDriftObject object;
  final Animation<double> clock;
  final double period;
  final double phase;
  final Color haze;
  final Offset drag;
  final double parallaxExtent;
  final bool still;

  const _DriftedObject({
    required this.object,
    required this.clock,
    required this.period,
    required this.phase,
    required this.haze,
    required this.drag,
    required this.parallaxExtent,
    required this.still,
  });

  /// The three depth cues, all read off the one number.
  double get _scale => 0.72 + object.depth * 0.46;
  double get _travel => 0.25 + object.depth * 0.75;
  double get _presence => 0.62 + object.depth * 0.38;

  @override
  Widget build(BuildContext context) {
    // A far object is carried toward the ground rather than made translucent:
    // opacity would let whatever is behind it show through, and there is
    // nothing behind it but the ground anyway — so this is the same picture at
    // a quarter of the cost, and it composites on one layer instead of two.
    // The depth scale is applied to the LAID-OUT box rather than as a
    // transform on top of it, so the object's real size is what the placement
    // arithmetic sees and an object's centre stays where it was put.
    final body = SizedBox.expand(
      child: _presence >= 0.999
          ? object.child
          : ColorFiltered(
              colorFilter: ColorFilter.mode(
                haze.withValues(alpha: 1 - _presence),
                BlendMode.srcATop,
              ),
              child: object.child,
            ),
    );

    // Positioned by its CENTRE over the measured field - see
    // [NeptuneDriftObject.at] for why `Align` is wrong here.
    final placed = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final side = object.size * _scale;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: (object.at.x + 1) / 2 * w - side / 2,
              top: (object.at.y + 1) / 2 * h - side / 2,
              width: side,
              height: side,
              child: body,
            ),
          ],
        );
      },
    );

    // Semantics: an object that carries no meaning is REMOVED from the tree
    // rather than merely unlabelled, so a screen reader moves from the
    // headline to the button without stopping on five anonymous images.
    final described = object.semanticLabel == null
        ? ExcludeSemantics(child: placed)
        : Semantics(label: object.semanticLabel, image: true, child: placed)
;

    if (still) {
      return Transform.rotate(
        angle: object.turns * 2 * math.pi,
        alignment: Alignment.center,
        child: described,
      );
    }

    return AnimatedBuilder(
      animation: clock,
      child: described,
      builder: (context, child) {
        // The shared clock is a 60-second ramp; each object reads it at its own
        // period, so `t` is this object's own cycle position in turns.
        final t = (clock.value * 60 / period + phase) * 2 * math.pi;
        // Two different frequencies on the two axes, so the path is a Lissajous
        // figure rather than a circle. A circle reads as a mechanism; this
        // reads as something floating.
        final dx = math.sin(t) * 6 * _travel + drag.dx * _travel;
        final dy = math.cos(t * 0.61) * 9 * _travel + drag.dy * _travel;
        final tilt = (object.turns + math.sin(t * 0.43) * 0.006) * 2 * math.pi;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: tilt,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}

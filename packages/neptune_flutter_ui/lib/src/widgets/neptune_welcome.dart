// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The Welcome / Sign-in template (templates.html §welcome): an ambient,
// gently-looping backdrop (a radial brand wash + three blurred drifting orbs in
// primary / tertiary / secondary), the brand lockup, a bold mixed-weight
// promise, and the animated CTA pair. Everything re-skins with the brand and
// pauses under reduced-motion. Theme-only, RTL-safe.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// The ambient welcome backdrop: `radial-gradient(135% 95% at 50% -5%,
/// primary 26% → surface 68%)` with three soft orbs drifting on independent
/// 15 / 19 / 17-second loops (web `welOrb1..3`). Static under reduced-motion.
class NeptuneAmbientBackdrop extends StatefulWidget {
  const NeptuneAmbientBackdrop({super.key});

  @override
  State<NeptuneAmbientBackdrop> createState() => _NeptuneAmbientBackdropState();
}

class _NeptuneAmbientBackdropState extends State<NeptuneAmbientBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    // One long master clock; each orb derives its own period from it.
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 57));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// 0→1→0 phase for a loop of [seconds] within the 57s master clock.
  double _phase(double seconds) {
    final t = (_c.value * 57.0 / seconds) % 1.0;
    return 0.5 - 0.5 * math.cos(2 * math.pi * t); // ease-in-out sine loop
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wash = Color.lerp(scheme.surface, scheme.primary, 0.26)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -1.05),
          radius: 1.35,
          colors: [wash, scheme.surface],
          stops: const [0, 0.68],
        ),
      ),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final p1 = _phase(15);
          final p2 = _phase(19);
          final p3 = _phase(17);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              _orb(scheme.primary, 220,
                  top: -44 + 38 * p1, start: -36 + 28 * p1, scale: 1 + 0.16 * p1),
              _orb(scheme.tertiary, 184,
                  top: 150 + 26 * p2, end: -46 - (-38) * p2, scale: 1 + 0.10 * p2),
              _orb(scheme.secondary, 160,
                  bottom: 90 + 30 * p3, start: 24 + 26 * p3, scale: 1 + 0.22 * p3),
            ],
          );
        },
      ),
    );
  }

  Widget _orb(
    Color color,
    double size, {
    double? top,
    double? bottom,
    double? start,
    double? end,
    required double scale,
  }) {
    return PositionedDirectional(
      top: top,
      bottom: bottom,
      start: start,
      end: end,
      child: Transform.scale(
        scale: scale,
        // A soft radial falloff reads like the web's blur(44px) orb without
        // the cost of a live blur filter.
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.42),
                color.withValues(alpha: 0.22),
                color.withValues(alpha: 0),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
      ),
    );
  }
}

/// The brand lockup (web `.wel__brand`): a rounded primary mark carrying the
/// brand initial in the display face with a tertiary accent dot, next to the
/// brand name at display-w800.
class NeptuneBrandLockup extends StatelessWidget {
  /// The mark letter (e.g. 'N').
  final String initial;

  /// The brand name (e.g. 'Neptune').
  final String name;

  /// Accent-dot colour; defaults to the brand tertiary.
  final Color? dotColor;

  const NeptuneBrandLockup({
    super.key,
    required this.initial,
    required this.name,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final type = theme.extension<NptType>()!;
    final text = theme.textTheme;

    final nameStyle = (text.titleLarge ?? const TextStyle()).copyWith(
      fontFamily: type.display,
      fontWeight: FontWeight.w800,
      fontSize: 20,
      letterSpacing: -0.2,
      color: scheme.onSurface,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: Stack(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: shape.rXs,
                ),
                child: Text(
                  initial,
                  style: nameStyle.copyWith(
                    color: scheme.onPrimary,
                    fontSize: 20,
                    height: 1,
                  ),
                ),
              ),
              PositionedDirectional(
                top: 6,
                end: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor ?? scheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 11),
        Text(name, style: nameStyle),
      ],
    );
  }
}

/// The full Welcome / Sign-in screen (templates.html §welcome): ambient
/// backdrop + lockup + a mixed-weight promise ([title] at display-w500 with
/// [emphasis] at w800 in primary) + supporting line + the CTA pair slot.
class NeptuneWelcome extends StatelessWidget {
  final String brandInitial;
  final String brandName;

  /// The regular-weight leading line of the promise.
  final String title;

  /// The bold primary-tinted second line.
  final String emphasis;

  /// Supporting paragraph under the promise.
  final String? supporting;

  /// Primary action — typically a `NeptuneCta(arrow: true)`.
  final Widget primaryAction;

  /// Secondary action — typically a tonal `NeptuneCta`.
  final Widget? secondaryAction;

  const NeptuneWelcome({
    super.key,
    required this.brandInitial,
    required this.brandName,
    required this.title,
    required this.emphasis,
    this.supporting,
    required this.primaryAction,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final type = theme.extension<NptType>()!;
    final text = theme.textTheme;

    final titleStyle = (text.headlineMedium ?? const TextStyle()).copyWith(
      fontFamily: type.display,
      fontWeight: FontWeight.w500,
      height: 1.08,
      letterSpacing: type.displayTracking * 32,
      color: scheme.onSurface,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        const NeptuneAmbientBackdrop(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(26, 64, 26, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeptuneBrandLockup(initial: brandInitial, name: brandName),
                const Spacer(),
                RichText(
                  text: TextSpan(
                    style: titleStyle,
                    children: [
                      TextSpan(text: '$title\n'),
                      TextSpan(
                        text: emphasis,
                        style: titleStyle.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (supporting != null) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      supporting!,
                      style: text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                primaryAction,
                if (secondaryAction != null) ...[
                  const SizedBox(height: 10),
                  secondaryAction!,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

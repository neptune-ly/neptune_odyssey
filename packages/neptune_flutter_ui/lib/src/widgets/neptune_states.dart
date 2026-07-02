// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// State completeness (R4b): banks judge kits by the unhappy paths. This file
// makes loading / empty / error a first-class contract:
//   · NeptuneShimmer      — the brand shimmer used by every skeleton
//   · NeptuneSkeletonCard / NeptuneSkeletonRow — ready-made placeholders that
//     mirror the real card/row anatomy
//   · NeptuneStateSwitcher — one wrapper that renders loading → skeleton,
//     error → branded retry, empty → NeptuneEmptyState, else the content —
//     with a soft cross-fade on the brand motion curve.
// Theme-only, RTL-safe, reduced-motion aware.

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import 'neptune_buttons.dart';
import 'neptune_shell_feedback.dart';

/// The four data states a surface can be in.
enum NeptuneDataState { loading, error, empty, ready }

/// A gentle brand shimmer: a sweeping highlight over any child (usually a
/// skeleton shape). Pauses under reduced-motion.
class NeptuneShimmer extends StatefulWidget {
  final Widget child;

  const NeptuneShimmer({super.key, required this.child});

  @override
  State<NeptuneShimmer> createState() => _NeptuneShimmerState();
}

class _NeptuneShimmerState extends State<NeptuneShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = (_c.value * 2.6 - 1.3) * (rtl ? -1 : 1);
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              scheme.onSurface.withValues(alpha: 0.06),
              scheme.onSurface.withValues(alpha: 0.14),
              scheme.onSurface.withValues(alpha: 0.06),
            ],
            stops: const [0.35, 0.5, 0.65],
            transform: _SlideGradient(t),
          ).createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Slides the shimmer highlight across the shader bounds; [t] is precomputed
/// with RTL direction already folded in (avoids resolving directional
/// alignment inside createShader, which has no ambient Directionality).
class _SlideGradient extends GradientTransform {
  final double t;

  const _SlideGradient(this.t);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * t, 0, 0);
  }
}

/// A skeleton block matching the brand corner family.
class _Bone extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? radius;

  const _Bone({this.width, required this.height, this.radius});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: radius ?? shape.rXs,
      ),
    );
  }
}

/// Skeleton for card-shaped content (hero/stat cards) — shimmering bones in
/// the real card anatomy.
class NeptuneSkeletonCard extends StatelessWidget {
  final double height;

  const NeptuneSkeletonCard({super.key, this.height = 148});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    return NeptuneShimmer(
      child: Container(
        height: height,
        padding: const EdgeInsetsDirectional.all(20),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: shape.rLg,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bone(width: 120, height: 12),
            SizedBox(height: 14),
            _Bone(width: 200, height: 26),
            Spacer(),
            _Bone(width: 90, height: 10),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for list rows (transactions/tiles) — [count] shimmering rows.
class NeptuneSkeletonRow extends StatelessWidget {
  final int count;

  const NeptuneSkeletonRow({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    final shape = Theme.of(context).extension<NptShape>()!;
    return NeptuneShimmer(
      child: Column(children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
            child: Row(children: [
              _Bone(width: 40, height: 40, radius: shape.rSm),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: 140, height: 12),
                    SizedBox(height: 8),
                    _Bone(width: 90, height: 10),
                  ],
                ),
              ),
              const _Bone(width: 64, height: 12),
            ]),
          ),
      ]),
    );
  }
}

/// One wrapper for the whole data-state contract: give it the [state] and the
/// four faces; it cross-fades between them on the brand motion curve.
class NeptuneStateSwitcher extends StatelessWidget {
  final NeptuneDataState state;
  final Widget child;

  /// Skeleton shown while loading; defaults to [NeptuneSkeletonRow].
  final Widget? loading;

  /// Empty face; defaults to a themed [NeptuneEmptyState].
  final Widget? empty;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;

  /// Error face; defaults to alert + retry button.
  final Widget? error;
  final String errorTitle;
  final String retryLabel;
  final VoidCallback? onRetry;

  const NeptuneStateSwitcher({
    super.key,
    required this.state,
    required this.child,
    this.loading,
    this.empty,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.error,
    this.errorTitle = 'Something went wrong',
    this.retryLabel = 'Try again',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final motion = Theme.of(context).extension<NptMotion>()!;

    final face = switch (state) {
      NeptuneDataState.loading =>
        KeyedSubtree(key: const ValueKey('loading'),
            child: loading ?? const NeptuneSkeletonRow()),
      NeptuneDataState.empty => KeyedSubtree(
          key: const ValueKey('empty'),
          child: empty ??
              NeptuneEmptyState(
                  icon: emptyIcon, title: emptyTitle, message: emptyMessage),
        ),
      NeptuneDataState.error => KeyedSubtree(
          key: const ValueKey('error'),
          child: error ??
              Column(mainAxisSize: MainAxisSize.min, children: [
                NeptuneAlert(
                    message: errorTitle, tone: NeptuneAlertTone.danger),
                const SizedBox(height: 12),
                NeptuneButton(
                    label: retryLabel,
                    variant: NeptuneButtonStyle.tonal,
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry),
              ]),
        ),
      NeptuneDataState.ready =>
        KeyedSubtree(key: const ValueKey('ready'), child: child),
    };

    return AnimatedSwitcher(
      duration: motion.durationStandard,
      switchInCurve: motion.standard,
      switchOutCurve: motion.standard,
      child: face,
    );
  }
}

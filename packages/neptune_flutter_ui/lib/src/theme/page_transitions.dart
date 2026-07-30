import 'package:flutter/material.dart';

/// Neptune's route transition — M3 fade-through with a gentle upward settle.
///
/// Flutter's stock Android transition (Zoom) reads as a mechanical pop; a
/// premium banking surface changes screens the way M3 Expressive specifies
/// for forward navigation: the incoming page fades in over the first half of
/// the timeline while settling up a few percent on an emphasized curve, and
/// the outgoing page recedes — a slight lift and dim, never a hard cut.
/// Reverse (pop) plays the same story backwards for free, because everything
/// is driven off the route animations.
///
/// iOS deliberately keeps [CupertinoPageTransitionsBuilder] when installed via
/// [NeptunePageTransitionsBuilder.theme] — replacing it would break the
/// native edge-swipe back gesture, which no visual polish is worth.
///
/// Reduced motion: a plain cross-fade — position never animates.
class NeptunePageTransitionsBuilder extends PageTransitionsBuilder {
  const NeptunePageTransitionsBuilder();

  /// The ready-made theme: Neptune motion everywhere, Cupertino on iOS.
  static const PageTransitionsTheme theme = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: NeptunePageTransitionsBuilder(),
      TargetPlatform.fuchsia: NeptunePageTransitionsBuilder(),
      TargetPlatform.linux: NeptunePageTransitionsBuilder(),
      TargetPlatform.macOS: NeptunePageTransitionsBuilder(),
      TargetPlatform.windows: NeptunePageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) {
      return FadeTransition(opacity: animation, child: child);
    }

    // Incoming: fade over the first 60%, settle up from 3.5% on the
    // emphasized-decelerate curve. Numbers chosen so the fade completes
    // before the settle does — the page is READ before it has finished
    // landing, which is what makes it feel fast and calm at once.
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    final settle = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    // Outgoing (this page is being covered): recede — dim to 90% and lift
    // 1.5%. Subtle enough to read as depth, cheap enough to never jank.
    final recedeFade = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeIn,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.035),
        end: Offset.zero,
      ).animate(settle),
      child: FadeTransition(
        opacity: fadeIn,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0, -0.015),
          ).animate(recedeFade),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.9).animate(recedeFade),
            child: child,
          ),
        ),
      ),
    );
  }
}

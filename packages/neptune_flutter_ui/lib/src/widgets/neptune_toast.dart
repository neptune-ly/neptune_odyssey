// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// An inverse-surface toast bar (web `<npt-snackbar>`): a high-contrast
/// [inverseSurface] strip with a body message and an optional trailing action,
/// auto-tinted to [inversePrimary]. Use [showNeptuneToast] to float one over
/// the current [Overlay]. Theme-only, RTL-safe.
class NeptuneToast extends StatelessWidget {
  final String message;
  final Widget? action;

  const NeptuneToast({
    super.key,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return Material(
      color: scheme.inverseSurface,
      borderRadius: shape.rXs,
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 16),
                IconTheme.merge(
                  data: IconThemeData(color: scheme.inversePrimary),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: scheme.inversePrimary),
                    child: TextButtonTheme(
                      data: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.inversePrimary,
                        ),
                      ),
                      child: action!,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Floats a [NeptuneToast] over the nearest [Overlay] — no [Scaffold] or
/// [ScaffoldMessenger] required. The bar is pinned inline-centre at the bottom
/// (inside [SafeArea]), capped at a readable width, fades in, and auto-removes
/// after [duration]. RTL-safe via logical insets.
void showNeptuneToast(
  BuildContext context,
  String message, {
  Widget? action,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, t, child) => Opacity(opacity: t, child: child),
              child: NeptuneToast(message: message, action: action),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Timer(duration, () {
    if (entry.mounted) entry.remove();
  });
}

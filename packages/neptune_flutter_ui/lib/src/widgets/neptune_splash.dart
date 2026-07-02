// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// R6: the branded splash/launch screen — the ambient welcome backdrop (the
// same radial wash + drifting orbs as NeptuneWelcome, so a cold-start app
// visually continues into its own welcome screen rather than jump-cutting),
// a large brand mark, and a loader beneath. Theme-only, RTL-safe.

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import 'neptune_loaders.dart';
import 'neptune_welcome.dart';

/// A full-bleed branded splash screen — cold-start/launch moment before the
/// app has enough state to show real content.
///
/// Pass [logo] to show a real brand mark instead of the generated
/// initial-in-a-square (mirrors [NeptuneWelcome]'s `lockup` override).
class NeptuneSplashScreen extends StatelessWidget {
  /// The mark letter shown when [logo] is not given (e.g. 'N').
  final String brandInitial;

  /// The brand name shown under the mark.
  final String brandName;

  /// Replaces the generated mark with a real logo/lockup widget.
  final Widget? logo;

  /// Which loader animates beneath the mark. Pulse (the default) is the
  /// quietest — a good fit for a moment the user can't interact with yet.
  final NeptuneLoaderStyle loaderStyle;

  /// Optional line under the loader (e.g. "Loading your account…").
  final String? caption;

  const NeptuneSplashScreen({
    super.key,
    required this.brandInitial,
    required this.brandName,
    this.logo,
    this.loaderStyle = NeptuneLoaderStyle.pulse,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final type = theme.extension<NptType>()!;
    final text = theme.textTheme;

    final nameStyle = (text.headlineSmall ?? const TextStyle()).copyWith(
      fontFamily: type.display,
      fontWeight: FontWeight.w800,
      letterSpacing: type.displayTracking * 24,
      color: scheme.onSurface,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        const NeptuneAmbientBackdrop(),
        SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                logo ??
                    Container(
                      width: 88,
                      height: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: shape.rXl,
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.28),
                            blurRadius: 32,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Text(
                        brandInitial,
                        style: nameStyle.copyWith(
                          color: scheme.onPrimary,
                          fontSize: 44,
                          height: 1,
                        ),
                      ),
                    ),
                const SizedBox(height: 20),
                Text(brandName, style: nameStyle),
                const SizedBox(height: 40),
                neptuneLoaderFor(loaderStyle, size: 48),
                if (caption != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    caption!,
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

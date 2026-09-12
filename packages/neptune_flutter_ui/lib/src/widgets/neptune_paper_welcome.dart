// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The PAPER pre-login shell (2.25.0): what `loginShell: 'paper-lockup'` and
// `'lockup-rule'` draw. Where `NeptuneWelcome` puts the customer on the
// bank's colour with drifting orbs, this puts a small lockup on a plain
// ground with one hairline under it. The restraint is the statement - there
// is no watermark, no motif and no orb to add. Flutter-ahead: no web
// template yet.

import 'package:flutter/material.dart';

import '../theme/brand_canvas.dart';
import 'neptune_identity_surfaces.dart';
import 'neptune_register.dart';

/// The paper welcome body: [lockup] centred and small, a short hairline rule
/// under it, the bank [name] as an eyebrow, then the CTA pair at the foot with
/// an optional [footer] (terms, version) under them.
///
/// It is a body, not a screen: the host keeps its own `Scaffold`/`AppBar`
/// (a language switch lives there) and every colour comes from
/// [NptBrandCanvas.paper], so the ground re-tones with the theme the way a
/// surface should.
class NeptunePaperWelcome extends StatelessWidget {
  /// The bank's mark, sized by the host (a 72dp square reads right).
  final Widget lockup;

  /// The bank's name, set as an eyebrow under the rule. Null draws no name.
  final String? name;

  /// Width of the hairline under the lockup.
  final double ruleWidth;

  final Widget primaryAction;
  final Widget? secondaryAction;
  final Widget? footer;

  const NeptunePaperWelcome({
    super.key,
    required this.lockup,
    this.name,
    this.ruleWidth = 40,
    required this.primaryAction,
    this.secondaryAction,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final paper = NptBrandCanvas.paper(scheme);
    return ColoredBox(
      color: paper.canvas,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      lockup,
                      const SizedBox(height: 20),
                      SizedBox(width: ruleWidth, child: const NeptuneHairline()),
                      if (name != null) ...[
                        const SizedBox(height: 14),
                        NeptuneEyebrow(name!, color: paper.onCanvasMuted),
                      ],
                    ],
                  ),
                ),
              ),
              primaryAction,
              if (secondaryAction != null) ...[
                const SizedBox(height: 12),
                secondaryAction!,
              ],
              if (footer != null) ...[
                const SizedBox(height: 28),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

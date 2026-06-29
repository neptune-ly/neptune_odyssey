// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// The common content frame every screen uses: a NeptunePageHeader, optional
// header actions, and a width-capped scrolling body so wide desktop windows keep
// a comfortable reading measure. Theme-only.

import 'package:flutter/material.dart';
import 'package:neptune_flutter_ui/neptune_flutter_ui.dart';

class ContentScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;
  final double maxContentWidth;

  const ContentScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.children,
    this.maxContentWidth = 1080,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(28, 24, 28, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: NeptunePageHeader(title: title, subtitle: subtitle)),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: 16),
                Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: actions),
              ],
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 8, 28, 36),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A titled block within a screen — a label over arbitrary content, used to
/// group cards/lists. Wraps NeptuneSection's spacing conventions.
class Block extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;

  const Block({super.key, required this.title, this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 20),
      child: NeptuneSection(title: title, description: description, child: child),
    );
  }
}

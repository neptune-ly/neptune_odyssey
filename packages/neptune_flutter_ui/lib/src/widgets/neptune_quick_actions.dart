// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import 'neptune_icon_slot.dart';

/// How a row of quick actions is composed — the `actionRow` lever (codec
/// `kActionRows`), rendered.
///
/// The pale tonal circle behind every glyph carries no information: it is the
/// same shape, the same size and the same role colour for "transfer" as for
/// "services", and it was identical on every white-label bank. These three
/// are compositions, not tints.
enum NeptuneQuickActionShell {
  /// The tonal `secondaryContainer` circle behind each glyph. The default,
  /// and what every host that names no shell keeps.
  filledCircles,

  /// No chip. One strip ruled top and bottom, the actions divided by
  /// hairlines — the column header of a register.
  registerRows,

  /// Each action in its own hairline cell, and the FIRST action — the one
  /// that moves the customer forward — marked in the brand's accent. The
  /// host orders its actions so the forward one leads.
  ruleGrid,
}

/// Carries the row's composition down to each [NeptuneQuickAction], so the
/// host keeps handing over a plain list of actions and no action has to be
/// told which bank it belongs to.
class _QuickActionShellScope extends InheritedWidget {
  final NeptuneQuickActionShell shell;
  final bool lead;

  const _QuickActionShellScope({
    required this.shell,
    required this.lead,
    required super.child,
  });

  static _QuickActionShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_QuickActionShellScope>();

  @override
  bool updateShouldNotify(_QuickActionShellScope old) =>
      old.shell != shell || old.lead != lead;
}

/// A single quick action: a circular tonal icon chip above a short label.
///
/// Mirrors the web `<npt-quick-action>` tonal treatment — a
/// [ColorScheme.secondaryContainer] chip with an
/// [ColorScheme.onSecondaryContainer] icon, captioned by a
/// [TextTheme.labelMedium] label in [ColorScheme.onSurfaceVariant].
/// Theme-only (no literal colours/radii/fonts), RTL-safe, 48dp-min target.
class NeptuneQuickAction extends StatelessWidget {
  /// The glyph shown inside the circular chip. Optional: supply this **or**
  /// [iconWidget].
  final IconData? icon;

  /// A host-supplied mark rendered inside the chip instead of [icon] — a
  /// per-brand SVG, an [ImageIcon], a lettermark. White-label apps ship their
  /// own icon sets, so quick actions never force Material glyphs on a brand.
  ///
  /// The widget is laid out in the same square the glyph would occupy and
  /// receives the [ColorScheme.onSecondaryContainer] tint through an
  /// [IconTheme] + [DefaultTextStyle] rather than a hard filter, so a
  /// multi-colour brand mark stays multi-colour. A monochrome SVG should
  /// inherit `currentColor` (i.e. read `IconTheme.of(context).color`) to stay
  /// on-brand across light/dark and every brandprint.
  final Widget? iconWidget;

  /// The caption shown beneath the chip.
  final String label;

  /// Invoked when the action is tapped. When null the action is inert.
  final VoidCallback? onTap;

  const NeptuneQuickAction({
    super.key,
    this.icon,
    this.iconWidget,
    required this.label,
    this.onTap,
  }) : assert(
          icon != null || iconWidget != null,
          'NeptuneQuickAction needs a glyph: pass `icon` (IconData) or `iconWidget`.',
        );

  @override
  Widget build(BuildContext context) {
    final scope = _QuickActionShellScope.maybeOf(context);
    return switch (scope?.shell ?? NeptuneQuickActionShell.filledCircles) {
      NeptuneQuickActionShell.filledCircles => _buildChip(context),
      NeptuneQuickActionShell.registerRows => _buildBare(context),
      NeptuneQuickActionShell.ruleGrid =>
        _buildCell(context, lead: scope?.lead ?? false),
    };
  }

  /// The quiet register: the mark and its label on the page itself, no chip
  /// to draw a shape that says nothing.
  Widget _buildBare(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _tappable(
      context,
      Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 26,
              child: Center(
                child: NeptuneIconSlot(
                  icon: icon,
                  iconWidget: iconWidget,
                  size: 24,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _caption(textTheme, scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  /// Line structure: a hairline cell per action, and the accent spent once on
  /// the [lead] one — the action that moves the customer forward.
  Widget _buildCell(BuildContext context, {required bool lead}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = theme.extension<NptShape>()!;
    final accent = theme.extension<NptColors>()!.accent;
    final textTheme = theme.textTheme;
    final mark = lead ? accent : scheme.onSurface;

    return _tappable(
      context,
      DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape.rSm,
          border: Border.all(
            color: lead ? accent : scheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 26,
                child: Center(
                  child: NeptuneIconSlot(
                    icon: icon,
                    iconWidget: iconWidget,
                    size: 24,
                    color: mark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _caption(textTheme, lead ? accent : scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _caption(TextTheme textTheme, Color color) => Text(
        label,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: textTheme.labelMedium?.copyWith(color: color),
      );

  /// The chip and its caption are one button named by the caption — the same
  /// semantics wrapper every shell wears.
  Widget _tappable(BuildContext context, Widget child) {
    final shape = Theme.of(context).extension<NptShape>()!;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape.rSm,
        child: child,
      ),
    );
  }

  Widget _buildChip(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final textTheme = Theme.of(context).textTheme;

    final chipRadius = BorderRadius.circular(shape.full);

    // The chip and its caption are one button named by the caption. Without
    // the merge the chip is an unnamed tap target and the caption a stray
    // text node after it.
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: scheme.secondaryContainer,
          borderRadius: chipRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: chipRadius),
            child: SizedBox(
              width: 56,
              height: 56,
              // Center loosens the chip's tight box so the glyph — or a
              // host-supplied [iconWidget] — keeps its natural icon size.
              child: Center(
                child: NeptuneIconSlot(
                  icon: icon,
                  iconWidget: iconWidget,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
      ),
    );
  }
}

/// A row of evenly-spaced [NeptuneQuickAction]s.
///
/// Mirrors the web `<npt-quick-actions>` — actions are laid out in equal,
/// top-aligned [Expanded] cells so they share the available width. When more
/// actions than [columns] are supplied they wrap onto further rows. Theme-only,
/// RTL-safe (logical layout mirrors automatically).
class NeptuneQuickActions extends StatelessWidget {
  /// The actions to display.
  final List<NeptuneQuickAction> actions;

  /// The number of actions per row before wrapping. Defaults to 4.
  final int columns;

  /// The composition — see [NeptuneQuickActionShell]. The host reads its
  /// brandprint's `actionRow` lever once and passes the result here.
  final NeptuneQuickActionShell shell;

  const NeptuneQuickActions({
    super.key,
    required this.actions,
    this.columns = 4,
    this.shell = NeptuneQuickActionShell.filledCircles,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final perRow = columns < 1 ? 1 : columns;

    final rows = <Widget>[];
    for (var start = 0; start < actions.length; start += perRow) {
      final end =
          (start + perRow) < actions.length ? start + perRow : actions.length;
      final slice = actions.sublist(start, end);

      final gridded = shell == NeptuneQuickActionShell.ruleGrid;
      final ruled = shell == NeptuneQuickActionShell.registerRows;

      final cells = <Widget>[
        for (final (i, action) in slice.indexed) ...[
          // The hairline between two register cells belongs to neither of
          // them, so it is drawn here rather than as a border on both.
          if (ruled && i > 0)
            Container(width: 1, color: scheme.outlineVariant),
          if (gridded && i > 0) const SizedBox(width: 10),
          Expanded(
            child: _QuickActionShellScope(
              shell: shell,
              lead: start + i == 0,
              child: action,
            ),
          ),
        ],
        // Pad the final row so trailing cells keep their natural width.
        for (var i = slice.length; i < perRow; i++) ...[
          if (gridded) const SizedBox(width: 10),
          const Expanded(child: SizedBox.shrink()),
        ],
      ];

      if (rows.isNotEmpty) rows.add(const SizedBox(height: 16));
      rows.add(
        // The register strip's dividers run the full height of the tallest
        // cell, which needs a bounded height — a stretched Row in an
        // unbounded box is the trap the rulebook names.
        ruled
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cells,
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cells,
              ),
      );
    }

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );

    if (shell != NeptuneQuickActionShell.registerRows) return body;

    // Ruled top and bottom: the strip is one entry in the register, not four
    // floating chips.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      child: body,
    );
  }
}

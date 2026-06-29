// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Branded overlays — dialogs, modal sheets, menus and tooltips. Each maps onto
// the Material overlay machinery (showDialog / showModalBottomSheet /
// MenuAnchor / Tooltip) but dresses it in the active Neptune theme: brand
// corner radii, surface-container fills, outlineVariant borders and the
// display/label/body type ramp. Theme-only, RTL-safe — every colour, radius and
// font comes from the active theme.

import 'package:flutter/material.dart';

import '../theme/extensions.dart';

/// A single action button shown in the actions row of a [showNeptuneDialog].
///
/// Render mapping:
///   * [primary] → a [FilledButton] (the affirmative action),
///   * [destructive] → an error-coloured button (delete/remove),
///   * otherwise → a quiet [TextButton].
/// Tapping pops the dialog, returning [label] (or `true` for primary) so the
/// caller can `await` the chosen action.
class NeptuneDialogAction {
  /// The button label.
  final String label;

  /// Optional handler invoked after the dialog is dismissed.
  final VoidCallback? onPressed;

  /// Whether this is the affirmative/primary action (filled button).
  final bool primary;

  /// Whether this is a destructive action (error-coloured).
  final bool destructive;

  const NeptuneDialogAction({
    required this.label,
    this.onPressed,
    this.primary = false,
    this.destructive = false,
  });
}

/// Show a branded modal dialog and resolve with the result of the tapped
/// action (or `null` if dismissed by a barrier tap).
///
/// The card uses [ColorScheme.surfaceContainerHigh], the brand `rLg` radius and
/// 24dp padding. When [icon] is given it sits in a [ColorScheme.primaryContainer]
/// circle above the title. [title] uses `titleLarge`; [message] uses
/// `bodyMedium` in [ColorScheme.onSurfaceVariant]; an optional [content] widget
/// renders below. The [actions] row sits at the end — when omitted a single
/// 'OK' button is added. Theme-only, RTL-safe.
Future<T?> showNeptuneDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  List<NeptuneDialogAction>? actions,
  IconData? icon,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => _NeptuneDialog<T>(
      title: title,
      message: message,
      content: content,
      actions: actions,
      icon: icon,
    ),
  );
}

/// The internal branded [Dialog] body built by [showNeptuneDialog].
class _NeptuneDialog<T> extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<NeptuneDialogAction>? actions;
  final IconData? icon;

  const _NeptuneDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.actions,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final resolved = (actions == null || actions!.isEmpty)
        ? const [NeptuneDialogAction(label: 'OK', primary: true)]
        : actions!;

    return Dialog(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: scheme.surfaceContainerHigh,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: shape.rLg),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Align(
                alignment: AlignmentDirectional.center,
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(shape.full),
                  ),
                  child: Icon(icon, size: 28, color: scheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: icon != null ? TextAlign.center : TextAlign.start,
              style: text.titleLarge?.copyWith(color: scheme.onSurface),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: icon != null ? TextAlign.center : TextAlign.start,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],
            const SizedBox(height: 24),
            _DialogActions<T>(actions: resolved),
          ],
        ),
      ),
    );
  }
}

/// The end-aligned, wrapping row of dialog action buttons.
class _DialogActions<T> extends StatelessWidget {
  final List<NeptuneDialogAction> actions;

  const _DialogActions({required this.actions});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget buildButton(NeptuneDialogAction action) {
      // Pop first, then run the caller's handler. Primary actions resolve
      // truthy; the rest resolve with their label so callers can branch.
      void onTap() {
        Navigator.of(context).pop<T?>(
          action.primary ? (true as T?) : (action.label as T?),
        );
        action.onPressed?.call();
      }

      if (action.primary) {
        return FilledButton(onPressed: onTap, child: Text(action.label));
      }
      if (action.destructive) {
        return TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: scheme.error),
          child: Text(action.label),
        );
      }
      return TextButton(onPressed: onTap, child: Text(action.label));
    }

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [for (final a in actions) buildButton(a)],
      ),
    );
  }
}

/// Show a branded modal bottom sheet and resolve with the result the sheet pops.
///
/// The sheet sits on [ColorScheme.surfaceContainerLow] with the brand `rXl`
/// radius on its top corners and a centred 32×4 grabber in
/// [ColorScheme.onSurfaceVariant] (alpha-blended). An optional [title] in
/// `titleMedium` precedes the [child]. Content is wrapped in [SafeArea] with
/// directional padding. Theme-only, RTL-safe.
Future<T?> showNeptuneSheet<T>({
  required BuildContext context,
  String? title,
  required Widget child,
  bool isScrollControlled = true,
}) {
  final scheme = Theme.of(context).colorScheme;
  final shape = Theme.of(context).extension<NptShape>()!;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: scheme.surfaceContainerLow,
    elevation: 0,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(shape.xl)),
    ),
    builder: (context) => _NeptuneSheetBody(title: title, child: child),
  );
}

/// The internal body for [showNeptuneSheet]: grabber, optional title, child.
class _NeptuneSheetBody extends StatelessWidget {
  final String? title;
  final Widget child;

  const _NeptuneSheetBody({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(shape.full),
                ),
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                style: text.titleMedium?.copyWith(color: scheme.onSurface),
              ),
            ],
            const SizedBox(height: 16),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// A single entry in a [NeptuneMenu]. [destructive] tints the label and icon in
/// [ColorScheme.error].
class NeptuneMenuItem {
  /// The item label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Handler invoked when the item is chosen.
  final VoidCallback? onSelected;

  /// Whether this item is destructive (error-coloured).
  final bool destructive;

  const NeptuneMenuItem({
    required this.label,
    this.icon,
    this.onSelected,
    this.destructive = false,
  });
}

/// A branded popup menu: tapping [child] opens a [MenuAnchor] whose surface uses
/// [ColorScheme.surfaceContainerHigh] and the brand `rMd` radius. Each entry is
/// a [MenuItemButton] with an optional leading icon; destructive entries render
/// in [ColorScheme.error]. Theme-only, RTL-safe.
class NeptuneMenu extends StatelessWidget {
  /// The anchor widget; tapping it opens the menu.
  final Widget child;

  /// The menu entries.
  final List<NeptuneMenuItem> items;

  const NeptuneMenu({
    super.key,
    required this.child,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    final menuStyle = MenuStyle(
      backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
      surfaceTintColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
      elevation: const WidgetStatePropertyAll(3),
      padding: const WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(vertical: 8),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: shape.rMd,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );

    return MenuAnchor(
      style: menuStyle,
      menuChildren: [
        for (final item in items)
          MenuItemButton(
            onPressed: () => item.onSelected?.call(),
            leadingIcon: item.icon == null
                ? null
                : Icon(
                    item.icon,
                    size: 20,
                    color:
                        item.destructive ? scheme.error : scheme.onSurfaceVariant,
                  ),
            style: MenuItemButton.styleFrom(
              foregroundColor:
                  item.destructive ? scheme.error : scheme.onSurface,
              padding:
                  const EdgeInsetsDirectional.symmetric(horizontal: 16),
              minimumSize: const Size(0, 48),
              textStyle: text.bodyLarge,
            ),
            child: Text(item.label),
          ),
      ],
      builder: (context, controller, _) => InkWell(
        onTap: () =>
            controller.isOpen ? controller.close() : controller.open(),
        customBorder: RoundedRectangleBorder(borderRadius: shape.rSm),
        child: child,
      ),
    );
  }
}

/// A branded [Tooltip]: a small [ColorScheme.inverseSurface] bubble with
/// [ColorScheme.onInverseSurface] text and the brand `rXs` radius, wrapping
/// [child]. Theme-only, RTL-safe.
class NeptuneTooltip extends StatelessWidget {
  /// The tooltip message.
  final String message;

  /// The widget the tooltip is attached to.
  final Widget child;

  const NeptuneTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;

    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: shape.rXs,
      ),
      textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: child,
    );
  }
}

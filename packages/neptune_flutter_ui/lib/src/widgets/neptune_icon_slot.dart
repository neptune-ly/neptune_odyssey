// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

/// Internal. Renders the icon of an Odyssey widget that accepts EITHER a
/// Material [IconData] glyph or a host-supplied [Widget] mark.
///
/// White-label consumers ship their own per-brand icon sets — each client bank
/// has designed its own marks — so an `IconData`-only API would force every
/// bank's chrome to look identical, the opposite of white-label. Every
/// icon-bearing widget therefore takes both and hands them to this slot.
///
/// * [iconWidget] `null` → exactly `Icon(icon, size: size, color: color)`, i.e.
///   unchanged behaviour for every existing call site.
/// * [iconWidget] non-null → the supplied widget replaces the glyph and is laid
///   out in the same square the glyph would have occupied ([size], else the
///   ambient [IconTheme] size). The tint the [Icon] would have received is
///   published to the subtree as an [IconTheme] **and** a [DefaultTextStyle],
///   so a nested [Icon]/[ImageIcon], a lettermark, or an SVG resolving
///   `currentColor` inherits the same active/inactive treatment for free.
///
/// The tint is deliberately NOT force-applied through a filter: a brand's
/// multi-colour mark must stay multi-colour. A host that wants its SVG to
/// follow the state should let the mark inherit `currentColor` — with
/// `flutter_svg` that is either `SvgTheme(currentColor: IconTheme.of(context).color!)`
/// on an asset whose paths use `fill="currentColor"`, or the equivalent
/// `colorFilter:` built from `IconTheme.of(context).color`.
class NeptuneIconSlot extends StatelessWidget {
  /// The Material glyph. Used only when [iconWidget] is null.
  final IconData? icon;

  /// The host-supplied mark. Replaces [icon] when non-null.
  final Widget? iconWidget;

  /// The tint the glyph gets, and the tint published to [iconWidget]'s subtree.
  final Color color;

  /// The glyph box. Null falls back to the ambient [IconTheme] size.
  final double? size;

  const NeptuneIconSlot({
    super.key,
    required this.color,
    this.icon,
    this.iconWidget,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final custom = iconWidget;
    if (custom == null) return Icon(icon, size: size, color: color);

    final box = size ?? IconTheme.of(context).size;
    return IconTheme.merge(
      data: IconThemeData(color: color, size: box),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: color),
        child: box == null ? custom : SizedBox.square(dimension: box, child: custom),
      ),
    );
  }
}

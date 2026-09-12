// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The labelled-value list: what a transaction detail, a bill summary or a
// payee's particulars are made of. One grouped surface, rows on hairlines,
// the label at the start edge and the value at the end - the anatomy every
// reference in the category shares (Lloyds, Chase, Revolut Business, N26)
// and the one a screen of `Container`s kept re-inventing with a different
// radius each time.

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';
import 'neptune_identity_surfaces.dart';
import 'neptune_numeral.dart';

/// One grouped surface of [NeptuneDetailItem]s (web `<npt-detail-list>`).
///
/// `surfaceContainerLow` on the brand `lg` corner, a hairline `outlineVariant`
/// between rows and no stroke around the group: the rows are what the eye
/// reads, the surface only says they belong together. An optional [title] is
/// drawn as a [NeptuneEyebrow] ABOVE the surface, not inside it, so a page of
/// several groups reads as sections rather than as titled boxes.
///
/// Children need not be [NeptuneDetailItem]s: a host row that carries its own
/// control (a category picker, a note editor) sits between them on the same
/// hairlines. Theme-only, RTL-safe.
class NeptuneDetailList extends StatelessWidget {
  /// The section marker drawn above the surface, if any.
  final String? title;

  /// The rows, top to bottom.
  final List<Widget> children;

  const NeptuneDetailList({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Divider(height: 1, thickness: 1, color: scheme.outlineVariant));
      }
      rows.add(children[i]);
    }

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: shape.rLg,
      ),
      child: ClipRRect(
        borderRadius: shape.rLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: rows,
        ),
      ),
    );

    if (title == null) return surface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 10),
          child: NeptuneEyebrow(title!),
        ),
        surface,
      ],
    );
  }
}

/// One label/value line inside a [NeptuneDetailList].
///
/// The [label] sits at the start edge in `bodyMedium`/`onSurfaceVariant`; the
/// [value] at the end edge in `bodyMedium` w600 `onSurface`, end-aligned, and
/// allowed to wrap onto a second line rather than ellipsize - an identifier
/// cut to "LY83 0020 ..." is worth nothing, and SomarSans-class fonts draw
/// the ellipsis as a box anyway. [numeric] pins the value's glyph order LTR
/// through [NeptuneNumeral] (account numbers, references, amounts in an
/// Arabic UI). [emphasis] promotes the value to the money face at
/// `titleMedium` for the one row that IS the figure. [trailing] is an
/// optional action at the end edge - a copy button, a chevron - kept to a
/// 40dp slot so the value column does not jump between rows. Theme-only,
/// RTL-safe. Min height 52.
class NeptuneDetailItem extends StatelessWidget {
  /// The name of the fact.
  final String label;

  /// The fact.
  final String value;

  /// Pin the value LTR regardless of locale.
  final bool numeric;

  /// Set the value in the money face at `titleMedium`.
  final bool emphasis;

  /// An optional end-edge action.
  final Widget? trailing;

  const NeptuneDetailItem({
    super.key,
    required this.label,
    required this.value,
    this.numeric = false,
    this.emphasis = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final valueStyle = emphasis
        ? NeptuneTheme.moneyStyle(context, base: text.titleMedium)
            .copyWith(color: scheme.onSurface)
        : text.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          );

    final valueText = numeric
        ? NeptuneNumeral(value, textAlign: TextAlign.end, style: valueStyle)
        : Text(value, textAlign: TextAlign.end, style: valueStyle);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          16,
          14,
          trailing == null ? 16 : 6,
          14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                label,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 3,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: valueText,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              SizedBox(width: 40, height: 40, child: Center(child: trailing)),
            ],
          ],
        ),
      ),
    );
  }
}

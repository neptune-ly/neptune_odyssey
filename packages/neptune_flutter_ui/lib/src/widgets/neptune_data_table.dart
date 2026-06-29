// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import '../theme/neptune_theme.dart';

/// One column header for a [NeptuneDataTable] (web `<npt-data-table>` column).
/// [numeric] right-aligns the column and renders its cells with tabular money
/// figures.
class NeptuneColumn {
  final String label;
  final bool numeric;

  const NeptuneColumn(this.label, {this.numeric = false});
}

/// A themed data grid (web `<npt-data-table>`): a rounded [surface] card with an
/// optional caption, a [surfaceContainer] heading row, zebra-striped body rows,
/// and right-aligned tabular-figure cells for numeric columns. Scrolls
/// horizontally on overflow. Theme-only, RTL-safe.
class NeptuneDataTable extends StatelessWidget {
  final String? caption;
  final List<NeptuneColumn> columns;
  final List<List<String>> rows;
  final bool dense;

  const NeptuneDataTable({
    super.key,
    this.caption,
    required this.columns,
    required this.rows,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = Theme.of(context).extension<NptShape>()!;
    final text = Theme.of(context).textTheme;
    final money = NeptuneTheme.moneyStyle(context, base: text.bodyMedium)
        .copyWith(color: scheme.onSurface);

    final headerStyle = text.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    final cellStyle = text.bodyMedium?.copyWith(color: scheme.onSurface);

    final table = DataTable(
      headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainer),
      headingRowHeight: dense ? 44 : 52,
      dataRowMinHeight: dense ? 40 : 48,
      dataRowMaxHeight: dense ? 44 : 56,
      dividerThickness: 1,
      border: TableBorder.symmetric(
        inside: BorderSide(color: scheme.outlineVariant),
      ),
      columns: [
        for (final column in columns)
          DataColumn(
            numeric: column.numeric,
            label: Text(column.label, style: headerStyle),
          ),
      ],
      rows: [
        for (var r = 0; r < rows.length; r++)
          DataRow(
            color: WidgetStatePropertyAll(
              r.isEven ? scheme.surfaceContainerLow : scheme.surface,
            ),
            cells: [
              for (var c = 0; c < columns.length; c++)
                DataCell(
                  Text(
                    c < rows[r].length ? rows[r][c] : '',
                    style: columns[c].numeric ? money : cellStyle,
                  ),
                ),
            ],
          ),
      ],
    );

    return Material(
      color: scheme.surface,
      borderRadius: shape.rMd,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (caption != null)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  caption!,
                  style: text.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          ),
        ],
      ),
    );
  }
}

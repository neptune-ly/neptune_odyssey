// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// A themed data grid. Web counterpart: `<npt-data-table>` · Flutter:
// NeptuneDataTable (neptune_data_table.dart). A rounded `surface` card with
// an optional caption, a `surfaceContainer` heading row, zebra-striped body
// rows, 1dp `outlineVariant` hairlines between rows and columns, and
// end-aligned tabular-figure cells for numeric columns. Scrolls horizontally
// inside its own container on overflow — it never overflows the layout.
// Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/**
 * One column header for a [NeptuneDataTable] (web `<npt-data-table>` column).
 * [numeric] end-aligns the column and renders its cells with tabular money
 * figures (the brand `num` face, numerals lever applied).
 */
@Immutable
public data class NeptuneColumn(
    public val label: String,
    public val numeric: Boolean = false,
)

// The Flutter DataTable geometry the Dart source renders with (M3 defaults it
// leaves unset): 24 edge margin, 56 column spacing (28 each side of a column
// boundary, so the vertical hairline sits centred in the gap).
private val EdgeMargin: Dp = 24.dp
private val HalfColumnSpacing: Dp = 28.dp

/**
 * A themed data grid (web `<npt-data-table>`): a rounded `surface` card with
 * an optional [caption], a `surfaceContainer` heading row, zebra-striped body
 * rows (even rows `surfaceContainerLow`, odd `surface`) and end-aligned
 * tabular-figure cells for [NeptuneColumn.numeric] columns. When the columns
 * outgrow the available width the grid scrolls horizontally inside the card;
 * when they underfill it, the spare width is shared between the columns so
 * the stripes always span the card.
 *
 * Web counterpart: `<npt-data-table>` · Flutter: `NeptuneDataTable`.
 *
 * [dense] tightens the heading row to 44dp and the body rows to 40–44dp
 * (52 / 48–56 comfortable). Missing trailing cells in a row render empty.
 */
@Composable
public fun NeptuneDataTable(
    columns: List<NeptuneColumn>,
    rows: List<List<String>>,
    modifier: Modifier = Modifier,
    caption: String? = null,
    dense: Boolean = false,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    val headingHeight = if (dense) 44.dp else 52.dp
    val rowMinHeight = if (dense) 40.dp else 48.dp
    val rowMaxHeight = if (dense) 44.dp else 56.dp

    val headerStyle = typography.labelMedium.copy(
        color = scheme.onSurfaceVariant,
        fontWeight = FontWeight.W600,
    )
    val cellStyle = typography.bodyMedium.copy(color = scheme.onSurface)
    val money = NeptuneTheme.moneyStyle(base = typography.bodyMedium).copy(color = scheme.onSurface)

    Column(
        modifier = modifier
            .clip(NeptuneTheme.shape.rMd)
            .background(scheme.surface),
    ) {
        if (caption != null) {
            Text(
                text = caption,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                style = typography.titleSmall.copy(
                    color = scheme.onSurface,
                    fontWeight = FontWeight.W600,
                ),
            )
        }
        if (columns.isEmpty()) return@Column
        BoxWithConstraints(Modifier.fillMaxWidth()) {
            val minTableWidth = if (constraints.hasBoundedWidth) maxWidth else 0.dp
            Box(Modifier.horizontalScroll(rememberScrollState())) {
                DataTableGrid(
                    columns = columns,
                    rows = rows,
                    headingHeight = headingHeight,
                    rowMinHeight = rowMinHeight,
                    rowMaxHeight = rowMaxHeight,
                    headerBackground = scheme.surfaceContainer,
                    zebraEven = scheme.surfaceContainerLow,
                    zebraOdd = scheme.surface,
                    hairline = scheme.outlineVariant,
                    headerStyle = headerStyle,
                    cellStyle = cellStyle,
                    moneyStyle = money,
                    modifier = Modifier.widthIn(min = minTableWidth),
                )
            }
        }
    }
}

/** The grid itself: shared per-column widths (max intrinsic cell width),
 * fixed heading height, body rows clamped to the min/max row heights, and
 * 1dp hairlines painted over every internal row/column boundary. Placed with
 * placeRelative so column order follows the reading direction. */
@Composable
private fun DataTableGrid(
    columns: List<NeptuneColumn>,
    rows: List<List<String>>,
    headingHeight: Dp,
    rowMinHeight: Dp,
    rowMaxHeight: Dp,
    headerBackground: Color,
    zebraEven: Color,
    zebraOdd: Color,
    hairline: Color,
    headerStyle: TextStyle,
    cellStyle: TextStyle,
    moneyStyle: TextStyle,
    modifier: Modifier = Modifier,
) {
    val colCount = columns.size
    val hLineCount = rows.size
    val vLineCount = colCount - 1

    Layout(
        modifier = modifier,
        content = {
            // 1. hairlines (row boundaries, then column boundaries) …
            repeat(hLineCount + vLineCount) {
                Box(Modifier.background(hairline))
            }
            // 2. heading cells …
            columns.forEachIndexed { c, column ->
                TableCell(
                    text = column.label,
                    style = headerStyle,
                    numeric = column.numeric,
                    background = headerBackground,
                    first = c == 0,
                    last = c == colCount - 1,
                )
            }
            // 3. body cells, row-major, zebra-striped (Flutter r.isEven).
            rows.forEachIndexed { r, row ->
                val zebra = if (r % 2 == 0) zebraEven else zebraOdd
                columns.forEachIndexed { c, column ->
                    val raw = row.getOrElse(c) { "" }
                    TableCell(
                        text = if (column.numeric) NeptuneTheme.formatDigits(raw) else raw,
                        style = if (column.numeric) moneyStyle else cellStyle,
                        numeric = column.numeric,
                        background = zebra,
                        first = c == 0,
                        last = c == colCount - 1,
                    )
                }
            }
        },
    ) { measurables, constraints ->
        val lineCount = hLineCount + vLineCount
        val cells = measurables.subList(lineCount, measurables.size)

        // Column widths: the widest cell of each column …
        val colWidths = IntArray(colCount)
        cells.forEachIndexed { index, cell ->
            val c = index % colCount
            val w = cell.maxIntrinsicWidth(Constraints.Infinity)
            if (w > colWidths[c]) colWidths[c] = w
        }
        // … stretched evenly when the grid underfills the viewport (the web
        // table's inline-size: 100%).
        var tableWidth = colWidths.sum()
        if (constraints.minWidth > tableWidth) {
            val extra = constraints.minWidth - tableWidth
            val per = extra / colCount
            val remainder = extra - per * colCount
            for (c in 0 until colCount) {
                colWidths[c] += per + if (c < remainder) 1 else 0
            }
            tableWidth = constraints.minWidth
        }

        // Row heights: heading fixed; body content clamped min..max.
        val headingPx = headingHeight.roundToPx()
        val minPx = rowMinHeight.roundToPx()
        val maxPx = rowMaxHeight.roundToPx()
        val rowHeights = IntArray(rows.size)
        for (r in rows.indices) {
            var h = 0
            for (c in 0 until colCount) {
                val cell = cells[colCount * (r + 1) + c]
                val ch = cell.minIntrinsicHeight(colWidths[c])
                if (ch > h) h = ch
            }
            rowHeights[r] = h.coerceIn(minPx, maxPx)
        }
        val tableHeight = headingPx + rowHeights.sum()

        val cellPlaceables = cells.mapIndexed { index, cell ->
            val c = index % colCount
            val r = index / colCount // 0 = heading row
            val h = if (r == 0) headingPx else rowHeights[r - 1]
            cell.measure(Constraints.fixed(colWidths[c], h))
        }

        val hairPx = 1.dp.roundToPx().coerceAtLeast(1)
        val hLines = (0 until hLineCount).map {
            measurables[it].measure(Constraints.fixed(tableWidth, hairPx))
        }
        val vLines = (0 until vLineCount).map {
            measurables[hLineCount + it].measure(Constraints.fixed(hairPx, tableHeight))
        }

        layout(tableWidth, tableHeight) {
            // Cells first …
            var y = 0
            for (r in 0..rows.size) {
                var x = 0
                for (c in 0 until colCount) {
                    cellPlaceables[r * colCount + c].placeRelative(x, y)
                    x += colWidths[c]
                }
                y += if (r == 0) headingPx else rowHeights[r - 1]
            }
            // … hairlines painted over the boundaries (the Flutter
            // TableBorder inside strokes + dividerThickness 1).
            var boundaryY = headingPx
            hLines.forEachIndexed { i, line ->
                line.placeRelative(0, boundaryY - hairPx)
                boundaryY += rowHeights[i]
            }
            var boundaryX = 0
            vLines.forEachIndexed { c, line ->
                boundaryX += colWidths[c]
                line.placeRelative(boundaryX - hairPx, 0)
            }
        }
    }
}

/** One grid cell: zebra/heading wash, DataTable edge/spacing padding, text
 * vertically centred and end-aligned when numeric. */
@Composable
private fun TableCell(
    text: String,
    style: TextStyle,
    numeric: Boolean,
    background: Color,
    first: Boolean,
    last: Boolean,
) {
    Box(
        modifier = Modifier
            .background(background)
            .padding(
                start = if (first) EdgeMargin else HalfColumnSpacing,
                end = if (last) EdgeMargin else HalfColumnSpacing,
            ),
        contentAlignment = if (numeric) Alignment.CenterEnd else Alignment.CenterStart,
    ) {
        Text(
            text = text,
            style = style,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

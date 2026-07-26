// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Corporate glyphs: the bulk-payment batch mark. There is no neptune_icons
// source for it yet (the Flutter widget leans on Material's built-in
// grid_view_rounded), so it is drawn in the house style — 24×24 grid, 1.8
// stroke, round caps, currentColor — like the other builder-drawn analogs.

package ly.neptune.odyssey.ui.glyphs

import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.PathBuilder

/** A rounded square outline: top-left at ([x], [y]), side [s], corner [r]. */
private fun PathBuilder.roundedSquare(x: Float, y: Float, s: Float, r: Float) {
    moveTo(x + r, y)
    horizontalLineTo(x + s - r)
    arcTo(r, r, 0f, isMoreThanHalf = false, isPositiveArc = true, x + s, y + r)
    verticalLineTo(y + s - r)
    arcTo(r, r, 0f, isMoreThanHalf = false, isPositiveArc = true, x + s - r, y + s)
    horizontalLineTo(x + r)
    arcTo(r, r, 0f, isMoreThanHalf = false, isPositiveArc = true, x, y + s - r)
    verticalLineTo(y + r)
    arcTo(r, r, 0f, isMoreThanHalf = false, isPositiveArc = true, x + r, y)
    close()
}

/** Corporate stroke glyphs (tinted via Icon's `tint` / currentColor). */
public object NptCorporateGlyphs {
    /** Four rounded tiles — the batch-card mark (the Flutter
     * `Icons.grid_view_rounded` analog, drawn in the neptune_icons style). */
    public val gridView: ImageVector by lazy {
        nptGlyph("npt.gridView") {
            roundedSquare(4f, 4f, 6.5f, 2f)
            roundedSquare(13.5f, 4f, 6.5f, 2f)
            roundedSquare(4f, 13.5f, 6.5f, 2f)
            roundedSquare(13.5f, 13.5f, 6.5f, 2f)
        }
    }
}

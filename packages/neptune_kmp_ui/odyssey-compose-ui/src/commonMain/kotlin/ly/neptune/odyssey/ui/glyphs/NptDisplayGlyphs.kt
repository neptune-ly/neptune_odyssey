// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Display glyphs used as built-in defaults by the display components
// (avatar fallback, rating stars). Path data ports 1:1 from
// packages/neptune_icons/src/icons.ts (`user`, `star`) — 24×24 grid,
// 1.8 stroke, round caps, currentColor. The filled star keeps the outline
// star's stroke so both footprints match when a rating swaps between them.

package ly.neptune.odyssey.ui.glyphs

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.PathBuilder
import androidx.compose.ui.graphics.vector.path
import androidx.compose.ui.unit.dp

/** neptune_icons `star`:
 * `M12 3.5l2.6 5.9 6.4.6-4.8 4.3 1.4 6.3L12 17.6l-5.6 3 1.4-6.3-4.8-4.3 6.4-.6L12 3.5Z`. */
private fun PathBuilder.starContour() {
    moveTo(12f, 3.5f)
    lineToRelative(2.6f, 5.9f)
    lineToRelative(6.4f, 0.6f)
    lineToRelative(-4.8f, 4.3f)
    lineToRelative(1.4f, 6.3f)
    lineTo(12f, 17.6f)
    lineToRelative(-5.6f, 3f)
    lineToRelative(1.4f, -6.3f)
    lineToRelative(-4.8f, -4.3f)
    lineToRelative(6.4f, -0.6f)
    lineTo(12f, 3.5f)
    close()
}

/** A 24×24 Odyssey glyph FILLED with the template colour while keeping the
 * family's 1.8 round stroke, so filled/outline pairs share one footprint. */
private fun nptFilledGlyph(
    name: String,
    pathData: PathBuilder.() -> Unit,
): ImageVector = ImageVector.Builder(
    name = name,
    defaultWidth = 24.dp,
    defaultHeight = 24.dp,
    viewportWidth = 24f,
    viewportHeight = 24f,
).apply {
    path(
        fill = SolidColor(Color.White),
        stroke = SolidColor(Color.White),
        strokeLineWidth = 1.8f,
        strokeLineCap = StrokeCap.Round,
        strokeLineJoin = StrokeJoin.Round,
        pathBuilder = pathData,
    )
}.build()

/** Built-in display stroke glyphs (tinted via Icon's `tint` / currentColor). */
public object NptDisplayGlyphs {
    /** Person silhouette — neptune_icons `user` (the avatar fallback,
     * the Flutter `Icons.person` analog). */
    public val user: ImageVector by lazy {
        nptGlyph("npt.user") {
            // circle cx=12 cy=8 r=3.5
            moveTo(8.5f, 8f)
            arcTo(3.5f, 3.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 15.5f, 8f)
            arcTo(3.5f, 3.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 8.5f, 8f)
            close()
            // M5.5 19.5 a6.5 6.5 0 0 1 13 0
            moveTo(5.5f, 19.5f)
            arcToRelative(6.5f, 6.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 13f, 0f)
        }
    }

    /** Outline rating star — neptune_icons `star`. */
    public val star: ImageVector by lazy {
        nptGlyph("npt.star") { starContour() }
    }

    /** Filled rating star — the same `star` contour, template-filled. */
    public val starFilled: ImageVector by lazy {
        nptFilledGlyph("npt.starFilled") { starContour() }
    }
}

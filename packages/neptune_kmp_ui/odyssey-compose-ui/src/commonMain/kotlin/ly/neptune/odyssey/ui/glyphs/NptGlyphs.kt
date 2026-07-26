// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The handful of built-in glyphs core components need (arrow, check, cross),
// drawn in the neptune_icons style: 24×24 grid, 1.8 stroke, round caps,
// currentColor. The full 94-icon set ports from packages/neptune_icons in a
// later milestone — components accept icon slots, so consumers are never
// limited to these.

package ly.neptune.odyssey.ui.glyphs

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.path
import androidx.compose.ui.unit.dp

/** Build a 24×24 Odyssey stroke glyph (1.8 stroke, round caps, tint-driven).
 * The stroke colour is a template — Icon()'s `tint` replaces it. */
public fun nptGlyph(
    name: String,
    autoMirror: Boolean = false,
    pathData: androidx.compose.ui.graphics.vector.PathBuilder.() -> Unit,
): ImageVector = ImageVector.Builder(
    name = name,
    defaultWidth = 24.dp,
    defaultHeight = 24.dp,
    viewportWidth = 24f,
    viewportHeight = 24f,
    autoMirror = autoMirror,
).apply {
    path(
        stroke = SolidColor(Color.White),
        strokeLineWidth = 1.8f,
        strokeLineCap = StrokeCap.Round,
        strokeLineJoin = StrokeJoin.Round,
        fill = null,
        pathBuilder = pathData,
    )
}.build()

/** Built-in stroke glyphs (tinted via Icon's `tint` / currentColor). */
public object NptGlyphs {
    /** Forward arrow — mirrors automatically under RTL. */
    public val arrowForward: ImageVector by lazy {
        nptGlyph("npt.arrowForward", autoMirror = true) {
            moveTo(4f, 12f)
            lineTo(20f, 12f)
            moveTo(13.5f, 5.5f)
            lineTo(20f, 12f)
            lineTo(13.5f, 18.5f)
        }
    }

    /** Success check. */
    public val check: ImageVector by lazy {
        nptGlyph("npt.check") {
            moveTo(5f, 12.5f)
            lineTo(10f, 17.5f)
            lineTo(19f, 6.5f)
        }
    }

    /** Rejection cross. */
    public val cross: ImageVector by lazy {
        nptGlyph("npt.cross") {
            moveTo(6.5f, 6.5f)
            lineTo(17.5f, 17.5f)
            moveTo(17.5f, 6.5f)
            lineTo(6.5f, 17.5f)
        }
    }
}

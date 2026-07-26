// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Card-management glyphs used by NeptuneCardControls (freeze / limits /
// details / pin), built through the shared nptGlyph() builder: 24×24 grid,
// 1.8 stroke, round caps, currentColor. `receipt` ports 1:1 from
// packages/neptune_icons/src/icons.ts; snowflake/tune/dialpad have no
// neptune_icons source yet (the Flutter widget leans on Material's
// ac_unit/tune/dialpad there) and are drawn in the same house style.

package ly.neptune.odyssey.ui.glyphs

import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.PathBuilder

/** A full circle outline centred on ([cx], [cy]) with radius [r]. */
private fun PathBuilder.circleAt(cx: Float, cy: Float, r: Float) {
    moveTo(cx - r, cy)
    arcTo(r, r, 0f, false, true, cx + r, cy)
    arcTo(r, r, 0f, false, true, cx - r, cy)
    close()
}

/** A solid dot of visual radius [r] — a stroked circle of path radius r-0.9
 * paints solid at the 1.8 stroke width (the NptStatusGlyphs recipe). */
private fun PathBuilder.dotAt(cx: Float, cy: Float, r: Float) {
    circleAt(cx, cy, r - 0.9f)
}

/** Card-control glyphs (tinted via Icon's `tint` / currentColor). */
public object NptCardControlGlyphs {
    /** Six-arm snowflake (the Flutter `Icons.ac_unit` analog on the Freeze
     * control): three crossing arms + chevron ticks on the vertical arm. */
    public val snowflake: ImageVector by lazy {
        nptGlyph("npt.snowflake") {
            // Vertical arm.
            moveTo(12f, 3.5f)
            verticalLineTo(20.5f)
            // The two 60°-rotated arms.
            moveTo(4.6f, 7.75f)
            lineTo(19.4f, 16.25f)
            moveTo(19.4f, 7.75f)
            lineTo(4.6f, 16.25f)
            // Chevron ticks on the vertical arm ends.
            moveTo(9.6f, 5.9f)
            lineTo(12f, 8.3f)
            lineTo(14.4f, 5.9f)
            moveTo(9.6f, 18.1f)
            lineTo(12f, 15.7f)
            lineTo(14.4f, 18.1f)
        }
    }

    /** Three staggered slider rails with knobs (the Flutter `Icons.tune`
     * analog on the Limits control). */
    public val tune: ImageVector by lazy {
        nptGlyph("npt.tune") {
            // Rail 1 — knob at x 15.5.
            moveTo(4f, 6.5f)
            horizontalLineTo(13f)
            circleAt(15.5f, 6.5f, 2f)
            moveTo(18f, 6.5f)
            horizontalLineTo(20f)
            // Rail 2 — knob at x 8.5.
            moveTo(4f, 12f)
            horizontalLineTo(6f)
            circleAt(8.5f, 12f, 2f)
            moveTo(11f, 12f)
            horizontalLineTo(20f)
            // Rail 3 — knob at x 13.5.
            moveTo(4f, 17.5f)
            horizontalLineTo(11f)
            circleAt(13.5f, 17.5f, 2f)
            moveTo(16f, 17.5f)
            horizontalLineTo(20f)
        }
    }

    /** Torn receipt — neptune_icons `receipt` (the Flutter
     * `Icons.receipt_long` analog on the Details control). */
    public val receipt: ImageVector by lazy {
        nptGlyph("npt.receipt") {
            // M6 3.5 h12 V20 a.8.8 0 0 1 -1.2 .7 L15 19.5 l-1.5 1.2
            // a1 1 0 0 1 -1.2 0 L10.8 19.5 9.3 20.7 a1 1 0 0 1 -1.2 0
            // L6.6 19.5 5.2 20.7 A.8.8 0 0 1 6 20 Z
            moveTo(6f, 3.5f)
            horizontalLineToRelative(12f)
            verticalLineTo(20f)
            arcToRelative(0.8f, 0.8f, 0f, isMoreThanHalf = false, isPositiveArc = true, -1.2f, 0.7f)
            lineTo(15f, 19.5f)
            lineToRelative(-1.5f, 1.2f)
            arcToRelative(1f, 1f, 0f, isMoreThanHalf = false, isPositiveArc = true, -1.2f, 0f)
            lineTo(10.8f, 19.5f)
            lineTo(9.3f, 20.7f)
            arcToRelative(1f, 1f, 0f, isMoreThanHalf = false, isPositiveArc = true, -1.2f, 0f)
            lineTo(6.6f, 19.5f)
            lineTo(5.2f, 20.7f)
            arcTo(0.8f, 0.8f, 0f, isMoreThanHalf = false, isPositiveArc = true, 6f, 20f)
            close()
            // M9 8 h6 · M9 11.5 h6 · M9 15 h3 (the line items)
            moveTo(9f, 8f)
            horizontalLineToRelative(6f)
            moveTo(9f, 11.5f)
            horizontalLineToRelative(6f)
            moveTo(9f, 15f)
            horizontalLineToRelative(3f)
        }
    }

    /** Keypad dot grid, 3×3 + one below centre (the Flutter `Icons.dialpad`
     * analog on the PIN control). */
    public val dialpad: ImageVector by lazy {
        nptGlyph("npt.dialpad") {
            dotAt(7f, 5.5f, 1.3f)
            dotAt(12f, 5.5f, 1.3f)
            dotAt(17f, 5.5f, 1.3f)
            dotAt(7f, 10f, 1.3f)
            dotAt(12f, 10f, 1.3f)
            dotAt(17f, 10f, 1.3f)
            dotAt(7f, 14.5f, 1.3f)
            dotAt(12f, 14.5f, 1.3f)
            dotAt(17f, 14.5f, 1.3f)
            dotAt(12f, 19f, 1.3f)
        }
    }
}

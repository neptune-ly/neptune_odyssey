// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Shell/feedback glyphs used as built-in defaults by the shell components
// (search field magnifier, state-switcher retry + empty inbox). `search` and
// `refresh` port 1:1 from packages/neptune_icons/src/icons.ts; `inbox` has no
// icons.ts source yet, so it is drawn in the same style (24×24 grid, 1.8
// stroke, round caps, currentColor) as the Flutter `Icons.inbox_outlined`
// analog used by NeptuneStateSwitcher's default empty face.

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

/** Built-in shell stroke glyphs (tinted via Icon's `tint` / currentColor). */
public object NptShellGlyphs {
    /** Magnifier — neptune_icons `search` (the search-field lead glyph). */
    public val search: ImageVector by lazy {
        nptGlyph("npt.search") {
            // circle cx=11 cy=11 r=6.5
            circleAt(11f, 11f, 6.5f)
            // M16 16 l3.5 3.5
            moveTo(16f, 16f)
            lineToRelative(3.5f, 3.5f)
        }
    }

    /** Circular refresh arrows — neptune_icons `refresh` (the retry default). */
    public val refresh: ImageVector by lazy {
        nptGlyph("npt.refresh") {
            // M4.5 12 a7.5 7.5 0 0 1 13.2 -4.8
            moveTo(4.5f, 12f)
            arcToRelative(7.5f, 7.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 13.2f, -4.8f)
            // M19.5 3.5 v4.5 H15
            moveTo(19.5f, 3.5f)
            verticalLineToRelative(4.5f)
            horizontalLineTo(15f)
            // M19.5 12 a7.5 7.5 0 0 1 -13.2 4.8
            moveTo(19.5f, 12f)
            arcToRelative(7.5f, 7.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, -13.2f, 4.8f)
            // M4.5 20.5 V16 H9
            moveTo(4.5f, 20.5f)
            verticalLineTo(16f)
            horizontalLineTo(9f)
        }
    }

    /** Empty inbox tray — the default empty-state glyph (the Flutter
     * `Icons.inbox_outlined` analog, drawn in the neptune_icons style). */
    public val inbox: ImageVector by lazy {
        nptGlyph("npt.inbox") {
            // Box: sloped shoulders down to a rounded base.
            moveTo(4f, 12.5f)
            lineTo(6.7f, 6f)
            horizontalLineTo(17.3f)
            lineTo(20f, 12.5f)
            verticalLineTo(17f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 17.5f, 19.5f)
            horizontalLineTo(6.5f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 4f, 17f)
            close()
            // Tray dip across the middle.
            moveTo(4f, 12.5f)
            horizontalLineTo(8.5f)
            lineTo(10f, 15f)
            horizontalLineTo(14f)
            lineTo(15.5f, 12.5f)
            horizontalLineTo(20f)
        }
    }
}

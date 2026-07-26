// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Fintech glyphs used as built-in defaults by the fintech/receipt components
// (FX change pill, receipt share action). Path data ports 1:1 from
// packages/neptune_icons/src/icons.ts (`trending-up`, `trending-down`,
// `share`) through the shared nptGlyph() builder: 24×24 grid, 1.8 stroke,
// round caps, currentColor.

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

/** Fintech stroke glyphs (tinted via Icon's `tint` / currentColor). Path
 * data: packages/neptune_icons/src/icons.ts. */
public object NptFintechGlyphs {
    /** Rising trend arrow — neptune_icons `trending-up` (the Flutter
     * `Icons.trending_up` analog). Chart direction — never mirrored. */
    public val trendingUp: ImageVector by lazy {
        nptGlyph("npt.trendingUp") {
            // M4 16 l5 -5 3 3 7 -7
            moveTo(4f, 16f)
            lineToRelative(5f, -5f)
            lineToRelative(3f, 3f)
            lineToRelative(7f, -7f)
            // M15 7 h4 v4
            moveTo(15f, 7f)
            horizontalLineToRelative(4f)
            verticalLineToRelative(4f)
        }
    }

    /** Falling trend arrow — neptune_icons `trending-down` (the Flutter
     * `Icons.trending_down` analog). Chart direction — never mirrored. */
    public val trendingDown: ImageVector by lazy {
        nptGlyph("npt.trendingDown") {
            // M4 8 l5 5 3 -3 7 7
            moveTo(4f, 8f)
            lineToRelative(5f, 5f)
            lineToRelative(3f, -3f)
            lineToRelative(7f, 7f)
            // M15 17 h4 v-4
            moveTo(15f, 17f)
            horizontalLineToRelative(4f)
            verticalLineToRelative(-4f)
        }
    }

    /** Share nodes — neptune_icons `share` (the receipt Share-action glyph,
     * the Flutter `Icons.ios_share` analog). */
    public val share: ImageVector by lazy {
        nptGlyph("npt.share") {
            circleAt(7f, 12f, 2.5f)
            circleAt(17f, 6f, 2.5f)
            circleAt(17f, 18f, 2.5f)
            // m9.2 10.8 l5.6 -3.4
            moveTo(9.2f, 10.8f)
            lineToRelative(5.6f, -3.4f)
            // m9.2 13.2 l5.6 3.4
            moveTo(9.2f, 13.2f)
            lineToRelative(5.6f, 3.4f)
        }
    }
}

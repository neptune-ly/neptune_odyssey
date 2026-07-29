// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Glyphs for the data-viz family (NeptuneTrend and friends): the vertical
// trend arrows — the Flutter `arrow_upward` / `arrow_downward` analogs used
// by neptune_data_viz.dart's NeptuneTrend chip. Same neptune_icons dialect as
// NptGlyphs.arrowForward (24×24 grid, 1.8 stroke, round caps), rotated a
// quarter turn. Vertical arrows do not mirror under RTL.

package ly.neptune.odyssey.ui.glyphs

import androidx.compose.ui.graphics.vector.ImageVector

/** Built-in stroke glyphs for the data-viz components. */
public object NptVizGlyphs {
    /** Upward trend arrow — the Flutter `arrow_upward` analog. */
    public val arrowUpward: ImageVector by lazy {
        nptGlyph("npt.arrowUpward") {
            moveTo(12f, 20f)
            lineTo(12f, 4f)
            moveTo(5.5f, 10.5f)
            lineTo(12f, 4f)
            lineTo(18.5f, 10.5f)
        }
    }

    /** Downward trend arrow — the Flutter `arrow_downward` analog. */
    public val arrowDownward: ImageVector by lazy {
        nptGlyph("npt.arrowDownward") {
            moveTo(12f, 4f)
            lineTo(12f, 20f)
            moveTo(5.5f, 13.5f)
            lineTo(12f, 20f)
            lineTo(18.5f, 13.5f)
        }
    }
}

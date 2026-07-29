// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Navigation glyphs used by the breadcrumb trail and the pagination arrows,
// ported 1:1 from packages/neptune_icons/src/icons.ts (`chevron-right`,
// `chevron-left`) through the shared nptGlyph() builder: 24×24 grid, 1.8
// stroke, round caps, currentColor. Both mirror automatically under RTL, so
// "forward" always points along the reading direction — the Flutter widgets'
// Directionality-based chevron swap.

package ly.neptune.odyssey.ui.glyphs

import androidx.compose.ui.graphics.vector.ImageVector

/** Navigation stroke glyphs (tinted via Icon's `tint` / currentColor). */
public object NptNavGlyphs {
    /** Forward chevron — neptune_icons `chevron-right`; mirrors under RTL. */
    public val chevronForward: ImageVector by lazy {
        nptGlyph("npt.chevronForward", autoMirror = true) {
            // M9.5 5.5 16 12l-6.5 6.5
            moveTo(9.5f, 5.5f)
            lineTo(16f, 12f)
            lineTo(9.5f, 18.5f)
        }
    }

    /** Backward chevron — neptune_icons `chevron-left`; mirrors under RTL. */
    public val chevronBack: ImageVector by lazy {
        nptGlyph("npt.chevronBack", autoMirror = true) {
            // M14.5 5.5 8 12l6.5 6.5
            moveTo(14.5f, 5.5f)
            lineTo(8f, 12f)
            lineTo(14.5f, 18.5f)
        }
    }
}

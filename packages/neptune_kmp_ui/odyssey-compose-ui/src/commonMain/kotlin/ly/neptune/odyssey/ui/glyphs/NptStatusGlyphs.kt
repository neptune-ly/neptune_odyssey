// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Status/alert glyphs used by NeptuneAlert's default tone icons, ported from
// packages/neptune_icons/src/icons.ts (info / success-check / warning / error)
// through the shared nptGlyph() builder: 24×24 grid, 1.8 stroke, round caps,
// currentColor. The tiny filled "i"/"!" dots in the source SVGs are rendered
// as stroked micro-circles — a stroked circle of path radius r-0.9 paints a
// solid dot of visual radius r at the 1.8 stroke width.

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

/** A solid dot of visual radius [r] (SVG `fill="currentColor"` micro-circle). */
private fun PathBuilder.dotAt(cx: Float, cy: Float, r: Float) {
    circleAt(cx, cy, r - 0.9f)
}

/** Status glyphs (tinted via Icon's `tint` / currentColor). Path data:
 * packages/neptune_icons/src/icons.ts, "Status & alerts" section. */
public object NptStatusGlyphs {
    /** Information circle (`info`). */
    public val info: ImageVector by lazy {
        nptGlyph("npt.info") {
            circleAt(12f, 12f, 8.5f)
            moveTo(12f, 11f)
            lineTo(12f, 16f)
            dotAt(12f, 8f, 1.1f)
        }
    }

    /** Success check in a circle (`success-check`). */
    public val successCheck: ImageVector by lazy {
        nptGlyph("npt.successCheck") {
            circleAt(12f, 12f, 8.5f)
            moveTo(8.5f, 12f)
            lineToRelative(2.3f, 2.3f)
            lineToRelative(4.7f, -4.6f)
        }
    }

    /** Warning triangle (`warning`). */
    public val warning: ImageVector by lazy {
        nptGlyph("npt.warning") {
            moveTo(12f, 4.5f)
            lineTo(21f, 19.5f)
            lineTo(3f, 19.5f)
            close()
            moveTo(12f, 10f)
            lineTo(12f, 14f)
            dotAt(12f, 17f, 1f)
        }
    }

    /** Error exclamation in a circle (`error`). */
    public val error: ImageVector by lazy {
        nptGlyph("npt.error") {
            circleAt(12f, 12f, 8.5f)
            moveTo(12f, 8f)
            lineTo(12f, 13f)
            dotAt(12f, 16f, 1f)
        }
    }
}

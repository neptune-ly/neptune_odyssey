// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The few extra stroke glyphs the screen templates need as slot defaults
// (bell, camera, security shield, users). Geometry is ported 1:1 from the
// canonical icon set (packages/neptune_icons/src/icons.ts) in the house
// style: 24×24 grid, 1.8 stroke, round caps, tint-driven. Internal — the
// public icon library ships in a later milestone; every consumer-facing
// slot still accepts any composable icon.

package ly.neptune.odyssey.ui.templates

import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.PathBuilder
import ly.neptune.odyssey.ui.glyphs.nptGlyph

/** A full circle outline centred on ([cx], [cy]) with radius [r]. */
private fun PathBuilder.circleAt(cx: Float, cy: Float, r: Float) {
    moveTo(cx - r, cy)
    arcTo(r, r, 0f, false, true, cx + r, cy)
    arcTo(r, r, 0f, false, true, cx - r, cy)
    close()
}

/** Template-default glyphs (tinted via Icon's `tint` / currentColor). */
internal object NptTemplateGlyphs {
    /** Notification bell (`bell` in neptune_icons). */
    val bell: ImageVector by lazy {
        nptGlyph("npt.bell") {
            moveTo(6f, 16.5f)
            verticalLineTo(11f)
            arcToRelative(6f, 6f, 0f, false, true, 12f, 0f)
            verticalLineToRelative(5.5f)
            lineToRelative(1.5f, 2f)
            horizontalLineTo(4.5f)
            close()
            moveTo(10f, 18.5f)
            arcToRelative(2f, 2f, 0f, false, false, 4f, 0f)
        }
    }

    /** Capture camera (`camera` in neptune_icons). */
    val camera: ImageVector by lazy {
        nptGlyph("npt.camera") {
            moveTo(4f, 8.5f)
            arcTo(1.5f, 1.5f, 0f, false, true, 5.5f, 7f)
            horizontalLineToRelative(2f)
            lineToRelative(1f, -2f)
            horizontalLineToRelative(7f)
            lineToRelative(1f, 2f)
            horizontalLineToRelative(2f)
            arcTo(1.5f, 1.5f, 0f, false, true, 20f, 8.5f)
            verticalLineTo(18f)
            arcToRelative(1.5f, 1.5f, 0f, false, true, -1.5f, 1.5f)
            horizontalLineToRelative(-13f)
            arcTo(1.5f, 1.5f, 0f, false, true, 4f, 18f)
            close()
            circleAt(12f, 13f, 3.2f)
        }
    }

    /** Verified shield with check (`security-shield` in neptune_icons). */
    val securityShield: ImageVector by lazy {
        nptGlyph("npt.securityShield") {
            moveTo(12f, 3.5f)
            lineTo(19f, 6f)
            verticalLineToRelative(5.5f)
            curveToRelative(0f, 4.5f, -3f, 7.5f, -7f, 9f)
            curveToRelative(-4f, -1.5f, -7f, -4.5f, -7f, -9f)
            verticalLineTo(6f)
            close()
            moveTo(9f, 12f)
            lineToRelative(2f, 2f)
            lineToRelative(4f, -4f)
        }
    }

    /** People group (`users` in neptune_icons). */
    val users: ImageVector by lazy {
        nptGlyph("npt.users") {
            circleAt(9f, 8f, 3f)
            moveTo(3.5f, 19f)
            arcToRelative(5.5f, 5.5f, 0f, false, true, 11f, 0f)
            moveTo(16f, 5.2f)
            arcToRelative(3f, 3f, 0f, false, true, 0f, 5.6f)
            moveTo(17f, 14.2f)
            arcToRelative(5.5f, 5.5f, 0f, false, true, 3.5f, 4.8f)
        }
    }
}

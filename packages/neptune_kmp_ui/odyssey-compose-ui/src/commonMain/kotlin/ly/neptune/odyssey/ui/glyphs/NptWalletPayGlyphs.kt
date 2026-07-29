// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Wallet & pay glyphs used as built-in defaults by the wallet-pay surfaces
// (the NeptuneQrPay placeholder mark, the NeptuneTopupRow icon tile and
// trailing chevron). Path data ports 1:1 from packages/neptune_icons/src/
// icons.ts (`qr-code`, `card-add`, `chevron-right`) through the shared
// nptGlyph() builder: 24×24 grid, 1.8 stroke, round caps, currentColor.

package ly.neptune.odyssey.ui.glyphs

import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.PathBuilder

/** A rounded-rect outline (SVG `<rect x y width height rx>`). */
private fun PathBuilder.roundedRectAt(x: Float, y: Float, w: Float, h: Float, r: Float) {
    moveTo(x + r, y)
    horizontalLineTo(x + w - r)
    arcTo(r, r, 0f, isMoreThanHalf = false, isPositiveArc = true, x + w, y + r)
    verticalLineTo(y + h - r)
    arcTo(r, r, 0f, isMoreThanHalf = false, isPositiveArc = true, x + w - r, y + h)
    horizontalLineTo(x + r)
    arcTo(r, r, 0f, isMoreThanHalf = false, isPositiveArc = true, x, y + h - r)
    verticalLineTo(y + r)
    arcTo(r, r, 0f, isMoreThanHalf = false, isPositiveArc = true, x + r, y)
    close()
}

/** Wallet & pay glyphs (tinted via Icon's `tint` / currentColor). Path data:
 * packages/neptune_icons/src/icons.ts. */
public object NptWalletPayGlyphs {
    /** QR mark — neptune_icons `qr-code`: three finder squares + data
     * modules. The NeptuneQrPay placeholder (the Flutter `Icons.qr_code_2`
     * analog). */
    public val qrCode: ImageVector by lazy {
        nptGlyph("npt.qrCode") {
            // rect x=4 y=4 w=6 h=6 rx=1.2 · x=14 y=4 · x=4 y=14
            roundedRectAt(4f, 4f, 6f, 6f, 1.2f)
            roundedRectAt(14f, 4f, 6f, 6f, 1.2f)
            roundedRectAt(4f, 14f, 6f, 6f, 1.2f)
            // M14 14 h2 v2
            moveTo(14f, 14f)
            horizontalLineToRelative(2f)
            verticalLineToRelative(2f)
            // M20 14 v2
            moveTo(20f, 14f)
            verticalLineToRelative(2f)
            // M14 20 h6
            moveTo(14f, 20f)
            horizontalLineToRelative(6f)
            // M20 18 v2
            moveTo(20f, 18f)
            verticalLineToRelative(2f)
        }
    }

    /** Card with a plus — neptune_icons `card-add` (the top-up row's default
     * icon tile, the Flutter `Icons.add_card` analog). */
    public val cardAdd: ImageVector by lazy {
        nptGlyph("npt.cardAdd") {
            // M21 11 V7.5 A2.5 2.5 0 0 0 18.5 5 h-13 A2.5 2.5 0 0 0 3 7.5
            // V16 a2.5 2.5 0 0 0 2.5 2.5 H12
            moveTo(21f, 11f)
            verticalLineTo(7.5f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = false, 18.5f, 5f)
            horizontalLineToRelative(-13f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = false, 3f, 7.5f)
            verticalLineTo(16f)
            arcToRelative(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = false, 2.5f, 2.5f)
            horizontalLineTo(12f)
            // M3 9.5 h18 (the card's magstripe rule)
            moveTo(3f, 9.5f)
            horizontalLineToRelative(18f)
            // M18 15 v6 · M15 18 h6 (the plus)
            moveTo(18f, 15f)
            verticalLineToRelative(6f)
            moveTo(15f, 18f)
            horizontalLineToRelative(6f)
        }
    }

    /** Inline-end chevron — neptune_icons `chevron-right`; mirrors under RTL
     * (the Flutter `Icons.chevron_right` + textDirection recipe, the web
     * `:dir(rtl)` scaleX(-1) flip). */
    public val chevronEnd: ImageVector by lazy {
        nptGlyph("npt.chevronEnd", autoMirror = true) {
            // M9.5 5.5 16 12 l-6.5 6.5
            moveTo(9.5f, 5.5f)
            lineTo(16f, 12f)
            lineToRelative(-6.5f, 6.5f)
        }
    }
}

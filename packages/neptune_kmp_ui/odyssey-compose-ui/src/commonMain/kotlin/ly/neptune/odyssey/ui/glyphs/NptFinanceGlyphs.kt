// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Finance glyphs used as built-in defaults by the financial components
// (transaction rows, account tiles). Path data ports 1:1 from
// packages/neptune_icons/src/icons.ts (`wallet`, `swap-exchange`) — 24×24
// grid, 1.8 stroke, round caps, currentColor.

package ly.neptune.odyssey.ui.glyphs

import androidx.compose.ui.graphics.vector.ImageVector

/** Built-in finance stroke glyphs (tinted via Icon's `tint` / currentColor). */
public object NptFinanceGlyphs {
    /** Wallet — neptune_icons `wallet` (account/balance affordances). */
    public val wallet: ImageVector by lazy {
        nptGlyph("npt.wallet") {
            // M4 7.5 A2.5 2.5 0 0 1 6.5 5 H17 a1 1 0 0 1 1 1 v1.5
            moveTo(4f, 7.5f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 6.5f, 5f)
            horizontalLineTo(17f)
            arcToRelative(1f, 1f, 0f, isMoreThanHalf = false, isPositiveArc = true, 1f, 1f)
            verticalLineToRelative(1.5f)
            // rect x=4 y=7.5 width=16 height=12 rx=2.5
            moveTo(6.5f, 7.5f)
            horizontalLineTo(17.5f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 20f, 10f)
            verticalLineTo(17f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 17.5f, 19.5f)
            horizontalLineTo(6.5f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 4f, 17f)
            verticalLineTo(10f)
            arcTo(2.5f, 2.5f, 0f, isMoreThanHalf = false, isPositiveArc = true, 6.5f, 7.5f)
            close()
            // M16 13 h2
            moveTo(16f, 13f)
            horizontalLineToRelative(2f)
            // M20 11.5 h-3 a1.5 1.5 0 0 0 0 3 h3
            moveTo(20f, 11.5f)
            horizontalLineToRelative(-3f)
            arcToRelative(1.5f, 1.5f, 0f, isMoreThanHalf = false, isPositiveArc = false, 0f, 3f)
            horizontalLineToRelative(3f)
        }
    }

    /** Two-way transfer arrows — neptune_icons `swap-exchange`
     * (the transaction-row default, the Flutter `Icons.swap_horiz` analog). */
    public val swapExchange: ImageVector by lazy {
        nptGlyph("npt.swapExchange") {
            // M6 8 h11 l-3.5 -3.5
            moveTo(6f, 8f)
            horizontalLineToRelative(11f)
            lineToRelative(-3.5f, -3.5f)
            // M6 8 V6
            moveTo(6f, 8f)
            verticalLineTo(6f)
            // M18 16 H7 l3.5 3.5
            moveTo(18f, 16f)
            horizontalLineTo(7f)
            lineToRelative(3.5f, 3.5f)
            // M18 16 v2
            moveTo(18f, 16f)
            verticalLineToRelative(2f)
        }
    }
}

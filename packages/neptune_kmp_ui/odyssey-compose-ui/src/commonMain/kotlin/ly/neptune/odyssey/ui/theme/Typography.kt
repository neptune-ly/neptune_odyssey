// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Brand M3 Typography — the Compose analog of neptune_theme.dart's
// _buildTextTheme. Display/headline styles ride the brand display face at the
// brand display weight with the brand tracking; title/body/label ride the
// text face (titles/labels at w600). Sizes/line-heights mirror the Flutter
// text theme exactly.

package ly.neptune.odyssey.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp

internal fun neptuneTypography(
    type: NptType,
    displayFamily: FontFamily?,
    textFamily: FontFamily?,
    odyssey3: Boolean = false,
    arabic: Boolean = false,
    numericFamily: FontFamily? = textFamily,
): Typography {
    val w = type.displayFontWeight

    fun disp(size: Int, lineHeight: Int? = null, tracked: Boolean = false): TextStyle = TextStyle(
        fontFamily = displayFamily,
        fontWeight = w,
        fontSize = size.sp,
        lineHeight = lineHeight?.sp ?: TextUnit.Unspecified,
        letterSpacing = if (odyssey3) 0.sp else if (tracked) (type.displayTracking * size).sp else TextUnit.Unspecified,
    )

    fun body(size: Int, weight: FontWeight = FontWeight.W400): TextStyle = TextStyle(
        fontFamily = textFamily,
        fontWeight = weight,
        fontSize = size.sp,
    )

    if (odyssey3) {
        val bodyLarge = if (arabic) 20 else 16
        val bodyMedium = if (arabic) 18 else 14
        val bodySmall = if (arabic) 16 else 12
        val bodyLargeLine = if (arabic) 28 else 24
        val bodyMediumLine = if (arabic) 24 else 20
        val bodySmallLine = if (arabic) 22 else 16
        fun o3Body(size: Int, line: Int, weight: FontWeight = FontWeight.W400): TextStyle =
            body(size, weight).copy(lineHeight = line.sp, letterSpacing = 0.sp)

        return Typography(
            displayLarge = disp(40, 48),
            displayMedium = disp(40, 48),
            displaySmall = o3Body(36, 44, FontWeight.W600).copy(fontFamily = numericFamily),
            headlineLarge = disp(32, 40),
            headlineMedium = disp(32, 40),
            headlineSmall = disp(24, 32),
            titleLarge = o3Body(24, 32, FontWeight.W700),
            titleMedium = o3Body(20, 28, FontWeight.W600),
            titleSmall = o3Body(20, 28, FontWeight.W600),
            bodyLarge = o3Body(bodyLarge, bodyLargeLine),
            bodyMedium = o3Body(bodyMedium, bodyMediumLine),
            bodySmall = o3Body(bodySmall, bodySmallLine),
            labelLarge = o3Body(bodyMedium, bodyMediumLine, FontWeight.W600),
            labelMedium = o3Body(bodyMedium, bodyMediumLine, FontWeight.W600),
            labelSmall = o3Body(bodySmall, bodySmallLine, FontWeight.W600),
        )
    }

    return Typography(
        displayLarge = disp(57, lineHeight = 64, tracked = true),
        displayMedium = disp(45, lineHeight = 52, tracked = true),
        displaySmall = disp(36, lineHeight = 44),
        headlineLarge = disp(32),
        headlineMedium = disp(28),
        headlineSmall = disp(24),
        titleLarge = body(22, FontWeight.W600),
        titleMedium = body(18, FontWeight.W600),
        titleSmall = body(14, FontWeight.W600),
        bodyLarge = body(16),
        bodyMedium = body(14),
        bodySmall = body(12),
        labelLarge = body(14, FontWeight.W600),
        labelMedium = body(12, FontWeight.W600),
        labelSmall = body(11, FontWeight.W600),
    )
}

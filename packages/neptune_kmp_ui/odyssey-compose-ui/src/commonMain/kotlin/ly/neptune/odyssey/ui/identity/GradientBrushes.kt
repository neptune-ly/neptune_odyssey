// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The 135° brand gradient (web `linear-gradient(135deg, primary, tertiary)`)
// — heroes and card art ride this. Compose brushes are not layout-direction
// aware, so the start/end corners are computed explicitly: top-start →
// bottom-end, mirroring under RTL exactly like Flutter's
// AlignmentDirectional pair.

package ly.neptune.odyssey.ui.identity

import androidx.compose.material3.ColorScheme
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.LayoutDirection

/**
 * The hero gradient brush for a surface of [size]: [start]→[end] from the
 * top-start corner to the bottom-end corner (RTL-mirrored via [direction]).
 */
public fun nptHeroGradient(
    start: Color,
    end: Color,
    size: Size,
    direction: LayoutDirection,
): Brush {
    val ltr = direction == LayoutDirection.Ltr
    return Brush.linearGradient(
        colors = listOf(start, end),
        start = Offset(if (ltr) 0f else size.width, 0f),
        end = Offset(if (ltr) size.width else 0f, size.height),
    )
}

/** The standard hero recipe: primary → tertiary (web hero/balance-card). */
public fun nptHeroGradient(
    scheme: ColorScheme,
    size: Size,
    direction: LayoutDirection,
): Brush = nptHeroGradient(scheme.primary, scheme.tertiary, size, direction)

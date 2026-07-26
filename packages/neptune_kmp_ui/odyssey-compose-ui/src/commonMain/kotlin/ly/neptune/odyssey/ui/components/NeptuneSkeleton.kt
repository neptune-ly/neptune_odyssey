// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The loading placeholder bone. Web counterpart: `<npt-skeleton>`
// (feedback-status.ts) · Flutter: `NeptuneSkeleton` + `NeptuneShimmer`. A
// rounded surface-container-highest block with the gentle brand shimmer — a
// soft on-surface highlight sweeping the reading direction on a 1.6s cycle.
// Under reduced motion the sweep is dropped and only the static base tone
// renders. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/**
 * A shimmering loading bone. Web counterpart: `<npt-skeleton>` · Flutter:
 * `NeptuneSkeleton` (wrapped in `NeptuneShimmer`).
 *
 * [width] null stretches to the available width. Set [circle] for an
 * avatar-style dot ([height] becomes the diameter). The shimmer is a
 * 6%→14%→6% on-surface highlight sweeping across every 1.6s along the reading
 * direction; under reduced motion the bone renders as the static base tone.
 */
@Composable
public fun NeptuneSkeleton(
    modifier: Modifier = Modifier,
    width: Dp? = null,
    height: Dp = 16.dp,
    circle: Boolean = false,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val reduced = NeptuneTheme.reducedMotion

    val sizing = if (circle) {
        Modifier.size(height)
    } else {
        (width?.let { Modifier.width(it) } ?: Modifier.fillMaxWidth()).height(height)
    }

    // 1.6s sweep; -1.3 → +1.3 of the bone width, RTL-mirrored (the Flutter
    // NeptuneShimmer slide).
    val transition = rememberInfiniteTransition(label = "skeleton")
    val sweepT by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(1600, easing = LinearEasing), RepeatMode.Restart),
        label = "shimmer",
    )

    Box(
        modifier
            .then(sizing)
            .clip(if (circle) shape.rFull else shape.rSm)
            .background(scheme.surfaceContainerHighest)
            .drawBehind {
                if (reduced) return@drawBehind
                val rtl = layoutDirection == LayoutDirection.Rtl
                val t = (sweepT * 2.6f - 1.3f) * (if (rtl) -1f else 1f)
                val tx = t * size.width
                val soft = scheme.onSurface.copy(alpha = 0.06f)
                val bright = scheme.onSurface.copy(alpha = 0.14f)
                drawRect(
                    brush = Brush.linearGradient(
                        0.35f to soft,
                        0.5f to bright,
                        0.65f to soft,
                        start = Offset(tx, 0f),
                        end = Offset(tx + size.width, 0f),
                    ),
                )
            },
    )
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The premium animated call-to-action. Web counterpart: `<npt-cta>` ·
// Flutter: `NeptuneCta`. A display-font pill riding the primary key-light,
// with a slow SPECULAR SHEEN sweeping across (brand-scaled 4.8s cycle,
// on-colour tinted, hold-sweep-hold 62%→82%), a gently NUDGING arrow (4dp,
// brand-scaled 2.4s) and a 0.98 press-scale on the brand's emphasized curve.
// All motion pauses under reduced-motion. RTL-safe (the arrow mirrors and the
// sheen sweeps the reading direction).

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.glyphs.NptGlyphs
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import ly.neptune.odyssey.ui.theme.NptShadow
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin

// Web keyframes: hold at -130% until 62%, sweep to +130% by 82%, hold.
private val sheenEase = CubicBezierEasing(0.42f, 0f, 0.58f, 1f) // ease-in-out
private fun sheenX(t: Float): Float = when {
    t < 0.62f -> -1.3f
    t > 0.82f -> 1.3f
    else -> -1.3f + 2.6f * sheenEase.transform((t - 0.62f) / 0.20f)
}

/**
 * [tonal] renders the secondary tone (no glow — web `variant="tonal"`).
 * [arrow] appends the nudging forward arrow (mirrors under RTL).
 */
@Composable
public fun NeptuneCta(
    label: String,
    onClick: (() -> Unit)?,
    modifier: Modifier = Modifier,
    icon: (@Composable () -> Unit)? = null,
    arrow: Boolean = false,
    expand: Boolean = true,
    tonal: Boolean = false,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape.rXxl
    val type = NeptuneTheme.type
    val motion = NeptuneTheme.motion
    val identity = NeptuneTheme.identity
    val density = NeptuneTheme.density
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val reduced = NeptuneTheme.reducedMotion
    val rtl = LocalLayoutDirection.current == LayoutDirection.Rtl
    val enabled = onClick != null

    val bg = if (tonal) scheme.secondaryContainer else scheme.primary
    val fg = if (tonal) scheme.onSecondaryContainer else scheme.onPrimary

    // R6 signature motion: cycle lengths are brand-driven; Neptune's baseline
    // (slow=500, standard=300) reproduces the web's 4800ms/2400ms exactly.
    val sheenMs = motion.slowMs * 96 / 10
    val nudgeMs = motion.standardMs * 8
    val transition = rememberInfiniteTransition(label = "cta")
    val sheenT by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(sheenMs, easing = LinearEasing), RepeatMode.Restart),
        label = "sheen",
    )
    val nudgeT by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(nudgeMs, easing = LinearEasing), RepeatMode.Restart),
        label = "nudge",
    )

    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (pressed && enabled) 0.98f else 1f,
        animationSpec = tween(220, easing = motion.emphasized),
        label = "press",
    )

    val display = rememberNeptuneFontFamily(type.display)
    val labelStyle = MaterialTheme.typography.titleMedium.copy(
        fontFamily = display,
        fontWeight = FontWeight.W700,
        letterSpacing = (type.displayTracking * 16).sp,
        color = fg,
    )

    // The primary key-light glow (web `--npt-glow-primary`).
    val glow = if (tonal || !enabled) {
        Modifier
    } else {
        Modifier.nptShadow(
            identity.elevation3(scheme) + NptShadow(
                color = scheme.primary.copy(alpha = 0.24f),
                blurRadius = 22.dp,
                offsetY = 10.dp,
                spread = (-8).dp,
            ),
            shape,
        )
    }

    Box(
        modifier = modifier
            .then(if (expand) Modifier.fillMaxWidth() else Modifier)
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .then(glow)
            .clip(shape)
            .background(if (enabled) bg else bg.copy(alpha = 0.5f))
            .clickable(
                interactionSource = interaction,
                indication = null,
                enabled = enabled,
            ) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onClick?.invoke()
            }
            .defaultMinSize(minHeight = density.s(54.dp)),
        contentAlignment = Alignment.Center,
    ) {
        // Specular sheen — an on-colour tinted highlight sweeping across on
        // the brand cycle (web `.sheen`, 110° tilt = 20° off the sweep axis).
        if (!reduced) {
            Box(
                Modifier
                    .matchParentSize()
                    .graphicsLayer { translationX = sheenX(sheenT) * size.width * (if (rtl) -1 else 1) }
                    .drawBehind {
                        val angle = 0.349f
                        val dir = Offset(cos(angle), sin(angle))
                        val center = Offset(size.width / 2, size.height / 2)
                        val half = dir * (size.width / 2)
                        drawRect(
                            Brush.linearGradient(
                                0.32f to fg.copy(alpha = 0f),
                                0.5f to fg.copy(alpha = 0.38f),
                                0.68f to fg.copy(alpha = 0f),
                                start = center - half,
                                end = center + half,
                            ),
                        )
                    },
            )
        }
        Row(
            modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (icon != null) {
                icon()
                Spacer(Modifier.width(8.dp))
            }
            Text(
                label,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = labelStyle,
                modifier = Modifier.weight(1f, fill = false),
            )
            if (arrow) {
                Spacer(Modifier.width(8.dp))
                // 0 → 4dp → 0 along the reading direction (web `nudge`).
                val dx = if (reduced) 0f else 4f * sin(PI.toFloat() * nudgeT) * (if (rtl) -1 else 1)
                Icon(
                    NptGlyphs.arrowForward,
                    contentDescription = null,
                    tint = fg,
                    modifier = Modifier
                        .offset { IntOffset(dx.dp.roundToPx(), 0) }
                        .size(20.dp),
                )
            }
        }
    }
}

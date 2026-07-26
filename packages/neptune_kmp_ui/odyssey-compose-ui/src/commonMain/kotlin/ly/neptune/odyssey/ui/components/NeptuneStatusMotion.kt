// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The Odyssey outcome motion — a loading indicator for in-flight work that
// hands off smoothly to an animated SUCCESS check or an animated REJECTED
// cross. One composable, three linked states: drive it with a
// [NeptuneFlowStatus] and the transitions (spin-out → spring-in, stroke-drawn
// glyphs, rejection shake) run on the brand's motion curves. Web counterpart:
// `<npt-status-motion state="loading|success|rejected">` · Flutter:
// neptune_status_motion.dart. Honours reduced-motion by rendering the final
// frame statically. Theme-only, RTL-safe.
//
// R6: the loading phase is no longer hourglass-only — [loaderStyle] picks any
// of the standalone loaders in NeptuneLoaders.kt, all sharing the same
// hand-off choreography into the outcome disc.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.EnterExitState
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathMeasure
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptShadow
import kotlin.math.PI
import kotlin.math.min
import kotlin.math.sin

// Flutter's easeOutCubic, ported numerically: cubic (0.215, 0.61, 0.355, 1).
private val easeOutCubic: CubicBezierEasing = CubicBezierEasing(0.215f, 0.61f, 0.355f, 1f)

/**
 * The three linked states of [NeptuneStatusMotion].
 *
 * Web counterpart: `<npt-status-motion state=…>` · Flutter:
 * `NeptuneFlowStatus`.
 */
public enum class NeptuneFlowStatus { Loading, Success, Rejected }

/**
 * Animated loader → check / cross outcome indicator.
 *
 * While [status] is [NeptuneFlowStatus.Loading], [loaderStyle] (hourglass by
 * default) animates on a gentle loop. Flip the status to `Success` and it
 * spins away while a tinted disc springs in and DRAWS the check stroke
 * ([color] defaults to the brand `success` role — pass any colour);
 * `Rejected` draws the cross in the `error` role with a decaying shake.
 * The hand-off is a scale × quarter-turn × fade on the brand's `spring`
 * curve in / `standard` curve out. Under reduced motion the target state
 * renders statically at its final frame.
 *
 * Web counterpart: `<npt-status-motion>` · Flutter: `NeptuneStatusMotion`.
 */
@Composable
public fun NeptuneStatusMotion(
    status: NeptuneFlowStatus,
    modifier: Modifier = Modifier,
    size: Dp = 96.dp,
    color: Color? = null,
    loaderStyle: NeptuneLoaderStyle = NeptuneLoaderStyle.Hourglass,
) {
    val motion = NeptuneTheme.motion
    val reduced = NeptuneTheme.reducedMotion

    if (reduced) {
        // No hand-off choreography — the target's final frame, statically
        // (each loader freezes itself; the disc jumps to completed t = 1).
        Box(modifier, contentAlignment = Alignment.Center) {
            StatusFrame(status, size, color, loaderStyle)
        }
        return
    }

    AnimatedContent(
        targetState = status,
        modifier = modifier,
        transitionSpec = {
            // Flutter AnimatedSwitcher: duration standard, switch-in on the
            // brand spring curve, switch-out on the brand standard curve,
            // scale × fade (the quarter turn rides the child below).
            val inSpec = tween<Float>(motion.standardMs, easing = motion.spring)
            val outSpec = tween<Float>(motion.standardMs, easing = motion.standard)
            (fadeIn(inSpec) + scaleIn(inSpec, initialScale = 0f))
                .togetherWith(fadeOut(outSpec) + scaleOut(outSpec, targetScale = 0f))
        },
        contentAlignment = Alignment.Center,
        label = "statusMotion",
    ) { target ->
        // A quarter-turn hand-off links the loader to the outcome disc:
        // incoming unwinds 90° → 0 on the spring curve, outgoing winds back
        // up on the standard curve (Flutter turns 0.25 → 0).
        val turns = transition.animateFloat(
            transitionSpec = {
                if (targetState == EnterExitState.Visible) {
                    tween(motion.standardMs, easing = motion.spring)
                } else {
                    tween(motion.standardMs, easing = motion.standard)
                }
            },
            label = "quarterTurn",
        ) { state -> if (state == EnterExitState.Visible) 0f else 90f }
        Box(Modifier.graphicsLayer { rotationZ = turns.value }) {
            StatusFrame(target, size, color, loaderStyle)
        }
    }
}

/** One frame of the status hand-off: the loader or an outcome disc. */
@Composable
private fun StatusFrame(
    status: NeptuneFlowStatus,
    size: Dp,
    color: Color?,
    loaderStyle: NeptuneLoaderStyle,
) {
    when (status) {
        NeptuneFlowStatus.Loading -> neptuneLoaderFor(loaderStyle, size = size)
        NeptuneFlowStatus.Success -> OutcomeDisc(success = true, size = size, tint = color)
        NeptuneFlowStatus.Rejected -> OutcomeDisc(success = false, size = size, tint = color)
    }
}

/**
 * The tinted outcome disc: springs in over 700ms while the check/cross is
 * STROKE-DRAWN progressively on easeOutCubic; rejection carries a decaying
 * horizontal shake. Reduced motion jumps straight to the completed frame.
 */
@Composable
private fun OutcomeDisc(
    success: Boolean,
    size: Dp,
    tint: Color?,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val reduced = NeptuneTheme.reducedMotion
    val shape = NeptuneTheme.shape.rFull

    val fill = tint ?: if (success) npt.success else scheme.error
    val glyph = if (success) npt.onSuccess else scheme.onError

    val progress = remember(reduced) { Animatable(if (reduced) 1f else 0f) }
    if (!reduced) {
        LaunchedEffect(progress) {
            progress.animateTo(1f, tween(700, easing = LinearEasing))
        }
    }

    Canvas(
        modifier
            .graphicsLayer {
                // Rejection carries a decaying shake while the cross draws:
                // sin(t·5π) · (1 − t) · 5% of the disc diameter.
                if (!success) {
                    val t = progress.value
                    translationX = sin(t * 5f * PI.toFloat()) * (1f - t) * this.size.width * 0.05f
                }
            }
            // The disc's soft self-coloured halo (Flutter BoxShadow:
            // fill @ 35%, blur 25% of size, offset-y 8% of size).
            .nptShadow(
                listOf(
                    NptShadow(
                        color = fill.copy(alpha = 0.35f),
                        blurRadius = size * 0.25f,
                        offsetY = size * 0.08f,
                    ),
                ),
                shape,
            )
            .size(size),
    ) {
        val w = this.size.width
        drawCircle(fill, radius = this.size.minDimension / 2f)

        // Stroke-draw the glyph from 0 → progress along its contours
        // (the Flutter _GlyphPainter metrics walk).
        val draw = easeOutCubic.transform(progress.value)
        val contours: List<Path> = if (success) {
            listOf(
                Path().apply {
                    moveTo(w * 0.30f, w * 0.52f)
                    lineTo(w * 0.45f, w * 0.66f)
                    lineTo(w * 0.71f, w * 0.36f)
                },
            )
        } else {
            listOf(
                Path().apply {
                    moveTo(w * 0.35f, w * 0.35f)
                    lineTo(w * 0.65f, w * 0.65f)
                },
                Path().apply {
                    moveTo(w * 0.65f, w * 0.35f)
                    lineTo(w * 0.35f, w * 0.65f)
                },
            )
        }
        val style = Stroke(width = w * 0.09f, cap = StrokeCap.Round, join = StrokeJoin.Round)
        val measures = contours.map { path -> PathMeasure().also { it.setPath(path, false) } }
        val total = measures.fold(0f) { acc, m -> acc + m.length }
        var budget = total * draw
        for (m in measures) {
            if (budget <= 0f) break
            val len = min(budget, m.length)
            val segment = Path()
            if (m.getSegment(0f, len, segment, startWithMoveTo = true)) {
                drawPath(segment, glyph, style = style)
            }
            budget -= len
        }
    }
}

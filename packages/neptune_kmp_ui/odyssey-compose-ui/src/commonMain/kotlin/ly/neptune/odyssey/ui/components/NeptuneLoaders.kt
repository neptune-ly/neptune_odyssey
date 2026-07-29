// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// R6: the standalone loading-indicator family — the draining/flipping
// hourglass, a branded ring spinner, a three-dot waiter and a breathing
// pulse. Web counterpart: the idle phase of `<npt-status-motion
// state="loading">` (feedback-status) · Flutter: neptune_loaders.dart.
// All four share [NeptuneLoaderStyle] so [NeptuneStatusMotion] can drive any
// of them into the same success/reject morph — one continuous animation,
// four different "waiting" feelings. Theme-only (colour from the scheme,
// timing from NptMotion), honours reduced-motion by freezing each loader on
// its representative static frame.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import kotlin.math.PI
import kotlin.math.cos

// The Flutter curve constants, ported numerically (flutter/animation curves.dart):
// easeInOutCubic (0.645, 0.045, 0.355, 1) · easeOut (0, 0, 0.58, 1) ·
// easeIn (0.42, 0, 1, 1) · easeInOut (0.42, 0, 0.58, 1).
private val easeInOutCubic: CubicBezierEasing = CubicBezierEasing(0.645f, 0.045f, 0.355f, 1f)
private val easeOut: CubicBezierEasing = CubicBezierEasing(0f, 0f, 0.58f, 1f)
private val easeIn: CubicBezierEasing = CubicBezierEasing(0.42f, 0f, 1f, 1f)
private val easeInOut: CubicBezierEasing = CubicBezierEasing(0.42f, 0f, 0.58f, 1f)

/**
 * Which waiting indicator a loader-family composable renders. Shared by the
 * standalone loaders and by [NeptuneStatusMotion]'s loading phase.
 *
 * Web counterpart: `<npt-status-motion>` loading treatments · Flutter:
 * `NeptuneLoaderStyle` (neptune_loaders.dart).
 */
public enum class NeptuneLoaderStyle { Hourglass, Spinner, Dots, Pulse }

/**
 * Render the loader for [style] at [size]. Used internally by
 * [NeptuneStatusMotion]'s loading phase and available standalone so both
 * paths render pixel-identically.
 *
 * Web counterpart: `<npt-status-motion state="loading">` · Flutter:
 * `neptuneLoaderFor` (neptune_loaders.dart).
 */
@Composable
public fun neptuneLoaderFor(
    style: NeptuneLoaderStyle,
    size: Dp,
    modifier: Modifier = Modifier,
) {
    when (style) {
        NeptuneLoaderStyle.Hourglass -> NeptuneHourglassLoader(modifier = modifier, size = size)
        NeptuneLoaderStyle.Spinner -> NeptuneSpinner(modifier = modifier, size = size)
        NeptuneLoaderStyle.Dots -> NeptuneDotsLoader(modifier = modifier, size = size)
        NeptuneLoaderStyle.Pulse -> NeptunePulseLoader(modifier = modifier, size = size)
    }
}

/** The 0→1 loop clock all loaders run on: a linear infinite cycle of
 * [durationMs], or a frozen [frozenAt] frame under reduced motion. Returned
 * as [State] so consumers can defer the read to the draw phase. */
@Composable
private fun loaderClock(
    reduced: Boolean,
    frozenAt: Float,
    durationMs: Int,
    repeatMode: RepeatMode,
    label: String,
): State<Float> = if (reduced) {
    remember(frozenAt) { mutableFloatStateOf(frozenAt) }
} else {
    rememberInfiniteTransition(label = label).animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(durationMs, easing = LinearEasing), repeatMode),
        label = "$label.cycle",
    )
}

/**
 * The draining/flipping hourglass on a tinted disc — any in-progress moment
 * that isn't part of a success/reject hand-off. Disc `surface-container-high`,
 * frame `on-surface-variant`, sand `primary`; 1900ms cycle (sand drains over
 * the first 72%, then the glass flips half a turn on easeInOutCubic).
 * Reduced motion freezes mid-drain at t = 0.35.
 *
 * Web counterpart: `<npt-status-motion state="loading">`'s idle phase ·
 * Flutter: `NeptuneHourglassLoader`.
 */
@Composable
public fun NeptuneHourglassLoader(
    modifier: Modifier = Modifier,
    size: Dp = 96.dp,
) {
    val scheme = MaterialTheme.colorScheme
    val reduced = NeptuneTheme.reducedMotion
    val clock = loaderClock(reduced, frozenAt = 0.35f, durationMs = 1900, RepeatMode.Restart, "hourglass")
    val disc = scheme.surfaceContainerHigh
    val frame = scheme.onSurfaceVariant
    val sand = scheme.primary

    Canvas(modifier.size(size)) {
        val w = this.size.width
        drawCircle(disc, radius = this.size.minDimension / 2f)

        // 0 → .72: sand drains. .72 → 1: the glass flips half a turn.
        val t = clock.value
        val drain = (t / 0.72f).coerceIn(0f, 1f)
        val flipT = ((t - 0.72f) / 0.28f).coerceIn(0f, 1f)
        rotate(degrees = easeInOutCubic.transform(flipT) * 180f) {
            // All geometry is relative to size (the Flutter _HourglassPainter).
            val cx = w / 2f
            val gw = w * 0.34f
            val gh = w * 0.44f
            val top = (w - gh) / 2f
            val bottom = top + gh
            val waist = top + gh / 2f
            val left = cx - gw / 2f
            val right = cx + gw / 2f

            val glass = Path().apply {
                moveTo(left, top)
                lineTo(right, top)
                lineTo(cx + gw * 0.06f, waist)
                lineTo(right, bottom)
                lineTo(left, bottom)
                lineTo(cx - gw * 0.06f, waist)
                close()
            }
            drawPath(
                glass,
                frame,
                style = Stroke(width = w * 0.035f, cap = StrokeCap.Round, join = StrokeJoin.Round),
            )

            // Upper bulb: a shrinking inverted triangle of sand.
            val topLevel = top + (waist - top) * drain
            if (drain < 1f) {
                val hw = (gw / 2f) * (1f - drain) * 0.92f
                val topSand = Path().apply {
                    moveTo(cx - hw, topLevel)
                    lineTo(cx + hw, topLevel)
                    lineTo(cx, waist)
                    close()
                }
                drawPath(topSand, sand)
            }

            // The falling stream through the waist.
            if (drain > 0.02f && drain < 1f) {
                drawLine(
                    sand,
                    Offset(cx, waist),
                    Offset(cx, bottom - w * 0.03f),
                    strokeWidth = w * 0.02f,
                    cap = StrokeCap.Round,
                )
            }

            // Lower bulb: the growing pile.
            val pileH = (gh / 2f) * 0.8f * drain
            if (pileH > 0.5.dp.toPx()) {
                val hw = (gw / 2f) * 0.92f * drain
                val base = bottom - w * 0.015f
                val pile = Path().apply {
                    moveTo(cx - hw, base)
                    lineTo(cx + hw, base)
                    lineTo(cx, base - pileH)
                    close()
                }
                drawPath(pile, sand)
            }
        }
    }
}

/**
 * A branded ring spinner: a partial arc (not a full circle — reads as
 * "spinning", not "static ring") sweeping while its own length breathes,
 * on a brand-scaled cycle of `slow × 2` so its personality matches the rest
 * of the brand's motion, not a generic Material spinner feel. Track
 * `surface-container-highest`, arc `primary` (or [color]). Reduced motion
 * freezes the arc at its start-of-cycle frame (t = 0).
 *
 * Web counterpart: the `<npt-status-motion>` spinner treatment · Flutter:
 * `NeptuneSpinner`.
 */
@Composable
public fun NeptuneSpinner(
    modifier: Modifier = Modifier,
    size: Dp = 40.dp,
    color: Color? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val motion = NeptuneTheme.motion
    val reduced = NeptuneTheme.reducedMotion
    val clock = loaderClock(reduced, frozenAt = 0f, durationMs = motion.slowMs * 2, RepeatMode.Restart, "spinner")
    val track = scheme.surfaceContainerHighest
    val arc = color ?: scheme.primary

    Canvas(modifier.size(size)) {
        val w = this.size.width
        val stroke = w * 0.09f
        val topLeft = Offset(stroke / 2f, stroke / 2f)
        val arcSize = Size(w - stroke, w - stroke)
        drawArc(
            track,
            startAngle = 0f,
            sweepAngle = 360f,
            useCenter = false,
            topLeft = topLeft,
            size = arcSize,
            style = Stroke(stroke),
        )

        // Arc sweeps around while its own length breathes — classic "spinner",
        // not a spinning static gap.
        val t = clock.value
        val sweep = 0.18f + 0.55f * (0.5f - 0.5f * cos(t * 2f * PI.toFloat()))
        drawArc(
            arc,
            startAngle = t * 360f,
            sweepAngle = sweep * 360f,
            useCenter = false,
            topLeft = topLeft,
            size = arcSize,
            style = Stroke(stroke, cap = StrokeCap.Round),
        )
    }
}

/**
 * Three dots waiting in sequence — the classic "typing/loading" indicator in
 * the brand's `primary` (or [color]) on a 1200ms cycle, each dot lagging the
 * last by 0.18 of the cycle. RTL-safe: the sequence starts from the reading
 * side. Reduced motion freezes at the start-of-cycle frame (t = 0).
 *
 * Web counterpart: the `<npt-status-motion>` dots treatment · Flutter:
 * `NeptuneDotsLoader`.
 */
@Composable
public fun NeptuneDotsLoader(
    modifier: Modifier = Modifier,
    size: Dp = 40.dp,
    color: Color? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val reduced = NeptuneTheme.reducedMotion
    val clock = loaderClock(reduced, frozenAt = 0f, durationMs = 1200, RepeatMode.Restart, "dots")
    val dotColor = color ?: scheme.primary

    Canvas(modifier.size(size)) {
        val w = this.size.width
        val d = w * 0.22f
        // The Flutter Row(spaceEvenly): equal free space before/between/after.
        val gap = (w - 3f * d) / 4f
        val rtl = layoutDirection == LayoutDirection.Rtl
        val t = clock.value
        for (i in 0 until 3) {
            // Each dot lags the last by a third of the cycle.
            val phase = (t - i * 0.18f).mod(1f)
            val bounce = if (phase < 0.5f) {
                easeOut.transform(phase * 2f)
            } else {
                easeIn.transform(1f - (phase - 0.5f) * 2f)
            }
            val slot = if (rtl) 2 - i else i
            val cx = gap * (slot + 1) + d * slot + d / 2f
            val cy = this.size.height / 2f - bounce * w * 0.32f
            drawCircle(
                dotColor.copy(alpha = 0.55f + 0.45f * bounce),
                radius = d / 2f,
                center = Offset(cx, cy),
            )
        }
    }
}

/**
 * A single breathing disc — the softest, most ambient "still working" cue
 * (a good fit for a splash screen or a quiet background sync indicator).
 * A radial `primary` (or [color]) falloff scaling 0.82→1 and fading
 * 0.55→1 on a brand-scaled `slow × 3` reverse-repeating cycle. Reduced
 * motion freezes mid-breath at t = 0.5.
 *
 * Web counterpart: the `<npt-status-motion>` pulse treatment · Flutter:
 * `NeptunePulseLoader`.
 */
@Composable
public fun NeptunePulseLoader(
    modifier: Modifier = Modifier,
    size: Dp = 56.dp,
    color: Color? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val motion = NeptuneTheme.motion
    val reduced = NeptuneTheme.reducedMotion
    val clock = loaderClock(reduced, frozenAt = 0.5f, durationMs = motion.slowMs * 3, RepeatMode.Reverse, "pulse")
    val pulse = color ?: scheme.primary
    val brush = remember(pulse) {
        Brush.radialGradient(listOf(pulse, pulse.copy(alpha = 0f)))
    }

    Canvas(
        modifier
            .size(size)
            .graphicsLayer {
                val t = easeInOut.transform(clock.value)
                val s = 0.82f + 0.18f * t
                scaleX = s
                scaleY = s
                alpha = 0.55f + 0.45f * t
            },
    ) {
        drawCircle(brush)
    }
}

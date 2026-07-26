// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The Welcome / Sign-in template (templates.html §welcome): an ambient,
// gently-looping backdrop (a radial brand wash + three blurred drifting orbs
// in primary / tertiary / secondary), the brand lockup, a bold mixed-weight
// promise, and the animated CTA pair. Web counterpart: `.wel` + `welOrb1..3`
// · Flutter: neptune_welcome.dart. Everything re-skins with the brand and
// pauses under reduced-motion. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily
import kotlin.math.PI
import kotlin.math.cos

/** The master-clock length: each orb derives its own period from one 57s
 * cycle (LCM-ish of 15/19/17 keeps the loop seamless enough). */
private const val MASTER_CLOCK_SECONDS: Float = 57f

/** 0→1→0 ease-in-out sine phase for a loop of [seconds] within the 57s
 * master clock (the web `welOrb…` `ease-in-out infinite` keyframes). */
private fun orbPhase(clock: Float, seconds: Float): Float {
    val t = (clock * MASTER_CLOCK_SECONDS / seconds).mod(1f)
    return 0.5f - 0.5f * cos(2f * PI.toFloat() * t)
}

/**
 * The ambient welcome backdrop: `radial-gradient(135% 95% at 50% -5%,
 * primary 26% → surface 68%)` with three soft orbs (primary / tertiary /
 * secondary) drifting on independent 15 / 19 / 17-second ease-in-out loops
 * driven by one 57-second master clock. Static (t = 0 frame) under
 * reduced-motion.
 *
 * Web counterpart: `.wel__bg` + `.wel__orb--1..3` / `welOrb1..3`
 * (templates.html §welcome) · Flutter: `NeptuneAmbientBackdrop`.
 */
@Composable
public fun NeptuneAmbientBackdrop(modifier: Modifier = Modifier) {
    val scheme = MaterialTheme.colorScheme
    val reduced = NeptuneTheme.reducedMotion
    val wash = lerp(scheme.surface, scheme.primary, 0.26f)

    // One long master clock; each orb derives its own period from it.
    val clock: State<Float> = if (reduced) {
        remember { mutableFloatStateOf(0f) }
    } else {
        rememberInfiniteTransition(label = "ambient").animateFloat(
            initialValue = 0f,
            targetValue = 1f,
            animationSpec = infiniteRepeatable(
                tween((MASTER_CLOCK_SECONDS * 1000).toInt(), easing = LinearEasing),
                RepeatMode.Restart,
            ),
            label = "clock",
        )
    }

    Box(
        modifier
            .fillMaxSize()
            .drawBehind {
                drawRect(
                    Brush.radialGradient(
                        0f to wash,
                        0.68f to scheme.surface,
                        // Alignment(0, -1.05) → centre-x, 5% above the top edge;
                        // radius 1.35 × the shortest side (the Flutter gradient).
                        center = Offset(size.width / 2f, size.height / 2f * (1f - 1.05f)),
                        radius = 1.35f * size.minDimension,
                    ),
                )
            },
    ) {
        AmbientOrb(
            color = scheme.primary,
            diameter = 220.dp,
            alignment = Alignment.TopStart,
            clock = clock,
            seconds = 15f,
            offsetX = { p -> -36f + 28f * p },
            offsetY = { p -> -44f + 38f * p },
            scaleAmp = 0.16f,
        )
        AmbientOrb(
            color = scheme.tertiary,
            diameter = 184.dp,
            alignment = Alignment.TopEnd,
            clock = clock,
            seconds = 19f,
            // end inset −46 → −8 expressed as a layout-direction offset.
            offsetX = { p -> 46f - 38f * p },
            offsetY = { p -> 150f + 26f * p },
            scaleAmp = 0.10f,
        )
        AmbientOrb(
            color = scheme.secondary,
            diameter = 160.dp,
            alignment = Alignment.BottomStart,
            clock = clock,
            seconds = 17f,
            offsetX = { p -> 24f + 26f * p },
            offsetY = { p -> -(90f + 30f * p) },
            scaleAmp = 0.22f,
        )
    }
}

/** One drifting orb: a soft radial falloff (42% → 22% → 0 at stops
 * 0/0.45/1) that reads like the web's blur(44px) orb without the cost of a
 * live blur filter. [offsetX]/[offsetY] map the orb's phase to dp offsets
 * along the reading direction. */
@Composable
private fun BoxScope.AmbientOrb(
    color: Color,
    diameter: Dp,
    alignment: Alignment,
    clock: State<Float>,
    seconds: Float,
    offsetX: (Float) -> Float,
    offsetY: (Float) -> Float,
    scaleAmp: Float,
) {
    val brush = remember(color) {
        Brush.radialGradient(
            0f to color.copy(alpha = 0.42f),
            0.45f to color.copy(alpha = 0.22f),
            1f to color.copy(alpha = 0f),
        )
    }
    Box(
        Modifier
            .align(alignment)
            .offset {
                val p = orbPhase(clock.value, seconds)
                IntOffset(offsetX(p).dp.roundToPx(), offsetY(p).dp.roundToPx())
            }
            .size(diameter)
            .graphicsLayer {
                val s = 1f + scaleAmp * orbPhase(clock.value, seconds)
                scaleX = s
                scaleY = s
            }
            .drawBehind { drawCircle(brush) },
    )
}

/**
 * The brand lockup: a rounded `primary` mark carrying the brand [initial] in
 * the display face with a tertiary accent dot, next to the brand [name] at
 * display-w800. For a real client logo, pass a custom `lockup` slot to
 * [NeptuneWelcome] instead.
 *
 * Web counterpart: `.wel__brand` / `.wel__mark` / `.wel__dot` / `.wel__name`
 * (templates.html §welcome) · Flutter: `NeptuneBrandLockup`.
 */
@Composable
public fun NeptuneBrandLockup(
    initial: String,
    name: String,
    modifier: Modifier = Modifier,
    dotColor: Color? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val type = NeptuneTheme.type
    val display = rememberNeptuneFontFamily(type.display)

    val nameStyle = MaterialTheme.typography.titleLarge.copy(
        fontFamily = display,
        fontWeight = FontWeight.W800,
        fontSize = 20.sp,
        letterSpacing = (-0.2).sp,
        color = scheme.onSurface,
    )

    Row(modifier, verticalAlignment = Alignment.CenterVertically) {
        Box(
            Modifier
                .size(34.dp)
                .clip(shape.rXs)
                .background(scheme.primary),
        ) {
            Text(
                initial,
                style = nameStyle.copy(color = scheme.onPrimary, lineHeight = 20.sp),
                modifier = Modifier.align(Alignment.Center),
            )
            // The tertiary accent dot, 6dp in from the top-end corner.
            Box(
                Modifier
                    .align(Alignment.TopEnd)
                    .offset(x = (-6).dp, y = 6.dp)
                    .size(6.dp)
                    .clip(shape.rFull)
                    .background(dotColor ?: scheme.tertiary),
            )
        }
        Spacer(Modifier.width(11.dp))
        Text(name, style = nameStyle)
    }
}

/**
 * The full Welcome / Sign-in screen: ambient backdrop + lockup + a
 * mixed-weight promise ([title] at display-w500 with [emphasis] at w800 in
 * `primary`) + supporting line + the CTA pair slot ([primaryAction] is
 * typically a `NeptuneCta(arrow = true)`, [secondaryAction] a tonal one).
 * [lockup] replaces the default [NeptuneBrandLockup] with a custom mark —
 * e.g. a real client logo; when set, [brandInitial]/[brandName] are ignored.
 *
 * Web counterpart: templates.html §welcome (`.wel`) · Flutter:
 * `NeptuneWelcome`.
 */
@Composable
public fun NeptuneWelcome(
    brandInitial: String,
    brandName: String,
    title: String,
    emphasis: String,
    primaryAction: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    lockup: (@Composable () -> Unit)? = null,
    supporting: String? = null,
    secondaryAction: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val type = NeptuneTheme.type
    val display = rememberNeptuneFontFamily(type.display)

    val base = MaterialTheme.typography.headlineMedium
    val titleStyle = base.copy(
        fontFamily = display,
        fontWeight = FontWeight.W500,
        lineHeight = base.fontSize * 1.08,
        letterSpacing = (type.displayTracking * 32).sp,
        color = scheme.onSurface,
    )

    Box(modifier.fillMaxSize()) {
        NeptuneAmbientBackdrop(Modifier.matchParentSize())
        Column(
            Modifier
                .fillMaxSize()
                .windowInsetsPadding(WindowInsets.safeDrawing)
                .padding(start = 26.dp, top = 64.dp, end = 26.dp, bottom = 30.dp),
        ) {
            if (lockup != null) {
                lockup()
            } else {
                NeptuneBrandLockup(initial = brandInitial, name = brandName)
            }
            Spacer(Modifier.weight(1f))
            Text(
                buildAnnotatedString {
                    append(title)
                    append('\n')
                    withStyle(SpanStyle(fontWeight = FontWeight.W800, color = scheme.primary)) {
                        append(emphasis)
                    }
                },
                style = titleStyle,
            )
            if (supporting != null) {
                Spacer(Modifier.height(12.dp))
                val body = MaterialTheme.typography.bodyMedium
                Text(
                    supporting,
                    style = body.copy(
                        color = scheme.onSurfaceVariant,
                        lineHeight = body.fontSize * 1.5,
                    ),
                    modifier = Modifier.widthIn(max = 320.dp),
                )
            }
            Spacer(Modifier.height(22.dp))
            primaryAction()
            if (secondaryAction != null) {
                Spacer(Modifier.height(10.dp))
                secondaryAction()
            }
        }
    }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Small display primitives — avatar (+ overlap group), progress bar/ring,
// rating stars and the step timeline. Web counterparts: `<npt-avatar>`
// (layout.ts) and `<npt-progress>` (feedback.ts) · Flutter:
// neptune_display.dart (NeptuneAvatar / NeptuneAvatarGroup /
// NeptuneProgressBar / NeptuneProgressRing / NeptuneRating /
// NeptuneTimeline). NeptuneBadge / NeptuneTag / NeptuneListTile already live
// in NeptuneBadgeTag.kt / NeptuneListTile.kt. Theme-only, RTL-safe; the
// indeterminate progress sweep honours reduced-motion by parking statically.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.clipRect
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.glyphs.NptDisplayGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import kotlin.math.roundToInt

// --- avatar ----------------------------------------------------------------------

/**
 * A circular avatar. Renders, in priority order: an [image] slot (provide a
 * cropped `Image` filling the circle), otherwise [initials] on a
 * `primaryContainer` fill, otherwise an [icon] slot — falling back to the
 * neutral person glyph. Text/icon scale with [size] (initials at 0.4×, icon
 * at 0.55× — the Flutter recipe).
 *
 * Web counterpart: `<npt-avatar>` · Flutter: `NeptuneAvatar`.
 */
@Composable
public fun NeptuneAvatar(
    modifier: Modifier = Modifier,
    initials: String? = null,
    image: (@Composable () -> Unit)? = null,
    icon: (@Composable () -> Unit)? = null,
    size: Dp = 40.dp,
    background: Color? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val bg = background ?: scheme.primaryContainer
    val fg = scheme.onPrimaryContainer

    Box(
        modifier = modifier
            .size(size)
            .clip(NeptuneTheme.shape.rFull)
            .then(if (image == null) Modifier.background(bg) else Modifier),
        contentAlignment = Alignment.Center,
    ) {
        when {
            image != null -> Box(Modifier.fillMaxSize()) { image() }
            !initials.isNullOrBlank() -> Text(
                text = initials.trim().uppercase(),
                maxLines = 1,
                style = typography.labelLarge.copy(
                    color = fg,
                    fontSize = (size.value * 0.4f).sp,
                    lineHeight = (size.value * 0.4f).sp,
                ),
            )
            else -> CompositionLocalProvider(LocalContentColor provides fg) {
                Box(Modifier.size(size * 0.55f), contentAlignment = Alignment.Center) {
                    if (icon != null) {
                        icon()
                    } else {
                        Icon(
                            NptDisplayGlyphs.user,
                            contentDescription = null,
                            modifier = Modifier.fillMaxSize(),
                        )
                    }
                }
            }
        }
    }
}

/** One avatar in a [NeptuneAvatarGroup] — the [NeptuneAvatar] content
 * parameters, rendered by the group at the group's cell size. */
@Immutable
public class NeptuneAvatarGroupItem(
    public val initials: String? = null,
    public val image: (@Composable () -> Unit)? = null,
    public val icon: (@Composable () -> Unit)? = null,
    public val background: Color? = null,
)

/**
 * A row of overlapping avatars, each ringed in `surface` so it reads cleanly
 * against the stack; later entries overlap the earlier ones. Renders at most
 * [max] avatars; any surplus collapses into a trailing `+N` count cell on
 * `secondaryContainer`. Ring width scales with [size] (0.06× + 1.5).
 *
 * Flutter: `NeptuneAvatarGroup` (no web counterpart — groups compose
 * `<npt-avatar>`s).
 */
@Composable
public fun NeptuneAvatarGroup(
    avatars: List<NeptuneAvatarGroupItem>,
    modifier: Modifier = Modifier,
    max: Int = 4,
    size: Dp = 36.dp,
    overlap: Dp = 12.dp,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rFull
    val shown = minOf(avatars.size, max)
    val extra = avatars.size - shown
    val ring = (size.value * 0.06f + 1.5f).dp

    // A surface-ringed circular cell wrapping any content (the ring insets
    // the content, matching the Flutter Border-as-padding behaviour).
    val cell: @Composable (content: @Composable () -> Unit) -> Unit = { content ->
        Box(
            Modifier
                .size(size)
                .clip(shape)
                .background(scheme.surface)
                .padding(ring),
        ) {
            Box(Modifier.fillMaxSize().clip(shape), contentAlignment = Alignment.Center) {
                content()
            }
        }
    }

    Row(modifier = modifier, horizontalArrangement = Arrangement.spacedBy(-overlap)) {
        for (i in 0 until shown) {
            val item = avatars[i]
            cell {
                NeptuneAvatar(
                    initials = item.initials,
                    image = item.image,
                    icon = item.icon,
                    size = size,
                    background = item.background,
                )
            }
        }
        if (extra > 0) {
            cell {
                Box(
                    Modifier.fillMaxSize().background(scheme.secondaryContainer),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = NeptuneTheme.formatDigits("+$extra"),
                        style = typography.labelMedium.copy(
                            color = scheme.onSecondaryContainer,
                            fontSize = (size.value * 0.34f).sp,
                        ),
                    )
                }
            }
        }
    }
}

// --- progress --------------------------------------------------------------------

/**
 * A rounded linear progress track (8dp tall, `surfaceContainerHighest`) with
 * a `primary` fill scaled to [value] (0..1) growing from the inline start.
 * An optional [label] + percentage row sits above (6dp gap). [indeterminate]
 * renders the web sweep instead: a 40% bar sliding −120%→320% every 1.4s on
 * the brand standard curve — parked at the start under reduced motion.
 *
 * Web counterpart: `<npt-progress variant="linear">` · Flutter:
 * `NeptuneProgressBar`.
 */
@Composable
public fun NeptuneProgressBar(
    value: Float,
    modifier: Modifier = Modifier,
    label: String? = null,
    indeterminate: Boolean = false,
    color: Color? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val motion = NeptuneTheme.motion
    val reduced = NeptuneTheme.reducedMotion
    val shape = NeptuneTheme.shape.rFull
    val fill = color ?: scheme.primary
    val clamped = value.coerceIn(0f, 1f)

    Column(modifier) {
        if (label != null || !indeterminate) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (label != null) {
                    Text(
                        text = label,
                        style = typography.labelMedium,
                        color = scheme.onSurfaceVariant,
                        modifier = Modifier.weight(1f),
                    )
                } else {
                    Spacer(Modifier.weight(1f))
                }
                if (!indeterminate) {
                    Text(
                        text = NeptuneTheme.formatDigits("${(clamped * 100).roundToInt()}%"),
                        style = typography.labelMedium,
                        color = scheme.onSurfaceVariant,
                    )
                }
            }
            Spacer(Modifier.height(6.dp))
        }
        Box(
            Modifier
                .fillMaxWidth()
                .height(8.dp)
                .clip(shape)
                .background(scheme.surfaceContainerHighest),
        ) {
            if (indeterminate) {
                if (reduced) {
                    Box(Modifier.fillMaxWidth(0.4f).fillMaxHeight().clip(shape).background(fill))
                } else {
                    val rtl = LocalLayoutDirection.current == LayoutDirection.Rtl
                    val t by rememberInfiniteTransition(label = "progress").animateFloat(
                        initialValue = 0f,
                        targetValue = 1f,
                        animationSpec = infiniteRepeatable(
                            tween(1400, easing = motion.standard),
                            RepeatMode.Restart,
                        ),
                        label = "slide",
                    )
                    Box(
                        Modifier
                            .fillMaxWidth(0.4f)
                            .fillMaxHeight()
                            .graphicsLayer {
                                // Web keyframes: translateX(-120%) → 320% of
                                // the bar's own width, reading-direction-wise.
                                translationX =
                                    (-1.2f + 4.4f * t) * size.width * (if (rtl) -1f else 1f)
                            }
                            .clip(shape)
                            .background(fill),
                    )
                }
            } else {
                Box(Modifier.fillMaxWidth(clamped).fillMaxHeight().clip(shape).background(fill))
            }
        }
    }
}

/**
 * A determinate circular progress ring: a full `outlineVariant` track behind
 * a round-capped `primary` arc sweeping clockwise from the top. Optionally
 * shows a [centerLabel] (`labelLarge`) in the middle.
 *
 * Web counterpart: `<npt-progress variant="circular">` · Flutter:
 * `NeptuneProgressRing`.
 */
@Composable
public fun NeptuneProgressRing(
    value: Float,
    modifier: Modifier = Modifier,
    size: Dp = 48.dp,
    stroke: Dp = 6.dp,
    centerLabel: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val clamped = value.coerceIn(0f, 1f)

    Box(modifier.size(size), contentAlignment = Alignment.Center) {
        Canvas(Modifier.fillMaxSize()) {
            val strokePx = stroke.toPx()
            val radius = (this.size.minDimension - strokePx) / 2f
            val center = Offset(this.size.width / 2f, this.size.height / 2f)
            drawCircle(
                color = scheme.outlineVariant,
                radius = radius,
                center = center,
                style = Stroke(width = strokePx),
            )
            if (clamped > 0f) {
                drawArc(
                    color = scheme.primary,
                    startAngle = -90f,
                    sweepAngle = 360f * clamped,
                    useCenter = false,
                    topLeft = Offset(center.x - radius, center.y - radius),
                    size = Size(radius * 2f, radius * 2f),
                    style = Stroke(width = strokePx, cap = StrokeCap.Round),
                )
            }
        }
        if (centerLabel != null) {
            Text(
                text = NeptuneTheme.formatDigits(centerLabel),
                textAlign = TextAlign.Center,
                style = typography.labelLarge,
                color = scheme.onSurface,
            )
        }
    }
}

// --- rating ----------------------------------------------------------------------

/**
 * A row of rating stars. Filled stars ride `primary`; a fractional [value]
 * renders a half star (filled on the reading-direction start half); empties
 * are an `onSurfaceVariant` outline. When [onChanged] is given each star
 * becomes tappable (1-based index) on a ≥48dp target.
 *
 * Flutter: `NeptuneRating` (glyphs: neptune_icons `star` via
 * [NptDisplayGlyphs]).
 */
@Composable
public fun NeptuneRating(
    value: Float,
    modifier: Modifier = Modifier,
    count: Int = 5,
    onChanged: ((Int) -> Unit)? = null,
    size: Dp = 22.dp,
) {
    val scheme = MaterialTheme.colorScheme
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val shape = NeptuneTheme.shape.rFull

    Row(modifier = modifier, verticalAlignment = Alignment.CenterVertically) {
        for (i in 1..count) {
            val filled = value >= i
            val half = !filled && value > i - 1
            if (onChanged == null) {
                Box(Modifier.padding(end = 2.dp)) {
                    RatingStar(filled, half, size, scheme.primary, scheme.onSurfaceVariant)
                }
            } else {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(shape)
                        .clickable {
                            feedback.trigger(NptFeedbackCue.Tap, haptics)
                            onChanged(i)
                        },
                    contentAlignment = Alignment.Center,
                ) {
                    RatingStar(filled, half, size, scheme.primary, scheme.onSurfaceVariant)
                }
            }
        }
    }
}

/** One star glyph: filled, half (start-half filled over an outline), or an
 * outline in the empty tint. */
@Composable
private fun RatingStar(
    filled: Boolean,
    half: Boolean,
    size: Dp,
    activeTint: Color,
    emptyTint: Color,
) {
    when {
        filled -> Icon(
            NptDisplayGlyphs.starFilled,
            contentDescription = null,
            tint = activeTint,
            modifier = Modifier.size(size),
        )
        half -> Box(Modifier.size(size)) {
            Icon(
                NptDisplayGlyphs.star,
                contentDescription = null,
                tint = activeTint,
                modifier = Modifier.fillMaxSize(),
            )
            Icon(
                NptDisplayGlyphs.starFilled,
                contentDescription = null,
                tint = activeTint,
                modifier = Modifier
                    .fillMaxSize()
                    .drawWithContent {
                        // Fill the reading-direction start half only.
                        val mid = this.size.width / 2f
                        val ltr = layoutDirection == LayoutDirection.Ltr
                        clipRect(
                            left = if (ltr) 0f else mid,
                            right = if (ltr) mid else this.size.width,
                        ) {
                            this@drawWithContent.drawContent()
                        }
                    },
            )
        }
        else -> Icon(
            NptDisplayGlyphs.star,
            contentDescription = null,
            tint = emptyTint,
            modifier = Modifier.size(size),
        )
    }
}

// --- timeline --------------------------------------------------------------------

/**
 * One step in a [NeptuneTimeline]: a [title], optional [subtitle] and [time],
 * and a [done] flag that fills the step's dot.
 */
@Immutable
public class NeptuneTimelineEntry(
    public val title: String,
    public val subtitle: String? = null,
    public val time: String? = null,
    public val done: Boolean = false,
)

/**
 * A vertical timeline. Each entry shows a 14dp dot — filled `primary` when
 * done, otherwise a `surface` disc ringed in `outline` — joined to the next
 * by a 2dp `outlineVariant` connector, beside its title (`labelLarge`) /
 * subtitle (`bodySmall`) / inline-end time (`labelSmall`).
 *
 * Flutter: `NeptuneTimeline` (no web counterpart).
 */
@Composable
public fun NeptuneTimeline(
    entries: List<NeptuneTimelineEntry>,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rFull

    Column(modifier) {
        entries.forEachIndexed { i, entry ->
            val last = i == entries.lastIndex
            Row(Modifier.height(IntrinsicSize.Min)) {
                // Rail: the dot for this step + a connector to the next.
                Column(
                    modifier = Modifier.width(14.dp).fillMaxHeight(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Box(
                        Modifier
                            .size(14.dp)
                            .clip(shape)
                            .background(if (entry.done) scheme.primary else scheme.surface)
                            .border(
                                width = 2.dp,
                                color = if (entry.done) scheme.primary else scheme.outline,
                                shape = shape,
                            ),
                    )
                    if (!last) {
                        Box(Modifier.width(2.dp).weight(1f).background(scheme.outlineVariant))
                    }
                }
                Spacer(Modifier.width(12.dp))
                // Content beside the rail.
                Column(
                    Modifier
                        .weight(1f)
                        .padding(bottom = if (last) 0.dp else 16.dp),
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = entry.title,
                            style = typography.labelLarge,
                            color = scheme.onSurface,
                            modifier = Modifier.weight(1f),
                        )
                        if (entry.time != null) {
                            Spacer(Modifier.width(8.dp))
                            Text(
                                text = entry.time,
                                style = typography.labelSmall,
                                color = scheme.onSurfaceVariant,
                            )
                        }
                    }
                    if (entry.subtitle != null) {
                        Spacer(Modifier.height(2.dp))
                        Text(
                            text = entry.subtitle,
                            style = typography.bodySmall,
                            color = scheme.onSurfaceVariant,
                        )
                    }
                }
            }
        }
    }
}

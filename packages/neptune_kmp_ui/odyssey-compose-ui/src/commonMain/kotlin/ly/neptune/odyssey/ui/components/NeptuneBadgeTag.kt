// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Small count/label markers. Web counterparts: `<npt-badge>` and
// `<npt-chip variant="input">` (the removable pill) · Flutter:
// `NeptuneBadge` / `NeptuneTag`. The badge is the error-coloured counter
// ringed in `surface` so it reads over any content; the tag is the tonal
// `secondaryContainer` stadium pill with optional icon and remove control.
// Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/**
 * A small error-coloured badge, ringed in `surface`.
 *
 * Web counterpart: `<npt-badge>` · Flutter: `NeptuneBadge`.
 *
 * When [content] is given the badge overlays its top inline-end corner
 * (4dp outside, RTL-mirrored); otherwise it renders standalone. Shows a
 * [label], a [count] (capped at `99+`), or — with [dot] — a bare 10dp dot.
 */
@Composable
public fun NeptuneBadge(
    modifier: Modifier = Modifier,
    count: Int? = null,
    label: String? = null,
    dot: Boolean = false,
    content: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rFull

    val badge: @Composable (Modifier) -> Unit = { badgeModifier ->
        if (dot) {
            Box(
                badgeModifier
                    .size(10.dp)
                    .clip(shape)
                    .background(scheme.error)
                    .border(width = 1.5.dp, color = scheme.surface, shape = shape),
            )
        } else {
            val text = label ?: count?.let { if (it > 99) "99+" else it.toString() } ?: ""
            Box(
                modifier = badgeModifier
                    .defaultMinSize(minWidth = 18.dp, minHeight = 18.dp)
                    .clip(shape)
                    .background(scheme.error)
                    .border(width = 1.5.dp, color = scheme.surface, shape = shape)
                    .padding(horizontal = 5.dp, vertical = 1.dp),
                contentAlignment = Alignment.Center,
            ) {
                Text(text = text, style = typography.labelSmall.copy(color = scheme.onError))
            }
        }
    }

    if (content == null) {
        badge(modifier)
        return
    }
    Box(modifier) {
        content()
        // 4dp beyond the top inline-end corner (offset is direction-aware).
        badge(
            Modifier
                .align(Alignment.TopEnd)
                .offset(x = 4.dp, y = (-4).dp),
        )
    }
}

/**
 * A small tonal tag pill (`secondaryContainer`, stadium-shaped) with an
 * optional leading [icon] (14dp) and, when [onRemove] is given, a trailing
 * remove control.
 *
 * Web counterpart: `<npt-chip variant="input">` (removable) · Flutter:
 * `NeptuneTag`.
 *
 * [color] overrides the fill; the foreground stays `onSecondaryContainer`.
 * The remove control keeps the compact 18dp visual of the source but rides
 * an invisible 48dp touch target.
 */
@Composable
public fun NeptuneTag(
    label: String,
    modifier: Modifier = Modifier,
    icon: (@Composable () -> Unit)? = null,
    onRemove: (() -> Unit)? = null,
    color: Color? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rFull
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val bg = color ?: scheme.secondaryContainer
    val fg = scheme.onSecondaryContainer

    Row(
        modifier = modifier
            .clip(shape)
            .background(bg)
            .padding(
                start = if (icon != null) 8.dp else 12.dp,
                end = if (onRemove != null) 4.dp else 12.dp,
                top = 4.dp,
                bottom = 4.dp,
            ),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            CompositionLocalProvider(LocalContentColor provides fg) {
                Box(Modifier.size(14.dp), contentAlignment = Alignment.Center) { icon() }
            }
            Spacer(Modifier.width(6.dp))
        }
        Text(text = label, style = typography.labelMedium.copy(color = fg))
        if (onRemove != null) {
            Spacer(Modifier.width(4.dp))
            val interaction = remember { MutableInteractionSource() }
            Box(Modifier.size(18.dp), contentAlignment = Alignment.Center) {
                Box(
                    modifier = Modifier
                        // 48dp touch target overflowing the pill; visual stays 18dp.
                        .requiredSize(48.dp)
                        .clip(shape)
                        .clickable(interactionSource = interaction, indication = null) {
                            feedback.trigger(NptFeedbackCue.Tap, haptics)
                            onRemove()
                        },
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        NptGlyphs.cross,
                        contentDescription = null,
                        tint = fg,
                        modifier = Modifier.size(14.dp),
                    )
                }
            }
        }
    }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Pills for selection and status. Web counterparts: `<npt-chip>` and
// `<npt-status-chip>` · Flutter: `NeptuneChip` / `NeptuneStatusChip`.
// The chip is the tappable stadium pill (tonal `secondaryContainer` when
// selected, neutral `surfaceContainerHigh` otherwise); the status chip is a
// read-only pill with a coloured dot + tinted background per tone.
// Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/** Tone of a [NeptuneStatusChip], mirroring the web `<npt-status-chip>`
 * statuses and the Flutter `NeptuneStatusTone`. */
public enum class NeptuneStatusTone { Neutral, Success, Warning, Danger }

/**
 * A pill-shaped chip with an optional leading [icon] (18dp). When [selected]
 * it uses the secondary-container tonal treatment; otherwise a neutral
 * `surfaceContainerHigh` surface.
 *
 * Web counterpart: `<npt-chip>` · Flutter: `NeptuneChip`.
 *
 * Tappable via [onClick] (≥48dp target when interactive).
 */
@Composable
public fun NeptuneChip(
    label: String,
    modifier: Modifier = Modifier,
    icon: (@Composable () -> Unit)? = null,
    selected: Boolean = false,
    onClick: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rFull
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    val bg = if (selected) scheme.secondaryContainer else scheme.surfaceContainerHigh
    val fg = if (selected) scheme.onSecondaryContainer else scheme.onSurfaceVariant

    val clickableModifier = if (onClick != null) {
        Modifier.clickable {
            feedback.trigger(NptFeedbackCue.Tap, haptics)
            onClick()
        }
    } else {
        Modifier
    }

    Row(
        modifier = modifier
            .clip(shape)
            .background(bg)
            .then(clickableModifier)
            // Source min is 44; interactive chips lift to the 48dp floor.
            .defaultMinSize(minHeight = if (onClick != null) 48.dp else 44.dp)
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            CompositionLocalProvider(LocalContentColor provides fg) {
                Box(Modifier.size(18.dp), contentAlignment = Alignment.Center) { icon() }
            }
            Spacer(Modifier.width(8.dp))
        }
        Text(text = label, style = typography.labelLarge.copy(color = fg))
    }
}

/**
 * A small rounded status pill with a coloured dot + tonal background,
 * coloured by [tone]: success = the `success` roles, warning = tertiary,
 * danger = error, neutral = `surfaceContainerHighest`.
 *
 * Web counterpart: `<npt-status-chip>` · Flutter: `NeptuneStatusChip`.
 */
@Composable
public fun NeptuneStatusChip(
    label: String,
    modifier: Modifier = Modifier,
    tone: NeptuneStatusTone = NeptuneStatusTone.Neutral,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rFull

    // Dot/foreground accent + a tinted background per tone (the Dart table).
    val accent = when (tone) {
        NeptuneStatusTone.Success -> npt.success
        NeptuneStatusTone.Warning -> scheme.tertiary
        NeptuneStatusTone.Danger -> scheme.error
        NeptuneStatusTone.Neutral -> scheme.onSurfaceVariant
    }
    val fg = when (tone) {
        NeptuneStatusTone.Success -> npt.onSuccessContainer
        NeptuneStatusTone.Warning -> scheme.onTertiaryContainer
        NeptuneStatusTone.Danger -> scheme.onErrorContainer
        NeptuneStatusTone.Neutral -> scheme.onSurfaceVariant
    }
    val bg = when (tone) {
        NeptuneStatusTone.Success -> npt.success.copy(alpha = 0.15f)
        NeptuneStatusTone.Warning -> scheme.tertiary.copy(alpha = 0.15f)
        NeptuneStatusTone.Danger -> scheme.error.copy(alpha = 0.15f)
        NeptuneStatusTone.Neutral -> scheme.surfaceContainerHighest
    }

    Row(
        modifier = modifier
            .clip(shape)
            .background(bg)
            .padding(horizontal = 12.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            Modifier
                .size(8.dp)
                .clip(shape)
                .background(accent),
        )
        Spacer(Modifier.width(8.dp))
        Text(text = label, style = typography.labelMedium.copy(color = fg))
    }
}

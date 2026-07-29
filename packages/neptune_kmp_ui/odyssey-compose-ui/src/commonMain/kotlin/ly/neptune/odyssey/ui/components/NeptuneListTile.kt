// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The branded list row. Web counterpart: the `<npt-card-row>`-style list
// recipe · Flutter: `NeptuneListTile`. A rounded surface-container-low row
// (min 56dp, density-scaled) with leading/trailing slots, a bodyLarge title
// and a bodySmall onSurfaceVariant subtitle. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/**
 * A branded list row (min 56dp, density-scaled) on a rounded
 * `surfaceContainerLow` surface.
 *
 * Web counterpart: the `<npt-card-row>`-style list recipe · Flutter:
 * `NeptuneListTile`.
 *
 * [leading]/[trailing] are free slots (e.g. a tinted icon tile, a chevron or
 * an amount). The [title] uses `bodyLarge`, the [subtitle] `bodySmall` in
 * `onSurfaceVariant`. Tappable via [onClick].
 */
@Composable
public fun NeptuneListTile(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    leading: (@Composable () -> Unit)? = null,
    trailing: (@Composable () -> Unit)? = null,
    onClick: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val density = NeptuneTheme.density
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

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
            .clip(NeptuneTheme.shape.rMd)
            .background(scheme.surfaceContainerLow)
            .then(clickableModifier)
            .defaultMinSize(minHeight = density.s(56.dp))
            .padding(horizontal = 16.dp, vertical = density.s(10.dp)),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (leading != null) {
            leading()
            Spacer(Modifier.width(12.dp))
        }
        Column(Modifier.weight(1f)) {
            Text(
                text = title,
                style = typography.bodyLarge.copy(color = scheme.onSurface),
            )
            if (subtitle != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    text = subtitle,
                    style = typography.bodySmall.copy(color = scheme.onSurfaceVariant),
                )
            }
        }
        if (trailing != null) {
            Spacer(Modifier.width(12.dp))
            trailing()
        }
    }
}

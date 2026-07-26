// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The wallet quick-action tiles. Web counterpart: `<npt-quick-actions>` /
// `<npt-quick-action>` (wallet-pay.ts) · Flutter: `NeptuneQuickActions` /
// `NeptuneQuickAction` (neptune_quick_actions.dart). A circular tonal icon
// chip above a short caption, laid out in equal-width columns that wrap onto
// further rows. Theme-only, RTL-safe, ≥48dp targets.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/** One tile of a [NeptuneQuickActions] grid: a [label] caption, a 24dp
 * [icon] slot (tinted via [LocalContentColor]) and an optional [onTap].
 * When [onTap] is null the tile is inert. */
public class NeptuneQuickActionItem(
    public val label: String,
    public val icon: @Composable () -> Unit,
    public val onTap: (() -> Unit)? = null,
)

/**
 * A single quick action: a 56dp circular tonal chip
 * (`secondaryContainer` / `onSecondaryContainer`) above a labelMedium
 * caption in `onSurfaceVariant`, 8dp apart. Web counterpart:
 * `<npt-quick-action>` (wallet-pay.ts) · Flutter: `NeptuneQuickAction`.
 * Theme-only, RTL-safe, ≥48dp target.
 */
@Composable
public fun NeptuneQuickAction(
    item: NeptuneQuickActionItem,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val pill = NeptuneTheme.shape.rFull
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(pill)
                .background(scheme.secondaryContainer)
                .clickable(enabled = item.onTap != null) {
                    feedback.trigger(NptFeedbackCue.Tap, haptics)
                    item.onTap?.invoke()
                },
            contentAlignment = Alignment.Center,
        ) {
            CompositionLocalProvider(LocalContentColor provides scheme.onSecondaryContainer) {
                Box(Modifier.size(24.dp), contentAlignment = Alignment.Center) { item.icon() }
            }
        }
        Spacer(Modifier.height(8.dp))
        Text(
            item.label,
            maxLines = 1,
            textAlign = TextAlign.Center,
            overflow = TextOverflow.Ellipsis,
            style = MaterialTheme.typography.labelMedium.copy(color = scheme.onSurfaceVariant),
        )
    }
}

/**
 * A grid/row of evenly-spaced [NeptuneQuickAction]s: [columns] equal,
 * top-aligned cells per row (16dp between rows); trailing cells of the last
 * row stay their natural width via empty spacer cells. Web counterpart:
 * `<npt-quick-actions>` (wallet-pay.ts) · Flutter: `NeptuneQuickActions`.
 * Theme-only, RTL-safe (logical layout mirrors automatically).
 */
@Composable
public fun NeptuneQuickActions(
    actions: List<NeptuneQuickActionItem>,
    modifier: Modifier = Modifier,
    columns: Int = 4,
) {
    val perRow = if (columns < 1) 1 else columns

    Column(modifier.fillMaxWidth()) {
        var start = 0
        var firstRow = true
        while (start < actions.size) {
            val end = minOf(start + perRow, actions.size)
            if (!firstRow) Spacer(Modifier.height(16.dp))
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.Top) {
                for (i in start until end) {
                    NeptuneQuickAction(actions[i], Modifier.weight(1f))
                }
                // Pad the final row so trailing cells keep their natural width.
                repeat(perRow - (end - start)) {
                    Spacer(Modifier.weight(1f))
                }
            }
            firstRow = false
            start = end
        }
    }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Brand tabs. Web counterpart: `<npt-tabs>`/`<npt-tab>` (layout.ts) · Flutter:
// `NeptuneTabs`. A horizontal strip of tab labels over a hairline
// outline-variant baseline, with an animated 3dp primary indicator beneath the
// active one. The row scrolls horizontally when the labels overflow. Each tab
// is at least 48dp tall. Theme-only, RTL-safe, reduced-motion safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/**
 * A horizontal strip of tab labels with an animated underline indicator
 * beneath the active one. Web counterpart: `<npt-tabs>`/`<npt-tab>` ·
 * Flutter: `NeptuneTabs`.
 *
 * The active label is primary-coloured; inactive labels use
 * `onSurfaceVariant`. The indicator fades on the brand's `motion.standard`
 * curve (snaps under reduced motion). When [onSelect] is null the tabs are
 * non-interactive.
 */
@Composable
public fun NeptuneTabs(
    tabs: List<String>,
    selectedIndex: Int,
    onSelect: ((Int) -> Unit)?,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    Box(modifier.horizontalScroll(rememberScrollState())) {
        Row(
            Modifier.drawBehind {
                // The hairline baseline under the whole strip (web
                // `border-bottom: 1px solid outline-variant`).
                val line = 1.dp.toPx()
                drawRect(
                    color = scheme.outlineVariant,
                    topLeft = Offset(0f, size.height - line),
                    size = Size(size.width, line),
                )
            },
        ) {
            tabs.forEachIndexed { i, label ->
                Tab(
                    label = label,
                    selected = i == selectedIndex,
                    onTap = onSelect?.let { select -> { select(i) } },
                )
            }
        }
    }
}

@Composable
private fun Tab(
    label: String,
    selected: Boolean,
    onTap: (() -> Unit)?,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val motion = NeptuneTheme.motion
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val reduced = NeptuneTheme.reducedMotion

    val fg = if (selected) scheme.primary else scheme.onSurfaceVariant
    // The indicator animates between transparent and primary on the brand's
    // standard curve; under reduced motion it snaps.
    val indicator by animateColorAsState(
        targetValue = if (selected) scheme.primary else scheme.primary.copy(alpha = 0f),
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "tabIndicator",
    )

    Column(
        modifier = Modifier
            .clickable(enabled = onTap != null) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onTap?.invoke()
            }
            .defaultMinSize(minHeight = 48.dp)
            .width(IntrinsicSize.Max),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Bottom,
    ) {
        Text(
            label,
            maxLines = 1,
            style = MaterialTheme.typography.titleSmall.copy(color = fg),
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
        )
        Box(
            Modifier
                .padding(horizontal = 8.dp)
                .fillMaxWidth()
                .height(3.dp)
                .clip(shape.rFull)
                .background(indicator),
        )
    }
}

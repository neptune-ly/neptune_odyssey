// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The pill-shaped segmented control. Web counterpart: `<npt-segmented-button>`
// (actions.ts) · Flutter: `NeptuneSegmented`. A surface-container pill of
// equal-width segments; the selected one renders as a secondary-container pill
// with on-secondary-container content, fading on the brand motion curve.
// Sized intrinsically so it is safe in horizontal scrollers (pass
// `Modifier.fillMaxWidth()` to stretch it in a bounded column). Theme-only,
// RTL-safe, reduced-motion safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/**
 * A single-select segmented control of equal-width segments. Web counterpart:
 * `<npt-segmented-button>`/`<npt-segmented-option>` · Flutter:
 * `NeptuneSegmented`.
 *
 * The selected segment fills with `secondaryContainer` (animated on the
 * brand's `motion.standard` curve, snapping under reduced motion); the rest
 * read in `onSurfaceVariant`. When [onSelect] is null the control renders
 * disabled. Each segment is a ≥48dp touch target.
 */
@Composable
public fun NeptuneSegmented(
    options: List<String>,
    selectedIndex: Int,
    onSelect: ((Int) -> Unit)?,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val enabled = onSelect != null

    Row(
        modifier = modifier
            // Intrinsic width keeps equal-weight segments well-bounded even in
            // horizontally-unbounded slots (scroll rows) — the Flutter port's
            // LayoutBuilder fallback, folded into one measurement.
            .width(IntrinsicSize.Max)
            .clip(shape.rFull)
            .background(scheme.surfaceContainer)
            .padding(horizontal = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        options.forEachIndexed { i, label ->
            Segment(
                label = label,
                selected = i == selectedIndex,
                onTap = onSelect?.let { select -> { select(i) } },
                modifier = Modifier.weight(1f),
            )
        }
    }
}

@Composable
private fun Segment(
    label: String,
    selected: Boolean,
    onTap: (() -> Unit)?,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val motion = NeptuneTheme.motion
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val reduced = NeptuneTheme.reducedMotion
    val enabled = onTap != null

    val fg = when {
        selected -> scheme.onSecondaryContainer
        enabled -> scheme.onSurfaceVariant
        else -> scheme.onSurface.copy(alpha = 0.38f)
    }
    val bg by animateColorAsState(
        targetValue = if (selected) scheme.secondaryContainer else scheme.surface.copy(alpha = 0f),
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "segmentFill",
    )

    // The 48dp touch cell; the 40dp visual pill centres inside it, leaving the
    // Flutter recipe's 4dp inset from the control's pill edge.
    Box(
        modifier = modifier
            .defaultMinSize(minHeight = 48.dp)
            .clip(shape.rFull)
            .clickable(enabled = enabled) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onTap?.invoke()
            }
            .semantics { this.selected = selected },
        contentAlignment = Alignment.Center,
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .defaultMinSize(minHeight = 40.dp)
                .clip(shape.rFull)
                .background(bg)
                .padding(horizontal = 16.dp, vertical = 8.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                label,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = MaterialTheme.typography.labelLarge.copy(color = fg),
            )
        }
    }
}

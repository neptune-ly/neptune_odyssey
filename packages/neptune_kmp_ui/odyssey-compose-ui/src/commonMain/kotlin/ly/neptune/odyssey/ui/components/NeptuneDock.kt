// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The floating glass dock. Web counterpart: `<npt-dock>`/`<npt-dock-item>` ·
// Flutter: `NeptuneDock`/`NeptuneDockItem`. A backdrop-blurred
// surface-container pane with a hairline border and soft elevation, where the
// active item lifts into a filled accent circle that pops ABOVE the bar — the
// signature "raised active" indicator, sprung on the brand's motion curve.
// Theme-only, RTL-safe, reduced-motion safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.identity.NeptuneGlass
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import ly.neptune.odyssey.ui.theme.NptShadow
import kotlin.math.roundToInt

/** One item in a [NeptuneDock]: a label plus a 22dp [icon] slot (tinted via
 * [LocalContentColor]). Selection is owned by the dock's `selectedIndex`. */
public class NeptuneDockItem(
    public val label: String,
    public val icon: @Composable () -> Unit,
)

/**
 * The floating glass dock. Web counterpart: `<npt-dock>` (premium.ts) ·
 * Flutter: `NeptuneDock`.
 *
 * The glass pane sits 12dp below the top of the hit area so the active item's
 * raised circle can pop ABOVE the bar (web `overflow: visible`); the shadow is
 * drawn outside the glass clip so the blur pane stays clean. The raise springs
 * on the brand's `motion.spring` curve and carries the primary key-light while
 * lifted. Under reduced motion the indicator snaps to its raised frame.
 */
@Composable
public fun NeptuneDock(
    items: List<NeptuneDockItem>,
    selectedIndex: Int,
    onSelect: ((Int) -> Unit)?,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val identity = NeptuneTheme.identity
    val shape = NeptuneTheme.shape

    Box(modifier) {
        Box(
            Modifier
                .matchParentSize()
                .padding(top = 12.dp),
        ) {
            NeptuneGlass(
                modifier = Modifier
                    .fillMaxSize()
                    .nptShadow(identity.elevation3(scheme), shape.rXxl),
                shape = shape.rXxl,
                dock = true,
            ) {}
        }
        Row(Modifier.padding(start = 8.dp, top = 12.dp, end = 8.dp, bottom = 10.dp)) {
            items.forEachIndexed { i, item ->
                DockItem(
                    item = item,
                    active = i == selectedIndex,
                    onTap = onSelect?.let { select -> { select(i) } },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

@Composable
private fun DockItem(
    item: NeptuneDockItem,
    active: Boolean,
    onTap: (() -> Unit)?,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val motion = NeptuneTheme.motion
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val reduced = NeptuneTheme.reducedMotion

    // The raised-active circle springs up on the brand's motion curve; under
    // reduced motion it snaps straight to the lifted/lowered frame.
    val raise by animateFloatAsState(
        targetValue = if (active) -0.30f else 0f,
        animationSpec = if (reduced) snap() else tween(motion.standardMs, easing = motion.spring),
        label = "dockRaise",
    )
    val circleColor by animateColorAsState(
        targetValue = if (active) scheme.primary else scheme.primary.copy(alpha = 0f),
        animationSpec = if (reduced) snap() else tween(motion.standardMs, easing = motion.spring),
        label = "dockCircle",
    )
    val glowAlpha by animateFloatAsState(
        targetValue = if (active) 0.32f else 0f,
        animationSpec = if (reduced) snap() else tween(motion.standardMs, easing = motion.spring),
        label = "dockGlow",
    )
    val labelColor by animateColorAsState(
        targetValue = if (active) scheme.primary else scheme.onSurfaceVariant,
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "dockLabel",
    )

    // The ripple lives on its own clipped layer: Compose's clip() cuts ALL
    // descendant drawing (unlike Flutter's InkWell borderRadius, which only
    // bounds the splash), and the raised circle must overshoot the item's top
    // edge to float above the bar. Content stays unclipped on the layer above;
    // taps fall through it to the ripple layer.
    Box(
        modifier = modifier
            .defaultMinSize(minWidth = 48.dp, minHeight = 48.dp)
            .semantics(mergeDescendants = true) {},
    ) {
        Box(
            Modifier
                .matchParentSize()
                .clip(shape.rLg)
                .clickable(enabled = onTap != null) {
                    feedback.trigger(NptFeedbackCue.Tap, haptics)
                    onTap?.invoke()
                },
        )
        DockItemContent(item, active, raise, circleColor, glowAlpha, labelColor)
    }
}

@Composable
private fun BoxScope.DockItemContent(
    item: NeptuneDockItem,
    active: Boolean,
    raise: Float,
    circleColor: androidx.compose.ui.graphics.Color,
    glowAlpha: Float,
    labelColor: androidx.compose.ui.graphics.Color,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    Column(
        modifier = Modifier
            .align(Alignment.Center)
            .padding(vertical = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        val glow = if (glowAlpha > 0f) {
            listOf(
                NptShadow(
                    color = scheme.primary.copy(alpha = glowAlpha),
                    blurRadius = 14.dp,
                    offsetY = 6.dp,
                ),
            )
        } else {
            emptyList()
        }
        Box(
            modifier = Modifier
                // -0.30 of the circle's own 44dp height, the Flutter
                // AnimatedSlide geometry.
                .offset { IntOffset(0, (raise * 44.dp.toPx()).roundToInt()) }
                .nptShadow(glow, shape.rFull)
                .size(44.dp)
                .clip(shape.rFull)
                .background(circleColor),
            contentAlignment = Alignment.Center,
        ) {
            CompositionLocalProvider(
                LocalContentColor provides if (active) scheme.onPrimary else scheme.onSurfaceVariant,
            ) {
                Box(Modifier.size(22.dp), contentAlignment = Alignment.Center) { item.icon() }
            }
        }
        Text(
            item.label,
            maxLines = 1,
            style = MaterialTheme.typography.labelSmall.copy(
                color = labelColor,
                fontWeight = if (active) FontWeight.W700 else FontWeight.W500,
            ),
            modifier = Modifier.padding(top = if (active) 0.dp else 2.dp),
        )
    }
}

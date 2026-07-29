// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Branded structure & navigation extras. Web counterparts:
// `<npt-breadcrumbs>`, `<npt-pagination>`, `<npt-accordion>` · Flutter:
// neptune_navigation.dart (NeptuneTabs already lives in NeptuneTabs.kt).
// Colour, shape and type are read from the active theme only — no literals.
// Every interactive target sits on a ≥48dp floor (the 40dp source visuals
// stay 40dp; the touch cell around them grows). RTL-safe via auto-mirroring
// chevrons and direction-aware layout; motion runs on the brand curves and
// snaps under reduced motion.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ProvideTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptInputGlyphs
import ly.neptune.odyssey.ui.glyphs.NptNavGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

// --- breadcrumbs ------------------------------------------------------------------

/**
 * One node in a [NeptuneBreadcrumbs] trail. A null [onClick] renders the
 * crumb as plain (non-interactive) text — typically the current/last crumb.
 */
@Immutable
public class NeptuneCrumb(
    /** The crumb's visible label. */
    public val label: String,
    /** Tap handler. When null the crumb is non-interactive. */
    public val onClick: (() -> Unit)? = null,
)

/**
 * A breadcrumb trail: crumbs separated by a direction-aware chevron.
 * Earlier crumbs are primary-coloured and tappable; the last crumb is the
 * current page in `onSurface`. Wraps onto a new line when it overflows.
 *
 * Web counterpart: `<npt-breadcrumbs>` · Flutter: `NeptuneBreadcrumbs`.
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
public fun NeptuneBreadcrumbs(
    crumbs: List<NeptuneCrumb>,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    FlowRow(modifier) {
        crumbs.forEachIndexed { i, crumb ->
            val isLast = i == crumbs.lastIndex
            val onClick = crumb.onClick
            val interactive = onClick != null && !isLast
            val label: @Composable () -> Unit = {
                Text(
                    crumb.label,
                    style = typography.labelLarge.copy(
                        color = if (isLast) scheme.onSurface else scheme.primary,
                    ),
                )
            }
            if (interactive) {
                Box(
                    Modifier
                        .align(Alignment.CenterVertically)
                        .clip(shape.rXs)
                        .clickable {
                            feedback.trigger(NptFeedbackCue.Tap, haptics)
                            onClick()
                        }
                        // Interactive crumbs lift to the 48dp target floor.
                        .defaultMinSize(minHeight = 48.dp)
                        .padding(horizontal = 6.dp, vertical = 4.dp),
                    contentAlignment = Alignment.Center,
                ) { label() }
            } else {
                Box(
                    Modifier
                        .align(Alignment.CenterVertically)
                        .padding(horizontal = 6.dp, vertical = 4.dp),
                ) { label() }
            }
            if (!isLast) {
                Icon(
                    NptNavGlyphs.chevronForward,
                    contentDescription = null,
                    tint = scheme.onSurfaceVariant,
                    modifier = Modifier
                        .align(Alignment.CenterVertically)
                        .size(18.dp),
                )
            }
        }
    }
}

// --- pagination -------------------------------------------------------------------

/** How many number pills the pager window shows. */
private const val PAGER_WINDOW = 5

/** The inclusive run of page indices visible in the window, clamped to range. */
private fun visiblePages(page: Int, pageCount: Int): List<Int> {
    if (pageCount <= 0) return emptyList()
    val half = PAGER_WINDOW / 2
    var start = page - half
    var end = page + half
    if (start < 0) {
        end -= start
        start = 0
    }
    if (end > pageCount - 1) {
        start -= end - (pageCount - 1)
        end = pageCount - 1
    }
    if (start < 0) start = 0
    return (start..end).toList()
}

/**
 * A windowed pager: a previous chevron, a run of page-number pills centred
 * on the current [page] (zero-based), and a next chevron. The active pill is
 * a filled `primary`; the rest are tonal surface-containers. Prev is
 * disabled on the first page and next on the last; a null [onChanged] makes
 * the pager read-only.
 *
 * Web counterpart: `<npt-pagination>` · Flutter: `NeptunePagination`.
 *
 * The 40dp source visuals sit centred in 48dp touch cells, so adjacent cells
 * reproduce the recipe's 8dp visual gaps while every target meets the 48dp
 * floor.
 */
@Composable
public fun NeptunePagination(
    page: Int,
    pageCount: Int,
    onChanged: ((Int) -> Unit)?,
    modifier: Modifier = Modifier,
) {
    val canPrev = page > 0
    val canNext = page < pageCount - 1
    val go: (Int) -> Unit = { p ->
        if (onChanged != null && p >= 0 && p < pageCount && p != page) onChanged(p)
    }

    Row(modifier, verticalAlignment = Alignment.CenterVertically) {
        PagerArrow(
            icon = NptNavGlyphs.chevronBack,
            onTap = if (canPrev && onChanged != null) ({ go(page - 1) }) else null,
        )
        for (p in visiblePages(page, pageCount)) {
            PagePill(
                page = p,
                active = p == page,
                onTap = if (onChanged != null) ({ go(p) }) else null,
            )
        }
        PagerArrow(
            icon = NptNavGlyphs.chevronForward,
            onTap = if (canNext && onChanged != null) ({ go(page + 1) }) else null,
        )
    }
}

/** A 40dp circular prev/next control in a 48dp touch cell. A null [onTap]
 * renders the disabled (dimmed) state. */
@Composable
private fun PagerArrow(icon: ImageVector, onTap: (() -> Unit)?) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape.rFull
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val enabled = onTap != null
    val fg = if (enabled) scheme.onSurface else scheme.onSurfaceVariant.copy(alpha = 0.38f)

    Box(
        Modifier
            .size(48.dp)
            .clip(shape)
            .clickable(enabled = enabled) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onTap?.invoke()
            },
        contentAlignment = Alignment.Center,
    ) {
        Box(
            Modifier
                .size(40.dp)
                .clip(shape)
                .background(scheme.surfaceContainerHigh),
            contentAlignment = Alignment.Center,
        ) {
            Icon(icon, contentDescription = null, tint = fg, modifier = Modifier.size(20.dp))
        }
    }
}

/** A single page-number pill (40dp visual in a 48dp touch cell). The active
 * page is a filled `primary`; inactive pages are tonal surface-containers. */
@Composable
private fun PagePill(page: Int, active: Boolean, onTap: (() -> Unit)?) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rSm
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val bg = if (active) scheme.primary else scheme.surfaceContainerHigh
    val fg = if (active) scheme.onPrimary else scheme.onSurfaceVariant

    Box(
        Modifier
            .defaultMinSize(minWidth = 48.dp, minHeight = 48.dp)
            .clip(shape)
            .clickable(enabled = onTap != null) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onTap?.invoke()
            },
        contentAlignment = Alignment.Center,
    ) {
        Box(
            Modifier
                .defaultMinSize(minWidth = 40.dp, minHeight = 40.dp)
                .clip(shape)
                .background(bg)
                .padding(horizontal = 8.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                NeptuneTheme.formatDigits("${page + 1}"),
                style = typography.labelLarge.copy(color = fg),
            )
        }
    }
}

// --- accordion --------------------------------------------------------------------

/** One collapsible panel in a [NeptuneAccordion]. */
@Immutable
public class NeptuneAccordionPanel(
    /** The header title. */
    public val title: String,
    /** Whether the panel starts expanded. */
    public val initiallyExpanded: Boolean = false,
    /** The body revealed when the panel is expanded. */
    public val content: @Composable () -> Unit,
)

/**
 * A stack of collapsible panels: each panel has a tappable header (title +
 * an animated chevron) over an animated body. The surface is a rounded
 * `surfaceContainerLow` with outline-variant dividers between panels. When
 * [allowMultiple] is false, opening a panel collapses the others. Expansion
 * state is managed internally.
 *
 * Web counterpart: `<npt-accordion>` · Flutter: `NeptuneAccordion`.
 *
 * Expand/collapse runs on the brand `motion.standard` curve over `fastMs`
 * and is instant under reduced motion.
 */
@Composable
public fun NeptuneAccordion(
    panels: List<NeptuneAccordionPanel>,
    modifier: Modifier = Modifier,
    allowMultiple: Boolean = false,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape.rLg
    var expanded by remember {
        mutableStateOf(panels.indices.filter { panels[it].initiallyExpanded }.toSet())
    }

    Column(
        modifier
            .clip(shape)
            .background(scheme.surfaceContainerLow)
            .border(1.dp, scheme.outlineVariant, shape),
    ) {
        panels.forEachIndexed { i, panel ->
            if (i > 0) {
                Box(
                    Modifier
                        .fillMaxWidth()
                        .height(1.dp)
                        .background(scheme.outlineVariant),
                )
            }
            AccordionTile(
                panel = panel,
                expanded = i in expanded,
                onToggle = {
                    expanded = if (i in expanded) {
                        expanded - i
                    } else {
                        (if (allowMultiple) expanded else emptySet()) + i
                    }
                },
            )
        }
    }
}

/** A single accordion header + animated body. */
@Composable
private fun AccordionTile(
    panel: NeptuneAccordionPanel,
    expanded: Boolean,
    onToggle: () -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val motion = NeptuneTheme.motion
    val reduced = NeptuneTheme.reducedMotion
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    Column {
        Row(
            Modifier
                .fillMaxWidth()
                .clickable {
                    feedback.trigger(NptFeedbackCue.Tap, haptics)
                    onToggle()
                }
                .defaultMinSize(minHeight = 48.dp)
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                panel.title,
                style = typography.titleSmall.copy(color = scheme.onSurface),
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.width(12.dp))
            // The chevron flips half a turn on the brand curve (snaps under
            // reduced motion).
            val turns by animateFloatAsState(
                targetValue = if (expanded) 180f else 0f,
                animationSpec = if (reduced) {
                    snap()
                } else {
                    tween(motion.fastMs, easing = motion.standard)
                },
                label = "accordionChevron",
            )
            Icon(
                NptInputGlyphs.caretDown,
                contentDescription = null,
                tint = scheme.onSurfaceVariant,
                modifier = Modifier
                    .size(22.dp)
                    .rotate(turns),
            )
        }
        AnimatedVisibility(
            visible = expanded,
            enter = if (reduced) {
                fadeIn(snap())
            } else {
                expandVertically(tween(motion.fastMs, easing = motion.standard)) +
                    fadeIn(tween(motion.fastMs, easing = motion.standard))
            },
            exit = if (reduced) {
                fadeOut(snap())
            } else {
                shrinkVertically(tween(motion.fastMs, easing = motion.standard)) +
                    fadeOut(tween(motion.fastMs, easing = motion.standard))
            },
        ) {
            Box(
                Modifier
                    .fillMaxWidth()
                    .padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
            ) {
                CompositionLocalProvider(LocalContentColor provides scheme.onSurfaceVariant) {
                    ProvideTextStyle(typography.bodyMedium.copy(color = scheme.onSurfaceVariant)) {
                        panel.content()
                    }
                }
            }
        }
    }
}

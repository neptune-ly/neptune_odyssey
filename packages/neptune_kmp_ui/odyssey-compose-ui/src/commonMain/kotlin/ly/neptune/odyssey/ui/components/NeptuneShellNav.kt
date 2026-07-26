// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The application shell + navigation chrome. Web counterparts:
// `<npt-app-shell>` / `<npt-side-nav>` / `<npt-side-nav-item>` /
// `<npt-toolbar>` (shell-layout.ts) and `<npt-nav-rail>` (nav-rail.ts) ·
// Flutter: NeptuneAppShell / NeptuneSideNav / NeptuneSideNavItem /
// NeptuneToolbar / NeptuneNavRail (neptune_shell_nav.dart).
//
// The shell provides [LocalNptGlassScope] and marks its content region with
// Modifier.nptGlassBackground, so glass surfaces composed inside (dock,
// app bar) get a real backdrop to blur. Slot rows constrain their children —
// the Flutter NeptuneToolbar once blanked a subtree by handing its center
// slot unbounded width; here the center slot is weighted so nothing silently
// overflows. Theme-only, RTL-safe (logical layout mirrors automatically).

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationRail
import androidx.compose.material3.NavigationRailItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.identity.LocalNptGlassScope
import ly.neptune.odyssey.ui.identity.nptGlassBackground
import ly.neptune.odyssey.ui.identity.rememberNptGlassScope
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/**
 * The application frame: an optional sticky [header] row (surface-container),
 * an inline-start [nav] sidebar (full 280dp, or a narrow 88dp [rail]) with a
 * trailing hairline, and the [content] region (24dp padding when the nav is
 * shown, 16dp when collapsed). The nav collapses away below [breakpoint] so
 * the content takes the full width — the web `@max-width:768` rule.
 *
 * Web counterpart: `<npt-app-shell>` (shell-layout.ts) · Flutter:
 * `NeptuneAppShell`.
 *
 * The shell publishes [LocalNptGlassScope] and marks the content region via
 * `Modifier.nptGlassBackground`, so glass surfaces (dock, app bar, glass
 * cards) composed anywhere inside find their backdrop automatically.
 * Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneAppShell(
    modifier: Modifier = Modifier,
    header: (@Composable () -> Unit)? = null,
    nav: (@Composable () -> Unit)? = null,
    rail: Boolean = false,
    breakpoint: Dp = 768.dp,
    content: @Composable () -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val glass = rememberNptGlassScope()

    CompositionLocalProvider(
        LocalNptGlassScope provides glass,
        LocalContentColor provides scheme.onSurface,
    ) {
        BoxWithConstraints(modifier.fillMaxSize().background(scheme.surface)) {
            val wide = maxWidth >= breakpoint && nav != null
            Column(Modifier.fillMaxSize()) {
                if (header != null) {
                    Box(Modifier.fillMaxWidth().background(scheme.surfaceContainer)) {
                        header()
                    }
                }
                Box(Modifier.weight(1f).fillMaxWidth()) {
                    if (wide) {
                        Row(Modifier.fillMaxSize()) {
                            val hairline = scheme.outlineVariant
                            Box(
                                Modifier
                                    .width(if (rail) 88.dp else 280.dp)
                                    .fillMaxHeight()
                                    .background(scheme.surfaceContainerLow)
                                    .drawBehind {
                                        // border-inline-end: 1px outline-variant
                                        // (drawn on the trailing edge, RTL-aware).
                                        val w = 1.dp.toPx()
                                        val x = if (layoutDirection == LayoutDirection.Rtl) {
                                            w / 2
                                        } else {
                                            size.width - w / 2
                                        }
                                        drawLine(
                                            color = hairline,
                                            start = Offset(x, 0f),
                                            end = Offset(x, size.height),
                                            strokeWidth = w,
                                        )
                                    },
                            ) {
                                nav()
                            }
                            Box(
                                Modifier
                                    .weight(1f)
                                    .fillMaxHeight()
                                    .nptGlassBackground(glass)
                                    .padding(24.dp),
                            ) {
                                content()
                            }
                        }
                    } else {
                        Box(
                            Modifier
                                .fillMaxSize()
                                .nptGlassBackground(glass)
                                .padding(16.dp),
                        ) {
                            content()
                        }
                    }
                }
            }
        }
    }
}

/**
 * The vertical sidebar nav container: a `surfaceContainer` column of
 * [NeptuneSideNavItem]s, 12dp padded, items 4dp apart. Web counterpart:
 * `<npt-side-nav>` (shell-layout.ts) · Flutter: `NeptuneSideNav`.
 * Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneSideNav(
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(scheme.surfaceContainer)
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp),
        content = content,
    )
}

/**
 * One row of a [NeptuneSideNav]: a stadium pill with an optional leading
 * 22dp [icon] slot, a [label], and an optional [trailing] slot (counts /
 * badges). [active] fills it with the secondary container; [enabled] false
 * fades it to 38% and gates taps. Web counterpart: `<npt-side-nav-item>`
 * (shell-layout.ts) · Flutter: `NeptuneSideNavItem`. Theme-only, RTL-safe,
 * ≥48dp.
 */
@Composable
public fun NeptuneSideNavItem(
    label: String,
    modifier: Modifier = Modifier,
    icon: (@Composable () -> Unit)? = null,
    active: Boolean = false,
    trailing: (@Composable () -> Unit)? = null,
    enabled: Boolean = true,
    onTap: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val pill = NeptuneTheme.shape.rFull
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val fg = if (active) scheme.onSecondaryContainer else scheme.onSurfaceVariant

    Row(
        modifier = modifier
            .fillMaxWidth()
            .alpha(if (enabled) 1f else 0.38f)
            .clip(pill)
            .then(if (active) Modifier.background(scheme.secondaryContainer) else Modifier)
            .clickable(enabled = enabled && onTap != null) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onTap?.invoke()
            }
            .defaultMinSize(minHeight = 48.dp)
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        CompositionLocalProvider(LocalContentColor provides fg) {
            if (icon != null) {
                Box(Modifier.size(22.dp), contentAlignment = Alignment.Center) { icon() }
                Spacer(Modifier.width(12.dp))
            }
            Text(
                label,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = MaterialTheme.typography.labelLarge.copy(color = fg),
                modifier = Modifier.weight(1f),
            )
            if (trailing != null) {
                Spacer(Modifier.width(12.dp))
                trailing()
            }
        }
    }
}

/**
 * A horizontal toolbar surface with [leading] / [center] / [trailing]
 * regions on a `surfaceContainer` pane (brand `lg` corner, ≥56dp, regions
 * 12dp apart). `leading` and `trailing` mirror in RTL via logical layout;
 * `center` stays centred. Web counterpart: `<npt-toolbar>` (shell-layout.ts)
 * · Flutter: `NeptuneToolbar`.
 *
 * The center slot gets BOUNDED width (a weighted row) — a bare row hands its
 * children unbounded width, which blanked flex children like
 * [NeptuneSearchField] in the Flutter port. Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneToolbar(
    modifier: Modifier = Modifier,
    leading: (@Composable RowScope.() -> Unit)? = null,
    center: (@Composable RowScope.() -> Unit)? = null,
    trailing: (@Composable RowScope.() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme

    CompositionLocalProvider(LocalContentColor provides scheme.onSurface) {
        Row(
            modifier = modifier
                .clip(NeptuneTheme.shape.rLg)
                .background(scheme.surfaceContainer)
                .defaultMinSize(minHeight = 56.dp)
                .padding(horizontal = 16.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (leading != null) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    leading()
                }
            }
            // Weighted ⇒ the center slot is constrained to the leftover width
            // and keeps trailing pinned at the end even when empty.
            Row(
                modifier = Modifier.weight(1f),
                horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                center?.invoke(this)
            }
            if (trailing != null) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    trailing()
                }
            }
        }
    }
}

/** One destination of a [NeptuneNavRail]: a [label], a 24dp [icon] slot and
 * an optional [selectedIcon] shown while active. */
public class NeptuneNavRailItem(
    public val label: String,
    public val icon: @Composable () -> Unit,
    public val selectedIcon: (@Composable () -> Unit)? = null,
)

/**
 * The desktop/tablet side rail: a themed Material 3 [NavigationRail] on the
 * `surface` role with always-visible labels, picking its indicator/content
 * colours from the active brand scheme. Provide [leading] (e.g. a FAB/logo)
 * and [trailing] slots as needed. Web counterpart: `<npt-nav-rail>`
 * (nav-rail.ts) · Flutter: `NeptuneNavRail`. Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneNavRail(
    items: List<NeptuneNavRailItem>,
    selectedIndex: Int,
    onSelect: (Int) -> Unit,
    modifier: Modifier = Modifier,
    leading: (@Composable () -> Unit)? = null,
    trailing: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    NavigationRail(
        modifier = modifier,
        containerColor = scheme.surface,
        contentColor = scheme.onSurfaceVariant,
        header = leading?.let { lead -> { lead() } },
    ) {
        items.forEachIndexed { i, item ->
            val selected = i == selectedIndex
            NavigationRailItem(
                selected = selected,
                onClick = {
                    feedback.trigger(NptFeedbackCue.Tap, haptics)
                    onSelect(i)
                },
                icon = {
                    if (selected && item.selectedIcon != null) {
                        item.selectedIcon.invoke()
                    } else {
                        item.icon()
                    }
                },
                label = { Text(item.label, maxLines = 1, overflow = TextOverflow.Ellipsis) },
                alwaysShowLabel = true,
            )
        }
        if (trailing != null) trailing()
    }
}

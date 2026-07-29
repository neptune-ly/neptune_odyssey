// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Inline feedback surfaces. Web counterparts: `<npt-alert>`
// (feedback-status.ts) and `<npt-banner>` (feedback.ts) · Flutter:
// `NeptuneAlert` / `NeptuneBanner`. The alert is a tone-tinted pane with a
// 4dp leading accent bar and a status glyph; the banner is a full-width
// secondary-container strip with an optional action. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptStatusGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/** Tone of a [NeptuneAlert] — drives its tinted background and accent colour. */
public enum class NeptuneAlertTone { Info, Success, Warning, Danger }

/**
 * An inline tonal alert: a tone-tinted background, a leading 4dp accent bar
 * plus status icon, and an optional [title] above the [message]. Web
 * counterpart: `<npt-alert>` · Flutter: `NeptuneAlert`.
 *
 * The accent per tone: info = `secondary`, success = the Neptune `success`
 * role, warning = `tertiary`, danger = `error`. [icon] overrides the default
 * tone glyph (a 20dp slot tinted with the accent via [LocalContentColor]).
 */
@Composable
public fun NeptuneAlert(
    message: String,
    modifier: Modifier = Modifier,
    tone: NeptuneAlertTone = NeptuneAlertTone.Info,
    title: String? = null,
    icon: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val shape = NeptuneTheme.shape

    val accent = when (tone) {
        NeptuneAlertTone.Info -> scheme.secondary
        NeptuneAlertTone.Success -> npt.success
        NeptuneAlertTone.Warning -> scheme.tertiary
        NeptuneAlertTone.Danger -> scheme.error
    }

    Row(
        modifier = modifier
            .clip(shape.rMd)
            .background(accent.copy(alpha = 0.12f))
            .drawBehind {
                // The 4dp leading accent bar (web `border-inline-start`),
                // drawn inside the clip so the brand corners crop it.
                val bar = 4.dp.toPx()
                val x = if (layoutDirection == LayoutDirection.Rtl) size.width - bar else 0f
                drawRect(
                    color = accent,
                    topLeft = Offset(x, 0f),
                    size = Size(bar, size.height),
                )
            }
            // 16dp inline padding + the 4dp accent bar on the leading side.
            .padding(start = 20.dp, top = 12.dp, end = 16.dp, bottom = 12.dp),
        verticalAlignment = Alignment.Top,
    ) {
        if (icon != null) {
            CompositionLocalProvider(LocalContentColor provides accent) {
                Box(Modifier.size(20.dp), contentAlignment = Alignment.Center) { icon() }
            }
        } else {
            Icon(
                imageVector = when (tone) {
                    NeptuneAlertTone.Info -> NptStatusGlyphs.info
                    NeptuneAlertTone.Success -> NptStatusGlyphs.successCheck
                    NeptuneAlertTone.Warning -> NptStatusGlyphs.warning
                    NeptuneAlertTone.Danger -> NptStatusGlyphs.error
                },
                contentDescription = null,
                tint = accent,
                modifier = Modifier.size(20.dp),
            )
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            if (title != null) {
                Text(
                    title,
                    style = MaterialTheme.typography.labelLarge.copy(
                        color = scheme.onSurface,
                        fontWeight = FontWeight.W600,
                    ),
                )
                Spacer(Modifier.height(4.dp))
            }
            Text(
                message,
                style = MaterialTheme.typography.bodyMedium.copy(color = scheme.onSurface),
            )
        }
    }
}

/**
 * A full-width banner: a secondary-container strip with an optional leading
 * [icon] (20dp slot), a [message], and an optional trailing [action]. Web
 * counterpart: `<npt-banner>` · Flutter: `NeptuneBanner`.
 */
@Composable
public fun NeptuneBanner(
    message: String,
    modifier: Modifier = Modifier,
    icon: (@Composable () -> Unit)? = null,
    action: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape

    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(shape.rMd)
            .background(scheme.secondaryContainer)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            CompositionLocalProvider(LocalContentColor provides scheme.onSecondaryContainer) {
                Box(Modifier.size(20.dp), contentAlignment = Alignment.Center) { icon() }
            }
            Spacer(Modifier.width(12.dp))
        }
        Text(
            message,
            style = MaterialTheme.typography.bodyMedium.copy(color = scheme.onSecondaryContainer),
            modifier = Modifier.weight(1f),
        )
        if (action != null) {
            Spacer(Modifier.width(12.dp))
            CompositionLocalProvider(LocalContentColor provides scheme.onSecondaryContainer) {
                action()
            }
        }
    }
}

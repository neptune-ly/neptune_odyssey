// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Shell feedback surfaces. Web counterparts: `<npt-page-header>` /
// `<npt-search-field>` (shell-layout.ts) and `<npt-empty-state>` · Flutter:
// `NeptunePageHeader` / `NeptuneSearchField` / `NeptuneEmptyState`
// (neptune_shell_feedback.dart). The page masthead (display-font title,
// optional eyebrow above and subtitle below, trailing actions), the pill
// search field (surface-container-high, focus ring, clear control) and the
// centred empty-collection placeholder. NeptuneAlert / NeptuneBanner /
// NeptuneSkeleton live in their own files. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.glyphs.NptGlyphs
import ly.neptune.odyssey.ui.glyphs.NptShellGlyphs
import ly.neptune.odyssey.ui.identity.NeptuneEyebrow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/**
 * The page-level masthead: a display-font [title], an optional [eyebrow]
 * micro-label above it, an optional supporting [subtitle] below, and trailing
 * [actions] inline-end of the title row (8dp apart). Web counterpart:
 * `<npt-page-header>` (shell-layout.ts) · Flutter: `NeptunePageHeader`.
 *
 * The title renders in displaySmall with the brand display face, weight and
 * em-scaled tracking, marked as a heading for assistive tech. Theme-only,
 * RTL-safe.
 */
@Composable
public fun NeptunePageHeader(
    title: String,
    modifier: Modifier = Modifier,
    eyebrow: String? = null,
    subtitle: String? = null,
    actions: (@Composable RowScope.() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val type = NeptuneTheme.type
    val typography = MaterialTheme.typography
    val display = rememberNeptuneFontFamily(type.display)

    Column(modifier.padding(bottom = 20.dp)) {
        if (eyebrow != null) {
            // The web header's slot above the title row (8dp column gap).
            NeptuneEyebrow(eyebrow)
            Spacer(Modifier.height(8.dp))
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            val base = typography.displaySmall
            val fontSize = if (base.fontSize.isSp) base.fontSize.value else 36f
            Text(
                title,
                style = base.copy(
                    fontFamily = display ?: base.fontFamily,
                    fontWeight = type.displayFontWeight,
                    // Em-scaled brand tracking (web `--npt-display-tracking`).
                    letterSpacing = (type.displayTracking * fontSize).sp,
                    color = scheme.onSurface,
                ),
                modifier = Modifier
                    .weight(1f)
                    .semantics { heading() },
            )
            if (actions != null) {
                Spacer(Modifier.width(16.dp))
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    actions()
                }
            }
        }
        if (subtitle != null) {
            Spacer(Modifier.height(8.dp))
            Text(
                subtitle,
                style = typography.titleMedium.copy(color = scheme.onSurfaceVariant),
            )
        }
    }
}

/**
 * A themed pill search field: a stadium `surfaceContainerHigh` row with a
 * leading 20dp magnifier, a borderless input, a hairline primary ring while
 * focused, and a trailing clear control once [value] is non-empty (48dp hit
 * area, 28dp visual, fires `onValueChange("")`). Web counterpart:
 * `<npt-search-field>` (shell-layout.ts) · Flutter: `NeptuneSearchField`.
 *
 * Disabled fields fade to 38% and ignore input. Theme-only, RTL-safe, ≥48dp.
 */
@Composable
public fun NeptuneSearchField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    placeholder: String = "Search",
    enabled: Boolean = true,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val pill = NeptuneTheme.shape.rFull
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    var focused by remember { mutableStateOf(false) }

    // Web: `border: 1px solid transparent` at rest → primary on focus-within.
    val ring = if (focused && enabled) Modifier.border(1.dp, scheme.primary, pill) else Modifier

    Row(
        modifier = modifier
            .alpha(if (enabled) 1f else 0.38f)
            .defaultMinSize(minHeight = 48.dp)
            .clip(pill)
            .background(scheme.surfaceContainerHigh)
            .then(ring)
            .padding(start = 16.dp, end = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            imageVector = NptShellGlyphs.search,
            contentDescription = null,
            tint = scheme.onSurfaceVariant,
            modifier = Modifier.size(20.dp),
        )
        Spacer(Modifier.width(8.dp))
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            modifier = Modifier
                .weight(1f)
                .onFocusChanged { focused = it.isFocused },
            enabled = enabled,
            singleLine = true,
            textStyle = typography.bodyLarge.copy(color = scheme.onSurface),
            cursorBrush = SolidColor(scheme.primary),
            decorationBox = { innerTextField ->
                Box(Modifier.padding(vertical = 12.dp)) {
                    if (value.isEmpty()) {
                        Text(
                            placeholder,
                            style = typography.bodyLarge.copy(
                                color = scheme.onSurfaceVariant.copy(alpha = 0.7f),
                            ),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                    innerTextField()
                }
            },
        )
        if (value.isNotEmpty() && enabled) {
            // Web `.clear`: a 28dp round control — kept inside a 48dp target.
            Box(
                modifier = Modifier
                    .defaultMinSize(minWidth = 48.dp, minHeight = 48.dp)
                    .clip(pill)
                    .clickable {
                        feedback.trigger(NptFeedbackCue.Tap, haptics)
                        onValueChange("")
                    },
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    imageVector = NptGlyphs.cross,
                    contentDescription = "Clear search",
                    tint = scheme.onSurfaceVariant,
                    modifier = Modifier.size(14.dp),
                )
            }
        }
    }
}

/**
 * A centred placeholder for empty collections: an optional [icon] slot inside
 * a 64dp `surfaceContainerHigh` circle, a display-font [title], an optional
 * supporting [message], and an optional [action] slot. Web counterpart:
 * `<npt-empty-state>` · Flutter: `NeptuneEmptyState`
 * (neptune_shell_feedback.dart). Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneEmptyState(
    title: String,
    modifier: Modifier = Modifier,
    icon: (@Composable () -> Unit)? = null,
    message: String? = null,
    action: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val type = NeptuneTheme.type
    val typography = MaterialTheme.typography
    val display = rememberNeptuneFontFamily(type.display)

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 48.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        if (icon != null) {
            Box(
                modifier = Modifier
                    .size(64.dp)
                    .clip(NeptuneTheme.shape.rFull)
                    .background(scheme.surfaceContainerHigh),
                contentAlignment = Alignment.Center,
            ) {
                CompositionLocalProvider(LocalContentColor provides scheme.onSurfaceVariant) {
                    Box(Modifier.size(28.dp), contentAlignment = Alignment.Center) { icon() }
                }
            }
            Spacer(Modifier.height(16.dp))
        }
        Text(
            title,
            textAlign = TextAlign.Center,
            style = typography.titleLarge.copy(
                fontFamily = display ?: typography.titleLarge.fontFamily,
                fontWeight = type.displayFontWeight,
                color = scheme.onSurface,
            ),
        )
        if (message != null) {
            Spacer(Modifier.height(8.dp))
            Text(
                message,
                textAlign = TextAlign.Center,
                style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
            )
        }
        if (action != null) {
            Spacer(Modifier.height(16.dp))
            action()
        }
    }
}

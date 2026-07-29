// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The lightweight themed top bar. Web counterpart: `<npt-app-bar>` /
// `<npt-top-app-bar variant="small|center|medium|large">` · Flutter:
// `NeptuneAppBar`. `small`/`center` keep the display-font title inline in the
// 56dp row; `medium`/`large` reserve the row for leading/actions only and
// stack a bigger headline below it. Exactly ONE title composable is rendered
// per variant — medium/large previously shipped with no accessible title at
// all (see the web fix in nav-rail.ts and the Flutter regression test).
// Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/** Which M3 top-app-bar layout [NeptuneAppBar] renders (web `<npt-top-app-bar
 * variant>`). [Medium]/[Large] stack a larger headline below the action row
 * instead of showing the title inline. */
public enum class NeptuneAppBarVariant { Small, Center, Medium, Large }

/**
 * A themed top bar: an optional [navigationIcon], a display-font [title] and
 * trailing [actions]. Web counterpart: `<npt-app-bar>` / `<npt-top-app-bar>`
 * (nav.ts / nav-rail.ts) · Flutter: `NeptuneAppBar`.
 *
 * [variant] picks the layout — [NeptuneAppBarVariant.Small] (default) and
 * [NeptuneAppBarVariant.Center] keep the title inline in the 56dp row;
 * [NeptuneAppBarVariant.Medium]/[NeptuneAppBarVariant.Large] reserve the row
 * for navigation/actions only and drop a bigger headline below it. Exactly
 * one title is rendered either way, marked as a heading for assistive tech.
 */
@Composable
public fun NeptuneAppBar(
    title: String,
    modifier: Modifier = Modifier,
    variant: NeptuneAppBarVariant = NeptuneAppBarVariant.Small,
    navigationIcon: (@Composable () -> Unit)? = null,
    actions: (@Composable RowScope.() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val type = NeptuneTheme.type
    val display = rememberNeptuneFontFamily(type.display)
    val stacked = variant == NeptuneAppBarVariant.Medium || variant == NeptuneAppBarVariant.Large

    Column(modifier.fillMaxWidth().background(scheme.surface)) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .defaultMinSize(minHeight = 56.dp)
                .padding(horizontal = 16.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (navigationIcon != null) {
                navigationIcon()
                Spacer(Modifier.width(12.dp))
            }
            if (stacked) {
                // The inline title is replaced by the stacked headline below —
                // an empty weighted spacer still reserves the same space for
                // navigation/actions without a second (hidden) title copy.
                Spacer(Modifier.weight(1f))
            } else {
                Text(
                    title,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    textAlign = if (variant == NeptuneAppBarVariant.Center) {
                        TextAlign.Center
                    } else {
                        TextAlign.Start
                    },
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontFamily = display,
                        fontWeight = type.displayFontWeight,
                        color = scheme.onSurface,
                    ),
                    modifier = Modifier
                        .weight(1f)
                        .semantics { heading() },
                )
            }
            if (actions != null) actions()
        }
        if (stacked) {
            val large = variant == NeptuneAppBarVariant.Large
            val base = if (large) {
                MaterialTheme.typography.displayMedium
            } else {
                MaterialTheme.typography.headlineMedium
            }
            Text(
                title,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = base.copy(
                    fontFamily = display,
                    fontWeight = type.displayFontWeight,
                    // Tracking is em-scaled by the headline's font size
                    // (displayMedium 45sp / headlineMedium 28sp).
                    letterSpacing = (type.displayTracking * if (large) 45 else 28).sp,
                    color = scheme.onSurface,
                ),
                modifier = Modifier
                    .padding(start = 16.dp, end = 16.dp, bottom = 24.dp)
                    .semantics { heading() },
            )
        }
    }
}

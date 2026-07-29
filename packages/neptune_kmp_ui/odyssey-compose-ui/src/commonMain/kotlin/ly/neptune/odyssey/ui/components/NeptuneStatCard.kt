// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The compact metric tile: an Odyssey eyebrow label, a big tabular money
// value with an optional unit on the baseline, a signed delta coloured
// success/error, and an optional chart slot (e.g. a sparkline). Web
// counterpart: `<npt-stat-card>` · Flutter: neptune_stat_card.dart.
// Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.identity.NeptuneEyebrow
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/**
 * A compact metric tile (web `<npt-stat-card>`): [label] as the eyebrow,
 * [value] in the brand money style (tabular figures, w700) with an optional
 * [unit] on the baseline, an optional signed [delta] coloured success (or
 * error when it starts with `-`), and an optional [chart] slot below.
 *
 * Web counterpart: `<npt-stat-card>` · Flutter: `NeptuneStatCard`.
 */
@Composable
public fun NeptuneStatCard(
    label: String,
    value: String,
    modifier: Modifier = Modifier,
    unit: String? = null,
    delta: String? = null,
    chart: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val money = NeptuneTheme.moneyStyle(base = typography.titleLarge)
        .copy(color = scheme.onSurface, fontWeight = FontWeight.W700)
    val isDown = (delta ?: "").trimStart().startsWith("-")
    val deltaColor = if (isDown) scheme.error else NeptuneTheme.colors.success

    Column(
        modifier
            .background(scheme.surfaceContainer, NeptuneTheme.shape.rLg)
            .padding(16.dp),
    ) {
        NeptuneEyebrow(label)
        Spacer(Modifier.height(6.dp))
        Row {
            Text(
                NeptuneTheme.formatDigits(value),
                style = money,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f, fill = false).alignByBaseline(),
            )
            if (unit != null) {
                Spacer(Modifier.width(6.dp))
                Text(
                    unit,
                    style = typography.labelLarge.copy(color = scheme.onSurfaceVariant),
                    modifier = Modifier.alignByBaseline(),
                )
            }
        }
        if (delta != null) {
            Spacer(Modifier.height(6.dp))
            Text(
                NeptuneTheme.formatDigits(delta),
                style = typography.labelMedium.copy(color = deltaColor, fontWeight = FontWeight.W700),
            )
        }
        if (chart != null) {
            Spacer(Modifier.height(10.dp))
            chart()
        }
    }
}

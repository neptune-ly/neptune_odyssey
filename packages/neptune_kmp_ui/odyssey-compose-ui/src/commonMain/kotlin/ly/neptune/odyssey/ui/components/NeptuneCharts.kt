// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Data-viz expansion (R4b): branded bar charts for the Insights tier —
//   · NeptuneBarChart     — labelled vertical bars, brand-rounded, optional
//                           highlight of one period
//   · NeptuneCompareBars  — this-vs-last paired bars per category (the web
//                           "vs last month" story)
// Flutter: neptune_charts.dart. Every colour arrives from the theme; bar
// growth animates on the brand standard duration (the Flutter
// AnimatedContainer recipe) and freezes at full height under reduced motion.
// Theme-only, RTL-safe (bars lay out with the reading direction).

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import kotlin.math.abs

/** One bar of a [NeptuneBarChart]. */
@Immutable
public data class NeptuneBarData(
    public val label: String,
    public val value: Float,
)

/** The brand-rounded bar cap: `xs` corners on the top edge only. */
@Composable
private fun barTopShape(): RoundedCornerShape {
    val shape = NeptuneTheme.shape
    return RoundedCornerShape(topStart = shape.xs, topEnd = shape.xs)
}

/**
 * A compact vertical bar chart: brand-rounded bars (top `xs` corners),
 * labels underneath in `labelSmall` `onSurfaceVariant`, optional
 * [highlightIndex] tinted `primary` (others use `secondaryContainer` ink)
 * with a money-style [caption] over the highlighted bar. Bar growth and the
 * highlight tint animate on the brand standard duration; under reduced
 * motion bars render at full height immediately.
 *
 * Flutter: `NeptuneBarChart` (neptune_charts.dart).
 *
 * [caption] formats the highlighted bar's value for the tooltip-style label
 * (e.g. `{ "LYD " + it.toInt() }`).
 */
@Composable
public fun NeptuneBarChart(
    bars: List<NeptuneBarData>,
    modifier: Modifier = Modifier,
    highlightIndex: Int? = null,
    height: Dp = 160.dp,
    caption: ((Float) -> String)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val motion = NeptuneTheme.motion
    val reduced = NeptuneTheme.reducedMotion
    val shape = barTopShape()
    val money = NeptuneTheme.moneyStyle(base = typography.labelSmall).copy(color = scheme.onSurface)
    val labelStyle = typography.labelSmall.copy(color = scheme.onSurfaceVariant)

    var maxV = 0f
    for (b in bars) if (b.value > maxV) maxV = b.value

    Row(
        modifier = modifier.height(height),
        verticalAlignment = Alignment.Bottom,
    ) {
        bars.forEachIndexed { i, bar ->
            if (i > 0) Spacer(Modifier.width(10.dp))
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Bottom,
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                if (i == highlightIndex && caption != null) {
                    Text(
                        text = NeptuneTheme.formatDigits(caption(bar.value)),
                        style = money,
                    )
                    Spacer(Modifier.height(4.dp))
                }
                // The Flutter AnimatedContainer: brand standard duration,
                // linear curve; reduced motion snaps to the target height.
                val target = if (maxV == 0f) 0.dp else (height - 46.dp) * (bar.value / maxV)
                val barHeight by animateDpAsState(
                    targetValue = target,
                    animationSpec = if (reduced) snap() else tween(motion.standardMs, easing = LinearEasing),
                    label = "barGrow",
                )
                val barColor by animateColorAsState(
                    targetValue = if (i == highlightIndex) scheme.primary else scheme.secondaryContainer,
                    animationSpec = if (reduced) snap() else tween(motion.standardMs, easing = LinearEasing),
                    label = "barTint",
                )
                Box(
                    Modifier
                        .fillMaxWidth()
                        .height(barHeight)
                        .background(barColor, shape),
                )
                Spacer(Modifier.height(6.dp))
                Text(
                    text = bar.label,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = labelStyle,
                )
            }
        }
    }
}

/** One category of a [NeptuneCompareBars]. */
@Immutable
public data class NeptuneCompareData(
    public val label: String,
    public val current: Float,
    public val previous: Float,
)

/**
 * Paired-period comparison ("vs last month"): per category, the previous
 * period as a muted `outlineVariant` bar behind the current period in
 * `primary`, with a legend row and a delta chip summarising the change
 * (spend down = `successContainer`, up = `errorContainer`).
 *
 * Flutter: `NeptuneCompareBars` (neptune_charts.dart).
 */
@Composable
public fun NeptuneCompareBars(
    data: List<NeptuneCompareData>,
    modifier: Modifier = Modifier,
    currentLabel: String = "This month",
    previousLabel: String = "Last month",
    height: Dp = 170.dp,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val typography = MaterialTheme.typography
    val shape = barTopShape()
    val labelStyle = typography.labelSmall.copy(color = scheme.onSurfaceVariant)

    var maxV = 0f
    var curSum = 0f
    var prevSum = 0f
    for (d in data) {
        if (d.current > maxV) maxV = d.current
        if (d.previous > maxV) maxV = d.previous
        curSum += d.current
        prevSum += d.previous
    }
    val deltaPct = if (prevSum == 0f) 0f else ((curSum - prevSum) / prevSum) * 100f
    val down = deltaPct <= 0f

    Column(modifier) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            LegendDot(scheme.primary, currentLabel, labelStyle)
            Spacer(Modifier.width(14.dp))
            LegendDot(scheme.outlineVariant, previousLabel, labelStyle)
            Spacer(Modifier.weight(1f))
            Box(
                Modifier
                    .background(
                        if (down) npt.successContainer else scheme.errorContainer,
                        NeptuneTheme.shape.rFull,
                    )
                    .padding(horizontal = 10.dp, vertical = 4.dp),
            ) {
                Text(
                    text = NeptuneTheme.formatDigits(
                        "${if (down) "−" else "+"}${nptFixed1(abs(deltaPct))}%",
                    ),
                    style = typography.labelSmall.copy(
                        fontWeight = FontWeight.W700,
                        color = if (down) npt.onSuccessContainer else scheme.onErrorContainer,
                    ),
                )
            }
        }
        Spacer(Modifier.height(12.dp))
        Row(
            modifier = Modifier.height(height),
            verticalAlignment = Alignment.Bottom,
        ) {
            data.forEachIndexed { i, d ->
                if (i > 0) Spacer(Modifier.width(12.dp))
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.Bottom,
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(height - 26.dp),
                        contentAlignment = Alignment.BottomCenter,
                    ) {
                        // previous period — muted, slightly wider …
                        CompareBar(
                            fraction = if (maxV == 0f) 0f else (d.previous / maxV).coerceIn(0.02f, 1f),
                            color = scheme.outlineVariant,
                            inset = 2.dp,
                            shape = shape,
                        )
                        // … current period — primary, narrower on top.
                        CompareBar(
                            fraction = if (maxV == 0f) 0f else (d.current / maxV).coerceIn(0.02f, 1f),
                            color = scheme.primary,
                            inset = 9.dp,
                            shape = shape,
                        )
                    }
                    Spacer(Modifier.height(6.dp))
                    Text(
                        text = d.label,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        style = labelStyle,
                    )
                }
            }
        }
    }
}

@Composable
private fun BoxScope.CompareBar(
    fraction: Float,
    color: Color,
    inset: Dp,
    shape: RoundedCornerShape,
) {
    Box(
        Modifier
            .align(Alignment.BottomCenter)
            .fillMaxWidth()
            .fillMaxHeight(fraction)
            .padding(horizontal = inset)
            .background(color, shape),
    )
}

@Composable
private fun LegendDot(
    color: Color,
    label: String,
    style: TextStyle,
) {
    Box(Modifier.size(8.dp).background(color, NeptuneTheme.shape.rFull))
    Spacer(Modifier.width(6.dp))
    Text(label, style = style)
}

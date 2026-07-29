// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Data-visualisation primitives. Web counterpart: data-viz.ts
// (`<npt-sparkline>`, `<npt-donut>`, `<npt-limit-meter>`, `<npt-trend>`) ·
// Flutter: neptune_data_viz.dart. Charts paint on Canvas; every colour is
// read from the theme in composition and passed into the draw phase. Money
// and metric text uses the brand money style (tabular figures, numerals
// lever applied). Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptVizGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import kotlin.math.abs
import kotlin.math.min
import kotlin.math.round

/** The Dart `toStringAsFixed(1)` analog for the data-viz percent labels. */
internal fun nptFixed1(value: Float): String {
    val scaled = round(value * 10f).toInt()
    val magnitude = abs(scaled)
    val sign = if (scaled < 0) "-" else ""
    return "$sign${magnitude / 10}.${magnitude % 10}"
}

/**
 * An inline line sparkline (web `<npt-sparkline>`): a smooth polyline with no
 * axes, normalised to its box (Catmull-Rom smoothed through the points, 2dp
 * round stroke, 2dp inset). Stroke defaults to the scheme `primary`; fewer
 * than two points draws a flat midline (the web fallback).
 *
 * Web counterpart: `<npt-sparkline>` · Flutter: `NeptuneSparkline`.
 */
@Composable
public fun NeptuneSparkline(
    points: List<Float>,
    modifier: Modifier = Modifier,
    color: Color? = null,
    height: Dp = 36.dp,
) {
    val stroke = color ?: MaterialTheme.colorScheme.primary

    Canvas(modifier.fillMaxWidth().height(height)) {
        val pad = 2.dp.toPx()
        val strokeWidth = 2.dp.toPx()
        val w = size.width
        val h = size.height

        // Fewer than two points → flat midline (matches web fallback).
        if (points.size < 2) {
            drawLine(
                color = stroke,
                start = Offset(pad, h / 2f),
                end = Offset(w - pad, h / 2f),
                strokeWidth = strokeWidth,
                cap = StrokeCap.Round,
            )
            return@Canvas
        }

        var minV = points.first()
        var maxV = points.first()
        for (v in points) {
            if (v < minV) minV = v
            if (v > maxV) maxV = v
        }
        val span = if (maxV - minV == 0f) 1f else maxV - minV
        val stepX = (w - pad * 2f) / (points.size - 1)

        val dx = FloatArray(points.size)
        val dy = FloatArray(points.size)
        for (i in points.indices) {
            dx[i] = pad + i * stepX
            dy[i] = pad + (h - pad * 2f) * (1f - (points[i] - minV) / span)
        }

        // Smooth Catmull-Rom → cubic Bézier path through the normalised points.
        val path = Path().apply {
            moveTo(dx[0], dy[0])
            for (i in 0 until points.size - 1) {
                val p0 = if (i == 0) 0 else i - 1
                val p3 = if (i + 2 < points.size) i + 2 else points.size - 1
                val c1x = dx[i] + (dx[i + 1] - dx[p0]) / 6f
                val c1y = dy[i] + (dy[i + 1] - dy[p0]) / 6f
                val c2x = dx[i + 1] - (dx[p3] - dx[i]) / 6f
                val c2y = dy[i + 1] - (dy[p3] - dy[i]) / 6f
                cubicTo(c1x, c1y, c2x, c2y, dx[i + 1], dy[i + 1])
            }
        }
        drawPath(
            path,
            stroke,
            style = Stroke(width = strokeWidth, cap = StrokeCap.Round, join = StrokeJoin.Round),
        )
    }
}

/**
 * A proportional ring/donut chart (web `<npt-donut>`): each value becomes an
 * arc on a `surfaceContainerHighest` track, starting at 12 o'clock and
 * sweeping clockwise (the web rotates its SVG -90°). Default segment colours
 * are `primary / secondary / tertiary / success`; ring thickness is 14% of
 * [size]. An optional [centerLabel] sits in the hole in the money style.
 *
 * Web counterpart: `<npt-donut>` · Flutter: `NeptuneDonut`.
 */
@Composable
public fun NeptuneDonut(
    segments: List<Float>,
    modifier: Modifier = Modifier,
    colors: List<Color>? = null,
    size: Dp = 96.dp,
    centerLabel: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    // The default success role lives on NeptuneTheme.colors, not the scheme.
    val segColors = colors ?: listOf(
        scheme.primary,
        scheme.secondary,
        scheme.tertiary,
        NeptuneTheme.colors.success,
    )
    val track = scheme.surfaceContainerHighest
    val thicknessDp = size * 0.14f
    val money = NeptuneTheme.moneyStyle(base = typography.titleMedium)
        .copy(color = scheme.onSurface, fontWeight = FontWeight.W700)

    Box(modifier.size(size), contentAlignment = Alignment.Center) {
        Canvas(Modifier.fillMaxSize()) {
            val thickness = thicknessDp.toPx()
            val center = Offset(this.size.width / 2f, this.size.height / 2f)
            val radius = (min(this.size.width, this.size.height) - thickness) / 2f

            drawCircle(track, radius = radius, center = center, style = Stroke(thickness))

            val valid = segments.map { if (it.isFinite() && it > 0f) it else 0f }
            val total = valid.sum()
            if (total <= 0f) return@Canvas

            // Start at 12 o'clock, sweep clockwise.
            val topLeft = Offset(center.x - radius, center.y - radius)
            val arcSize = Size(radius * 2f, radius * 2f)
            var start = -90f
            for (i in valid.indices) {
                if (valid[i] <= 0f) continue
                val sweep = (valid[i] / total) * 360f
                drawArc(
                    color = segColors[i % segColors.size],
                    startAngle = start,
                    sweepAngle = sweep,
                    useCenter = false,
                    topLeft = topLeft,
                    size = arcSize,
                    style = Stroke(thickness, cap = StrokeCap.Butt),
                )
                start += sweep
            }
        }
        if (centerLabel != null) {
            Text(
                text = NeptuneTheme.formatDigits(centerLabel),
                textAlign = TextAlign.Center,
                style = money,
            )
        }
    }
}

/**
 * A labelled progress meter (web `<npt-limit-meter>`): a header row with the
 * [label] and a trailing [amount] in the money style, then an 8dp rounded
 * `surfaceContainerHighest` track with a filled bar. [value] is 0..1; [warn]
 * flips the fill from `primary` to `error`. The amount is flexible and
 * ellipsised so narrow (≤430dp) layouts never overflow.
 *
 * Web counterpart: `<npt-limit-meter>` · Flutter: `NeptuneLimitMeter`.
 */
@Composable
public fun NeptuneLimitMeter(
    value: Float,
    label: String,
    modifier: Modifier = Modifier,
    amount: String? = null,
    warn: Boolean = false,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val money = NeptuneTheme.moneyStyle(base = typography.labelLarge)
        .copy(color = scheme.onSurfaceVariant)

    val pct = if (value.isNaN()) 0f else value.coerceIn(0f, 1f)
    val fill = if (warn) scheme.error else scheme.primary

    Column(modifier) {
        Row(verticalAlignment = Alignment.Bottom) {
            Text(
                text = label,
                modifier = Modifier.weight(1f),
                style = typography.labelLarge.copy(color = scheme.onSurface),
            )
            if (amount != null) {
                Spacer(Modifier.width(12.dp))
                Text(
                    text = NeptuneTheme.formatDigits(amount),
                    modifier = Modifier.weight(1f, fill = false),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    textAlign = TextAlign.End,
                    style = money,
                )
            }
        }
        Spacer(Modifier.height(8.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(8.dp)
                .clip(NeptuneTheme.shape.rFull)
                .background(scheme.surfaceContainerHighest),
            contentAlignment = Alignment.CenterStart,
        ) {
            Box(
                Modifier
                    .fillMaxWidth(pct)
                    .fillMaxHeight()
                    .background(fill, NeptuneTheme.shape.rFull),
            )
        }
    }
}

/**
 * A small signed-percent trend chip (web `<npt-trend>`): an up/down arrow
 * plus the value on a `secondaryContainer` pill, coloured with the `success`
 * role when up and `error` when down. Direction follows [down] if given,
 * else the sign of [value].
 *
 * Web counterpart: `<npt-trend>` · Flutter: `NeptuneTrend`.
 */
@Composable
public fun NeptuneTrend(
    value: Float,
    modifier: Modifier = Modifier,
    down: Boolean? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    val isDown = down ?: (value < 0f)
    val fg = if (isDown) scheme.error else NeptuneTheme.colors.success
    val arrow = if (isDown) NptVizGlyphs.arrowDownward else NptVizGlyphs.arrowUpward
    val sign = if (value > 0f) "+" else ""
    val label = "$sign${nptFixed1(value)}%"
    val money = NeptuneTheme.moneyStyle(base = typography.labelMedium)
        .copy(color = fg, fontWeight = FontWeight.W700)

    Row(
        modifier = modifier
            .background(scheme.secondaryContainer, NeptuneTheme.shape.rFull)
            .padding(horizontal = 8.dp, vertical = 2.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(arrow, contentDescription = null, modifier = Modifier.size(14.dp), tint = fg)
        Spacer(Modifier.width(4.dp))
        Text(NeptuneTheme.formatDigits(label), style = money)
    }
}

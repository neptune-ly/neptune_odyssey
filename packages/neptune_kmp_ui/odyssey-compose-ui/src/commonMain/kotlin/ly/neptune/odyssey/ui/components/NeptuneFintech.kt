// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Premium fintech components: a tonal insight card, an FX-rate card, a budget
// ring, a stacked spend breakdown, and a credit-score gauge. Web counterparts:
// `<npt-insight-card>` / `<npt-fx-card>` / `<npt-budget-ring>` /
// `<npt-spend-breakdown>` / `<npt-credit-gauge>` · Flutter:
// neptune_fintech.dart. Charts paint on explicitly sized canvases — the
// credit gauge derives its arc geometry from its own [size] parameter, never
// from parent constraints (the 2.5.2 out-of-bounds fix). Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.glyphs.NptFinanceGlyphs
import ly.neptune.odyssey.ui.glyphs.NptFintechGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import kotlin.math.abs
import kotlin.math.roundToInt

/** Compact thousands-grouped amount without forcing a currency symbol (the
 * Dart `_format` recipe, shared by the budget ring and spend legend). */
private fun formatAmount(v: Double): String {
    if (!v.isFinite()) return "0"
    val neg = v < 0
    val absV = abs(v)
    val whole = absV.toLong()
    val digits = whole.toString()
    val buf = StringBuilder()
    for (i in digits.indices) {
        if (i > 0 && (digits.length - i) % 3 == 0) buf.append(',')
        buf.append(digits[i])
    }
    val frac = absV - whole
    if (frac > 0) {
        val cents = (frac * 100).roundToInt().toString().padStart(2, '0')
        buf.append('.').append(cents)
    }
    return if (neg) "-$buf" else buf.toString()
}

/**
 * A tinted insight surface: a leading 24dp [icon] slot, a `titleSmall`
 * title, a `bodyMedium` message, and an optional text-button action. The
 * [tone] picks a tonal container fill with its matching on-colour: neutral →
 * `secondaryContainer`, success → the Neptune success container, warning →
 * `tertiaryContainer`, danger → `errorContainer`.
 *
 * Web counterpart: `<npt-insight-card>` · Flutter: `NeptuneInsightCard`.
 */
@Composable
public fun NeptuneInsightCard(
    icon: @Composable () -> Unit,
    title: String,
    message: String,
    modifier: Modifier = Modifier,
    actionLabel: String? = null,
    onAction: (() -> Unit)? = null,
    tone: NeptuneStatusTone = NeptuneStatusTone.Neutral,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val typography = MaterialTheme.typography
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    // Resolve the container fill + matching on-colour per tone.
    val bg = when (tone) {
        NeptuneStatusTone.Success -> npt.successContainer
        NeptuneStatusTone.Warning -> scheme.tertiaryContainer
        NeptuneStatusTone.Danger -> scheme.errorContainer
        NeptuneStatusTone.Neutral -> scheme.secondaryContainer
    }
    val fg = when (tone) {
        NeptuneStatusTone.Success -> npt.onSuccessContainer
        NeptuneStatusTone.Warning -> scheme.onTertiaryContainer
        NeptuneStatusTone.Danger -> scheme.onErrorContainer
        NeptuneStatusTone.Neutral -> scheme.onSecondaryContainer
    }

    Row(
        modifier = modifier
            .clip(NeptuneTheme.shape.rLg)
            .background(bg)
            .padding(horizontal = 16.dp, vertical = 16.dp),
        verticalAlignment = Alignment.Top,
    ) {
        CompositionLocalProvider(LocalContentColor provides fg) {
            Box(Modifier.size(24.dp), contentAlignment = Alignment.Center) { icon() }
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(title, style = typography.titleSmall.copy(color = fg))
            Spacer(Modifier.height(4.dp))
            Text(message, style = typography.bodyMedium.copy(color = fg.copy(alpha = 0.85f)))
            if (!actionLabel.isNullOrEmpty()) {
                Spacer(Modifier.height(8.dp))
                TextButton(
                    onClick = {
                        feedback.trigger(NptFeedbackCue.Tap, haptics)
                        onAction?.invoke()
                    },
                    enabled = onAction != null,
                    shape = NeptuneTheme.shape.rFull,
                    colors = ButtonDefaults.textButtonColors(contentColor = fg),
                    contentPadding = PaddingValues(horizontal = 12.dp, vertical = 8.dp),
                    modifier = Modifier.defaultMinSize(minHeight = 40.dp),
                ) {
                    Text(actionLabel)
                }
            }
        }
    }
}

/**
 * An exchange-rate card: a `FROM → TO` header with a swap glyph, the [rate]
 * rendered large via [NeptuneTheme.moneyStyle], and an optional change pill.
 * When [up] the pill tints with the Neptune success role and a trending-up
 * arrow; otherwise it tints with `error` (down arrow).
 *
 * Web counterpart: `<npt-fx-card>` · Flutter: `NeptuneFxCard`.
 */
@Composable
public fun NeptuneFxCard(
    fromCurrency: String,
    toCurrency: String,
    rate: String,
    modifier: Modifier = Modifier,
    change: String? = null,
    up: Boolean = true,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rLg

    val pairStyle = typography.titleSmall.copy(color = scheme.onSurface)
    val rateStyle = NeptuneTheme.moneyStyle(base = typography.displaySmall)
        .copy(color = scheme.onSurface)
    val accent = if (up) npt.success else scheme.error

    Column(
        modifier = modifier
            .clip(shape)
            .background(scheme.surfaceContainerLow)
            .border(1.dp, scheme.outlineVariant, shape)
            .padding(horizontal = 20.dp, vertical = 18.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = fromCurrency,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = pairStyle,
                modifier = Modifier.weight(1f, fill = false),
            )
            Spacer(Modifier.width(8.dp))
            Icon(
                NptFinanceGlyphs.swapExchange,
                contentDescription = null,
                tint = scheme.onSurfaceVariant,
                modifier = Modifier.size(18.dp),
            )
            Spacer(Modifier.width(8.dp))
            Text(
                text = toCurrency,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = pairStyle,
                modifier = Modifier.weight(1f, fill = false),
            )
        }
        Spacer(Modifier.height(12.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = NeptuneTheme.formatDigits(rate),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = rateStyle,
                modifier = Modifier.weight(1f),
            )
            if (!change.isNullOrEmpty()) {
                Spacer(Modifier.width(12.dp))
                Row(
                    modifier = Modifier
                        .clip(NeptuneTheme.shape.rFull)
                        .background(accent.copy(alpha = 0.14f))
                        .padding(horizontal = 10.dp, vertical = 4.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(
                        if (up) NptFintechGlyphs.trendingUp else NptFintechGlyphs.trendingDown,
                        contentDescription = null,
                        tint = accent,
                        modifier = Modifier.size(16.dp),
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        text = NeptuneTheme.formatDigits(change),
                        style = typography.labelMedium.copy(
                            color = accent,
                            fontWeight = FontWeight.W700,
                        ),
                    )
                }
            }
        }
    }
}

/**
 * A budget progress ring: a canvas arc that fills `spent / limit`, switching
 * from `primary` to `error` when over budget. The [spent] amount (money
 * style) and [label] sit centred. The arc clamps to 0..1 but the real
 * numbers are still shown.
 *
 * Web counterpart: `<npt-budget-ring>` · Flutter: `NeptuneBudgetRing`.
 */
@Composable
public fun NeptuneBudgetRing(
    spent: Double,
    limit: Double,
    label: String,
    modifier: Modifier = Modifier,
    size: Dp = 140.dp,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    val safeLimit = if (limit.isFinite() && limit > 0) limit else 0.0
    val raw = if (safeLimit == 0.0) 0.0 else spent / safeLimit
    val fraction = if (raw.isNaN()) 0f else raw.coerceIn(0.0, 1.0).toFloat()
    val over = safeLimit > 0 && spent > safeLimit
    val arcColor = if (over) scheme.error else scheme.primary
    val track = scheme.surfaceContainerHighest

    val amountStyle = NeptuneTheme.moneyStyle(base = typography.titleLarge)
        .copy(color = scheme.onSurface, fontWeight = FontWeight.W700)
    val labelStyle = typography.bodySmall.copy(color = scheme.onSurfaceVariant)

    // The outer Box loosens any tight incoming constraints, so the ring
    // always paints at its own [size] — never beyond its bounds.
    Box(modifier, contentAlignment = Alignment.Center) {
        Box(Modifier.size(size), contentAlignment = Alignment.Center) {
            Canvas(Modifier.matchParentSize()) {
                // Ring thickness rides the [size] parameter (the Dart
                // `size * 0.1`), not the parent-imposed canvas size.
                val thickness = size.toPx() * 0.1f
                val radius = (this.size.minDimension - thickness) / 2f
                val center = Offset(this.size.width / 2f, this.size.height / 2f)
                drawCircle(
                    color = track,
                    radius = radius,
                    center = center,
                    style = Stroke(width = thickness, cap = StrokeCap.Round),
                )
                if (fraction > 0f) {
                    // Start at 12 o'clock, sweep clockwise.
                    drawArc(
                        color = arcColor,
                        startAngle = -90f,
                        sweepAngle = 360f * fraction,
                        useCenter = false,
                        topLeft = Offset(center.x - radius, center.y - radius),
                        size = Size(radius * 2f, radius * 2f),
                        style = Stroke(width = thickness, cap = StrokeCap.Round),
                    )
                }
            }
            Column(
                modifier = Modifier.padding(horizontal = size * 0.18f),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text(
                    text = NeptuneTheme.formatDigits(formatAmount(spent)),
                    textAlign = TextAlign.Center,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = amountStyle,
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    text = label,
                    textAlign = TextAlign.Center,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    style = labelStyle,
                )
            }
        }
    }
}

/** One slice of a [NeptuneSpendBreakdown]: a [label], an [amount], and an
 * optional 16dp [icon] slot shown in the legend. */
@Immutable
public class NeptuneSpendSlice(
    public val label: String,
    public val amount: Double,
    public val icon: (@Composable () -> Unit)? = null,
)

/**
 * A spend breakdown: a single horizontal stacked bar where each
 * [NeptuneSpendSlice] is a proportional segment, above a legend of dot +
 * label + amount (money style, end-aligned). Segment colours cycle through
 * `primary / secondary / tertiary / success`.
 *
 * Web counterpart: `<npt-spend-breakdown>` · Flutter: `NeptuneSpendBreakdown`.
 */
@Composable
public fun NeptuneSpendBreakdown(
    slices: List<NeptuneSpendSlice>,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val typography = MaterialTheme.typography
    val barShape = NeptuneTheme.shape.rFull

    val palette = listOf(scheme.primary, scheme.secondary, scheme.tertiary, npt.success)
    val money = NeptuneTheme.moneyStyle(base = typography.labelLarge)
        .copy(color = scheme.onSurface)

    var total = 0.0
    for (s in slices) {
        if (s.amount.isFinite() && s.amount > 0) total += s.amount
    }
    val hasSegments = total > 0

    Column(modifier) {
        // Stacked bar: each segment flexes by its share of the total.
        Row(
            Modifier
                .fillMaxWidth()
                .height(12.dp)
                .clip(barShape)
                .then(if (hasSegments) Modifier else Modifier.background(scheme.surfaceContainerHighest)),
        ) {
            slices.forEachIndexed { i, slice ->
                if (slice.amount.isFinite() && slice.amount > 0) {
                    Box(
                        Modifier
                            .weight(slice.amount.toFloat())
                            .fillMaxHeight()
                            .background(palette[i % palette.size].copy(alpha = 0.9f)),
                    )
                }
            }
        }
        Spacer(Modifier.height(16.dp))
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            slices.forEachIndexed { i, slice ->
                SpendLegendRow(
                    slice = slice,
                    color = palette[i % palette.size],
                    total = total,
                    money = money,
                )
            }
        }
    }
}

/** A single legend line: dot + (optional icon) + label, with the amount and
 * a faint share percentage end-aligned. */
@Composable
private fun SpendLegendRow(
    slice: NeptuneSpendSlice,
    color: Color,
    total: Double,
    money: TextStyle,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val share = if (total > 0) slice.amount / total else 0.0
    val pct = (share * 100).roundToInt()

    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            Modifier
                .size(10.dp)
                .clip(NeptuneTheme.shape.rFull)
                .background(color),
        )
        Spacer(Modifier.width(10.dp))
        if (slice.icon != null) {
            CompositionLocalProvider(LocalContentColor provides scheme.onSurfaceVariant) {
                Box(Modifier.size(16.dp), contentAlignment = Alignment.Center) {
                    slice.icon.invoke()
                }
            }
            Spacer(Modifier.width(6.dp))
        }
        Text(
            text = slice.label,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = typography.bodyMedium.copy(color = scheme.onSurface),
            modifier = Modifier.weight(1f),
        )
        Spacer(Modifier.width(12.dp))
        Text(
            text = NeptuneTheme.formatDigits("$pct%"),
            style = typography.labelMedium.copy(color = scheme.onSurfaceVariant),
        )
        Spacer(Modifier.width(12.dp))
        Text(
            text = NeptuneTheme.formatDigits(formatAmount(slice.amount)),
            textAlign = TextAlign.End,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = money,
        )
    }
}

/**
 * A credit-score gauge: a 240° arc with an `outlineVariant` track and a
 * `primary` fill up to the score's fraction of [min]..[max]. The [score]
 * sits large in the centre (display type) with an optional [band] label
 * (e.g. "Good") below.
 *
 * The gauge sizes its canvas explicitly from [size] and derives the arc
 * geometry from that same parameter — under tight/stretched parent
 * constraints it centres itself and never paints outside its bounds (the
 * 2.5.2 fix).
 *
 * Web counterpart: `<npt-credit-gauge>` · Flutter: `NeptuneCreditScoreGauge`.
 */
@Composable
public fun NeptuneCreditScoreGauge(
    score: Int,
    modifier: Modifier = Modifier,
    min: Int = 300,
    max: Int = 850,
    band: String? = null,
    size: Dp = 180.dp,
) {
    val scheme = MaterialTheme.colorScheme
    val type = NeptuneTheme.type
    val typography = MaterialTheme.typography

    val span = if (max - min == 0) 1 else max - min
    val fraction = ((score - min).toFloat() / span).coerceIn(0f, 1f)

    // displaySmall already rides the brand display face at the brand weight;
    // the Dart recipe additionally applies the raw display tracking.
    val scoreStyle = typography.displaySmall.copy(
        letterSpacing = type.displayTracking.sp,
        color = scheme.onSurface,
    )
    val bandStyle = typography.titleSmall.copy(color = scheme.onSurfaceVariant)

    // The outer Box loosens incoming tight constraints (the Flutter `Center`
    // fix), so the gauge always lays out at its own [size].
    Box(modifier, contentAlignment = Alignment.Center) {
        Box(
            // The 240° arc leaves a gap at the bottom; trim the box accordingly.
            modifier = Modifier.size(width = size, height = size * 0.82f),
            contentAlignment = Alignment.Center,
        ) {
            Canvas(Modifier.matchParentSize()) {
                // Arc geometry from the [size] PARAMETER, never the canvas
                // constraints — a stretched canvas only recentres the arc.
                val d = size.toPx()
                val thickness = d * 0.09f
                val radius = (d - thickness) / 2f
                val center = Offset(this.size.width / 2f, radius + thickness / 2f)
                val topLeft = Offset(center.x - radius, center.y - radius)
                val arcSize = Size(radius * 2f, radius * 2f)
                // A 240° gauge: a 120° gap centred at the bottom — start at
                // 150° and sweep 240° clockwise.
                drawArc(
                    color = scheme.outlineVariant,
                    startAngle = 150f,
                    sweepAngle = 240f,
                    useCenter = false,
                    topLeft = topLeft,
                    size = arcSize,
                    style = Stroke(width = thickness, cap = StrokeCap.Round),
                )
                if (fraction > 0f) {
                    drawArc(
                        color = scheme.primary,
                        startAngle = 150f,
                        sweepAngle = 240f * fraction,
                        useCenter = false,
                        topLeft = topLeft,
                        size = arcSize,
                        style = Stroke(width = thickness, cap = StrokeCap.Round),
                    )
                }
            }
            Column(
                modifier = Modifier.padding(bottom = size * 0.04f),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text(NeptuneTheme.formatDigits("$score"), style = scoreStyle)
                if (!band.isNullOrEmpty()) {
                    Spacer(Modifier.height(2.dp))
                    Text(band, style = bandStyle)
                }
            }
        }
    }
}

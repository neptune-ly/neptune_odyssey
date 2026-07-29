// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The transfer-flow building blocks: the progress stepper, the transfer
// review summary card, the selectable payment-method row and the selectable
// beneficiary tile. Web counterparts: `<npt-stepper>` / `<npt-transfer-review>`
// / `<npt-method-row>` / `<npt-beneficiary-tile>` · Flutter:
// neptune_money_movement.dart. Theme-only, RTL-safe, ≥48dp targets.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxSize
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
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptGlyphs
import ly.neptune.odyssey.ui.glyphs.NptStatusGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/**
 * A horizontal progress stepper: numbered nodes joined by connector lines,
 * with a label under each. Done steps are filled `primary` (check glyph),
 * the active step is an outlined primary ring on `surface`, and future steps
 * use `surfaceContainerHighest` / `outlineVariant`.
 *
 * Web counterpart: `<npt-stepper>` · Flutter: `NeptuneStepper`.
 */
@Composable
public fun NeptuneStepper(
    steps: List<String>,
    active: Int,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape

    Row(modifier, verticalAlignment = Alignment.Top) {
        steps.forEachIndexed { i, step ->
            val done = i < active
            val isActive = i == active

            // Node colours by state; the active node reads as an outlined
            // ring (primary outline, hollow surface fill).
            val fill = if (done || isActive) scheme.primary else scheme.surfaceContainerHighest
            val borderColor = if (done || isActive) scheme.primary else scheme.outlineVariant
            val fg = if (done || isActive) scheme.onPrimary else scheme.onSurfaceVariant

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Box(
                    modifier = Modifier
                        .size(32.dp)
                        .clip(shape.rFull)
                        .background(if (isActive) scheme.surface else fill)
                        .border(2.dp, borderColor, shape.rFull),
                    contentAlignment = Alignment.Center,
                ) {
                    if (done) {
                        Icon(
                            NptGlyphs.check,
                            contentDescription = null,
                            tint = fg,
                            modifier = Modifier.size(18.dp),
                        )
                    } else {
                        Text(
                            text = NeptuneTheme.formatDigits("${i + 1}"),
                            style = NeptuneTheme.moneyStyle(base = typography.labelLarge).copy(
                                color = if (isActive) scheme.primary else fg,
                                fontWeight = FontWeight.W600,
                            ),
                        )
                    }
                }
                Spacer(Modifier.height(8.dp))
                Text(
                    text = step,
                    textAlign = TextAlign.Center,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    style = typography.labelSmall.copy(
                        color = if (isActive) scheme.onSurface else scheme.onSurfaceVariant,
                        fontWeight = if (isActive) FontWeight.W600 else FontWeight.W500,
                    ),
                    modifier = Modifier.width(80.dp),
                )
            }

            // Connector between this node and the next.
            if (i < steps.lastIndex) {
                Box(
                    Modifier
                        .weight(1f)
                        .padding(top = 15.dp, start = 4.dp, end = 4.dp)
                        .height(2.dp)
                        .clip(shape.rXs)
                        .background(if (done) scheme.primary else scheme.outlineVariant),
                )
            }
        }
    }
}

/**
 * A transfer review card: a `surfaceContainer` card with key/value rows
 * (From, To, Amount, optional Fee) and a highlighted, bold Total rendered in
 * the money style with an optional trailing [currency] code.
 *
 * Web counterpart: `<npt-transfer-review>` · Flutter: `NeptuneTransferReview`.
 */
@Composable
public fun NeptuneTransferReview(
    fromLabel: String,
    toLabel: String,
    amount: String,
    modifier: Modifier = Modifier,
    fee: String? = null,
    total: String? = null,
    currency: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val totalStyle = NeptuneTheme.moneyStyle(base = typography.titleLarge)
        .copy(color = scheme.primary, fontWeight = FontWeight.W700)

    Column(
        modifier = modifier
            .clip(NeptuneTheme.shape.rLg)
            .background(scheme.surfaceContainer)
            .padding(20.dp),
    ) {
        ReviewRow(label = "From", value = fromLabel)
        Spacer(Modifier.height(12.dp))
        ReviewRow(label = "To", value = toLabel)
        Spacer(Modifier.height(12.dp))
        ReviewRow(label = "Amount", value = amount, numeric = true)
        if (fee != null) {
            Spacer(Modifier.height(12.dp))
            ReviewRow(label = "Fee", value = fee, numeric = true)
        }
        if (total != null) {
            Spacer(Modifier.height(16.dp))
            Box(Modifier.fillMaxWidth().height(1.dp).background(scheme.outlineVariant))
            Spacer(Modifier.height(16.dp))
            Row {
                Text(
                    text = "Total",
                    style = typography.labelLarge.copy(
                        color = scheme.onSurface,
                        fontWeight = FontWeight.W600,
                    ),
                    modifier = Modifier.weight(1f).alignByBaseline(),
                )
                Spacer(Modifier.width(16.dp))
                Text(
                    text = NeptuneTheme.formatDigits(total),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = totalStyle,
                    modifier = Modifier.weight(1f, fill = false).alignByBaseline(),
                )
                if (currency != null) {
                    Spacer(Modifier.width(4.dp))
                    Text(
                        text = currency,
                        style = typography.bodyMedium.copy(
                            color = scheme.primary.copy(alpha = 0.85f),
                        ),
                        modifier = Modifier.alignByBaseline(),
                    )
                }
            }
        }
    }
}

/** One key/value line in a [NeptuneTransferReview]. Numeric values use the
 * money style for column-aligned figures. */
@Composable
private fun ReviewRow(
    label: String,
    value: String,
    numeric: Boolean = false,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val valueStyle = if (numeric) {
        NeptuneTheme.moneyStyle(base = typography.bodyLarge).copy(color = scheme.onSurface)
    } else {
        typography.bodyLarge.copy(color = scheme.onSurface)
    }

    Row {
        Text(
            text = label,
            style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
            modifier = Modifier.alignByBaseline(),
        )
        Spacer(Modifier.width(16.dp))
        Text(
            text = if (numeric) NeptuneTheme.formatDigits(value) else value,
            textAlign = TextAlign.End,
            style = valueStyle,
            modifier = Modifier.weight(1f).alignByBaseline(),
        )
    }
}

/**
 * A selectable payment-method row: a leading rounded 24dp [icon] slot on a
 * `secondaryContainer` tile, a title with optional subtitle, and a trailing
 * radio that fills `primary` with a check when [selected]. The whole row is
 * tappable and at least 64dp tall.
 *
 * Web counterpart: `<npt-method-row>` · Flutter: `NeptuneMethodRow`.
 */
@Composable
public fun NeptuneMethodRow(
    icon: @Composable () -> Unit,
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    selected: Boolean = false,
    onTap: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    val clickableModifier = if (onTap != null) {
        Modifier.clickable {
            feedback.trigger(NptFeedbackCue.Tap, haptics)
            onTap()
        }
    } else {
        Modifier
    }

    Row(
        modifier = modifier
            .clip(shape.rMd)
            .background(scheme.surfaceContainerLowest)
            .then(clickableModifier)
            .border(
                width = if (selected) 2.dp else 1.dp,
                color = if (selected) scheme.primary else scheme.outlineVariant,
                shape = shape.rMd,
            )
            .defaultMinSize(minHeight = 64.dp)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(shape.rSm)
                .background(scheme.secondaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            CompositionLocalProvider(LocalContentColor provides scheme.onSecondaryContainer) {
                Box(Modifier.size(20.dp), contentAlignment = Alignment.Center) { icon() }
            }
        }
        Spacer(Modifier.width(16.dp))
        Column(Modifier.weight(1f)) {
            Text(
                text = title,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = typography.bodyLarge.copy(
                    color = scheme.onSurface,
                    fontWeight = FontWeight.W600,
                ),
            )
            if (subtitle != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    text = subtitle,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                )
            }
        }
        Spacer(Modifier.width(12.dp))
        // The trailing radio: fills primary with a check when selected, an
        // empty outlined circle otherwise.
        Box(
            modifier = Modifier
                .size(24.dp)
                .clip(shape.rFull)
                .then(if (selected) Modifier.background(scheme.primary) else Modifier)
                .border(
                    width = 2.dp,
                    color = if (selected) scheme.primary else scheme.outline,
                    shape = shape.rFull,
                ),
            contentAlignment = Alignment.Center,
        ) {
            if (selected) {
                Icon(
                    NptGlyphs.check,
                    contentDescription = null,
                    tint = scheme.onPrimary,
                    modifier = Modifier.size(16.dp),
                )
            }
        }
    }
}

/**
 * A selectable beneficiary tile: a circular 44dp avatar (provided [avatar]
 * slot or generated initials on `primaryContainer`), the [name], and a
 * masked [account] in tabular figures. When [selected] the tile lifts onto
 * `surfaceContainerHigh` with a primary ring and a trailing check-circle.
 * At least 56dp tall, whole tile tappable.
 *
 * Web counterpart: `<npt-beneficiary-tile>` · Flutter: `NeptuneBeneficiaryTile`.
 */
@Composable
public fun NeptuneBeneficiaryTile(
    name: String,
    modifier: Modifier = Modifier,
    account: String? = null,
    avatar: (@Composable () -> Unit)? = null,
    selected: Boolean = false,
    onTap: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val type = NeptuneTheme.type
    val shape = NeptuneTheme.shape
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val display = rememberNeptuneFontFamily(type.display)

    val accountStyle = NeptuneTheme.moneyStyle(base = typography.bodyMedium)
        .copy(color = scheme.onSurfaceVariant)

    val clickableModifier = if (onTap != null) {
        Modifier.clickable {
            feedback.trigger(NptFeedbackCue.Tap, haptics)
            onTap()
        }
    } else {
        Modifier
    }

    Row(
        modifier = modifier
            .clip(shape.rMd)
            .background(if (selected) scheme.surfaceContainerHigh else scheme.surface)
            .then(clickableModifier)
            .border(
                width = if (selected) 2.dp else 1.dp,
                color = if (selected) scheme.primary else scheme.outlineVariant,
                shape = shape.rMd,
            )
            .defaultMinSize(minHeight = 56.dp)
            .padding(horizontal = 12.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(Modifier.size(44.dp)) {
            if (avatar != null) {
                avatar()
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(shape.rFull)
                        .background(scheme.primaryContainer),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = beneficiaryInitials(name),
                        style = typography.labelLarge.copy(
                            fontFamily = display,
                            color = scheme.onPrimaryContainer,
                            fontWeight = FontWeight.W600,
                        ),
                    )
                }
            }
        }
        Spacer(Modifier.width(16.dp))
        Column(Modifier.weight(1f)) {
            Text(
                text = name,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = typography.bodyLarge.copy(color = scheme.onSurface),
            )
            if (account != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    text = NeptuneTheme.formatDigits(account),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = accountStyle,
                )
            }
        }
        if (selected) {
            Spacer(Modifier.width(12.dp))
            Icon(
                NptStatusGlyphs.successCheck,
                contentDescription = null,
                tint = scheme.primary,
                modifier = Modifier.size(22.dp),
            )
        }
    }
}

/** First letter of the first + last name parts, uppercased ('•' fallback) —
 * the Dart `_initials` recipe. */
private fun beneficiaryInitials(value: String): String {
    val parts = value.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
    if (parts.isEmpty()) return "•"
    val first = parts.first().first()
    val last = if (parts.size > 1) parts.last().first().toString() else ""
    val out = ("$first$last").uppercase()
    return out.ifEmpty { "•" }
}

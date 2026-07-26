// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The large display-font amount field. Web counterpart: `<npt-amount-input>`
// · Flutter: `NeptuneAmountInput`. Big tabular figures at display-small with
// the brand display weight/tracking, an optional currency affix, on a
// surface-container-lowest pane with an outline hairline (brand `md`
// corner). Input sanitizes to digits + one decimal point. Theme-only,
// RTL-safe (the affix leads, the amount ends the reading direction).

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/** Keep only digits and a single decimal point (first separator wins) —
 * the shared web/Flutter amount sanitizer. */
private fun sanitizeAmount(raw: String): String {
    var seenDot = false
    return buildString(raw.length) {
        for (ch in raw) {
            when {
                ch in '0'..'9' -> append(ch)
                (ch == '.' || ch == ',') && !seenDot -> {
                    seenDot = true
                    append('.')
                }
            }
        }
    }
}

/**
 * A large display-font amount field: big tabular figures with an optional
 * [currency] affix.
 *
 * Web counterpart: `<npt-amount-input>` · Flutter: `NeptuneAmountInput`.
 *
 * Numeric (decimal) keyboard; every edit is sanitized to digits plus a
 * single decimal point before reaching [onValueChange]. The amount renders
 * end-aligned in the brand money style (number family, tabular figures,
 * display weight + tracking). [placeholder] defaults to `0.00`.
 */
@Composable
public fun NeptuneAmountInput(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    currency: String? = null,
    placeholder: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val type = NeptuneTheme.type
    val shape = NeptuneTheme.shape.rMd
    val money = NeptuneTheme.moneyStyle(base = typography.displaySmall).copy(
        color = scheme.onSurface,
        fontWeight = type.displayFontWeight,
        letterSpacing = type.displayTracking.sp,
    )
    val affix = typography.titleMedium.copy(color = scheme.onSurfaceVariant)

    Row(
        modifier = modifier
            .clip(shape)
            .background(scheme.surfaceContainerLowest)
            .border(width = 1.dp, color = scheme.outline, shape = shape)
            .defaultMinSize(minHeight = 64.dp)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (!currency.isNullOrEmpty()) {
            Text(text = currency, style = affix, modifier = Modifier.alignByBaseline())
            Spacer(Modifier.width(8.dp))
        }
        BasicTextField(
            value = value,
            onValueChange = { raw -> onValueChange(sanitizeAmount(raw)) },
            modifier = Modifier
                .weight(1f)
                .alignByBaseline(),
            textStyle = money.copy(textAlign = TextAlign.End),
            cursorBrush = SolidColor(scheme.primary),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
            singleLine = true,
            decorationBox = { innerTextField ->
                Box {
                    if (value.isEmpty()) {
                        Text(
                            text = placeholder ?: "0.00",
                            style = money.copy(
                                color = scheme.onSurfaceVariant.copy(alpha = 0.5f),
                                textAlign = TextAlign.End,
                            ),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.fillMaxWidth(),
                        )
                    }
                    innerTextField()
                }
            },
        )
    }
}

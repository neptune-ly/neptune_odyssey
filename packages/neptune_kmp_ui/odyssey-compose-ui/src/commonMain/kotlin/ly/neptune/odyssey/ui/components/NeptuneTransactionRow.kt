// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// A single transaction line. Web counterpart: `<npt-transaction-row>` ·
// Flutter: `NeptuneTransactionRow`. Leading glyph tile, title/subtitle,
// signed amount in the money style; credits take the `success` role.
// Theme-only, RTL-safe, 48dp-min touch target.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptFinanceGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/**
 * A single transaction line: leading glyph, title/subtitle, signed amount.
 *
 * Web counterpart: `<npt-transaction-row>` · Flutter: `NeptuneTransactionRow`.
 *
 * Credits ([isCredit]) colour the amount with the `success` role; debits use
 * `onSurface`. The amount renders in the brand money style (tabular figures,
 * numerals lever applied). [icon] fills the 40dp `secondaryContainer` tile;
 * when null the built-in transfer glyph is used (the Dart default).
 */
@Composable
public fun NeptuneTransactionRow(
    title: String,
    amount: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    isCredit: Boolean = false,
    icon: (@Composable () -> Unit)? = null,
    onClick: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    val amountColor = if (isCredit) NeptuneTheme.colors.success else scheme.onSurface
    val money = NeptuneTheme.moneyStyle(base = typography.titleMedium).copy(color = amountColor)

    val clickableModifier = if (onClick != null) {
        Modifier.clickable {
            feedback.trigger(NptFeedbackCue.Tap, haptics)
            onClick()
        }
    } else {
        Modifier
    }

    Row(
        modifier = modifier
            .clip(NeptuneTheme.shape.rSm)
            .then(clickableModifier)
            .defaultMinSize(minHeight = 56.dp)
            .padding(horizontal = 8.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(NeptuneTheme.shape.rSm)
                .background(scheme.secondaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            CompositionLocalProvider(LocalContentColor provides scheme.onSecondaryContainer) {
                if (icon != null) {
                    icon()
                } else {
                    Icon(
                        NptFinanceGlyphs.swapExchange,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp),
                    )
                }
            }
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(
                text = title,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = typography.titleSmall.copy(color = scheme.onSurface),
            )
            if (subtitle != null) {
                Text(
                    text = subtitle,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = typography.bodySmall.copy(color = scheme.onSurfaceVariant),
                )
            }
        }
        Spacer(Modifier.width(12.dp))
        Text(NeptuneTheme.formatDigits(amount), style = money)
    }
}

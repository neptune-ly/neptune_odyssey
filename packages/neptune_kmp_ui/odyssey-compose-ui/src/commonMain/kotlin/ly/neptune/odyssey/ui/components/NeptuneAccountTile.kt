// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// A list tile for an account: avatar/icon, name + masked number, balance.
// Web counterpart: `<npt-card-row>` (the saved-item row recipe) · Flutter:
// `NeptuneAccountTile`. Narrow-width-safe: the trailing balance shares the
// row loosely and ellipsizes instead of overflowing (the ≤430dp fix).
// Theme-only, RTL-safe, 48dp-min target.

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
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptFinanceGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/**
 * A list tile for an account: leading icon tile, [name] + [maskedNumber],
 * trailing [balance] in the brand money style.
 *
 * Web counterpart: `<npt-card-row>` (nearest saved-item row) · Flutter:
 * `NeptuneAccountTile`.
 *
 * The balance shares the row loosely with the name column and ellipsizes
 * end-aligned under pressure — it can never overflow at narrow widths
 * (ports the Flutter `Flexible` fix semantics). [icon] fills the 44dp
 * `primaryContainer` tile; when null the built-in wallet glyph is used
 * (the Dart default).
 */
@Composable
public fun NeptuneAccountTile(
    name: String,
    maskedNumber: String,
    balance: String,
    modifier: Modifier = Modifier,
    icon: (@Composable () -> Unit)? = null,
    onClick: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val money = NeptuneTheme.moneyStyle(base = typography.titleMedium).copy(color = scheme.onSurface)

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
            .clip(NeptuneTheme.shape.rMd)
            .background(scheme.surfaceContainerLow)
            .then(clickableModifier)
            .defaultMinSize(minHeight = 64.dp)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(NeptuneTheme.shape.rSm)
                .background(scheme.primaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            CompositionLocalProvider(LocalContentColor provides scheme.onPrimaryContainer) {
                if (icon != null) {
                    icon()
                } else {
                    Icon(NptFinanceGlyphs.wallet, contentDescription = null)
                }
            }
        }
        Spacer(Modifier.width(16.dp))
        Column(Modifier.weight(1f)) {
            Text(
                text = name,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = typography.titleSmall.copy(color = scheme.onSurface),
            )
            Text(
                text = maskedNumber,
                style = typography.bodySmall.copy(color = scheme.onSurfaceVariant),
            )
        }
        Spacer(Modifier.width(12.dp))
        // Loose flex (the Dart `Flexible`): the balance yields to the name
        // column when space is tight and ellipsizes rather than overflowing.
        Text(
            text = balance,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.End,
            style = money,
            modifier = Modifier.weight(1f, fill = false),
        )
    }
}

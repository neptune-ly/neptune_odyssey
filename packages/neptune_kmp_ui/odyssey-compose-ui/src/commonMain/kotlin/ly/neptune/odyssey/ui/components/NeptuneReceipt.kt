// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The transfer outcome pair: the centred success hero and the itemised
// receipt card. Web counterparts: `<npt-success>` / `<npt-receipt>` ·
// Flutter: neptune_receipt.dart. The Dart success hero is a STATIC disc +
// glyph (it does not compose NeptuneStatusMotion) — flows that want the
// animated hand-off compose [NeptuneStatusMotion] themselves. Theme-only,
// RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
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
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptFintechGlyphs
import ly.neptune.odyssey.ui.glyphs.NptStatusGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/**
 * A centred success hero: a large success-coloured 96dp disc with a 56dp
 * [icon] slot (check-circle glyph by default), a display-font title, an
 * optional big [amount] in money style, and an optional [subtitle].
 *
 * Web counterpart: `<npt-success>` · Flutter: `NeptuneSuccess`.
 */
@Composable
public fun NeptuneSuccess(
    title: String,
    modifier: Modifier = Modifier,
    amount: String? = null,
    subtitle: String? = null,
    icon: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val typography = MaterialTheme.typography
    val money = NeptuneTheme.moneyStyle(base = typography.displaySmall)
        .copy(color = scheme.onSurface, fontWeight = FontWeight.W700)

    Column(
        modifier = modifier.padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            modifier = Modifier
                .size(96.dp)
                .clip(NeptuneTheme.shape.rFull)
                .background(npt.successContainer),
            contentAlignment = Alignment.Center,
        ) {
            CompositionLocalProvider(LocalContentColor provides npt.success) {
                Box(Modifier.size(56.dp), contentAlignment = Alignment.Center) {
                    if (icon != null) {
                        icon()
                    } else {
                        Icon(
                            NptStatusGlyphs.successCheck,
                            contentDescription = null,
                            modifier = Modifier.fillMaxSize(),
                        )
                    }
                }
            }
        }
        Spacer(Modifier.height(16.dp))
        // headlineSmall already rides the brand display face at the brand
        // display weight (the Dart copyWith is a no-op restated).
        Text(
            text = title,
            textAlign = TextAlign.Center,
            style = typography.headlineSmall.copy(color = scheme.onSurface),
        )
        if (amount != null) {
            Spacer(Modifier.height(12.dp))
            Text(
                text = NeptuneTheme.formatDigits(amount),
                textAlign = TextAlign.Center,
                style = money,
            )
        }
        if (subtitle != null) {
            Spacer(Modifier.height(8.dp))
            Text(
                text = subtitle,
                textAlign = TextAlign.Center,
                style = typography.bodyLarge.copy(color = scheme.onSurfaceVariant),
            )
        }
    }
}

/** One label/value line of a [NeptuneReceipt] (the Dart record row). */
@Immutable
public class NeptuneReceiptRow(
    public val label: String,
    public val value: String,
)

/**
 * A receipt card: a display-font title, a list of label/value rows (value
 * end-aligned in the money style), a hairline divider, and an optional Share
 * action (tonal [NeptuneButton]).
 *
 * Web counterpart: `<npt-receipt>` · Flutter: `NeptuneReceipt`.
 */
@Composable
public fun NeptuneReceipt(
    title: String,
    rows: List<NeptuneReceiptRow>,
    modifier: Modifier = Modifier,
    onShare: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val type = NeptuneTheme.type
    val shape = NeptuneTheme.shape.rLg
    val display = rememberNeptuneFontFamily(type.display)
    val money = NeptuneTheme.moneyStyle(base = typography.bodyLarge)
        .copy(color = scheme.onSurface)

    Column(
        modifier = modifier
            .clip(shape)
            .background(scheme.surfaceContainerLowest)
            .border(1.dp, scheme.outlineVariant, shape)
            .padding(20.dp),
    ) {
        Text(
            text = title,
            style = typography.titleLarge.copy(
                fontFamily = display,
                fontWeight = type.displayFontWeight,
                color = scheme.onSurface,
            ),
        )
        Spacer(Modifier.height(16.dp))
        for (row in rows) {
            Row(Modifier.padding(bottom = 12.dp)) {
                Text(
                    text = row.label,
                    style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                    modifier = Modifier.alignByBaseline(),
                )
                Spacer(Modifier.width(16.dp))
                Text(
                    text = NeptuneTheme.formatDigits(row.value),
                    textAlign = TextAlign.End,
                    style = money,
                    modifier = Modifier.weight(1f).alignByBaseline(),
                )
            }
        }
        // Hairline divider (the Dart 1dp outline-variant Divider).
        Box(Modifier.fillMaxWidth().height(1.dp).background(scheme.outlineVariant))
        if (onShare != null) {
            Spacer(Modifier.height(16.dp))
            NeptuneButton(
                label = "Share",
                onClick = onShare,
                variant = NeptuneButtonStyle.Tonal,
                icon = {
                    Icon(
                        NptFintechGlyphs.share,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp),
                    )
                },
            )
        }
    }
}

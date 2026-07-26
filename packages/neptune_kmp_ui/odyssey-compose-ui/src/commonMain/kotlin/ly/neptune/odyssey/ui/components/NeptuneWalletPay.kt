// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Wallet & pay surfaces. Web counterparts: `<npt-merchant-row>`,
// `<npt-voucher-card>`, `<npt-qr-pay>`, `<npt-topup-row>`, `<npt-tier-badge>`
// (wallet-pay.ts) · Flutter: neptune_wallet_pay.dart. Money renders in the
// brand money style (tabular figures, numerals lever applied). Theme-only,
// RTL-safe, rows ellipsize at narrow widths.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxHeight
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
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.glyphs.NptWalletPayGlyphs
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

// The tear/dashed-border pattern shared with the Dart _DashedBorderPainter
// (neptune_card_controls.dart): 6 on, 5 off.
private const val DASH_ON = 6f
private const val DASH_OFF = 5f

/**
 * A transaction-like merchant row: a circular merchant logo/avatar (or the
 * name's initial), the merchant name + category, and a trailing tabular
 * amount + time. When [pending] the amount dims to `onSurfaceVariant` and a
 * "pending" pill appears next to the category.
 *
 * Web counterpart: `<npt-merchant-row>` · Flutter: `NeptuneMerchantRow`.
 *
 * [logo] fills the 44dp circular `secondaryContainer` avatar; when null the
 * name's first initial renders in the display face. Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneMerchantRow(
    name: String,
    amount: String,
    modifier: Modifier = Modifier,
    category: String? = null,
    time: String? = null,
    pending: Boolean = false,
    logo: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val display = rememberNeptuneFontFamily(NeptuneTheme.type.display)

    val amountColor = if (pending) scheme.onSurfaceVariant else scheme.onSurface
    val money = NeptuneTheme.moneyStyle(base = typography.bodyLarge)
        .copy(color = amountColor, fontWeight = FontWeight.W600)
    val timeStyle = NeptuneTheme.moneyStyle(base = typography.labelSmall)
        .copy(color = scheme.onSurfaceVariant)

    val trimmed = name.trim()
    val initial = if (trimmed.isEmpty()) "•" else trimmed.take(1).uppercase()
    val divider = scheme.outlineVariant

    Row(
        modifier = modifier
            // The 1dp bottom hairline (web border-bottom outline-variant).
            .drawBehind {
                val stroke = 1.dp.toPx()
                drawLine(
                    color = divider,
                    start = Offset(0f, size.height - stroke / 2),
                    end = Offset(size.width, size.height - stroke / 2),
                    strokeWidth = stroke,
                )
            }
            .defaultMinSize(minHeight = 56.dp)
            .padding(horizontal = 8.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Logo / avatar (falls back to the name's initial).
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(NeptuneTheme.shape.rFull)
                .background(scheme.secondaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            CompositionLocalProvider(LocalContentColor provides scheme.onSecondaryContainer) {
                if (logo != null) {
                    logo()
                } else {
                    Text(
                        initial,
                        style = typography.labelLarge.copy(
                            fontFamily = display ?: typography.labelLarge.fontFamily,
                            fontWeight = FontWeight.W700,
                            color = scheme.onSecondaryContainer,
                        ),
                    )
                }
            }
        }
        Spacer(Modifier.width(16.dp))
        // Name + category/pending.
        Column(Modifier.weight(1f)) {
            Text(
                text = name,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = typography.bodyLarge.copy(color = scheme.onSurface),
            )
            if (category != null || pending) {
                Spacer(Modifier.height(2.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    if (category != null) {
                        Text(
                            text = category,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                            modifier = Modifier.weight(1f, fill = false),
                        )
                    }
                    if (pending) {
                        if (category != null) Spacer(Modifier.width(8.dp))
                        Box(
                            modifier = Modifier
                                .clip(NeptuneTheme.shape.rFull)
                                .background(scheme.tertiaryContainer)
                                .padding(horizontal = 8.dp, vertical = 1.dp),
                        ) {
                            Text(
                                text = "pending",
                                style = typography.labelSmall.copy(
                                    color = scheme.onTertiaryContainer,
                                    fontWeight = FontWeight.W600,
                                ),
                            )
                        }
                    }
                }
            }
        }
        Spacer(Modifier.width(16.dp))
        // Trailing amount + time (bounded by the row, so they can never
        // overflow at narrow widths; the name column yields).
        Column(horizontalAlignment = Alignment.End) {
            Text(
                text = NeptuneTheme.formatDigits(amount),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = money,
            )
            if (time != null) {
                Spacer(Modifier.height(2.dp))
                Text(NeptuneTheme.formatDigits(time), style = timeStyle)
            }
        }
    }
}

/**
 * A reward/voucher coupon: a big tabular value stub separated by a dashed
 * tear line from the title, an optional mono code chip, and an expiry
 * caption. Painted on `primaryContainer` at elevation-1.
 *
 * Web counterpart: `<npt-voucher-card>` · Flutter: `NeptuneVoucherCard`.
 * Theme-only, RTL-safe (the tear line sits on the inline-end edge of the
 * value stub).
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
public fun NeptuneVoucherCard(
    title: String,
    value: String,
    modifier: Modifier = Modifier,
    code: String? = null,
    expiry: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape
    val identity = NeptuneTheme.identity
    val display = rememberNeptuneFontFamily(NeptuneTheme.type.display)

    val onContainer = scheme.onPrimaryContainer
    val valueStyle = NeptuneTheme.moneyStyle(base = typography.headlineSmall)
        .copy(color = onContainer, fontWeight = FontWeight.W700)
    val codeStyle = NeptuneTheme.moneyStyle(base = typography.labelLarge).copy(
        color = scheme.onSurface,
        fontWeight = FontWeight.W600,
        letterSpacing = 1.2.sp,
    )
    val tear = scheme.outline

    Row(
        modifier = modifier
            // Elevation-1 at rest (web --npt-elev-1; the Dart 0/1/3 @ .20
            // shadow) — outside the clip.
            .nptShadow(identity.elevation1(scheme), shape.rLg)
            .clip(shape.rLg)
            .background(scheme.primaryContainer)
            .padding(20.dp)
            // Equal-height stub/body regardless of the parent's height (the
            // Dart IntrinsicHeight + stretch-Row recipe).
            .height(IntrinsicSize.Min),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Value stub with a dashed tear line on the inline-end edge.
        Box(
            modifier = Modifier
                .fillMaxHeight()
                .drawBehind {
                    val stroke = 2.dp.toPx()
                    val x = if (layoutDirection == LayoutDirection.Rtl) {
                        stroke / 2
                    } else {
                        size.width - stroke / 2
                    }
                    drawLine(
                        color = tear,
                        start = Offset(x, 0f),
                        end = Offset(x, size.height),
                        strokeWidth = stroke,
                        pathEffect = PathEffect.dashPathEffect(
                            floatArrayOf(DASH_ON.dp.toPx(), DASH_OFF.dp.toPx()),
                        ),
                    )
                }
                .padding(end = 16.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text(NeptuneTheme.formatDigits(value), style = valueStyle)
        }
        Spacer(Modifier.width(16.dp))
        // Body: title, code chip, expiry.
        Column(
            modifier = Modifier.weight(1f).fillMaxHeight(),
            verticalArrangement = Arrangement.Center,
        ) {
            Text(
                text = title,
                style = typography.titleMedium.copy(
                    fontFamily = display ?: typography.titleMedium.fontFamily,
                    fontWeight = FontWeight.W600,
                    color = onContainer,
                ),
            )
            if (code != null || expiry != null) {
                Spacer(Modifier.height(8.dp))
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp),
                ) {
                    if (code != null) {
                        Box(
                            modifier = Modifier
                                .align(Alignment.CenterVertically)
                                .clip(shape.rXs)
                                .background(scheme.surface)
                                .padding(horizontal = 12.dp, vertical = 4.dp),
                        ) {
                            Text(code, style = codeStyle)
                        }
                    }
                    if (expiry != null) {
                        Text(
                            text = expiry,
                            style = typography.bodySmall.copy(
                                color = onContainer.copy(alpha = 0.78f),
                            ),
                            modifier = Modifier.align(Alignment.CenterVertically),
                        )
                    }
                }
            }
        }
    }
}

/**
 * A scan-to-pay panel: a bordered QR frame sized [size], an optional
 * merchant caption, and a big tabular amount.
 *
 * Web counterpart: `<npt-qr-pay>` · Flutter: `NeptuneQrPay`.
 *
 * Real QR data is the consumer's job — fill the frame via [qr] (the web `qr`
 * slot); when null a placeholder QR mark renders at 70% of the frame.
 * Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneQrPay(
    amount: String,
    modifier: Modifier = Modifier,
    merchant: String? = null,
    size: Dp = 180.dp,
    qr: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape
    val money = NeptuneTheme.moneyStyle(base = typography.displaySmall)
        .copy(color = scheme.onSurface, fontWeight = FontWeight.W700)

    Column(
        modifier = modifier
            .clip(shape.rXl)
            .background(scheme.surfaceContainerLow)
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // The QR frame: 2dp outline-variant border on a surface pane.
        Box(
            modifier = Modifier
                .size(size)
                .clip(shape.rMd)
                .background(scheme.surface)
                .border(2.dp, scheme.outlineVariant, shape.rMd),
            contentAlignment = Alignment.Center,
        ) {
            CompositionLocalProvider(LocalContentColor provides scheme.onSurfaceVariant) {
                if (qr != null) {
                    qr()
                } else {
                    Icon(
                        NptWalletPayGlyphs.qrCode,
                        contentDescription = null,
                        modifier = Modifier.size(size * 0.7f),
                        tint = scheme.onSurfaceVariant,
                    )
                }
            }
        }
        if (merchant != null) {
            Spacer(Modifier.height(20.dp))
            Text(
                text = merchant,
                textAlign = TextAlign.Center,
                style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
            )
        }
        Spacer(Modifier.height(8.dp))
        Text(NeptuneTheme.formatDigits(amount), style = money)
    }
}

/**
 * A selectable top-up option row: a squared icon tile slot, a label +
 * optional sublabel, a trailing tabular amount, and a chevron that mirrors
 * in RTL.
 *
 * Web counterpart: `<npt-topup-row>` · Flutter: `NeptuneTopupRow`.
 *
 * [icon] fills the 40dp `secondaryContainer` tile; when null the built-in
 * card-add glyph is used (the Dart default). Tappable via [onTap]
 * (≥56dp target). Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneTopupRow(
    label: String,
    amount: String,
    modifier: Modifier = Modifier,
    sublabel: String? = null,
    icon: (@Composable () -> Unit)? = null,
    onTap: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val money = NeptuneTheme.moneyStyle(base = typography.bodyLarge)
        .copy(color = scheme.onSurface, fontWeight = FontWeight.W600)

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
            .clip(NeptuneTheme.shape.rMd)
            .background(scheme.surfaceContainerLow)
            .then(clickableModifier)
            .defaultMinSize(minHeight = 56.dp)
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Icon tile.
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
                        NptWalletPayGlyphs.cardAdd,
                        contentDescription = null,
                        modifier = Modifier.size(24.dp),
                    )
                }
            }
        }
        Spacer(Modifier.width(16.dp))
        // Label + sublabel (yield and ellipsize at narrow widths).
        Column(Modifier.weight(1f)) {
            Text(
                text = label,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = typography.bodyLarge.copy(color = scheme.onSurface),
            )
            if (sublabel != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    text = sublabel,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = typography.bodySmall.copy(color = scheme.onSurfaceVariant),
                )
            }
        }
        Spacer(Modifier.width(12.dp))
        Text(
            text = NeptuneTheme.formatDigits(amount),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = money,
        )
        Spacer(Modifier.width(8.dp))
        Icon(
            NptWalletPayGlyphs.chevronEnd,
            contentDescription = null,
            modifier = Modifier.size(24.dp),
            tint = scheme.onSurfaceVariant,
        )
    }
}

/** The membership tier tones for [NeptuneTierBadge], mirroring the web
 * `tone` attribute (`gold`/`silver`/`primary`/`neutral`) and the Flutter
 * `NeptuneTierTone`. */
public enum class NeptuneTierTone { Neutral, Primary, Gold, Silver }

/**
 * A small membership tier pill: a leading dot + the tier label, coloured
 * from the theme by [tone] — primary/gold/silver take the matching container
 * roles; neutral sits on `surfaceContainerHighest` with an outline-variant
 * ring.
 *
 * Web counterpart: `<npt-tier-badge>` · Flutter: `NeptuneTierBadge`.
 * Theme-only, RTL-safe.
 */
@Composable
public fun NeptuneTierBadge(
    tier: String,
    modifier: Modifier = Modifier,
    tone: NeptuneTierTone = NeptuneTierTone.Neutral,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val display = rememberNeptuneFontFamily(NeptuneTheme.type.display)
    val pill = NeptuneTheme.shape.rFull

    val (bg, fg) = when (tone) {
        NeptuneTierTone.Primary -> scheme.primaryContainer to scheme.onPrimaryContainer
        NeptuneTierTone.Gold -> scheme.tertiaryContainer to scheme.onTertiaryContainer
        NeptuneTierTone.Silver -> scheme.secondaryContainer to scheme.onSecondaryContainer
        NeptuneTierTone.Neutral -> scheme.surfaceContainerHighest to scheme.onSurface
    }
    val ring = if (tone == NeptuneTierTone.Neutral) {
        Modifier.border(1.dp, scheme.outlineVariant, pill)
    } else {
        Modifier
    }

    Row(
        modifier = modifier
            .clip(pill)
            .background(bg)
            .then(ring)
            .defaultMinSize(minHeight = 24.dp)
            .padding(horizontal = 12.dp, vertical = 2.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            Modifier
                .size(6.dp)
                .clip(pill)
                .background(fg),
        )
        Spacer(Modifier.width(4.dp))
        Text(
            text = tier,
            style = typography.labelLarge.copy(
                fontFamily = display ?: typography.labelLarge.fontFamily,
                fontWeight = FontWeight.W700,
                color = fg,
                letterSpacing = 0.28.sp,
            ),
        )
    }
}

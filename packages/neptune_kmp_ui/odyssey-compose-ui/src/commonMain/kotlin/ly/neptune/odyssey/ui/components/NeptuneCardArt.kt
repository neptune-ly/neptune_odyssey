// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// A payment-card visual. Web counterpart: `<npt-card-art>` · Flutter:
// `NeptuneCardArt`. A 1.586 aspect-ratio card on the 135° primary→tertiary
// brand gradient (virtual cards flip the order), the brand motif embossed at
// full strength, masked number in tabular figures, holder/expiry bottom row
// and a top-trailing network-mark slot. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.identity.NeptuneMotifLayer
import ly.neptune.odyssey.ui.identity.nptHeroGradient
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import ly.neptune.odyssey.ui.theme.NptShadow
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/**
 * A payment-card visual on the brand gradient.
 *
 * Web counterpart: `<npt-card-art>` · Flutter: `NeptuneCardArt`.
 *
 * Renders a 1.586 aspect-ratio card on primary → tertiary (135°,
 * RTL-mirrored); [virtual] flips the colour order (the virtual-card accent).
 * The top row shows the [scheme] label (display font, uppercase) and an
 * optional [brandMark] network-mark slot in the top-trailing corner; below
 * sit the masked number ending in [last4] (tabular figures), then [holder]
 * and [expiry]. [selected] draws an accent ring + primary glow that lift the
 * chosen card out of a stack.
 */
@Composable
public fun NeptuneCardArt(
    holder: String,
    last4: String,
    modifier: Modifier = Modifier,
    expiry: String? = null,
    scheme: String? = null,
    virtual: Boolean = false,
    selected: Boolean = false,
    brandMark: (@Composable () -> Unit)? = null,
    onClick: (() -> Unit)? = null,
) {
    val palette = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val identity = NeptuneTheme.identity
    val type = NeptuneTheme.type
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val cardShape = NeptuneTheme.shape.rLg
    val onCard = palette.onPrimary

    // Gradient runs primary → tertiary (135°); virtual cards flip the order.
    val gradientStart = if (virtual) palette.tertiary else palette.primary
    val gradientEnd = if (virtual) palette.primary else palette.tertiary

    // The masked number: 12 dots + the real last four (tabular figures).
    val numberStyle = NeptuneTheme.moneyStyle(base = typography.titleMedium)
        .copy(color = onCard, letterSpacing = 3.sp)

    val display = rememberNeptuneFontFamily(type.display)
    val schemeStyle = typography.labelLarge.copy(
        color = onCard.copy(alpha = 0.92f),
        fontFamily = display ?: typography.labelLarge.fontFamily,
        fontWeight = type.displayFontWeight,
        letterSpacing = 1.2.sp,
    )

    val clickableModifier = if (onClick != null) {
        Modifier.clickable {
            feedback.trigger(NptFeedbackCue.Tap, haptics)
            onClick()
        }
    } else {
        Modifier
    }

    val card: @Composable (Modifier) -> Unit = { cardModifier ->
        Box(
            modifier = cardModifier
                .aspectRatio(1.586f)
                // Elevation-2 at rest (web box-shadow) — outside the clip.
                .nptShadow(identity.elevation2(palette), cardShape)
                .clip(cardShape)
                .drawBehind {
                    drawRect(nptHeroGradient(gradientStart, gradientEnd, size, layoutDirection))
                }
                .then(clickableModifier),
        ) {
            // The brand's signature motif, embossed over the gradient — the
            // web layers the motif on card art at full strength.
            NeptuneMotifLayer(Modifier.matchParentSize(), color = onCard, strength = 1f)
            CompositionLocalProvider(LocalContentColor provides onCard) {
                Column(
                    modifier = Modifier.matchParentSize().padding(24.dp),
                    verticalArrangement = Arrangement.SpaceBetween,
                ) {
                    // Top row: scheme label + brand mark (top-trailing).
                    Row(verticalAlignment = Alignment.Top) {
                        Text(
                            text = scheme?.uppercase() ?: "",
                            style = schemeStyle,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f),
                        )
                        if (brandMark != null) {
                            Spacer(Modifier.width(16.dp))
                            brandMark()
                        }
                    }
                    // Masked card number.
                    Text(
                        text = "•••• •••• •••• $last4",
                        style = numberStyle,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                    // Bottom row: holder + expiry block.
                    Row(verticalAlignment = Alignment.Bottom) {
                        Text(
                            text = holder.uppercase(),
                            style = typography.labelMedium.copy(
                                color = onCard,
                                letterSpacing = 0.6.sp,
                            ),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f),
                        )
                        if (expiry != null) {
                            Spacer(Modifier.width(16.dp))
                            Column(horizontalAlignment = Alignment.End) {
                                Text(
                                    text = "Expires",
                                    style = typography.bodySmall.copy(
                                        color = onCard.copy(alpha = 0.85f),
                                    ),
                                )
                                Spacer(Modifier.height(4.dp))
                                Text(
                                    text = expiry,
                                    style = NeptuneTheme.moneyStyle(base = typography.labelLarge)
                                        .copy(color = onCard),
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    if (!selected) {
        card(modifier)
        return
    }

    // Selected: an accent ring sits *outside* the card (ring radius = brand
    // lg + 3, the Dart recipe) plus a glow that lifts it out of a stack.
    val ringShape = RoundedCornerShape(NeptuneTheme.shape.lg + 3.dp)
    Box(
        modifier = modifier
            .nptShadow(
                listOf(
                    NptShadow(
                        color = palette.primary.copy(alpha = 0.28f),
                        blurRadius = 22.dp,
                        offsetY = 8.dp,
                    ),
                ),
                ringShape,
            )
            .border(width = 3.dp, color = palette.primary, shape = ringShape)
            // 3dp ring + 3dp gap before the card (Flutter border+padding).
            .padding(6.dp),
    ) {
        card(Modifier)
    }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The primary account/balance card. Web counterpart: `<npt-balance-card>` ·
// Flutter: `NeptuneBalanceCard`. `hero` promotes it to the dashboard hero
// treatment: the 135° primary→tertiary brand gradient under on-primary text,
// the brand motif etched over it, the `xl` radius and a soft branded
// key-light. The flat variant is a tonal primary-container surface on the
// `lg` radius. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
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
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.identity.NeptuneMotifLayer
import ly.neptune.odyssey.ui.identity.nptHeroGradient
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import ly.neptune.odyssey.ui.theme.NptShadow

/**
 * A primary account/balance card.
 *
 * Web counterpart: `<npt-balance-card>` · Flutter: `NeptuneBalanceCard`.
 *
 * [hero] rides the brand gradient (primary → tertiary, 135°, RTL-mirrored)
 * with on-primary text, the brand motif at 0.8 strength and the primary
 * key-light glow; the flat variant is a `primaryContainer` tonal surface.
 * [amount] renders in the brand money style (tabular figures, numerals
 * lever applied). [trailing] is an optional inline-end slot on the label
 * row. [motif] disables the hero motif etch when false.
 */
@Composable
public fun NeptuneBalanceCard(
    label: String,
    amount: String,
    modifier: Modifier = Modifier,
    caption: String? = null,
    trailing: (@Composable () -> Unit)? = null,
    hero: Boolean = false,
    motif: Boolean = true,
    onClick: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    // Hero rides the brand gradient with on-primary text; the flat variant is
    // a tonal container. Corner: hero = xl, flat = lg (the Dart recipe).
    val shape = if (hero) NeptuneTheme.shape.rXl else NeptuneTheme.shape.rLg
    val onColor = if (hero) scheme.onPrimary else scheme.onPrimaryContainer
    // Web hero amount rides display-md (45px); the flat variant stays smaller.
    val money = NeptuneTheme.moneyStyle(
        base = if (hero) typography.displayMedium else typography.displaySmall,
    ).copy(color = onColor)

    // The hero key-light (Dart: primary at 0.28 alpha, blur 28, offset 14,
    // spread -12) — drawn outside the clip like the web box-shadow.
    val glow = if (hero) {
        Modifier.nptShadow(
            listOf(
                NptShadow(
                    color = scheme.primary.copy(alpha = 0.28f),
                    blurRadius = 28.dp,
                    offsetY = 14.dp,
                    spread = (-12).dp,
                ),
            ),
            shape,
        )
    } else {
        Modifier
    }

    val surface = if (hero) {
        Modifier.drawBehind { drawRect(nptHeroGradient(scheme, size, layoutDirection)) }
    } else {
        Modifier.background(scheme.primaryContainer)
    }
    val clickableModifier = if (onClick != null) {
        Modifier.clickable {
            feedback.trigger(NptFeedbackCue.Tap, haptics)
            onClick()
        }
    } else {
        Modifier
    }

    Box(
        modifier = modifier
            .then(glow)
            .clip(shape)
            .then(surface)
            .then(clickableModifier),
    ) {
        if (hero && motif) {
            // The dashboard-hero treatment on the site etches the brand motif
            // over the gradient (templates layer the motif at 0.8 strength).
            NeptuneMotifLayer(Modifier.matchParentSize(), color = onColor, strength = 0.8f)
        }
        CompositionLocalProvider(LocalContentColor provides onColor) {
            Column(Modifier.padding(if (hero) 24.dp else 20.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = label,
                        style = typography.labelLarge.copy(color = onColor),
                        modifier = Modifier.weight(1f),
                    )
                    if (trailing != null) trailing()
                }
                Spacer(Modifier.height(if (hero) 14.dp else 12.dp))
                Text(NeptuneTheme.formatDigits(amount), style = money)
                if (caption != null) {
                    Spacer(Modifier.height(6.dp))
                    Text(
                        text = caption,
                        style = typography.bodySmall.copy(color = onColor.copy(alpha = 0.8f)),
                    )
                }
            }
        }
    }
}

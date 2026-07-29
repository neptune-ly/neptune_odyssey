// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The composed KYC/onboarding-verification screen template. Ported 1:1 from
// neptune_templates.dart (NeptuneKycTemplate + _CaptureTile) /
// site/templates.html §kyc — composition only; the capture tile is the one
// inline recipe the Dart template carries, ported exactly.

package ly.neptune.odyssey.ui.templates

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.PaddingValues
import ly.neptune.odyssey.ui.components.NeptuneAlert
import ly.neptune.odyssey.ui.components.NeptuneAlertTone
import ly.neptune.odyssey.ui.components.NeptuneCta
import ly.neptune.odyssey.ui.components.NeptuneLimitMeter
import ly.neptune.odyssey.ui.components.NeptuneStatusChip
import ly.neptune.odyssey.ui.components.NeptuneStatusTone
import ly.neptune.odyssey.ui.components.NeptuneStepper
import ly.neptune.odyssey.ui.glyphs.NptStatusGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/** Document-capture status for one side of an ID. */
public enum class NeptuneKycCaptureState { Pending, Captured, Verified }

/**
 * KYC verification step: progress stepper, two capture tiles (front/back),
 * the account-limit meter this tier unlocks, and the continue CTA.
 *
 * Web counterpart: site/templates.html §kyc · Flutter: `NeptuneKycTemplate`.
 */
@Composable
public fun NeptuneKycTemplate(
    modifier: Modifier = Modifier,
    steps: List<String> = listOf("Identity", "Selfie", "Done"),
    activeStep: Int = 0,
    title: String = "Verify your identity",
    supporting: String = "Photograph both sides of your national ID.",
    frontLabel: String = "ID — front",
    backLabel: String = "ID — back",
    frontState: NeptuneKycCaptureState = NeptuneKycCaptureState.Captured,
    backState: NeptuneKycCaptureState = NeptuneKycCaptureState.Pending,
    limitValue: Float = 0.4f,
    limitLabel: String = "Tier limit after verification",
    limitAmount: String = "5,000 / 12,500 LYD",
    notice: String? = null,
    continueLabel: String = "Continue",
    onCaptureFront: (() -> Unit)? = null,
    onCaptureBack: (() -> Unit)? = null,
    onContinue: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    LazyColumn(
        modifier = modifier.fillMaxSize().windowInsetsPadding(WindowInsets.safeDrawing),
        contentPadding = PaddingValues(start = 20.dp, top = 16.dp, end = 20.dp, bottom = 24.dp),
    ) {
        item { NeptuneStepper(steps = steps, active = activeStep) }
        item {
            Spacer(Modifier.height(20.dp))
            // headlineSmall rides the brand display face (Typography.kt).
            Text(title, style = typography.headlineSmall.copy(color = scheme.onSurface))
            Spacer(Modifier.height(6.dp))
            Text(supporting, style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant))
        }
        item {
            Spacer(Modifier.height(18.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                CaptureTile(
                    label = frontLabel,
                    state = frontState,
                    onTap = onCaptureFront,
                    modifier = Modifier.weight(1f),
                )
                Spacer(Modifier.width(12.dp))
                CaptureTile(
                    label = backLabel,
                    state = backState,
                    onTap = onCaptureBack,
                    modifier = Modifier.weight(1f),
                )
            }
        }
        item {
            Spacer(Modifier.height(18.dp))
            NeptuneLimitMeter(value = limitValue, label = limitLabel, amount = limitAmount)
        }
        if (notice != null) {
            item {
                Spacer(Modifier.height(14.dp))
                NeptuneAlert(message = notice, tone = NeptuneAlertTone.Info)
            }
        }
        item {
            Spacer(Modifier.height(20.dp))
            NeptuneCta(continueLabel, onClick = onContinue, arrow = true)
        }
    }
}

/**
 * One capture tile: a `surfaceContainerLow` card (rMd, outline-variant
 * hairline) with a 34dp primary icon, the side label and a status chip —
 * the `_CaptureTile` recipe from neptune_templates.dart, exactly.
 */
@Composable
private fun CaptureTile(
    label: String,
    state: NeptuneKycCaptureState,
    onTap: (() -> Unit)?,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape.rMd

    val icon: ImageVector
    val tone: NeptuneStatusTone
    val chip: String
    when (state) {
        NeptuneKycCaptureState.Pending -> {
            icon = NptTemplateGlyphs.camera
            tone = NeptuneStatusTone.Neutral
            chip = "Pending"
        }
        NeptuneKycCaptureState.Captured -> {
            icon = NptStatusGlyphs.successCheck
            tone = NeptuneStatusTone.Warning
            chip = "Review"
        }
        NeptuneKycCaptureState.Verified -> {
            icon = NptTemplateGlyphs.securityShield
            tone = NeptuneStatusTone.Success
            chip = "Verified"
        }
    }

    Column(
        modifier = modifier
            .clip(shape)
            .background(scheme.surfaceContainerLow)
            .border(1.dp, scheme.outlineVariant, shape)
            .clickable(enabled = onTap != null) { onTap?.invoke() }
            .padding(16.dp)
            .fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Icon(icon, contentDescription = null, tint = scheme.primary, modifier = Modifier.size(34.dp))
        Spacer(Modifier.height(10.dp))
        Text(
            label,
            textAlign = TextAlign.Center,
            style = MaterialTheme.typography.labelLarge.copy(color = scheme.onSurface),
        )
        Spacer(Modifier.height(8.dp))
        NeptuneStatusChip(chip, tone = tone)
    }
}

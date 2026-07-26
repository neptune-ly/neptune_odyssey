// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The full account-opening onboarding flow — modelled on the real production
// sequence (otp → passport → selfie → confirmation → personal/account info →
// documents → terms → processing → terminal outcome), not a generic wizard.
// Each screen mirrors the real app's actual anatomy: the passport capture
// frame uses four independent corner brackets (not a full box), the selfie
// guide is an oval with readiness tinting and an auto countdown, OCR review
// mixes read-only + editable fields, attachments are dashed-until-filled
// tiles, and every terminal state (success/manualReview/rejected/failed)
// shares ONE status screen built on NeptuneStatusMotion — exactly like the
// real app collapses those seven backend states onto one animated screen.
// Web counterpart: site/templates.html › "KYC / Onboarding" · Flutter:
// neptune_onboarding_flow.dart. Theme-only, RTL-safe, reduced-motion aware.

package ly.neptune.odyssey.ui.templates

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.PathBuilder
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.components.NeptuneAlert
import ly.neptune.odyssey.ui.components.NeptuneAlertTone
import ly.neptune.odyssey.ui.components.NeptuneButton
import ly.neptune.odyssey.ui.components.NeptuneButtonStyle
import ly.neptune.odyssey.ui.components.NeptuneCta
import ly.neptune.odyssey.ui.components.NeptuneFlowStatus
import ly.neptune.odyssey.ui.components.NeptuneOtpInput
import ly.neptune.odyssey.ui.components.NeptuneStatusMotion
import ly.neptune.odyssey.ui.components.NeptuneTextField
import ly.neptune.odyssey.ui.glyphs.NptNavGlyphs
import ly.neptune.odyssey.ui.glyphs.NptStatusGlyphs
import ly.neptune.odyssey.ui.glyphs.nptGlyph
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

// --- flow-local glyphs -----------------------------------------------------------
//
// The handful of icons this flow needs beyond the shared glyph objects, built
// through the shared nptGlyph() builder (24×24 grid, 1.8 stroke, round caps,
// tint-driven). Path data ports 1:1 from packages/neptune_icons/src/icons.ts
// (`arrow-left`, `close`, `chat`, `copy`, `upload`, `id-card`); the volume
// pair has no neptune_icons source yet, so it is drawn in the same family
// style (speaker wedge + contactless-style waves / mute cross).

/** A full circle outline centred on ([cx], [cy]) with radius [r]. */
private fun PathBuilder.circleAt(cx: Float, cy: Float, r: Float) {
    moveTo(cx - r, cy)
    arcTo(r, r, 0f, false, true, cx + r, cy)
    arcTo(r, r, 0f, false, true, cx - r, cy)
    close()
}

/** An SVG `<rect x y width height rx>` as a rounded-corner path outline. */
private fun PathBuilder.roundRectAt(x: Float, y: Float, w: Float, h: Float, r: Float) {
    moveTo(x + r, y)
    horizontalLineTo(x + w - r)
    arcTo(r, r, 0f, false, true, x + w, y + r)
    verticalLineTo(y + h - r)
    arcTo(r, r, 0f, false, true, x + w - r, y + h)
    horizontalLineTo(x + r)
    arcTo(r, r, 0f, false, true, x, y + h - r)
    verticalLineTo(y + r)
    arcTo(r, r, 0f, false, true, x + r, y)
    close()
}

private object FlowGlyphs {
    /** Back arrow (`arrow-left`) — mirrors under RTL. */
    val back: ImageVector by lazy {
        nptGlyph("npt.flow.back", autoMirror = true) {
            moveTo(20f, 12f)
            horizontalLineTo(5f)
            moveTo(11f, 6f)
            lineToRelative(-6f, 6f)
            lineToRelative(6f, 6f)
        }
    }

    /** Close cross (`close`). */
    val close: ImageVector by lazy {
        nptGlyph("npt.flow.close") {
            moveTo(6f, 6f)
            lineTo(18f, 18f)
            moveTo(18f, 6f)
            lineTo(6f, 18f)
        }
    }

    /** Speaker with sound waves (guidance audio on). */
    val volumeUp: ImageVector by lazy {
        nptGlyph("npt.flow.volumeUp") {
            moveTo(4f, 9.5f)
            horizontalLineTo(7f)
            lineTo(11f, 6f)
            verticalLineTo(18f)
            lineTo(7f, 14.5f)
            horizontalLineTo(4f)
            close()
            moveTo(14.5f, 9.5f)
            arcToRelative(3.5f, 3.5f, 0f, false, true, 0f, 5f)
            moveTo(17f, 7.5f)
            arcToRelative(6f, 6f, 0f, false, true, 0f, 9f)
        }
    }

    /** Speaker with a mute cross (guidance audio off). */
    val volumeOff: ImageVector by lazy {
        nptGlyph("npt.flow.volumeOff") {
            moveTo(4f, 9.5f)
            horizontalLineTo(7f)
            lineTo(11f, 6f)
            verticalLineTo(18f)
            lineTo(7f, 14.5f)
            horizontalLineTo(4f)
            close()
            moveTo(15f, 9.5f)
            lineTo(20f, 14.5f)
            moveTo(20f, 9.5f)
            lineTo(15f, 14.5f)
        }
    }

    /** Message bubble (`chat`) — the SMS verification-code icon. */
    val sms: ImageVector by lazy {
        nptGlyph("npt.flow.sms") {
            moveTo(4.5f, 6f)
            arcTo(2.5f, 2.5f, 0f, false, true, 7f, 3.5f)
            horizontalLineToRelative(10f)
            arcTo(2.5f, 2.5f, 0f, false, true, 19.5f, 6f)
            verticalLineToRelative(7f)
            arcTo(2.5f, 2.5f, 0f, false, true, 17f, 15.5f)
            horizontalLineTo(9f)
            lineToRelative(-4.5f, 4f)
            close()
        }
    }

    /** Copy-to-clipboard (`copy`). */
    val copy: ImageVector by lazy {
        nptGlyph("npt.flow.copy") {
            roundRectAt(8f, 8f, 12f, 12f, 2.5f)
            moveTo(16f, 8f)
            verticalLineTo(6f)
            arcToRelative(2f, 2f, 0f, false, false, -2f, -2f)
            horizontalLineTo(6f)
            arcToRelative(2f, 2f, 0f, false, false, -2f, 2f)
            verticalLineToRelative(8f)
            arcToRelative(2f, 2f, 0f, false, false, 2f, 2f)
            horizontalLineToRelative(2f)
        }
    }

    /** Upload arrow over a baseline (`upload`). */
    val upload: ImageVector by lazy {
        nptGlyph("npt.flow.upload") {
            moveTo(12f, 14f)
            verticalLineTo(4f)
            moveTo(7.5f, 8.5f)
            lineTo(12f, 4f)
            lineToRelative(4.5f, 4.5f)
            moveTo(5f, 18.5f)
            horizontalLineToRelative(14f)
        }
    }

    /** Identity document (`id-card`) — the default instruction illustration. */
    val idCard: ImageVector by lazy {
        nptGlyph("npt.flow.idCard") {
            roundRectAt(3f, 5f, 18f, 14f, 2.5f)
            circleAt(8.5f, 11f, 2.1f)
            moveTo(5.5f, 15.8f)
            curveToRelative(0f, -1.7f, 1.3f, -3f, 3f, -3f)
            reflectiveCurveToRelative(3f, 1.3f, 3f, 3f)
            moveTo(14f, 9.5f)
            horizontalLineToRelative(5f)
            moveTo(14f, 13f)
            horizontalLineToRelative(5f)
        }
    }
}

// --- shared progress chrome -----------------------------------------------------

/**
 * The "N/8" progress chip used on every wizard screen.
 *
 * Web counterpart: site/templates.html › KYC / Onboarding progress chip ·
 * Flutter: `NeptuneOnboardingProgress` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneOnboardingProgress(
    step: Int,
    modifier: Modifier = Modifier,
    total: Int = 8,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    Box(
        modifier
            .clip(shape.rFull)
            .background(scheme.secondaryContainer)
            .padding(horizontal = 12.dp, vertical = 6.dp),
    ) {
        Text(
            NeptuneTheme.formatDigits("$step/$total"),
            style = MaterialTheme.typography.labelMedium.copy(color = scheme.onSecondaryContainer),
        )
    }
}

/**
 * Frame shared by every wizard screen: progress chip, back action, scrolling
 * content, and the Continue/Cancel action pair pinned to the bottom
 * (Flutter: `_WizardScaffold`).
 */
@Composable
private fun WizardScaffold(
    step: Int,
    total: Int,
    modifier: Modifier = Modifier,
    continueLabel: String = "Continue",
    onContinue: (() -> Unit)? = null,
    cancelLabel: String? = "Cancel",
    onCancel: (() -> Unit)? = null,
    continueEnabled: Boolean = true,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(modifier.fillMaxSize().windowInsetsPadding(WindowInsets.safeDrawing)) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 20.dp, top = 12.dp, end = 20.dp, bottom = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            IconButton(onClick = { onCancel?.invoke() }, enabled = onCancel != null) {
                Icon(FlowGlyphs.back, contentDescription = "Back")
            }
            Spacer(Modifier.weight(1f))
            NeptuneOnboardingProgress(step = step, total = total)
        }
        Column(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(start = 20.dp, top = 8.dp, end = 20.dp, bottom = 20.dp),
        ) {
            content()
        }
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 20.dp, end = 20.dp, bottom = 20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            NeptuneCta(label = continueLabel, onClick = if (continueEnabled) onContinue else null)
            if (cancelLabel != null) {
                Spacer(Modifier.height(6.dp))
                NeptuneButton(
                    label = cancelLabel,
                    onClick = onCancel,
                    variant = NeptuneButtonStyle.Text,
                )
            }
        }
    }
}

// --- 1. instruction screens (passport-instructions / selfie-instructions) ------

/**
 * A static "how this works" screen: brand illustration slot, headline, body
 * and bulleted tips, then Continue/Cancel — the exact pattern the real app
 * reuses for both the passport and selfie instruction steps.
 *
 * Web counterpart: site/templates.html › KYC / Onboarding · Flutter:
 * `NeptuneInstructionTemplate` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneInstructionTemplate(
    title: String,
    body: String,
    modifier: Modifier = Modifier,
    step: Int = 2,
    total: Int = 8,
    illustration: ImageVector = FlowGlyphs.idCard,
    tips: List<String> = emptyList(),
    onContinue: (() -> Unit)? = null,
    onCancel: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val type = NeptuneTheme.type
    val typography = MaterialTheme.typography
    val display = rememberNeptuneFontFamily(type.display)

    WizardScaffold(
        step = step,
        total = total,
        modifier = modifier,
        onContinue = onContinue,
        onCancel = onCancel,
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp)
                .clip(shape.rXl)
                .background(scheme.secondaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                illustration,
                contentDescription = null,
                tint = scheme.onSecondaryContainer,
                modifier = Modifier.size(72.dp),
            )
        }
        Spacer(Modifier.height(24.dp))
        Text(
            title,
            style = typography.headlineSmall.copy(
                fontFamily = display ?: typography.headlineSmall.fontFamily,
                fontWeight = type.displayFontWeight,
                color = scheme.onSurface,
            ),
        )
        Spacer(Modifier.height(8.dp))
        Text(body, style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant))
        Spacer(Modifier.height(18.dp))
        for (tip in tips) {
            Row(
                modifier = Modifier.padding(bottom = 10.dp),
                verticalAlignment = Alignment.Top,
            ) {
                Icon(
                    NptStatusGlyphs.successCheck,
                    contentDescription = null,
                    tint = scheme.primary,
                    modifier = Modifier.size(20.dp),
                )
                Spacer(Modifier.width(10.dp))
                Text(
                    tip,
                    style = typography.bodyMedium.copy(color = scheme.onSurface),
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

// --- 2. document capture (passport scan) — corner-bracket frame ----------------

/** The readiness state of a document/selfie capture surface. */
public enum class NeptuneCaptureReadiness { Aligning, Ready, Capturing, Processing }

/**
 * The passport/ID capture screen: a full-bleed themed surface, a document
 * frame drawn with four INDEPENDENT corner brackets (matching the real
 * capture UI — not a full rectangle), a status pill and a shutter button
 * that fills in once the frame reports ready. [readiness] is driven by the
 * caller — this composable is the faithful visual shell; wire it to a real
 * camera/quality pipeline in your app.
 *
 * Web counterpart: site/templates.html › KYC / Onboarding capture card ·
 * Flutter: `NeptuneDocumentCaptureTemplate` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneDocumentCaptureTemplate(
    modifier: Modifier = Modifier,
    readiness: NeptuneCaptureReadiness = NeptuneCaptureReadiness.Aligning,
    statusLabel: String = "Align the document within the frame",
    onCapture: (() -> Unit)? = null,
    onClose: (() -> Unit)? = null,
    muted: Boolean = false,
    onToggleMute: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val reduced = NeptuneTheme.reducedMotion
    val ready = readiness == NeptuneCaptureReadiness.Ready
    val busy = readiness == NeptuneCaptureReadiness.Capturing ||
        readiness == NeptuneCaptureReadiness.Processing

    val bracketColor = if (ready) {
        scheme.inversePrimary
    } else {
        scheme.inverseOnSurface.copy(alpha = 0.7f)
    }
    val pillFg = if (ready) scheme.inversePrimary else scheme.inverseOnSurface
    // The shutter fills in on readiness (Flutter AnimatedContainer, 220ms).
    val shutterFill by animateColorAsState(
        targetValue = if (ready) {
            scheme.inversePrimary
        } else {
            scheme.inverseOnSurface.copy(alpha = 0.12f)
        },
        animationSpec = if (reduced) snap() else tween(220),
        label = "shutter",
    )

    Box(modifier.fillMaxSize().background(scheme.inverseSurface)) {
        Box(Modifier.fillMaxSize().windowInsetsPadding(WindowInsets.safeDrawing)) {
            // The four independent L-shaped corner brackets around the
            // document frame (the real overlay — not a solid rectangle).
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(start = 28.dp, top = 60.dp, end = 28.dp, bottom = 140.dp)
                    .drawBehind {
                        val strokeWidth = 4.dp.toPx()
                        val len = size.minDimension * 0.14f
                        fun corner(a: Offset, h: Offset, v: Offset) {
                            drawLine(bracketColor, a, a + h, strokeWidth, StrokeCap.Round)
                            drawLine(bracketColor, a, a + v, strokeWidth, StrokeCap.Round)
                        }
                        corner(Offset(0f, 0f), Offset(len, 0f), Offset(0f, len))
                        corner(Offset(size.width, 0f), Offset(-len, 0f), Offset(0f, len))
                        corner(Offset(0f, size.height), Offset(len, 0f), Offset(0f, -len))
                        corner(
                            Offset(size.width, size.height),
                            Offset(-len, 0f),
                            Offset(0f, -len),
                        )
                    },
                contentAlignment = Alignment.Center,
            ) {
                if (busy) CircularProgressIndicator(color = scheme.inverseOnSurface)
            }
            Row(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .fillMaxWidth()
                    .padding(start = 4.dp, top = 8.dp, end = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                IconButton(onClick = { onClose?.invoke() }, enabled = onClose != null) {
                    Icon(
                        FlowGlyphs.close,
                        contentDescription = "Close",
                        tint = scheme.inverseOnSurface,
                    )
                }
                Spacer(Modifier.weight(1f))
                IconButton(onClick = { onToggleMute?.invoke() }, enabled = onToggleMute != null) {
                    Icon(
                        if (muted) FlowGlyphs.volumeOff else FlowGlyphs.volumeUp,
                        contentDescription = if (muted) "Unmute guidance" else "Mute guidance",
                        tint = scheme.inverseOnSurface,
                    )
                }
            }
            Box(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = 70.dp)
                    .clip(shape.rFull)
                    .background(pillFg.copy(alpha = 0.16f))
                    .padding(horizontal = 16.dp, vertical = 8.dp),
            ) {
                Text(
                    statusLabel,
                    style = LocalTextStyle.current.copy(
                        color = pillFg,
                        fontWeight = FontWeight.W600,
                        fontSize = 13.sp,
                    ),
                )
            }
            // Shutter: a 72dp ring that fills in and tints once ready.
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 36.dp)
                    .size(72.dp)
                    .clip(shape.rFull)
                    .background(shutterFill)
                    .border(3.dp, scheme.inverseOnSurface, shape.rFull)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        enabled = onCapture != null,
                        role = Role.Button,
                    ) { onCapture?.invoke() }
                    .semantics { contentDescription = "Capture" },
            )
        }
    }
}

// --- 3. selfie capture — oval guide + countdown ---------------------------------

/** Selfie-guide colour phase. */
public enum class NeptuneSelfieGuideState { Idle, Challenge, Aligned }

/**
 * The selfie/liveness capture screen: an oval face guide that retints with
 * [guideState] (neutral → inverse-primary during a challenge → success when
 * aligned) and a large centred countdown numeral — fully automatic, no
 * shutter button, matching the real liveness capture screen.
 *
 * Web counterpart: site/templates.html › KYC / Onboarding "Liveness selfie" ·
 * Flutter: `NeptuneSelfieCaptureTemplate` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneSelfieCaptureTemplate(
    modifier: Modifier = Modifier,
    guideState: NeptuneSelfieGuideState = NeptuneSelfieGuideState.Idle,
    statusLabel: String = "Center your face in the oval",
    countdown: Int? = null,
    onClose: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val shape = NeptuneTheme.shape
    val guideColor = when (guideState) {
        NeptuneSelfieGuideState.Idle -> scheme.inverseOnSurface
        NeptuneSelfieGuideState.Challenge -> scheme.inversePrimary
        NeptuneSelfieGuideState.Aligned -> npt.success
    }

    Box(modifier.fillMaxSize().background(scheme.inverseSurface)) {
        Box(Modifier.fillMaxSize().windowInsetsPadding(WindowInsets.safeDrawing)) {
            if (onClose != null) {
                Box(Modifier.align(Alignment.TopStart).padding(start = 4.dp, top = 8.dp)) {
                    IconButton(onClick = onClose) {
                        Icon(
                            FlowGlyphs.close,
                            contentDescription = "Close",
                            tint = scheme.inverseOnSurface,
                        )
                    }
                }
            }
            Box(
                modifier = Modifier.align(Alignment.Center).size(width = 240.dp, height = 320.dp),
                contentAlignment = Alignment.Center,
            ) {
                Canvas(Modifier.fillMaxSize()) {
                    drawOval(guideColor, style = Stroke(width = 4.dp.toPx()))
                }
                if (countdown != null) {
                    Text(
                        NeptuneTheme.formatDigits("$countdown"),
                        style = LocalTextStyle.current.copy(
                            color = scheme.inverseOnSurface,
                            fontSize = 64.sp,
                            fontWeight = FontWeight.W800,
                        ),
                    )
                }
            }
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 56.dp)
                    .clip(shape.rFull)
                    .background(guideColor.copy(alpha = 0.18f))
                    .padding(horizontal = 16.dp, vertical = 10.dp),
            ) {
                Text(
                    statusLabel,
                    style = LocalTextStyle.current.copy(
                        color = guideColor,
                        fontWeight = FontWeight.W600,
                        fontSize = 14.sp,
                    ),
                )
            }
        }
    }
}

// --- 4. OCR review (passport confirmation) --------------------------------------

/**
 * One field of a [NeptuneOcrReviewTemplate]. Read-only fields (e.g. the
 * OCR'd name) render as plain text rows; editable fields (e.g. dates)
 * render as [NeptuneTextField]s. Flutter: `NeptuneOcrField`.
 */
@Immutable
public class NeptuneOcrField(
    public val label: String,
    public val value: String,
    public val editable: Boolean = false,
)

/**
 * Reviews OCR-extracted document data: read-only fields as plain rows,
 * editable fields (dates) as text inputs, with an optional validation
 * banner — mirrors the real passport-confirmation screen.
 *
 * Web counterpart: site/templates.html › KYC / Onboarding · Flutter:
 * `NeptuneOcrReviewTemplate` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneOcrReviewTemplate(
    fields: List<NeptuneOcrField>,
    modifier: Modifier = Modifier,
    step: Int = 3,
    total: Int = 8,
    title: String = "Confirm your details",
    subtitle: String = "We read this from your document — check it's correct.",
    warning: String? = null,
    onContinue: (() -> Unit)? = null,
    onCancel: (() -> Unit)? = null,
    onFieldChanged: ((label: String, value: String) -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    WizardScaffold(
        step = step,
        total = total,
        modifier = modifier,
        onContinue = onContinue,
        onCancel = onCancel,
    ) {
        Text(title, style = typography.headlineSmall.copy(color = scheme.onSurface))
        Spacer(Modifier.height(6.dp))
        Text(subtitle, style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant))
        if (warning != null) {
            Spacer(Modifier.height(14.dp))
            NeptuneAlert(message = warning, tone = NeptuneAlertTone.Warning)
        }
        Spacer(Modifier.height(18.dp))
        for (f in fields) {
            if (f.editable) {
                var text by remember(f.label, f.value) { mutableStateOf(f.value) }
                NeptuneTextField(
                    value = text,
                    onValueChange = {
                        text = it
                        onFieldChanged?.invoke(f.label, it)
                    },
                    label = f.label,
                    modifier = Modifier.padding(bottom = 14.dp),
                )
            } else {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(bottom = 14.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        f.label,
                        style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                    )
                    Text(
                        NeptuneTheme.formatDigits(f.value),
                        style = typography.bodyLarge.copy(
                            color = scheme.onSurface,
                            fontWeight = FontWeight.W600,
                        ),
                    )
                }
            }
        }
    }
}

// --- 5. generic form step (essential/personal details, account details) -------

/**
 * One field slot in a [NeptuneOnboardingFormStep] — a text field or, when
 * [picker] is true, a tappable picker row (branch/job/municipality — the
 * real app's bottom-sheet selects). Flutter: `NeptuneFormFieldSpec`.
 */
@Immutable
public class NeptuneFormFieldSpec(
    public val label: String,
    public val value: String? = null,
    public val icon: ImageVector? = null,
    public val picker: Boolean = false,
    public val onTap: (() -> Unit)? = null,
    public val onChanged: ((String) -> Unit)? = null,
)

/**
 * A generic labelled-fields wizard step — used for essential details
 * (phone/national ID/passport), personal details (email/municipality/
 * address/mother's name) and account details (branch/job/salary pickers).
 *
 * Web counterpart: site/templates.html › KYC / Onboarding · Flutter:
 * `NeptuneOnboardingFormStep` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneOnboardingFormStep(
    step: Int,
    title: String,
    fields: List<NeptuneFormFieldSpec>,
    modifier: Modifier = Modifier,
    total: Int = 8,
    subtitle: String? = null,
    selectPlaceholder: String = "Select",
    onContinue: (() -> Unit)? = null,
    onCancel: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val typography = MaterialTheme.typography

    WizardScaffold(
        step = step,
        total = total,
        modifier = modifier,
        onContinue = onContinue,
        onCancel = onCancel,
    ) {
        Text(title, style = typography.headlineSmall.copy(color = scheme.onSurface))
        if (subtitle != null) {
            Spacer(Modifier.height(6.dp))
            Text(subtitle, style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant))
        }
        Spacer(Modifier.height(18.dp))
        for (f in fields) {
            if (f.picker) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 14.dp)
                        .clip(shape.rSm)
                        .background(scheme.surfaceContainerHighest)
                        .clickable(enabled = f.onTap != null, role = Role.Button) {
                            f.onTap?.invoke()
                        }
                        .defaultMinSize(minHeight = 48.dp)
                        .padding(horizontal = 16.dp, vertical = 14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    if (f.icon != null) {
                        Icon(
                            f.icon,
                            contentDescription = null,
                            tint = scheme.onSurfaceVariant,
                            modifier = Modifier.size(20.dp),
                        )
                        Spacer(Modifier.width(12.dp))
                    }
                    Column(Modifier.weight(1f)) {
                        Text(
                            f.label,
                            style = typography.labelMedium.copy(color = scheme.onSurfaceVariant),
                        )
                        Text(
                            f.value ?: selectPlaceholder,
                            style = typography.bodyLarge.copy(color = scheme.onSurface),
                        )
                    }
                    Icon(
                        NptNavGlyphs.chevronForward,
                        contentDescription = null,
                        tint = scheme.onSurfaceVariant,
                    )
                }
            } else {
                var text by remember(f.label, f.value) { mutableStateOf(f.value.orEmpty()) }
                NeptuneTextField(
                    value = text,
                    onValueChange = {
                        text = it
                        f.onChanged?.invoke(it)
                    },
                    label = f.label,
                    prefix = f.icon?.let { icon ->
                        { Icon(icon, contentDescription = null, modifier = Modifier.size(20.dp)) }
                    },
                    modifier = Modifier.padding(bottom = 14.dp),
                )
            }
        }
    }
}

// --- 6. attachments (documents / account details) --------------------------------

/** One attachment's state. */
public enum class NeptuneAttachmentState { Empty, Attached }

/**
 * One attachment slot: a dashed tile until [state] is attached, then a
 * filled tile with the filename and a checkmark — the real app's
 * AttachmentBox pattern (birth certificate, signature image).
 *
 * Web counterpart: site/templates.html › KYC / Onboarding capture tiles ·
 * Flutter: `NeptuneAttachmentTile` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneAttachmentTile(
    label: String,
    modifier: Modifier = Modifier,
    state: NeptuneAttachmentState = NeptuneAttachmentState.Empty,
    fileName: String? = null,
    onTap: (() -> Unit)? = null,
    uploadLabel: String = "Upload",
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val shape = NeptuneTheme.shape
    val typography = MaterialTheme.typography
    val attached = state == NeptuneAttachmentState.Attached

    val surface = if (attached) {
        // Filled tile: the success container at 35%.
        Modifier.background(npt.successContainer.copy(alpha = 0.35f))
    } else {
        // Dashed-until-filled: 2dp outline dashes (6 on / 5 off), inset 1dp,
        // on the brand `md` corner.
        val outline = scheme.outline
        val radius = shape.md
        Modifier.drawBehind {
            val inset = 1.dp.toPx()
            drawRoundRect(
                color = outline,
                topLeft = Offset(inset, inset),
                size = Size(size.width - inset * 2, size.height - inset * 2),
                cornerRadius = CornerRadius(radius.toPx()),
                style = Stroke(
                    width = 2.dp.toPx(),
                    pathEffect = PathEffect.dashPathEffect(
                        floatArrayOf(6.dp.toPx(), 5.dp.toPx()),
                    ),
                ),
            )
        }
    }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(shape.rMd)
            .then(surface)
            .clickable(enabled = onTap != null, role = Role.Button) { onTap?.invoke() }
            .defaultMinSize(minHeight = 48.dp)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            if (attached) NptStatusGlyphs.successCheck else FlowGlyphs.upload,
            contentDescription = null,
            tint = if (attached) npt.success else scheme.onSurfaceVariant,
        )
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(label, style = typography.bodyLarge.copy(color = scheme.onSurface))
            if (attached && fileName != null) {
                Text(fileName, style = typography.labelSmall.copy(color = scheme.onSurfaceVariant))
            }
        }
        if (!attached) {
            Text(uploadLabel, style = typography.labelLarge.copy(color = scheme.primary))
        }
    }
}

/**
 * A documents/attachments step: a title, a 12dp-spaced column of
 * [NeptuneAttachmentTile]s and Continue/Cancel — the documents (step 5) and
 * the attachment portion of account details (step 7) both use this shape.
 *
 * Web counterpart: site/templates.html › KYC / Onboarding · Flutter:
 * `NeptuneDocumentsStep` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneDocumentsStep(
    step: Int,
    modifier: Modifier = Modifier,
    total: Int = 8,
    title: String = "Upload your documents",
    subtitle: String? = null,
    continueEnabled: Boolean = true,
    onContinue: (() -> Unit)? = null,
    onCancel: (() -> Unit)? = null,
    attachments: @Composable ColumnScope.() -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    WizardScaffold(
        step = step,
        total = total,
        modifier = modifier,
        onContinue = onContinue,
        onCancel = onCancel,
        continueEnabled = continueEnabled,
    ) {
        Text(title, style = typography.headlineSmall.copy(color = scheme.onSurface))
        if (subtitle != null) {
            Spacer(Modifier.height(6.dp))
            Text(subtitle, style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant))
        }
        Spacer(Modifier.height(18.dp))
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            attachments()
        }
    }
}

// --- 7. terms & conditions --------------------------------------------------------

/**
 * Scrollable terms text with Accept/Decline — the real ToS step.
 *
 * Web counterpart: site/templates.html › KYC / Onboarding · Flutter:
 * `NeptuneTermsTemplate` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneTermsTemplate(
    body: String,
    modifier: Modifier = Modifier,
    step: Int = 5,
    total: Int = 8,
    title: String = "Terms & conditions",
    acceptLabel: String = "I Accept",
    declineLabel: String = "I Don't Accept",
    onAccept: (() -> Unit)? = null,
    onDecline: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val typography = MaterialTheme.typography

    WizardScaffold(
        step = step,
        total = total,
        modifier = modifier,
        continueLabel = acceptLabel,
        onContinue = onAccept,
        cancelLabel = declineLabel,
        onCancel = onDecline,
    ) {
        Text(title, style = typography.headlineSmall.copy(color = scheme.onSurface))
        Spacer(Modifier.height(14.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(shape.rMd)
                .background(scheme.surfaceContainerLow)
                .padding(16.dp),
        ) {
            Text(
                body,
                style = typography.bodyMedium.copy(
                    color = scheme.onSurfaceVariant,
                    // Flutter `height: 1.6` — a 1.6× line height.
                    lineHeight = typography.bodyMedium.fontSize * 1.6,
                ),
            )
        }
    }
}

// --- 8. shared terminal status screen ---------------------------------------------

/** The backend outcomes the real app collapses onto ONE status screen. */
public enum class NeptuneOnboardingOutcome {
    Processing,
    Success,
    ManualReview,
    CustomerExists,
    SubmissionFailed,
    Rejected,
}

/** A key/value row of the terminal detail card (account number, customer ID…). */
@Immutable
public class NeptuneDetailRow(
    public val label: String,
    public val value: String,
)

/**
 * The shared processing/terminal-outcome screen — exactly like the real app,
 * every backend state (finalize, processing, success, manualReview,
 * customerExists, submissionFailed, rejected) renders through this ONE
 * composable. Drives [NeptuneStatusMotion] (hourglass while processing/
 * manualReview, drawn checkmark on success, drawn cross on failure/rejected)
 * plus an optional terminal detail card and the Check-now/Refresh + Leave
 * action pair.
 *
 * Web counterpart: `<npt-status-motion>` in site/templates.html · Flutter:
 * `NeptuneOnboardingStatusTemplate` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneOnboardingStatusTemplate(
    outcome: NeptuneOnboardingOutcome,
    title: String,
    message: String,
    modifier: Modifier = Modifier,
    details: List<NeptuneDetailRow> = emptyList(),
    checking: Boolean = false,
    checkLabel: String = "Check now",
    refreshLabel: String = "Refresh status",
    leaveLabel: String = "Leave and return later",
    onCheck: (() -> Unit)? = null,
    onLeave: (() -> Unit)? = null,
    onCopyDetail: ((label: String, value: String) -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val typography = MaterialTheme.typography
    val terminal = outcome != NeptuneOnboardingOutcome.Processing

    val motionStatus = when (outcome) {
        NeptuneOnboardingOutcome.Processing,
        NeptuneOnboardingOutcome.ManualReview,
        -> NeptuneFlowStatus.Loading

        NeptuneOnboardingOutcome.Success -> NeptuneFlowStatus.Success
        else -> NeptuneFlowStatus.Rejected
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .windowInsetsPadding(WindowInsets.safeDrawing)
            .padding(28.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        NeptuneStatusMotion(status = motionStatus, size = 120.dp)
        Spacer(Modifier.height(24.dp))
        Text(
            title,
            textAlign = TextAlign.Center,
            style = typography.headlineSmall.copy(color = scheme.onSurface),
        )
        Spacer(Modifier.height(8.dp))
        Text(
            message,
            textAlign = TextAlign.Center,
            style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
        )
        if (details.isNotEmpty()) {
            Spacer(Modifier.height(22.dp))
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(shape.rMd)
                    .background(scheme.surfaceContainerLow)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                for (row in details) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Text(
                            row.label,
                            style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                        )
                        Row(
                            modifier = Modifier
                                .clip(shape.rSm)
                                .clickable(
                                    enabled = onCopyDetail != null,
                                    role = Role.Button,
                                    onClickLabel = "Copy",
                                ) { onCopyDetail?.invoke(row.label, row.value) }
                                .defaultMinSize(minHeight = 48.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Text(
                                NeptuneTheme.formatDigits(row.value),
                                style = typography.bodyLarge.copy(
                                    color = scheme.onSurface,
                                    fontWeight = FontWeight.W600,
                                ),
                            )
                            Spacer(Modifier.width(6.dp))
                            Icon(
                                FlowGlyphs.copy,
                                contentDescription = null,
                                tint = scheme.onSurfaceVariant,
                                modifier = Modifier.size(16.dp),
                            )
                        }
                    }
                }
            }
        }
        Spacer(Modifier.height(26.dp))
        NeptuneCta(
            label = if (terminal) refreshLabel else checkLabel,
            onClick = if (checking) null else onCheck,
            expand = false,
        )
        Spacer(Modifier.height(6.dp))
        NeptuneButton(label = leaveLabel, onClick = onLeave, variant = NeptuneButtonStyle.Text)
    }
}

// --- 9. identity correction (recovery) --------------------------------------------

/**
 * The 422/MATCH_FAILED recovery screen: edit the identifying fields and
 * restart the session, or cancel out. [onFieldChanged] reports edits under
 * the keys `phone` / `nationalId` / `passportNumber`.
 *
 * Web counterpart: site/templates.html › KYC / Onboarding · Flutter:
 * `NeptuneIdentityCorrectionTemplate` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneIdentityCorrectionTemplate(
    modifier: Modifier = Modifier,
    phone: String = "",
    nationalId: String = "",
    passportNumber: String = "",
    title: String = "Identity verification failed",
    message: String = "We couldn't match your details. Please review and correct them below.",
    phoneLabel: String = "Phone",
    nationalIdLabel: String = "National ID",
    passportLabel: String = "Passport number",
    continueLabel: String = "Continue",
    cancelLabel: String = "Cancel",
    onContinue: (() -> Unit)? = null,
    onCancel: (() -> Unit)? = null,
    onFieldChanged: ((field: String, value: String) -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    var phoneText by remember(phone) { mutableStateOf(phone) }
    var nationalIdText by remember(nationalId) { mutableStateOf(nationalId) }
    var passportText by remember(passportNumber) { mutableStateOf(passportNumber) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .windowInsetsPadding(WindowInsets.safeDrawing)
            .padding(24.dp),
    ) {
        Icon(
            NptStatusGlyphs.error,
            contentDescription = null,
            tint = scheme.error,
            modifier = Modifier.size(40.dp),
        )
        Spacer(Modifier.height(16.dp))
        Text(title, style = typography.headlineSmall.copy(color = scheme.onSurface))
        Spacer(Modifier.height(8.dp))
        Text(message, style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant))
        Spacer(Modifier.height(22.dp))
        NeptuneTextField(
            value = phoneText,
            onValueChange = {
                phoneText = it
                onFieldChanged?.invoke("phone", it)
            },
            label = phoneLabel,
        )
        Spacer(Modifier.height(14.dp))
        NeptuneTextField(
            value = nationalIdText,
            onValueChange = {
                nationalIdText = it
                onFieldChanged?.invoke("nationalId", it)
            },
            label = nationalIdLabel,
        )
        Spacer(Modifier.height(14.dp))
        NeptuneTextField(
            value = passportText,
            onValueChange = {
                passportText = it
                onFieldChanged?.invoke("passportNumber", it)
            },
            label = passportLabel,
        )
        Spacer(Modifier.weight(1f))
        NeptuneCta(label = continueLabel, onClick = onContinue)
        Spacer(Modifier.height(6.dp))
        NeptuneButton(label = cancelLabel, onClick = onCancel, variant = NeptuneButtonStyle.Text)
    }
}

// --- 10. OTP step (thin wrapper matching the real screen's anatomy) --------------

/**
 * The verification-code step: SMS icon, headline, [NeptuneOtpInput],
 * Continue/Cancel — mirrors the real otp screen (no visible resend timer).
 *
 * Web counterpart: `<npt-otp-input>` in site/templates.html · Flutter:
 * `NeptuneOtpStepTemplate` (neptune_onboarding_flow.dart).
 */
@Composable
public fun NeptuneOtpStepTemplate(
    phoneMasked: String,
    modifier: Modifier = Modifier,
    step: Int = 1,
    total: Int = 8,
    title: String = "Enter verification code",
    message: String = "We sent a code to $phoneMasked",
    errorText: String? = null,
    onCompleted: ((String) -> Unit)? = null,
    onContinue: (() -> Unit)? = null,
    onCancel: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    var code by remember { mutableStateOf("") }

    WizardScaffold(
        step = step,
        total = total,
        modifier = modifier,
        onContinue = onContinue,
        onCancel = onCancel,
    ) {
        Icon(
            FlowGlyphs.sms,
            contentDescription = null,
            tint = scheme.primary,
            modifier = Modifier.size(40.dp),
        )
        Spacer(Modifier.height(16.dp))
        Text(title, style = typography.headlineSmall.copy(color = scheme.onSurface))
        Spacer(Modifier.height(6.dp))
        Text(message, style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant))
        Spacer(Modifier.height(22.dp))
        NeptuneOtpInput(
            value = code,
            onValueChange = { code = it },
            length = 6,
            error = errorText != null,
            onComplete = onCompleted,
        )
        if (errorText != null) {
            Spacer(Modifier.height(10.dp))
            Text(errorText, style = typography.bodySmall.copy(color = scheme.error))
        }
    }
}

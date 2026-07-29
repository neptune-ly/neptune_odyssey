// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The composed auth/sign-in screen template. Ported 1:1 from
// neptune_templates.dart (NeptuneAuthTemplate) / site/templates.html §auth —
// composition only, every styled surface is an existing Odyssey component.

package ly.neptune.odyssey.ui.templates

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneBrandLockup
import ly.neptune.odyssey.ui.components.NeptuneCta
import ly.neptune.odyssey.ui.components.NeptuneOtpInput
import ly.neptune.odyssey.ui.components.NeptuneTextField
import ly.neptune.odyssey.ui.glyphs.NptDisplayGlyphs

/**
 * Two-step sign-in: lockup + phone/IBAN entry, then the one-time code.
 * Drive [step] (0 = credentials, 1 = OTP) and handle [onContinue]/[onVerify].
 * The phone and OTP fields keep their own (saveable) state, like the Flutter
 * widgets; [onOtp] mirrors the code as it is typed.
 *
 * Web counterpart: site/templates.html §auth · Flutter: `NeptuneAuthTemplate`.
 */
@Composable
public fun NeptuneAuthTemplate(
    brandInitial: String,
    brandName: String,
    modifier: Modifier = Modifier,
    lockup: (@Composable () -> Unit)? = null,
    step: Int = 0,
    title: String = "Welcome back",
    supporting: String = "Sign in with your phone number or IBAN.",
    phoneLabel: String = "Phone or IBAN",
    otpLabel: String = "Enter the 6-digit code",
    continueLabel: String = "Continue",
    verifyLabel: String = "Verify",
    onContinue: (() -> Unit)? = null,
    onVerify: (() -> Unit)? = null,
    onOtp: ((String) -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography

    var phone: String by rememberSaveable { mutableStateOf("") }
    var otp: String by rememberSaveable { mutableStateOf("") }

    Column(
        modifier
            .fillMaxSize()
            .windowInsetsPadding(WindowInsets.safeDrawing)
            .padding(start = 24.dp, top = 40.dp, end = 24.dp, bottom = 24.dp),
    ) {
        if (lockup != null) {
            lockup()
        } else {
            NeptuneBrandLockup(initial = brandInitial, name = brandName)
        }
        Spacer(Modifier.height(36.dp))
        // headlineMedium already rides the brand display face at the brand
        // display weight (Typography.kt) — the Dart copyWith is baked in.
        Text(title, style = typography.headlineMedium.copy(color = scheme.onSurface))
        Spacer(Modifier.height(8.dp))
        Text(supporting, style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant))
        Spacer(Modifier.height(28.dp))
        if (step == 0) {
            NeptuneTextField(
                value = phone,
                onValueChange = { phone = it },
                label = phoneLabel,
                prefix = { Icon(NptDisplayGlyphs.user, contentDescription = null) },
            )
            Spacer(Modifier.height(16.dp))
            NeptuneCta(continueLabel, onClick = onContinue, arrow = true)
        } else {
            Text(otpLabel, style = typography.labelLarge.copy(color = scheme.onSurfaceVariant))
            Spacer(Modifier.height(12.dp))
            NeptuneOtpInput(
                value = otp,
                onValueChange = {
                    otp = it
                    onOtp?.invoke(it)
                },
                length = 6,
            )
            Spacer(Modifier.height(20.dp))
            NeptuneCta(verifyLabel, onClick = onVerify)
        }
        Spacer(Modifier.weight(1f))
    }
}

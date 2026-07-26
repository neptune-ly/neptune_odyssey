// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The branded text input. Web counterpart: `<npt-text-field>` · Flutter:
// `NeptuneTextField`. Filled surface-container-highest on the brand `sm`
// corner: no border at rest, a 2dp primary ring on focus, the error colour
// when an error is set, an outline-variant hairline when disabled. Label
// above, helper/error below. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/**
 * A labelled, branded text input.
 *
 * Web counterpart: `<npt-text-field>` · Flutter: `NeptuneTextField`.
 *
 * Renders an optional [label] (labelMedium, onSurfaceVariant) above a filled
 * field (`surfaceContainerHighest`, brand `sm` corners: no border at rest, a
 * 2dp primary ring on focus, the error colour when [error] is set, an
 * outline-variant hairline when disabled), with optional [prefix]/[suffix]
 * slots (20dp, onSurfaceVariant tint) and [helper]/[error] text below.
 * [maxLength] truncates input. Theme-only, RTL-safe, ≥48dp target.
 */
@Composable
public fun NeptuneTextField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    label: String? = null,
    placeholder: String? = null,
    helper: String? = null,
    error: String? = null,
    enabled: Boolean = true,
    obscureText: Boolean = false,
    prefix: (@Composable () -> Unit)? = null,
    suffix: (@Composable () -> Unit)? = null,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    singleLine: Boolean = true,
    maxLength: Int? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rSm
    var focused by remember { mutableStateOf(false) }

    val hasError = error != null
    val labelColor = when {
        hasError -> scheme.error
        enabled -> scheme.onSurfaceVariant
        else -> scheme.onSurfaceVariant.copy(alpha = 0.5f)
    }
    val fill = if (enabled) {
        scheme.surfaceContainerHighest
    } else {
        scheme.surfaceContainerHighest.copy(alpha = 0.5f)
    }
    // No visible border at rest; primary ring on focus; error tint; hairline
    // when disabled — the Dart InputDecoration border table.
    val borderModifier = when {
        focused && enabled -> Modifier.border(2.dp, if (hasError) scheme.error else scheme.primary, shape)
        hasError -> Modifier.border(1.dp, scheme.error, shape)
        !enabled -> Modifier.border(1.dp, scheme.outlineVariant, shape)
        else -> Modifier
    }

    Column(modifier) {
        if (label != null) {
            Text(text = label, style = typography.labelMedium.copy(color = labelColor))
            Spacer(Modifier.height(6.dp))
        }
        BasicTextField(
            value = value,
            onValueChange = { raw ->
                onValueChange(if (maxLength != null) raw.take(maxLength) else raw)
            },
            modifier = Modifier
                .fillMaxWidth()
                .onFocusChanged { focused = it.isFocused },
            enabled = enabled,
            textStyle = typography.bodyLarge.copy(color = scheme.onSurface),
            cursorBrush = SolidColor(scheme.primary),
            visualTransformation = if (obscureText) {
                PasswordVisualTransformation()
            } else {
                VisualTransformation.None
            },
            keyboardOptions = keyboardOptions,
            singleLine = singleLine,
            decorationBox = { innerTextField ->
                Row(
                    modifier = Modifier
                        .defaultMinSize(minHeight = 48.dp)
                        .clip(shape)
                        .background(fill)
                        .then(borderModifier)
                        .padding(horizontal = 16.dp, vertical = 14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    if (prefix != null) {
                        CompositionLocalProvider(LocalContentColor provides scheme.onSurfaceVariant) {
                            Box(Modifier.size(20.dp), contentAlignment = Alignment.Center) { prefix() }
                        }
                        Spacer(Modifier.width(12.dp))
                    }
                    Box(Modifier.weight(1f)) {
                        if (value.isEmpty() && placeholder != null) {
                            Text(
                                text = placeholder,
                                style = typography.bodyLarge.copy(
                                    color = scheme.onSurfaceVariant.copy(alpha = 0.6f),
                                ),
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                        innerTextField()
                    }
                    if (suffix != null) {
                        Spacer(Modifier.width(12.dp))
                        CompositionLocalProvider(LocalContentColor provides scheme.onSurfaceVariant) {
                            Box(Modifier.size(20.dp), contentAlignment = Alignment.Center) { suffix() }
                        }
                    }
                }
            },
        )
        if (hasError || helper != null) {
            Spacer(Modifier.height(6.dp))
            Text(
                text = error ?: helper.orEmpty(),
                style = typography.bodySmall.copy(
                    color = if (hasError) scheme.error else scheme.onSurfaceVariant,
                ),
            )
        }
    }
}

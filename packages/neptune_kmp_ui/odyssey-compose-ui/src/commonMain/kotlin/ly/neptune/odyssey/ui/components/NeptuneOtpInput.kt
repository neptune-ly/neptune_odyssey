// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The boxed one-time-code entry. Web counterpart: `<npt-otp-input>` ·
// Flutter: `NeptuneOtpInput`. One hidden text field drives N rendered cells
// (48×56, surface-container-lowest, brand `sm` corner): filled/active cells
// lift to a primary border, the focused cell gets the 2dp ring, the error
// tone recolours the borders. The cell row stays LTR under RTL exactly like
// the web `direction: ltr`. Theme-only.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
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
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/**
 * A row of boxed single-digit OTP cells driven by one hidden text field —
 * auto-advance, backspace-rewind and paste-fill come from the platform text
 * editing itself.
 *
 * Web counterpart: `<npt-otp-input>` · Flutter: `NeptuneOtpInput`.
 *
 * Filled or active cells take a primary border; the focused cell gets the
 * 2dp focus ring; [error] switches the borders to the error tone. [obscure]
 * renders dots instead of digits (the `npt-pin-input` treatment). [value]
 * is digits-only, truncated to [length]; [onComplete] fires once all cells
 * are filled. The cell row stays LTR under RTL (like the web).
 */
@Composable
public fun NeptuneOtpInput(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    length: Int = 6,
    obscure: Boolean = false,
    error: Boolean = false,
    enabled: Boolean = true,
    onComplete: ((String) -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val cellShape = NeptuneTheme.shape.rSm
    var focused by remember { mutableStateOf(false) }

    val digits = value.filter { it.isDigit() }.take(length)
    val activeIndex = digits.length.coerceAtMost(length - 1)
    val cellStyle = NeptuneTheme.moneyStyle(base = typography.headlineSmall)
        .copy(color = scheme.onSurface)
    // The real field is invisible — the cells below render its value.
    val hiddenStyle = cellStyle.copy(color = scheme.onSurface.copy(alpha = 0f))

    BasicTextField(
        value = digits,
        onValueChange = { raw ->
            val clean = raw.filter { it.isDigit() }.take(length)
            if (clean != digits) {
                onValueChange(clean)
                if (clean.length == length) onComplete?.invoke(clean)
            }
        },
        modifier = modifier.onFocusChanged { focused = it.isFocused },
        enabled = enabled,
        textStyle = hiddenStyle,
        cursorBrush = SolidColor(scheme.onSurface.copy(alpha = 0f)),
        keyboardOptions = KeyboardOptions(
            keyboardType = if (obscure) KeyboardType.NumberPassword else KeyboardType.Number,
        ),
        singleLine = true,
        decorationBox = { innerTextField ->
            Box {
                // The cell row stays LTR — codes read left-to-right even
                // under RTL (web `direction: ltr`).
                CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        repeat(length) { i ->
                            val filled = i < digits.length
                            val focusedCell = focused && enabled && i == activeIndex
                            val active = focusedCell || filled
                            val borderColor = when {
                                error -> scheme.error
                                active -> scheme.primary
                                else -> scheme.outline
                            }
                            Box(
                                modifier = Modifier
                                    .width(48.dp)
                                    .height(56.dp)
                                    .alpha(if (enabled) 1f else 0.38f)
                                    .clip(cellShape)
                                    .background(scheme.surfaceContainerLowest)
                                    .border(
                                        width = if (focusedCell) 2.dp else 1.dp,
                                        color = borderColor,
                                        shape = cellShape,
                                    ),
                                contentAlignment = Alignment.Center,
                            ) {
                                if (filled) {
                                    Text(
                                        text = if (obscure) "•" else digits[i].toString(),
                                        style = cellStyle,
                                    )
                                }
                            }
                        }
                    }
                }
                // Keep the (invisible) editable layer over the cells so taps
                // focus it and the keyboard/paste drive the value.
                Box(Modifier.matchParentSize()) { innerTextField() }
            }
        },
    )
}

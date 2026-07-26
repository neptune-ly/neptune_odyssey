// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Secure-entry inputs. Web counterparts: `<npt-pin-input>`,
// `<npt-amount-keypad>` (money-inputs.ts) · Flutter:
// neptune_secure_inputs.dart. The PIN input is the boxed OTP entry, always
// dot-masked and defaulting to 4 cells; the amount keypad is a 3-column grid
// of ≥56dp keys (digits on surface-container-high, brand `md` corner, money
// type; decimal and backspace as quiet action keys) with a haptic tap per
// key. Theme-only, RTL-safe (the grid lays out logically and mirrors).

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.max
import ly.neptune.odyssey.ui.glyphs.NptInputGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/**
 * A masked PIN entry: the same boxed cells as [NeptuneOtpInput], but always
 * obscured with dots and defaulting to 4 digits.
 *
 * Web counterpart: `<npt-pin-input>` · Flutter: `NeptunePinInput`.
 *
 * [value] is digits-only, truncated to [length]; [onComplete] fires once
 * every cell is filled. [error] recolours the cell borders; the cell row
 * stays LTR under RTL (like the web `direction: ltr`).
 */
@Composable
public fun NeptunePinInput(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    length: Int = 4,
    error: Boolean = false,
    enabled: Boolean = true,
    onComplete: ((String) -> Unit)? = null,
) {
    NeptuneOtpInput(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier,
        length = length,
        obscure = true,
        error = error,
        enabled = enabled,
        onComplete = onComplete,
    )
}

// The keypad rows: digits 1–9, then decimal · 0 · backspace.
private val keypadRows: List<List<String>> = listOf(
    listOf("1", "2", "3"),
    listOf("4", "5", "6"),
    listOf("7", "8", "9"),
    listOf(".", "0", "back"),
)

/**
 * A 3×4 on-screen amount keypad: digits 1–9, a decimal point, 0 and a
 * backspace. Digit keys are `surfaceContainerHigh` tiles on the brand `md`
 * corner in the money style (num family, tabular, headlineSmall); the
 * decimal and backspace render as quiet (transparent) action keys. Every
 * key is at least 56dp tall (8dp gutters, 1.6 aspect cells) and fires the
 * brand haptic tap.
 *
 * Web counterpart: `<npt-amount-keypad>` · Flutter: `NeptuneAmountKeypad`.
 *
 * [onKey] receives `"0"`–`"9"` or `"."`; [onBackspace] fires for the delete
 * key. Null callbacks disable their keys. The grid lays out logically, so
 * it mirrors under RTL like the web/Flutter grids.
 */
@Composable
public fun NeptuneAmountKeypad(
    onKey: ((String) -> Unit)?,
    onBackspace: (() -> Unit)?,
    modifier: Modifier = Modifier,
) {
    BoxWithConstraints(modifier) {
        // The Flutter grid: 3 columns, 8dp gutters, 1.6 aspect cells — with
        // the 56dp key floor. Unbounded slots fall back to shrink-wrapped
        // 90dp keys (the Segmented port's bounded-width guard).
        val bounded = maxWidth != Dp.Infinity
        val keyWidth = if (bounded) (maxWidth - 16.dp) / 3 else 90.dp
        val keyHeight = max(56.dp, keyWidth / 1.6f)
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            keypadRows.forEach { row ->
                Row(
                    modifier = if (bounded) Modifier.fillMaxWidth() else Modifier,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    row.forEach { key ->
                        KeypadKey(
                            value = key,
                            onTap = when {
                                key == "back" -> onBackspace
                                onKey != null -> ({ onKey(key) })
                                else -> null
                            },
                            modifier = (
                                if (bounded) {
                                    Modifier.weight(1f)
                                } else {
                                    Modifier.width(keyWidth)
                                }
                                ).height(keyHeight),
                        )
                    }
                }
            }
        }
    }
}

/** One keypad tile. Digits use the money style; backspace is a 24dp glyph. */
@Composable
private fun KeypadKey(
    value: String,
    onTap: (() -> Unit)?,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rMd
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val isBack = value == "back"
    // The decimal and backspace are quiet action keys (no tile fill).
    val isAction = isBack || value == "."
    val keyStyle = NeptuneTheme.moneyStyle(base = typography.headlineSmall)
        .copy(color = scheme.onSurface)

    Box(
        modifier = modifier
            .clip(shape)
            .then(if (isAction) Modifier else Modifier.background(scheme.surfaceContainerHigh))
            .clickable(enabled = onTap != null, role = Role.Button) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onTap?.invoke()
            },
        contentAlignment = Alignment.Center,
    ) {
        if (isBack) {
            Icon(
                NptInputGlyphs.backspace,
                contentDescription = "Backspace",
                tint = scheme.onSurfaceVariant,
                modifier = Modifier.size(24.dp),
            )
        } else {
            Text(text = NeptuneTheme.formatDigits(value), style = keyStyle)
        }
    }
}

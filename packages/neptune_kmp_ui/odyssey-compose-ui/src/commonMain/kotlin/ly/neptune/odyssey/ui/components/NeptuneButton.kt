// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The brand action button. Web counterpart: `<npt-button>` · Flutter:
// `NeptuneButton`. Maps onto the Material 3 button family so it inherits the
// pill shape and ≥48dp target — theme-only, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback

/** Visual style for [NeptuneButton], mirroring the web `<npt-button>` variants. */
public enum class NeptuneButtonStyle { Filled, Tonal, Outlined, Text }

/**
 * [busy] shows an 18dp spinner in place of the label and disables the button.
 * [expand] stretches to the available width. [icon] is a 20dp leading slot.
 */
@Composable
public fun NeptuneButton(
    label: String,
    onClick: (() -> Unit)?,
    modifier: Modifier = Modifier,
    variant: NeptuneButtonStyle = NeptuneButtonStyle.Filled,
    icon: (@Composable () -> Unit)? = null,
    expand: Boolean = false,
    busy: Boolean = false,
) {
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val shape = NeptuneTheme.shape.rFull
    val enabled = onClick != null && !busy
    val handleClick: () -> Unit = {
        feedback.trigger(NptFeedbackCue.Tap, haptics)
        onClick?.invoke()
    }
    val sizing = Modifier
        .defaultMinSize(minWidth = 64.dp, minHeight = 48.dp)
        .then(if (expand) Modifier.fillMaxWidth() else Modifier)

    val body: @Composable () -> Unit = {
        Row(verticalAlignment = Alignment.CenterVertically) {
            if (busy) {
                CircularProgressIndicator(
                    modifier = Modifier.size(18.dp),
                    strokeWidth = 2.dp,
                    color = LocalContentColor.current,
                )
            } else {
                if (icon != null) {
                    icon()
                    Spacer(Modifier.width(8.dp))
                }
                Text(label, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
        }
    }

    when (variant) {
        NeptuneButtonStyle.Filled -> Button(
            onClick = handleClick,
            modifier = modifier.then(sizing),
            enabled = enabled,
            shape = shape,
        ) { body() }

        NeptuneButtonStyle.Tonal -> FilledTonalButton(
            onClick = handleClick,
            modifier = modifier.then(sizing),
            enabled = enabled,
            shape = shape,
        ) { body() }

        NeptuneButtonStyle.Outlined -> OutlinedButton(
            onClick = handleClick,
            modifier = modifier.then(sizing),
            enabled = enabled,
            shape = shape,
        ) { body() }

        NeptuneButtonStyle.Text -> TextButton(
            onClick = handleClick,
            modifier = modifier.then(sizing),
            enabled = enabled,
            shape = shape,
        ) { body() }
    }
}

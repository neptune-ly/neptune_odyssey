// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The Odyssey eyebrow — the uppercase, letter-spaced display-face micro-label
// that tops heroes and sections on the web (`.scheme`/`.eyebrow`: display
// font, 700, tracking 0.08em, uppercase).

package ly.neptune.odyssey.ui.identity

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/**
 * Web counterpart: `.eyebrow` / card scheme labels · Flutter: `NeptuneEyebrow`.
 */
@Composable
public fun NeptuneEyebrow(
    text: String,
    modifier: Modifier = Modifier,
    color: Color? = null,
) {
    val base = MaterialTheme.typography.labelMedium
    val fontSize = if (base.fontSize.isSp) base.fontSize.value else 12f
    val display = rememberNeptuneFontFamily(NeptuneTheme.type.display)
    Text(
        text = text.uppercase(),
        modifier = modifier,
        style = base.copy(
            fontFamily = display ?: base.fontFamily,
            fontWeight = FontWeight.W700,
            letterSpacing = (0.08f * fontSize).sp,
            color = color ?: MaterialTheme.colorScheme.onSurfaceVariant,
        ),
    )
}

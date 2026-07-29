// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Card-management surfaces. Web counterparts: `<npt-card-controls>`,
// `<npt-add-card>` (cards.ts) · Flutter: neptune_card_controls.dart.
// A strip of equal-width action tiles (Freeze/Limits/Details/PIN) and the
// dashed add-card call-to-action tile. Theme-only, RTL-safe, ≥48dp targets.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptCardControlGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/** One action in a [NeptuneCardControls] bar. */
private class CardAction(val action: String, val label: String, val icon: ImageVector)

private val cardActions: List<CardAction> = listOf(
    CardAction("freeze", "Freeze", NptCardControlGlyphs.snowflake),
    CardAction("limits", "Limits", NptCardControlGlyphs.tune),
    CardAction("details", "Details", NptCardControlGlyphs.receipt),
    CardAction("pin", "PIN", NptCardControlGlyphs.dialpad),
)

// The Dart _DashedBorderPainter recipe: 6 on, 5 off, 2 stroke, 1 inset.
private const val DASH_ON = 6f
private const val DASH_OFF = 5f

/**
 * A row of card-management toggles: Freeze, Limits, Details, PIN — four
 * equal-width, equal-height tiles 8dp apart. Each press calls [onControl]
 * with the action key (`freeze` | `limits` | `details` | `pin`). [frozen]
 * flips the first tile to an active "Unfreeze" affordance on
 * `primaryContainer`.
 *
 * Web counterpart: `<npt-card-controls>` · Flutter: `NeptuneCardControls`.
 * Theme-only, RTL-safe, ≥64dp targets.
 */
@Composable
public fun NeptuneCardControls(
    onControl: (String) -> Unit,
    modifier: Modifier = Modifier,
    frozen: Boolean = false,
) {
    // Equal-height tiles regardless of the parent's (possibly unbounded)
    // height — the Dart IntrinsicHeight + stretch-Row recipe.
    Row(
        modifier = modifier.height(IntrinsicSize.Min),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        for (action in cardActions) {
            ControlTile(
                action = action,
                frozen = frozen,
                onControl = onControl,
                modifier = Modifier.weight(1f).fillMaxHeight(),
            )
        }
    }
}

@Composable
private fun ControlTile(
    action: CardAction,
    frozen: Boolean,
    onControl: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val tileShape = NeptuneTheme.shape.rMd
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    val pressed = action.action == "freeze" && frozen
    val label = if (pressed) "Unfreeze" else action.label
    val bg = if (pressed) scheme.primaryContainer else scheme.surfaceContainerLow
    val fg = if (pressed) scheme.onPrimaryContainer else scheme.onSurface
    // Pressed tiles hide the ring by matching it to the fill (the Dart/web
    // border-color recipe).
    val ring = if (pressed) scheme.primaryContainer else scheme.outlineVariant

    Column(
        modifier = modifier
            .clip(tileShape)
            .background(bg)
            .border(1.dp, ring, tileShape)
            .clickable {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onControl(action.action)
            }
            .defaultMinSize(minHeight = 64.dp)
            .padding(horizontal = 8.dp, vertical = 12.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            action.icon,
            contentDescription = null,
            modifier = Modifier.size(22.dp),
            tint = fg,
        )
        Spacer(Modifier.height(4.dp))
        Text(
            text = label,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = typography.labelMedium.copy(color = fg),
        )
    }
}

/**
 * A dashed "add a card" tile: a dashed-outline row with a circular plus and
 * a [label]. Calls [onTap] on press unless [disabled] (which dims the whole
 * tile to 38%).
 *
 * Web counterpart: `<npt-add-card>` · Flutter: `NeptuneAddCard`.
 * Theme-only, RTL-safe, ≥88dp target.
 */
@Composable
public fun NeptuneAddCard(
    modifier: Modifier = Modifier,
    label: String = "Add card",
    onTap: (() -> Unit)? = null,
    disabled: Boolean = false,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    val outline = scheme.outline
    val cornerRadius = shape.lg

    Row(
        modifier = modifier
            .alpha(if (disabled) 0.38f else 1f)
            .clip(shape.rLg)
            // The dashed 2dp border, stroked 1dp inside the bounds (the Dart
            // _DashedBorderPainter: rect.deflate(1), radius = brand lg).
            .drawBehind {
                val inset = 1.dp.toPx()
                drawRoundRect(
                    color = outline,
                    topLeft = Offset(inset, inset),
                    size = Size(size.width - 2 * inset, size.height - 2 * inset),
                    cornerRadius = CornerRadius(cornerRadius.toPx()),
                    style = Stroke(
                        width = 2.dp.toPx(),
                        pathEffect = PathEffect.dashPathEffect(
                            floatArrayOf(DASH_ON.dp.toPx(), DASH_OFF.dp.toPx()),
                        ),
                    ),
                )
            }
            .clickable(enabled = !disabled && onTap != null) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onTap?.invoke()
            }
            .defaultMinSize(minHeight = 88.dp)
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // The circular plus chip.
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(shape.rFull)
                .background(scheme.secondaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                text = "+",
                style = typography.titleLarge.copy(
                    color = scheme.onSecondaryContainer,
                    fontWeight = FontWeight.W700,
                ),
            )
        }
        Spacer(Modifier.width(16.dp))
        Text(
            text = label,
            style = typography.bodyLarge.copy(color = scheme.onSurfaceVariant),
            modifier = Modifier.weight(1f),
        )
    }
}

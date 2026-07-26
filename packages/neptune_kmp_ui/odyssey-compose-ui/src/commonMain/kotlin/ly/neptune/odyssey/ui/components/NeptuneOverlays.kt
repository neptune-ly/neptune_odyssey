// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Branded overlays — dialog, modal sheet, menu and tooltip. Web counterparts:
// `<npt-dialog>` / `<npt-bottom-sheet>` / `<npt-menu>` + `<npt-menu-item>`
// (containers.ts) and `<npt-tooltip>` (feedback.ts) · Flutter:
// neptune_overlays.dart (showNeptuneDialog / showNeptuneSheet / NeptuneMenu /
// NeptuneTooltip). Each maps onto the Material overlay machinery
// (BasicAlertDialog / ModalBottomSheet / DropdownMenu / TooltipBox) but
// dresses it in the active Neptune theme: brand corner radii,
// surface-container fills, outlineVariant borders and the display/label/body
// type ramp. Theme-only, RTL-safe.
//
// Compose idiom: where Flutter shows overlays imperatively (showNeptuneDialog,
// showNeptuneSheet) this port is STATE-DRIVEN — compose [NeptuneDialog] /
// [NeptuneSheet] / [NeptuneMenu] while the overlay should be visible (the
// `if (open) { … }` idiom) and clear the flag from `onDismissRequest`. Action
// taps mirror Flutter's pop-then-handle order: the overlay is dismissed
// first, then the action's handler runs.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.BasicAlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MenuDefaults
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TooltipBox
import androidx.compose.material3.TooltipDefaults
import androidx.compose.material3.rememberTooltipState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.DialogProperties
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

// --- dialog --------------------------------------------------------------------

/**
 * A single action button in a [NeptuneDialog] actions row.
 *
 * Render mapping (the Flutter `NeptuneDialogAction` contract):
 *   * [primary] → a filled button (the affirmative action),
 *   * [destructive] → an error-coloured text button (delete/remove),
 *   * otherwise → a quiet text button.
 * Tapping dismisses the dialog first, then invokes [onClick].
 */
@Immutable
public class NeptuneDialogAction(
    public val label: String,
    public val onClick: (() -> Unit)? = null,
    public val primary: Boolean = false,
    public val destructive: Boolean = false,
)

/**
 * The branded modal dialog. Compose while it should be visible; every path
 * out (scrim tap, back press, action tap) calls [onDismissRequest].
 *
 * Web counterpart: `<npt-dialog>` · Flutter: `showNeptuneDialog`.
 *
 * The card sits on `surfaceContainerHigh` at the brand `lg` radius with 24dp
 * padding, capped at 560dp (web `min(560px, 100%)`) and riding the elev-5
 * recipe (web `--npt-elev-5`). When [icon] is given it renders in a 56dp
 * `primaryContainer` circle above a centred [title] (`titleLarge`);
 * [message] uses `bodyMedium` in `onSurfaceVariant`; an optional [content]
 * slot renders below. [actions] sit end-aligned and wrap (8dp gaps) — when
 * empty a single primary 'OK' action is added, mirroring Flutter.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
public fun NeptuneDialog(
    onDismissRequest: () -> Unit,
    title: String,
    modifier: Modifier = Modifier,
    message: String? = null,
    icon: (@Composable () -> Unit)? = null,
    actions: List<NeptuneDialogAction> = emptyList(),
    properties: DialogProperties = DialogProperties(),
    content: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val identity = NeptuneTheme.identity
    val shape = NeptuneTheme.shape.rLg
    val resolved = actions.ifEmpty { listOf(NeptuneDialogAction(label = "OK", primary = true)) }

    BasicAlertDialog(
        onDismissRequest = onDismissRequest,
        modifier = modifier,
        properties = properties,
    ) {
        Column(
            modifier = Modifier
                .widthIn(max = 560.dp)
                // Deep, soft drop (web `--npt-elev-5`: 0 28px 60px @ .30).
                .nptShadow(identity.elevation5(scheme), shape)
                .clip(shape)
                .background(scheme.surfaceContainerHigh)
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
        ) {
            if (icon != null) {
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterHorizontally)
                        .size(56.dp)
                        .clip(NeptuneTheme.shape.rFull)
                        .background(scheme.primaryContainer),
                    contentAlignment = Alignment.Center,
                ) {
                    CompositionLocalProvider(LocalContentColor provides scheme.onPrimaryContainer) {
                        // The Flutter recipe renders the dialog icon at 28dp.
                        Box(Modifier.size(28.dp), contentAlignment = Alignment.Center) { icon() }
                    }
                }
                Spacer(Modifier.height(16.dp))
            }
            Text(
                text = title,
                modifier = Modifier.fillMaxWidth(),
                textAlign = if (icon != null) TextAlign.Center else TextAlign.Start,
                style = typography.titleLarge,
                color = scheme.onSurface,
            )
            if (message != null) {
                Spacer(Modifier.height(8.dp))
                Text(
                    text = message,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = if (icon != null) TextAlign.Center else TextAlign.Start,
                    style = typography.bodyMedium,
                    color = scheme.onSurfaceVariant,
                )
            }
            if (content != null) {
                Spacer(Modifier.height(16.dp))
                content()
            }
            Spacer(Modifier.height(24.dp))
            DialogActions(resolved, onDismissRequest)
        }
    }
}

/** The end-aligned, wrapping row of dialog action buttons. */
@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun DialogActions(
    actions: List<NeptuneDialogAction>,
    onDismissRequest: () -> Unit,
) {
    FlowRow(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.End),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        for (action in actions) {
            DialogActionButton(action, onDismissRequest)
        }
    }
}

/** One dialog action, on the NeptuneButton sizing recipe (pill, ≥48dp). */
@Composable
private fun DialogActionButton(
    action: NeptuneDialogAction,
    onDismissRequest: () -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val shape = NeptuneTheme.shape.rFull
    val sizing = Modifier.defaultMinSize(minWidth = 64.dp, minHeight = 48.dp)
    // Dismiss first, then run the caller's handler (the Flutter pop order).
    val onTap: () -> Unit = {
        feedback.trigger(NptFeedbackCue.Tap, haptics)
        onDismissRequest()
        action.onClick?.invoke()
    }
    when {
        action.primary -> Button(onClick = onTap, modifier = sizing, shape = shape) {
            Text(action.label)
        }
        action.destructive -> TextButton(
            onClick = onTap,
            modifier = sizing,
            shape = shape,
            colors = ButtonDefaults.textButtonColors(contentColor = scheme.error),
        ) {
            Text(action.label)
        }
        else -> TextButton(onClick = onTap, modifier = sizing, shape = shape) {
            Text(action.label)
        }
    }
}

// --- bottom sheet ----------------------------------------------------------------

/**
 * The branded modal bottom sheet. Compose while it should be visible; swipe
 * down, scrim tap and back press all call [onDismissRequest].
 *
 * Web counterpart: `<npt-bottom-sheet>` · Flutter: `showNeptuneSheet`.
 *
 * The sheet sits on `surfaceContainerLow` with the brand `xl` radius on its
 * top corners, a 40% `scrim` (web `color-mix(scrim 40%, transparent)`), a
 * centred 32×4 grabber in `onSurfaceVariant` @ 40%, and is capped at the
 * Material sheet width (640dp — the web `min(640px, 100%)`). An optional
 * [title] in `titleMedium` precedes [content]; padding follows the Flutter
 * recipe (20 inline / 12 above the grabber / 20 below).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
public fun NeptuneSheet(
    onDismissRequest: () -> Unit,
    modifier: Modifier = Modifier,
    title: String? = null,
    content: @Composable ColumnScope.() -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val identity = NeptuneTheme.identity
    val s = NeptuneTheme.shape
    // Brand `xl` on the top corners only (web `border-start-start/end-radius`).
    val sheetShape = RoundedCornerShape(
        topStart = s.xl,
        topEnd = s.xl,
        bottomEnd = 0.dp,
        bottomStart = 0.dp,
    )
    ModalBottomSheet(
        onDismissRequest = onDismissRequest,
        modifier = modifier.nptShadow(identity.elevation5(scheme), sheetShape),
        shape = sheetShape,
        containerColor = scheme.surfaceContainerLow,
        contentColor = scheme.onSurface,
        scrimColor = scheme.scrim.copy(alpha = 0.40f),
        dragHandle = {
            Box(
                Modifier
                    .padding(top = 12.dp)
                    .size(width = 32.dp, height = 4.dp)
                    .clip(s.rFull)
                    .background(scheme.onSurfaceVariant.copy(alpha = 0.4f)),
            )
        },
    ) {
        Column(Modifier.padding(start = 20.dp, end = 20.dp, bottom = 20.dp)) {
            if (title != null) {
                Spacer(Modifier.height(16.dp))
                Text(text = title, style = typography.titleMedium, color = scheme.onSurface)
            }
            Spacer(Modifier.height(16.dp))
            content()
        }
    }
}

// --- menu ------------------------------------------------------------------------

/**
 * A single entry in a [NeptuneMenu]. [destructive] tints the label and icon
 * in `error`; [enabled] false renders the web `[disabled]` treatment.
 * The 20dp [icon] slot leads the label.
 */
@Immutable
public class NeptuneMenuItem(
    public val label: String,
    public val icon: (@Composable () -> Unit)? = null,
    public val destructive: Boolean = false,
    public val enabled: Boolean = true,
    public val onSelected: (() -> Unit)? = null,
)

/**
 * The branded popup menu, anchored to its position in the composition (place
 * it inside a `Box` beside the anchor, the DropdownMenu idiom). Selecting an
 * item dismisses the menu first, then runs the item's handler.
 *
 * Web counterpart: `<npt-menu>` + `<npt-menu-item>` · Flutter: `NeptuneMenu`.
 *
 * Surface `surfaceContainerHigh` at the brand `md` radius with a hairline
 * `outlineVariant` border and elevation-3 (the Flutter MenuStyle recipe);
 * 8dp vertical padding and a 180dp min width (web `min-inline-size`). Items
 * are ≥48dp rows, 16dp inline padding, `bodyLarge` labels.
 */
@Composable
public fun NeptuneMenu(
    expanded: Boolean,
    onDismissRequest: () -> Unit,
    items: List<NeptuneMenuItem>,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    DropdownMenu(
        expanded = expanded,
        onDismissRequest = onDismissRequest,
        modifier = modifier.widthIn(min = 180.dp),
        shape = NeptuneTheme.shape.rMd,
        containerColor = scheme.surfaceContainerHigh,
        shadowElevation = 3.dp,
        border = BorderStroke(1.dp, scheme.outlineVariant),
    ) {
        for (item in items) {
            DropdownMenuItem(
                text = { Text(item.label, style = typography.bodyLarge) },
                onClick = {
                    feedback.trigger(NptFeedbackCue.Tap, haptics)
                    onDismissRequest()
                    item.onSelected?.invoke()
                },
                enabled = item.enabled,
                leadingIcon = item.icon?.let { slot ->
                    {
                        Box(Modifier.size(20.dp), contentAlignment = Alignment.Center) { slot() }
                    }
                },
                colors = MenuDefaults.itemColors(
                    textColor = if (item.destructive) scheme.error else scheme.onSurface,
                    leadingIconColor = if (item.destructive) scheme.error else scheme.onSurfaceVariant,
                ),
                contentPadding = PaddingValues(horizontal = 16.dp),
            )
        }
    }
}

// --- tooltip ---------------------------------------------------------------------

/**
 * A branded plain tooltip wrapping [content]: a small `inverseSurface`
 * bubble with `onInverseSurface` `bodySmall` text at the brand `xs` radius
 * (padding 12×8), floating 8dp above the anchor (web `--npt-space-2` gap).
 * Reveals on hover/focus (pointer) or long-press (touch).
 *
 * Web counterpart: `<npt-tooltip>` · Flutter: `NeptuneTooltip`.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
public fun NeptuneTooltip(
    message: String,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    TooltipBox(
        positionProvider = TooltipDefaults.rememberPlainTooltipPositionProvider(
            spacingBetweenTooltipAndAnchor = 8.dp,
        ),
        tooltip = {
            Box(
                Modifier
                    .clip(NeptuneTheme.shape.rXs)
                    .background(scheme.inverseSurface)
                    .padding(horizontal = 12.dp, vertical = 8.dp),
            ) {
                Text(text = message, style = typography.bodySmall, color = scheme.inverseOnSurface)
            }
        },
        state = rememberTooltipState(),
        modifier = modifier,
    ) {
        content()
    }
}

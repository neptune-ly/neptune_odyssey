// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Corporate & back-office widgets. Web counterpart: corporate.ts · Flutter:
// neptune_corporate.dart. Approval queue items, bulk-payment batch cards,
// audit-log rows, user-admin rows, permission toggles and compact workflow
// status. Theme-only (colour, shape, type read from the active theme),
// RTL-safe. The approval item carries the Flutter ≤430dp overflow fix
// forward: on narrow widths the amount ellipsises beside the title and the
// Approve/Reject pair stacks full-width below it.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.toggleable
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.glyphs.NptCorporateGlyphs
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue
import ly.neptune.odyssey.ui.theme.NptShadow
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/**
 * A maker-checker queue item: a title/subtitle, an amount in tabular
 * figures, and Approve (filled) + Reject (outlined) actions.
 *
 * Web counterpart: `<npt-approval-item>` · Flutter: `NeptuneApprovalItem`.
 *
 * On narrow widths (< 440dp — mobile) the buttons can't fit beside the
 * title, so they stack full-width below it and the amount ellipsises rather
 * than overflowing (the Flutter ≤430dp fix). A null [onApprove]/[onReject]
 * disables that action.
 */
@Composable
public fun NeptuneApprovalItem(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    amount: String? = null,
    onApprove: (() -> Unit)? = null,
    onReject: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rMd
    val money = NeptuneTheme.moneyStyle(base = typography.titleMedium)
        .copy(color = scheme.onSurface, fontWeight = FontWeight.W600)

    val info: @Composable () -> Unit = {
        Column {
            Text(
                title,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = typography.bodyLarge.copy(
                    color = scheme.onSurface,
                    fontWeight = FontWeight.W600,
                ),
            )
            if (subtitle != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    subtitle,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                )
            }
        }
    }

    BoxWithConstraints(
        modifier
            .clip(shape)
            .background(scheme.surfaceContainerLow)
            .border(1.dp, scheme.outlineVariant, shape)
            .padding(16.dp),
    ) {
        val narrow = maxWidth < 440.dp
        if (narrow) {
            Column {
                Row(verticalAlignment = Alignment.Top) {
                    Box(Modifier.weight(1f)) { info() }
                    if (amount != null) {
                        Spacer(Modifier.width(12.dp))
                        // Flexible + ellipsis: the amount may shrink but
                        // never blanks or overflows the row.
                        Text(
                            amount,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            textAlign = TextAlign.End,
                            style = money,
                            modifier = Modifier.weight(1f, fill = false),
                        )
                    }
                }
                Spacer(Modifier.height(12.dp))
                Row {
                    NeptuneButton(
                        label = "Reject",
                        onClick = onReject,
                        modifier = Modifier.weight(1f),
                        variant = NeptuneButtonStyle.Outlined,
                    )
                    Spacer(Modifier.width(8.dp))
                    NeptuneButton(
                        label = "Approve",
                        onClick = onApprove,
                        modifier = Modifier.weight(1f),
                    )
                }
            }
        } else {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.weight(1f)) { info() }
                if (amount != null) {
                    Spacer(Modifier.width(16.dp))
                    Text(amount, style = money)
                }
                Spacer(Modifier.width(16.dp))
                NeptuneButton(
                    label = "Reject",
                    onClick = onReject,
                    variant = NeptuneButtonStyle.Outlined,
                )
                Spacer(Modifier.width(8.dp))
                NeptuneButton(label = "Approve", onClick = onApprove)
            }
        }
    }
}

/**
 * A bulk-payment batch summary: a title, a count of items, a total amount in
 * tabular figures, and an optional status pill.
 *
 * Web counterpart: `<npt-batch-card>` · Flutter: `NeptuneBatchCard`.
 */
@Composable
public fun NeptuneBatchCard(
    title: String,
    count: String,
    total: String,
    modifier: Modifier = Modifier,
    status: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val type = NeptuneTheme.type
    val shape = NeptuneTheme.shape
    val money = NeptuneTheme.moneyStyle(base = typography.headlineSmall).copy(
        color = scheme.onSurface,
        fontWeight = FontWeight.W700,
        letterSpacing = (type.displayTracking * 28).sp,
    )

    Column(
        modifier
            // The Flutter card shadow: shadow-black (the scrim role) at 12%,
            // blur 3, y-offset 1.
            .nptShadow(
                listOf(
                    NptShadow(
                        color = scheme.scrim.copy(alpha = 0.12f),
                        blurRadius = 3.dp,
                        offsetY = 1.dp,
                    ),
                ),
                shape.rLg,
            )
            .clip(shape.rLg)
            .background(scheme.surfaceContainer)
            .padding(24.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier
                    .size(40.dp)
                    .clip(shape.rSm)
                    .background(scheme.primaryContainer),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    NptCorporateGlyphs.gridView,
                    contentDescription = null,
                    tint = scheme.onPrimaryContainer,
                    modifier = Modifier.size(20.dp),
                )
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(
                    title,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = typography.bodyLarge.copy(
                        color = scheme.onSurface,
                        fontWeight = FontWeight.W600,
                    ),
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    "$count items",
                    style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                )
            }
            if (status != null) {
                Spacer(Modifier.width(12.dp))
                BatchStatusChip(status)
            }
        }
        Spacer(Modifier.height(16.dp))
        Text(total, style = money)
    }
}

/** The batch-status pill: a neutral `surfaceContainerHighest` chip. */
@Composable
private fun BatchStatusChip(label: String) {
    val scheme = MaterialTheme.colorScheme
    Box(
        Modifier
            .clip(NeptuneTheme.shape.rFull)
            .background(scheme.surfaceContainerHighest)
            .defaultMinSize(minHeight = 24.dp)
            .padding(horizontal = 12.dp, vertical = 4.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = MaterialTheme.typography.labelSmall.copy(
                color = scheme.onSurfaceVariant,
                fontWeight = FontWeight.W600,
            ),
        )
    }
}

/**
 * A compact audit-log line: a leading `primary` status dot (or an optional
 * 16dp [icon] slot), the actor + action text, and a trailing timestamp in
 * tabular figures, over an outline-variant bottom hairline.
 *
 * Web counterpart: `<npt-audit-row>` · Flutter: `NeptuneAuditRow`.
 */
@Composable
public fun NeptuneAuditRow(
    actor: String,
    action: String,
    time: String,
    modifier: Modifier = Modifier,
    icon: (@Composable () -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val timeStyle = NeptuneTheme.moneyStyle(base = typography.labelSmall)
        .copy(color = scheme.onSurfaceVariant)

    Row(
        modifier
            .drawBehind {
                // The bottom hairline (Flutter Border.bottom, outline-variant).
                val line = 1.dp.toPx()
                drawRect(
                    color = scheme.outlineVariant,
                    topLeft = Offset(0f, size.height - line),
                    size = Size(size.width, line),
                )
            }
            .defaultMinSize(minHeight = 36.dp)
            .padding(horizontal = 8.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            CompositionLocalProvider(LocalContentColor provides scheme.primary) {
                Box(Modifier.size(16.dp), contentAlignment = Alignment.Center) { icon() }
            }
        } else {
            Box(
                Modifier
                    .size(8.dp)
                    .clip(NeptuneTheme.shape.rFull)
                    .background(scheme.primary),
            )
        }
        Spacer(Modifier.width(12.dp))
        Text(
            buildAnnotatedString {
                withStyle(SpanStyle(color = scheme.onSurface, fontWeight = FontWeight.W600)) {
                    append(actor)
                }
                append(' ')
                withStyle(SpanStyle(color = scheme.onSurfaceVariant)) {
                    append(action)
                }
            },
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = typography.bodyMedium,
            modifier = Modifier.weight(1f),
        )
        Spacer(Modifier.width(12.dp))
        Text(time, style = timeStyle)
    }
}

/**
 * A user-admin list row: a 40dp `primaryContainer` initials disc (or a
 * custom [avatar] slot), name + role, an optional secondary-container status
 * pill and an optional tap target ([onClick]).
 *
 * Web counterpart: `<npt-user-row>` · Flutter: `NeptuneUserRow`.
 */
@Composable
public fun NeptuneUserRow(
    name: String,
    modifier: Modifier = Modifier,
    role: String? = null,
    status: String? = null,
    avatar: (@Composable () -> Unit)? = null,
    onClick: (() -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape
    val display = rememberNeptuneFontFamily(NeptuneTheme.type.display)
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current

    val clickableModifier = if (onClick != null) {
        Modifier
            .clip(shape.rSm)
            .clickable {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onClick()
            }
    } else {
        Modifier
    }

    Row(
        modifier
            .then(clickableModifier)
            .drawBehind {
                val line = 1.dp.toPx()
                drawRect(
                    color = scheme.outlineVariant,
                    topLeft = Offset(0f, size.height - line),
                    size = Size(size.width, line),
                )
            }
            .defaultMinSize(minHeight = 56.dp)
            .padding(horizontal = 8.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            Modifier
                .size(40.dp)
                .clip(shape.rFull)
                .background(scheme.primaryContainer),
            contentAlignment = Alignment.Center,
        ) {
            if (avatar != null) {
                avatar()
            } else {
                Text(
                    initialsOf(name),
                    style = typography.labelLarge.copy(
                        fontFamily = display ?: typography.labelLarge.fontFamily,
                        fontWeight = FontWeight.W600,
                        color = scheme.onPrimaryContainer,
                    ),
                )
            }
        }
        Spacer(Modifier.width(16.dp))
        Column(Modifier.weight(1f)) {
            Text(
                name,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = typography.bodyLarge.copy(
                    color = scheme.onSurface,
                    fontWeight = FontWeight.W600,
                ),
            )
            if (role != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    role,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                )
            }
        }
        if (status != null) {
            Spacer(Modifier.width(16.dp))
            UserStatusChip(status)
        }
    }
}

/** The first letters of the first two words of [name], uppercased. */
private fun initialsOf(name: String): String {
    val letters = name.trim()
        .split(Regex("\\s+"))
        .filter { it.isNotEmpty() }
        .take(2)
        .map { it.first().uppercaseChar() }
        .joinToString("")
    return letters.ifEmpty { "?" }
}

/** The user-row status chip: a secondary-container pill. Theme-only. */
@Composable
private fun UserStatusChip(label: String) {
    val scheme = MaterialTheme.colorScheme
    Box(
        Modifier
            .clip(NeptuneTheme.shape.rFull)
            .background(scheme.secondaryContainer)
            .defaultMinSize(minHeight = 24.dp)
            .padding(horizontal = 12.dp, vertical = 4.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = MaterialTheme.typography.labelSmall.copy(
                color = scheme.onSecondaryContainer,
                fontWeight = FontWeight.W600,
            ),
        )
    }
}

/**
 * A permission row: a label, optional description and a trailing
 * [NeptuneSwitch]. Tapping anywhere on the row toggles the value; a null
 * [onChanged] disables it. At least 48dp tall.
 *
 * Web counterpart: `<npt-permission-toggle>` · Flutter:
 * `NeptunePermissionToggle`.
 */
@Composable
public fun NeptunePermissionToggle(
    label: String,
    value: Boolean,
    onChanged: ((Boolean) -> Unit)?,
    modifier: Modifier = Modifier,
    description: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val enabled = onChanged != null

    Row(
        modifier
            .clip(NeptuneTheme.shape.rSm)
            .toggleable(
                value = value,
                enabled = enabled,
                role = Role.Switch,
            ) { next ->
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onChanged?.invoke(next)
            }
            .defaultMinSize(minHeight = 48.dp)
            .padding(horizontal = 4.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(Modifier.weight(1f)) {
            Text(label, style = typography.bodyLarge.copy(color = scheme.onSurface))
            if (description != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    description,
                    style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                )
            }
        }
        Spacer(Modifier.width(16.dp))
        NeptuneSwitch(value = value, onChanged = onChanged)
    }
}

/**
 * A compact multi-step status: a 'Step k of n' label with a mini 4dp linear
 * progress track (`primary` fill, `success` once complete). [step] is
 * 1-based.
 *
 * Web counterpart: `<npt-workflow-status>` · Flutter:
 * `NeptuneWorkflowStatus`.
 */
@Composable
public fun NeptuneWorkflowStatus(
    label: String,
    step: Int,
    total: Int,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val npt = NeptuneTheme.colors
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rFull

    val safeTotal = if (total <= 0) 1 else total
    val clampedStep = step.coerceIn(0, safeTotal)
    val progress = (clampedStep.toFloat() / safeTotal).coerceIn(0f, 1f)
    val complete = clampedStep >= safeTotal

    Column(modifier) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                label,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = typography.labelLarge.copy(color = scheme.onSurface),
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.width(8.dp))
            Text(
                NeptuneTheme.formatDigits("Step $clampedStep of $safeTotal"),
                style = NeptuneTheme.moneyStyle(base = typography.labelSmall)
                    .copy(color = scheme.onSurfaceVariant),
            )
        }
        Spacer(Modifier.height(8.dp))
        Box(
            Modifier
                .fillMaxWidth()
                .height(4.dp)
                .clip(shape)
                .background(scheme.surfaceContainerHighest),
        ) {
            Box(
                Modifier
                    .fillMaxWidth(progress)
                    .fillMaxHeight()
                    .clip(shape)
                    .background(if (complete) npt.success else scheme.primary),
            )
        }
    }
}

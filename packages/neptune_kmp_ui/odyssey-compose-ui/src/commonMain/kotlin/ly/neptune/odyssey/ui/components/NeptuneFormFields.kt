// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Branded form inputs. Web counterparts: `<npt-select>`, `<npt-stepper>`,
// `<npt-date-field>` · Flutter: neptune_form_fields.dart. All three wear the
// NeptuneTextField decoration — filled surface-container-highest on the brand
// `sm` corner, 2dp primary focus ring, outline-variant hairline when
// disabled. Theme-only, ≥48dp targets, RTL-safe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.OffsetMapping
import androidx.compose.ui.text.input.TransformedText
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.glyphs.NptInputGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/** One option in a [NeptuneSelect]: a [value], its [label], and an optional
 * leading [icon] slot (20dp, onSurfaceVariant tint) shown in the menu and in
 * the closed field. Flutter: `NeptuneSelectOption`. */
@Immutable
public class NeptuneSelectOption<T>(
    public val value: T,
    public val label: String,
    public val icon: (@Composable () -> Unit)? = null,
)

/**
 * A labelled, branded dropdown select.
 *
 * Web counterpart: `<npt-select>` · Flutter: `NeptuneSelect`.
 *
 * The closed field matches [NeptuneTextField] (filled
 * `surfaceContainerHighest`, brand `sm` corners, 2dp primary ring while the
 * menu is open, outline-variant hairline when disabled) with a caret suffix.
 * The menu is a field-width `surfaceContainerHigh` popup on the same `sm`
 * corner; items show the option's icon slot before its label (bodyLarge,
 * onSurface). [onChanged] null (or `enabled = false`) disables the control.
 */
@Composable
public fun <T> NeptuneSelect(
    options: List<NeptuneSelectOption<T>>,
    value: T?,
    onChanged: ((T) -> Unit)?,
    modifier: Modifier = Modifier,
    label: String? = null,
    hint: String? = null,
    enabled: Boolean = true,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rSm
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val density = LocalDensity.current
    val isOn = enabled && onChanged != null

    var expanded by remember { mutableStateOf(false) }
    var fieldWidthPx by remember { mutableIntStateOf(0) }

    val fill = if (isOn) {
        scheme.surfaceContainerHighest
    } else {
        scheme.surfaceContainerHighest.copy(alpha = 0.5f)
    }
    // No border at rest; primary ring while open; hairline when disabled —
    // the NeptuneTextField border table.
    val borderModifier = when {
        expanded && isOn -> Modifier.border(2.dp, scheme.primary, shape)
        !isOn -> Modifier.border(1.dp, scheme.outlineVariant, shape)
        else -> Modifier
    }
    val selected = options.firstOrNull { it.value == value }

    Column(modifier) {
        if (label != null) {
            Text(
                text = label,
                style = typography.labelMedium.copy(
                    color = if (isOn) {
                        scheme.onSurfaceVariant
                    } else {
                        scheme.onSurfaceVariant.copy(alpha = 0.5f)
                    },
                ),
            )
            Spacer(Modifier.height(6.dp))
        }
        Box {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .onSizeChanged { fieldWidthPx = it.width }
                    .defaultMinSize(minHeight = 48.dp)
                    .clip(shape)
                    .background(fill)
                    .then(borderModifier)
                    .clickable(enabled = isOn, role = Role.DropdownList) {
                        feedback.trigger(NptFeedbackCue.Tap, haptics)
                        expanded = true
                    }
                    .padding(horizontal = 16.dp, vertical = 14.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                if (selected?.icon != null) {
                    CompositionLocalProvider(LocalContentColor provides scheme.onSurfaceVariant) {
                        Box(Modifier.size(20.dp), contentAlignment = Alignment.Center) {
                            selected.icon.invoke()
                        }
                    }
                    Spacer(Modifier.width(12.dp))
                }
                Text(
                    text = selected?.label ?: hint.orEmpty(),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = typography.bodyLarge.copy(
                        color = if (selected != null) {
                            scheme.onSurface
                        } else {
                            scheme.onSurfaceVariant.copy(alpha = 0.6f)
                        },
                    ),
                    modifier = Modifier.weight(1f),
                )
                Spacer(Modifier.width(12.dp))
                Icon(
                    NptInputGlyphs.caretDown,
                    contentDescription = null,
                    tint = scheme.onSurfaceVariant,
                    modifier = Modifier.size(24.dp),
                )
            }
            DropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false },
                modifier = Modifier.width(with(density) { fieldWidthPx.toDp() }),
                shape = shape,
                containerColor = scheme.surfaceContainerHigh,
            ) {
                options.forEach { option ->
                    DropdownMenuItem(
                        text = {
                            Text(
                                text = option.label,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                                style = typography.bodyLarge.copy(color = scheme.onSurface),
                            )
                        },
                        leadingIcon = option.icon?.let { icon ->
                            {
                                CompositionLocalProvider(
                                    LocalContentColor provides scheme.onSurfaceVariant,
                                ) {
                                    Box(
                                        Modifier.size(20.dp),
                                        contentAlignment = Alignment.Center,
                                    ) { icon() }
                                }
                            }
                        },
                        onClick = {
                            feedback.trigger(NptFeedbackCue.Tap, haptics)
                            expanded = false
                            onChanged?.invoke(option.value)
                        },
                    )
                }
            }
        }
    }
}

/**
 * A branded numeric +/- stepper: a pill row (`surfaceContainerHighest` on
 * the brand `full` corner with an outline-variant hairline) of a minus
 * control, the centred value (titleMedium, tabular figures) and a plus
 * control. Minus disables at [min], plus at [max]; both are 48dp targets.
 *
 * Web counterpart: `<npt-stepper>` · Flutter: `NeptuneStepperInput`.
 *
 * [onChanged] receives the clamped new value per tap; null disables the
 * control. RTL-safe (minus leads the reading direction, like the sources).
 */
@Composable
public fun NeptuneStepperInput(
    value: Int,
    onChanged: ((Int) -> Unit)?,
    modifier: Modifier = Modifier,
    min: Int = 0,
    max: Int = 9999,
    step: Int = 1,
    label: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rFull

    val canDecrement = onChanged != null && value > min
    val canIncrement = onChanged != null && value < max
    fun emit(next: Int) {
        onChanged?.invoke(next.coerceIn(min, max))
    }

    Column(modifier) {
        if (label != null) {
            Text(
                text = label,
                style = typography.labelMedium.copy(color = scheme.onSurfaceVariant),
            )
            Spacer(Modifier.height(6.dp))
        }
        Row(
            modifier = Modifier
                .clip(shape)
                .background(scheme.surfaceContainerHighest)
                .border(1.dp, scheme.outlineVariant, shape),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            StepperControl(
                glyph = NptInputGlyphs.minus,
                contentDescription = "Decrease",
                enabled = canDecrement,
                onTap = { emit(value - step) },
            )
            Text(
                text = NeptuneTheme.formatDigits(value.toString()),
                textAlign = TextAlign.Center,
                style = typography.titleMedium.copy(
                    color = scheme.onSurface,
                    fontFeatureSettings = "tnum",
                ),
                modifier = Modifier.defaultMinSize(minWidth = 40.dp),
            )
            StepperControl(
                glyph = NptInputGlyphs.plus,
                contentDescription = "Increase",
                enabled = canIncrement,
                onTap = { emit(value + step) },
            )
        }
    }
}

/** A 48dp round +/- control used by [NeptuneStepperInput]. */
@Composable
private fun StepperControl(
    glyph: ImageVector,
    contentDescription: String,
    enabled: Boolean,
    onTap: () -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val tint = if (enabled) scheme.onSurface else scheme.onSurfaceVariant.copy(alpha = 0.4f)

    Box(
        modifier = Modifier
            .size(48.dp)
            .clip(NeptuneTheme.shape.rFull)
            .clickable(enabled = enabled, role = Role.Button) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onTap()
            },
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            glyph,
            contentDescription = contentDescription,
            tint = tint,
            modifier = Modifier.size(20.dp),
        )
    }
}

/** Inserts the `yyyy-MM-dd` dashes over a digits-only field value. */
private object DateDashTransformation : VisualTransformation {
    override fun filter(text: AnnotatedString): TransformedText {
        val out = buildString {
            text.text.forEachIndexed { i, c ->
                if (i == 4 || i == 6) append('-')
                append(c)
            }
        }
        val mapping = object : OffsetMapping {
            override fun originalToTransformed(offset: Int): Int =
                offset + (if (offset > 4) 1 else 0) + (if (offset > 6) 1 else 0)

            override fun transformedToOriginal(offset: Int): Int =
                offset - (if (offset > 4) 1 else 0) - (if (offset > 7) 1 else 0)
        }
        return TransformedText(AnnotatedString(out), mapping)
    }
}

/** Digits of [formatted] (max 8), dropping the dashes. */
private fun dateDigits(formatted: String): String =
    formatted.filter { it in '0'..'9' }.take(8)

/** Format [digits] (≤8) as a partial `yyyy-MM-dd` string. */
private fun formatDate(digits: String): String = buildString {
    digits.forEachIndexed { i, c ->
        if (i == 4 || i == 6) append('-')
        append(c)
    }
}

/**
 * A branded date field with formatted text entry: digits format as
 * `yyyy-MM-dd` while typing (no picker dependency — the Compose stand-in
 * for the Flutter widget's `showDatePicker` flow).
 *
 * Web counterpart: `<npt-date-field>` · Flutter: `NeptuneDateField`.
 *
 * Decoration matches [NeptuneTextField]: filled `surfaceContainerHighest`
 * on the brand `sm` corner (2dp primary ring on focus, outline-variant
 * hairline when disabled), bodyLarge value with tabular figures, the
 * `yyyy-MM-dd` [hint] at 60% onSurfaceVariant and a 20dp calendar suffix.
 *
 * [value] and [onValueChange] carry the formatted (possibly partial)
 * `yyyy-MM-dd` string; [onComplete] fires once all eight digits are typed.
 */
@Composable
public fun NeptuneDateField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    label: String? = null,
    hint: String? = null,
    enabled: Boolean = true,
    onComplete: ((String) -> Unit)? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rSm
    var focused by remember { mutableStateOf(false) }

    val digits = dateDigits(value)
    val hasValue = digits.isNotEmpty()
    val fill = if (enabled) {
        scheme.surfaceContainerHighest
    } else {
        scheme.surfaceContainerHighest.copy(alpha = 0.5f)
    }
    val borderModifier = when {
        focused && enabled -> Modifier.border(2.dp, scheme.primary, shape)
        !enabled -> Modifier.border(1.dp, scheme.outlineVariant, shape)
        else -> Modifier
    }
    val textStyle = typography.bodyLarge.copy(
        color = scheme.onSurface,
        fontFeatureSettings = "tnum",
    )

    Column(modifier) {
        if (label != null) {
            Text(
                text = label,
                style = typography.labelMedium.copy(color = scheme.onSurfaceVariant),
            )
            Spacer(Modifier.height(6.dp))
        }
        BasicTextField(
            value = digits,
            onValueChange = { raw ->
                val clean = dateDigits(raw)
                if (clean != digits) {
                    val formatted = formatDate(clean)
                    onValueChange(formatted)
                    if (clean.length == 8) onComplete?.invoke(formatted)
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .onFocusChanged { focused = it.isFocused },
            enabled = enabled,
            textStyle = textStyle,
            cursorBrush = SolidColor(scheme.primary),
            visualTransformation = DateDashTransformation,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            singleLine = true,
            decorationBox = { innerTextField ->
                Row(
                    modifier = Modifier
                        .defaultMinSize(minHeight = 48.dp)
                        .clip(shape)
                        .background(fill)
                        .then(borderModifier)
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(Modifier.weight(1f)) {
                        if (!hasValue) {
                            Text(
                                text = hint ?: "yyyy-MM-dd",
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                                style = typography.bodyLarge.copy(
                                    color = scheme.onSurfaceVariant.copy(alpha = 0.6f),
                                ),
                            )
                        }
                        innerTextField()
                    }
                    Spacer(Modifier.width(12.dp))
                    Icon(
                        NptInputGlyphs.calendar,
                        contentDescription = null,
                        tint = scheme.onSurfaceVariant,
                        modifier = Modifier.size(20.dp),
                    )
                }
            },
        )
    }
}

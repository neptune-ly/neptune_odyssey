// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Branded selection controls. Web counterparts: `<npt-checkbox>`,
// `<npt-radio>`, `<npt-switch>`, `<npt-slider>` (selection.ts) · Flutter:
// neptune_selection_controls.dart. A 22dp `xs`-corner checkbox that fills
// primary, radio tiles with a spring-in primary dot, a 52×32 pill switch
// whose thumb travels on the brand emphasized curve, and a 6dp-track slider
// with a primary value bubble. Theme-only, ≥48dp targets, RTL-safe,
// reduced-motion gated.

package ly.neptune.odyssey.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsDraggedAsState
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
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
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.selection.toggleable
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.BiasAlignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.layout.layout
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt
import ly.neptune.odyssey.ui.glyphs.NptGlyphs
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptFeedbackCue

/**
 * A branded checkbox: a 22dp rounded (brand `xs` corner) box that fills with
 * `primary` and shows an `onPrimary` check when [value] is true, else an
 * outline border. The control sits inside a 48dp tappable area.
 *
 * Web counterpart: `<npt-checkbox>` · Flutter: `NeptuneCheckbox`.
 *
 * Pass `onChanged = null` (or `enabled = false`) to disable it. Fill and
 * border animate on the brand `motion.standard` curve over `fastMs`
 * (snapping under reduced motion).
 */
@Composable
public fun NeptuneCheckbox(
    value: Boolean,
    onChanged: ((Boolean) -> Unit)?,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val motion = NeptuneTheme.motion
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val reduced = NeptuneTheme.reducedMotion
    val isOn = onChanged != null && enabled

    val fill by animateColorAsState(
        targetValue = when {
            value && isOn -> scheme.primary
            value -> scheme.onSurface.copy(alpha = 0.12f)
            else -> scheme.surface.copy(alpha = 0f)
        },
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "checkboxFill",
    )
    val borderColor by animateColorAsState(
        targetValue = when {
            value && isOn -> scheme.primary
            value -> scheme.onSurface.copy(alpha = 0.12f)
            isOn -> scheme.outline
            else -> scheme.outlineVariant
        },
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "checkboxBorder",
    )
    val checkColor = if (isOn) scheme.onPrimary else scheme.onSurface.copy(alpha = 0.38f)

    Box(
        modifier = modifier
            .size(48.dp)
            .clip(shape.rFull)
            .toggleable(
                value = value,
                enabled = isOn,
                role = Role.Checkbox,
            ) { next ->
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onChanged?.invoke(next)
            },
        contentAlignment = Alignment.Center,
    ) {
        Box(
            modifier = Modifier
                .size(22.dp)
                .clip(shape.rXs)
                .background(fill)
                .border(2.dp, borderColor, shape.rXs),
            contentAlignment = Alignment.Center,
        ) {
            if (value) {
                Icon(
                    NptGlyphs.check,
                    contentDescription = null,
                    tint = checkColor,
                    modifier = Modifier.size(16.dp),
                )
            }
        }
    }
}

/**
 * A full-width selectable row: a [NeptuneCheckbox] beside a [label]
 * (bodyLarge) and optional [description] (bodySmall, onSurfaceVariant) on a
 * rounded `surfaceContainerLow` background (brand `md` corner). Tapping
 * anywhere on the row toggles the value. At least 48dp tall.
 *
 * Web counterpart: `<npt-checkbox>` with slotted label ·
 * Flutter: `NeptuneCheckboxTile`.
 */
@Composable
public fun NeptuneCheckboxTile(
    label: String,
    value: Boolean,
    onChanged: ((Boolean) -> Unit)?,
    modifier: Modifier = Modifier,
    description: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rMd
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val enabled = onChanged != null
    val fg = if (enabled) scheme.onSurface else scheme.onSurface.copy(alpha = 0.38f)

    Row(
        modifier = modifier
            .clip(shape)
            .background(scheme.surfaceContainerLow)
            .toggleable(
                value = value,
                enabled = enabled,
                role = Role.Checkbox,
            ) { next ->
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onChanged?.invoke(next)
            }
            .defaultMinSize(minHeight = 48.dp)
            .padding(start = 4.dp, end = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        NeptuneCheckbox(
            value = value,
            enabled = enabled,
            onChanged = onChanged,
        )
        Spacer(Modifier.width(8.dp))
        Column(Modifier.weight(1f)) {
            Text(text = label, style = typography.bodyLarge.copy(color = fg))
            if (description != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    text = description,
                    style = typography.bodySmall.copy(color = scheme.onSurfaceVariant),
                )
            }
        }
    }
}

/** One option in a [NeptuneRadioGroup]: its [value], a [label] and an
 * optional secondary [description] line. Flutter: `NeptuneRadioOption`. */
@Immutable
public data class NeptuneRadioOption<T>(
    public val value: T,
    public val label: String,
    public val description: String? = null,
)

/**
 * A vertical list of branded radio tiles. The selected tile shows a filled
 * `primary` dot inside its ring (scaling in on the brand `motion.standard`
 * curve) over a 40%-alpha `secondaryContainer` wash; others show an empty
 * `outline` ring on `surfaceContainerLow`. Each tile is at least 48dp tall.
 *
 * Web counterpart: `<npt-radio>` · Flutter: `NeptuneRadioGroup`.
 *
 * [onChanged] receives an option's value when its tile is tapped; null
 * disables the whole group. RTL-safe, reduced-motion gated.
 */
@Composable
public fun <T> NeptuneRadioGroup(
    options: List<NeptuneRadioOption<T>>,
    value: T?,
    onChanged: ((T) -> Unit)?,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.selectableGroup(),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        options.forEach { option ->
            RadioTile(
                option = option,
                selected = value == option.value,
                onTap = onChanged?.let { change -> { change(option.value) } },
            )
        }
    }
}

/** A single tappable radio row used by [NeptuneRadioGroup]. */
@Composable
private fun <T> RadioTile(
    option: NeptuneRadioOption<T>,
    selected: Boolean,
    onTap: (() -> Unit)?,
    modifier: Modifier = Modifier,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape.rMd
    val motion = NeptuneTheme.motion
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val reduced = NeptuneTheme.reducedMotion
    val enabled = onTap != null

    val ringColor by animateColorAsState(
        targetValue = when {
            selected && enabled -> scheme.primary
            selected -> scheme.onSurface.copy(alpha = 0.12f)
            enabled -> scheme.outline
            else -> scheme.outlineVariant
        },
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "radioRing",
    )
    val dotColor = if (enabled) scheme.primary else scheme.onSurface.copy(alpha = 0.38f)
    val dotScale by animateFloatAsState(
        targetValue = if (selected) 1f else 0f,
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "radioDot",
    )
    val bg by animateColorAsState(
        targetValue = if (selected) {
            scheme.secondaryContainer.copy(alpha = 0.4f)
        } else {
            scheme.surfaceContainerLow
        },
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "radioTileFill",
    )
    val fg = if (enabled) scheme.onSurface else scheme.onSurface.copy(alpha = 0.38f)

    Row(
        modifier = modifier
            .clip(shape)
            .background(bg)
            .selectable(
                selected = selected,
                enabled = enabled,
                role = Role.RadioButton,
            ) {
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onTap?.invoke()
            }
            .defaultMinSize(minHeight = 48.dp)
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(22.dp)
                .border(2.dp, ringColor, NeptuneTheme.shape.rFull),
            contentAlignment = Alignment.Center,
        ) {
            Box(
                Modifier
                    .size(12.dp)
                    .scale(dotScale)
                    .clip(NeptuneTheme.shape.rFull)
                    .background(dotColor),
            )
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(text = option.label, style = typography.bodyLarge.copy(color = fg))
            if (option.description != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    text = option.description,
                    style = typography.bodySmall.copy(color = scheme.onSurfaceVariant),
                )
            }
        }
    }
}

/**
 * A branded on/off switch: a 52×32 pill track (`primary` when on,
 * `surfaceContainerHighest` when off, animated on `motion.standard`) with a
 * 26dp thumb (`onPrimary` / `outline`) travelling on the brand
 * `motion.emphasized` curve. The whole control lives in a 56×48 tap area.
 *
 * Web counterpart: `<npt-switch>` · Flutter: `NeptuneSwitch`.
 *
 * Pass `onChanged = null` (or `enabled = false`) to disable it. The thumb
 * runs start→end, mirroring under RTL. Reduced motion snaps.
 */
@Composable
public fun NeptuneSwitch(
    value: Boolean,
    onChanged: ((Boolean) -> Unit)?,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
) {
    val scheme = MaterialTheme.colorScheme
    val shape = NeptuneTheme.shape
    val motion = NeptuneTheme.motion
    val feedback = NeptuneTheme.feedback
    val haptics: HapticFeedback = LocalHapticFeedback.current
    val reduced = NeptuneTheme.reducedMotion
    val isOn = onChanged != null && enabled

    val trackColor by animateColorAsState(
        targetValue = when {
            value && isOn -> scheme.primary
            value -> scheme.onSurface.copy(alpha = 0.12f)
            isOn -> scheme.surfaceContainerHighest
            else -> scheme.onSurface.copy(alpha = 0.06f)
        },
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "switchTrack",
    )
    val thumbColor by animateColorAsState(
        targetValue = when {
            value && isOn -> scheme.onPrimary
            value -> scheme.surface
            isOn -> scheme.outline
            else -> scheme.onSurface.copy(alpha = 0.38f)
        },
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "switchThumb",
    )
    // centerStart (-1) ↔ centerEnd (+1) on the emphasized curve — the
    // Flutter AnimatedAlign; BiasAlignment mirrors under RTL by itself.
    val thumbBias by animateFloatAsState(
        targetValue = if (value) 1f else -1f,
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.emphasized),
        label = "switchTravel",
    )

    Box(
        modifier = modifier
            .size(width = 56.dp, height = 48.dp)
            .clip(shape.rFull)
            .toggleable(
                value = value,
                enabled = isOn,
                role = Role.Switch,
            ) { next ->
                feedback.trigger(NptFeedbackCue.Tap, haptics)
                onChanged?.invoke(next)
            },
        contentAlignment = Alignment.Center,
    ) {
        Box(
            modifier = Modifier
                .size(width = 52.dp, height = 32.dp)
                .clip(shape.rFull)
                .background(trackColor)
                .padding(3.dp),
        ) {
            Box(
                modifier = Modifier
                    .align(BiasAlignment(thumbBias, 0f))
                    .size(26.dp)
                    .clip(shape.rFull)
                    .background(thumbColor),
            )
        }
    }
}

/**
 * A branded slider: a 6dp rounded track (active `primary`, inactive
 * `surfaceContainerHighest`), a 20dp `primary` thumb with a 12%-primary
 * press halo, optional division tick marks, and — while dragging a divided
 * slider — a `primary` value bubble (num family, tabular, labelMedium on
 * onPrimary). An optional [label] (labelLarge, onSurfaceVariant) sits above
 * the track.
 *
 * Web counterpart: `<npt-slider>` · Flutter: `NeptuneSlider`.
 *
 * [divisions] is the number of discrete intervals (the Flutter meaning);
 * null keeps the track continuous. [onValueChange] null disables the
 * control (disabled tones: onSurface 38%/12%). RTL-safe (the track and
 * thumb mirror), reduced-motion gated.
 */
@OptIn(ExperimentalMaterial3Api::class) // Slider's thumb/track slots.
@Composable
public fun NeptuneSlider(
    value: Float,
    onValueChange: ((Float) -> Unit)?,
    modifier: Modifier = Modifier,
    min: Float = 0f,
    max: Float = 1f,
    divisions: Int? = null,
    label: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape
    val motion = NeptuneTheme.motion
    val reduced = NeptuneTheme.reducedMotion
    val enabled = onValueChange != null

    val activeTrack = if (enabled) scheme.primary else scheme.onSurface.copy(alpha = 0.38f)
    val inactiveTrack = if (enabled) {
        scheme.surfaceContainerHighest
    } else {
        scheme.onSurface.copy(alpha = 0.12f)
    }
    val thumbColor = if (enabled) scheme.primary else scheme.onSurface.copy(alpha = 0.38f)
    val activeTick = scheme.onPrimary.copy(alpha = 0.6f)
    val inactiveTick = scheme.onSurfaceVariant.copy(alpha = 0.4f)
    val overlayColor = scheme.primary.copy(alpha = 0.12f)

    val interaction = remember { MutableInteractionSource() }
    val dragged by interaction.collectIsDraggedAsState()
    val pressed by interaction.collectIsPressedAsState()
    val active = (dragged || pressed) && enabled
    val overlayAlpha by animateFloatAsState(
        targetValue = if (active) 1f else 0f,
        animationSpec = if (reduced) snap() else tween(motion.fastMs, easing = motion.standard),
        label = "sliderOverlay",
    )

    Column(modifier) {
        if (label != null) {
            Text(
                text = label,
                style = typography.labelLarge.copy(
                    color = if (enabled) {
                        scheme.onSurfaceVariant
                    } else {
                        scheme.onSurface.copy(alpha = 0.38f)
                    },
                ),
                modifier = Modifier.padding(start = 4.dp, bottom = 4.dp),
            )
        }
        Slider(
            value = value.coerceIn(min, max),
            onValueChange = { onValueChange?.invoke(it) },
            modifier = Modifier
                .fillMaxWidth()
                .defaultMinSize(minHeight = 48.dp),
            enabled = enabled,
            valueRange = min..max,
            steps = divisions?.let { (it - 1).coerceAtLeast(0) } ?: 0,
            interactionSource = interaction,
            thumb = { state ->
                Box(Modifier.size(20.dp), contentAlignment = Alignment.Center) {
                    Box(
                        Modifier
                            .size(20.dp)
                            .drawBehind {
                                // The 48dp press/drag halo (Flutter overlay).
                                if (overlayAlpha > 0f) {
                                    drawCircle(
                                        color = overlayColor.copy(
                                            alpha = overlayColor.alpha * overlayAlpha,
                                        ),
                                        radius = 24.dp.toPx(),
                                        center = center,
                                    )
                                }
                            }
                            .clip(shape.rFull)
                            .background(thumbColor),
                    )
                    // The value indicator: shown while interacting with a
                    // divided slider (the Flutter `label`), styled like the
                    // web `.bubble` (xs corner, 8×2 padding, tabular num).
                    if (divisions != null && active) {
                        Box(
                            Modifier.layout { measurable, _ ->
                                val bubble = measurable.measure(Constraints())
                                layout(0, 0) {
                                    bubble.place(
                                        x = -bubble.width / 2,
                                        y = -bubble.height - 14.dp.roundToPx(),
                                    )
                                }
                            },
                        ) {
                            Box(
                                Modifier
                                    .clip(shape.rXs)
                                    .background(scheme.primary)
                                    .padding(horizontal = 8.dp, vertical = 2.dp),
                            ) {
                                Text(
                                    text = NeptuneTheme.formatDigits(
                                        state.value.roundToInt().toString(),
                                    ),
                                    maxLines = 1,
                                    style = NeptuneTheme.moneyStyle(base = typography.labelMedium)
                                        .copy(color = scheme.onPrimary),
                                )
                            }
                        }
                    }
                }
            },
            track = { state ->
                val fraction = if (max > min) {
                    ((state.value - min) / (max - min)).coerceIn(0f, 1f)
                } else {
                    0f
                }
                Canvas(
                    Modifier
                        .fillMaxWidth()
                        .height(6.dp),
                ) {
                    val h = size.height
                    val radius = CornerRadius(h / 2f, h / 2f)
                    val rtl = layoutDirection == LayoutDirection.Rtl
                    drawRoundRect(color = inactiveTrack, cornerRadius = radius)
                    val activeWidth = fraction * size.width
                    drawRoundRect(
                        color = activeTrack,
                        topLeft = Offset(if (rtl) size.width - activeWidth else 0f, 0f),
                        size = Size(activeWidth, h),
                        cornerRadius = radius,
                    )
                    if (divisions != null && divisions > 0) {
                        // Flutter's tick radius: trackHeight / 4.
                        val tickR = h / 4f
                        for (i in 0..divisions) {
                            val f = i.toFloat() / divisions
                            val x = tickR + f * (size.width - 2 * tickR)
                            drawCircle(
                                color = if (f <= fraction) activeTick else inactiveTick,
                                radius = tickR,
                                center = Offset(if (rtl) size.width - x else x, h / 2f),
                            )
                        }
                    }
                }
            },
        )
    }
}

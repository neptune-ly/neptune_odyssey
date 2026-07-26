// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Neptune Odyssey theme token groups (the Compose analog of the Flutter
// ThemeExtensions in neptune_flutter_ui/lib/src/theme/extensions.dart +
// density.dart + numerals.dart + feedback.dart). Read these via the
// [NeptuneTheme] accessor object — never hard-code a value.

package ly.neptune.odyssey.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * The `success` colour role + its on/container variants. Not part of M3's
 * ColorScheme, so carried here. Values come from tokens.resolved.json.
 * Web counterpart: `--md-sys-color-success*`.
 */
@Immutable
public data class NptColors(
    public val success: Color,
    public val onSuccess: Color,
    public val successContainer: Color,
    public val onSuccessContainer: Color,
)

/** The six brand corner radii plus `full` (9999 → stadium/pill).
 * Web counterpart: `--npt-corner-*`. */
@Immutable
public data class NptShape(
    public val xs: Dp,
    public val sm: Dp,
    public val md: Dp,
    public val lg: Dp,
    public val xl: Dp,
    public val xxl: Dp,
    public val full: Dp = 9999.dp,
) {
    public val rXs: RoundedCornerShape get() = RoundedCornerShape(xs)
    public val rSm: RoundedCornerShape get() = RoundedCornerShape(sm)
    public val rMd: RoundedCornerShape get() = RoundedCornerShape(md)
    public val rLg: RoundedCornerShape get() = RoundedCornerShape(lg)
    public val rXl: RoundedCornerShape get() = RoundedCornerShape(xl)
    public val rXxl: RoundedCornerShape get() = RoundedCornerShape(xxl)
    public val rFull: RoundedCornerShape get() = RoundedCornerShape(full)
}

/**
 * Brand font families + display weight/tracking. Money/number UI should use
 * the [num] family with tabular figures (see `NeptuneTheme.moneyStyle`).
 *
 * Families are carried by NAME (the system-wide vocabulary shared with the
 * web tokens and the brandprint registry); [NeptuneFontRegistry] resolves a
 * name to a loaded [androidx.compose.ui.text.font.FontFamily]. Under RTL the
 * web maps `num` → `text-ar`, so [numAr] normally mirrors [textAr].
 */
@Immutable
public data class NptType(
    public val display: String,
    public val text: String,
    public val num: String,
    public val displayAr: String = "IBM Plex Sans Arabic",
    public val textAr: String = "IBM Plex Sans Arabic",
    public val numAr: String = textAr,
    public val displayWeight: Int,
    public val displayTracking: Double,
) {
    public val displayFontWeight: FontWeight
        get() = when (displayWeight) {
            100 -> FontWeight.W100
            200 -> FontWeight.W200
            300 -> FontWeight.W300
            400 -> FontWeight.W400
            500 -> FontWeight.W500
            600 -> FontWeight.W600
            700 -> FontWeight.W700
            800 -> FontWeight.W800
            900 -> FontWeight.W900
            else -> FontWeight.W700
        }
}

/** Brand motion: easing curves, durations (ms) and glass blur radius.
 * Web counterpart: `--npt-ease-*`, `--npt-dur-*`, `--npt-glass-blur`. */
@Immutable
public data class NptMotion(
    public val standard: androidx.compose.animation.core.Easing,
    public val emphasized: androidx.compose.animation.core.Easing,
    public val spring: androidx.compose.animation.core.Easing,
    public val fastMs: Int,
    public val standardMs: Int,
    public val slowMs: Int,
    public val glassBlur: Dp,
)

/** Tenant density lever (R6): comfortable (1.0) or compact (0.82). */
public enum class NeptuneDensityMode { Comfortable, Compact }

/** Density scale carried in the theme; use [s] to scale spacing. */
@Immutable
public data class NptDensity(public val mode: NeptuneDensityMode) {
    public val scale: Float
        get() = if (mode == NeptuneDensityMode.Compact) 0.82f else 1f

    public fun s(v: Dp): Dp = v * scale
}

/** Tenant numeral lever (R6): Latin (ASCII) or Eastern Arabic digits. */
public enum class NeptuneNumeralStyle { Latin, EasternArabic }

private const val EASTERN_ARABIC_DIGITS = "٠١٢٣٤٥٦٧٨٩"

/** Swaps ASCII digits for Arabic-Indic glyphs when the tenant opted in. */
@Immutable
public data class NptNumerals(public val style: NeptuneNumeralStyle) {
    public fun format(text: String): String {
        if (style == NeptuneNumeralStyle.Latin) return text
        return buildString(text.length) {
            for (ch in text) {
                if (ch in '0'..'9') append(EASTERN_ARABIC_DIGITS[ch - '0']) else append(ch)
            }
        }
    }
}

/** Haptic weight axis, derived per brand from the `contentTone` lever. */
public enum class NptHapticWeight { Light, Medium, Heavy }

/** Feedback cues fired by interactive Odyssey components. */
public enum class NptFeedbackCue { Tap, Success, Warning, Error }

/**
 * Tenant feedback lever: haptics on/off + weight, and an optional sound hook
 * (no audio ships in this package — wire `neptune_sound_kit`-style cues via
 * [onSoundCue]).
 */
@Immutable
public class NptFeedback(
    public val hapticsEnabled: Boolean = true,
    public val hapticWeight: NptHapticWeight = NptHapticWeight.Medium,
    public val onSoundCue: ((NptFeedbackCue) -> Unit)? = null,
) {
    /** Fire haptics (when enabled) + the sound hook for [cue]. */
    public fun trigger(cue: NptFeedbackCue, haptics: HapticFeedback?) {
        if (hapticsEnabled && haptics != null) {
            haptics.performHapticFeedback(
                when (cue) {
                    NptFeedbackCue.Tap -> when (hapticWeight) {
                        NptHapticWeight.Light -> HapticFeedbackType.TextHandleMove
                        NptHapticWeight.Medium -> HapticFeedbackType.ContextClick
                        NptHapticWeight.Heavy -> HapticFeedbackType.LongPress
                    }
                    NptFeedbackCue.Success -> HapticFeedbackType.Confirm
                    NptFeedbackCue.Warning -> HapticFeedbackType.LongPress
                    NptFeedbackCue.Error -> HapticFeedbackType.Reject
                },
            )
        }
        onSoundCue?.invoke(cue)
    }
}

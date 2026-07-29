// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The unified theming surface (docs/04, docs/11). Three ways to theme, one
// composable:
//   1. brand id     — NeptuneTheme(brand = "triton") { … }
//   2. brandprint   — NeptuneTheme(brand = "NO1-…") { … }   (web applyTheme parity)
//   3. config       — NeptuneTheme(config = BrandprintConfig(…)) { … }
// Reference brands resolve via the pinned generated schemes; custom seeds
// generate deterministically through the shared OKLCH ramp. Same brandprint ⇒
// identical theme on every platform.

package ly.neptune.odyssey.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ProvidableCompositionLocal
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.remember
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.tokens.Brandprint
import ly.neptune.odyssey.tokens.BrandprintConfig
import ly.neptune.odyssey.tokens.Oklch
import ly.neptune.odyssey.tokens.brandConfigs
import ly.neptune.odyssey.tokens.generated.genSchemes
import ly.neptune.odyssey.tokens.generatePaletteArgb
import ly.neptune.odyssey.tokens.matchReferenceBrand
import ly.neptune.odyssey.ui.platform.rememberSystemReducedMotion

// --- CompositionLocals -------------------------------------------------------

private fun <T> nptLocal(name: String): ProvidableCompositionLocal<T> =
    staticCompositionLocalOf { error("$name is only available inside NeptuneTheme { }") }

internal val LocalNptColors: ProvidableCompositionLocal<NptColors> = nptLocal("NeptuneTheme.colors")
internal val LocalNptShape: ProvidableCompositionLocal<NptShape> = nptLocal("NeptuneTheme.shape")
internal val LocalNptType: ProvidableCompositionLocal<NptType> = nptLocal("NeptuneTheme.type")
internal val LocalNptMotion: ProvidableCompositionLocal<NptMotion> = nptLocal("NeptuneTheme.motion")
internal val LocalNptIdentity: ProvidableCompositionLocal<NptIdentity> = nptLocal("NeptuneTheme.identity")
internal val LocalNptDensity: ProvidableCompositionLocal<NptDensity> = nptLocal("NeptuneTheme.density")
internal val LocalNptNumerals: ProvidableCompositionLocal<NptNumerals> = nptLocal("NeptuneTheme.numerals")
internal val LocalNptFeedback: ProvidableCompositionLocal<NptFeedback> = nptLocal("NeptuneTheme.feedback")

/** Reduced-motion flag: system setting by default, overridable per subtree
 * (tests, previews). Every animated Odyssey composable respects it. */
public val LocalNptReducedMotion: ProvidableCompositionLocal<Boolean> =
    staticCompositionLocalOf { false }

// --- resolution (pure, testable) ----------------------------------------------

internal class ResolvedNeptuneTheme(
    val colorScheme: ColorScheme,
    val colors: NptColors,
    val shape: NptShape,
    val type: NptType,
    val motion: NptMotion,
    val identity: NptIdentity,
)

private fun schemeFromRoles(roles: Map<String, Int>, dark: Boolean): ColorScheme {
    fun c(role: String): Color = Color(roles.getValue(role))
    // surfaceDim/Bright and the fixed roles are not part of the Odyssey token
    // set; they default to surface / the container roles, mirroring Flutter's
    // ColorScheme fallbacks so no M3-baseline colour ever leaks in.
    return if (dark) {
        darkColorScheme(
            primary = c("primary"), onPrimary = c("on-primary"),
            primaryContainer = c("primary-container"), onPrimaryContainer = c("on-primary-container"),
            inversePrimary = c("inverse-primary"),
            secondary = c("secondary"), onSecondary = c("on-secondary"),
            secondaryContainer = c("secondary-container"), onSecondaryContainer = c("on-secondary-container"),
            tertiary = c("tertiary"), onTertiary = c("on-tertiary"),
            tertiaryContainer = c("tertiary-container"), onTertiaryContainer = c("on-tertiary-container"),
            background = c("background"), onBackground = c("on-background"),
            surface = c("surface"), onSurface = c("on-surface"),
            surfaceVariant = c("surface-variant"), onSurfaceVariant = c("on-surface-variant"),
            surfaceTint = c("primary"),
            inverseSurface = c("inverse-surface"), inverseOnSurface = c("inverse-on-surface"),
            error = c("error"), onError = c("on-error"),
            errorContainer = c("error-container"), onErrorContainer = c("on-error-container"),
            outline = c("outline"), outlineVariant = c("outline-variant"),
            scrim = c("scrim"),
            surfaceBright = c("surface"), surfaceDim = c("surface"),
            surfaceContainer = c("surface-container"),
            surfaceContainerHigh = c("surface-container-high"),
            surfaceContainerHighest = c("surface-container-highest"),
            surfaceContainerLow = c("surface-container-low"),
            surfaceContainerLowest = c("surface-container-lowest"),
        )
    } else {
        lightColorScheme(
            primary = c("primary"), onPrimary = c("on-primary"),
            primaryContainer = c("primary-container"), onPrimaryContainer = c("on-primary-container"),
            inversePrimary = c("inverse-primary"),
            secondary = c("secondary"), onSecondary = c("on-secondary"),
            secondaryContainer = c("secondary-container"), onSecondaryContainer = c("on-secondary-container"),
            tertiary = c("tertiary"), onTertiary = c("on-tertiary"),
            tertiaryContainer = c("tertiary-container"), onTertiaryContainer = c("on-tertiary-container"),
            background = c("background"), onBackground = c("on-background"),
            surface = c("surface"), onSurface = c("on-surface"),
            surfaceVariant = c("surface-variant"), onSurfaceVariant = c("on-surface-variant"),
            surfaceTint = c("primary"),
            inverseSurface = c("inverse-surface"), inverseOnSurface = c("inverse-on-surface"),
            error = c("error"), onError = c("on-error"),
            errorContainer = c("error-container"), onErrorContainer = c("on-error-container"),
            outline = c("outline"), outlineVariant = c("outline-variant"),
            scrim = c("scrim"),
            surfaceBright = c("surface"), surfaceDim = c("surface"),
            surfaceContainer = c("surface-container"),
            surfaceContainerHigh = c("surface-container-high"),
            surfaceContainerHighest = c("surface-container-highest"),
            surfaceContainerLow = c("surface-container-low"),
            surfaceContainerLowest = c("surface-container-lowest"),
        )
    }
}

private fun successFromRoles(roles: Map<String, Int>): NptColors = NptColors(
    success = Color(roles.getValue("success")),
    onSuccess = Color(roles.getValue("on-success")),
    successContainer = Color(roles.getValue("success-container")),
    onSuccessContainer = Color(roles.getValue("on-success-container")),
)

/** Resolve the full theme spec for [cfg]. Reference-brand seeds (within the
 * brandprint quantisation tolerance) use the pinned canonical palette
 * byte-identically; custom seeds generate through the v1 OKLCH ramp. */
internal fun resolveNeptuneTheme(cfg: BrandprintConfig, dark: Boolean): ResolvedNeptuneTheme {
    val ref = matchReferenceBrand(cfg.primary, cfg.tertiary)
    val roles: Map<String, Int>
    val shape: NptShape
    val type: NptType
    if (ref != null) {
        val pair = genSchemes.getValue(ref)
        roles = if (dark) pair.dark else pair.light
        shape = brandShape.getValue(ref)
        type = brandType.getValue(ref)
    } else {
        roles = generatePaletteArgb(
            Oklch(cfg.primary.l, cfg.primary.c, cfg.primary.h.toDouble()),
            Oklch(cfg.tertiary.l, cfg.tertiary.c, cfg.tertiary.h.toDouble()),
            if (dark) "dark" else "light",
        )
        shape = NptShape(
            xs = cfg.corners.xs.dp,
            sm = cfg.corners.sm.dp,
            md = cfg.corners.md.dp,
            lg = cfg.corners.lg.dp,
            xl = cfg.corners.xl.dp,
            xxl = cfg.corners.xxl.dp,
        )
        type = NptType(
            display = cfg.fontDisplay,
            text = cfg.fontText,
            num = cfg.fontNum,
            displayWeight = cfg.displayWeight,
            displayTracking = cfg.displayTracking,
        )
    }
    return ResolvedNeptuneTheme(
        colorScheme = schemeFromRoles(roles, dark),
        colors = successFromRoles(roles),
        shape = shape,
        type = type,
        motion = motionFor(cfg.motion),
        identity = identityFor(cfg),
    )
}

// --- the composable entry points ----------------------------------------------

/**
 * Apply a Neptune Odyssey theme from a [BrandprintConfig].
 *
 * [dark] `null` follows the config's `defaultDark`, else the system setting.
 * [arabic] `null` follows the config's `defaultRtl`; when true the brand's
 * Arabic faces drive the typography (the web `[dir="rtl"]` font swap) —
 * layout direction itself comes from [LocalLayoutDirection], which the caller
 * controls. [density]/[numerals] are independent tenant levers (R6).
 * [feedback] overrides the per-brand haptic weight derived from `contentTone`.
 * [reducedMotion] `null` reads the platform accessibility setting.
 */
@Composable
public fun NeptuneTheme(
    config: BrandprintConfig,
    dark: Boolean? = null,
    arabic: Boolean? = null,
    density: NeptuneDensityMode = NeptuneDensityMode.Comfortable,
    numerals: NeptuneNumeralStyle = NeptuneNumeralStyle.Latin,
    feedback: NptFeedback? = null,
    reducedMotion: Boolean? = null,
    content: @Composable () -> Unit,
) {
    val isDark = dark ?: (config.defaultDark || isSystemInDarkTheme())
    val isArabic = arabic ?: config.defaultRtl
    val spec = remember(config, isDark) { resolveNeptuneTheme(config, isDark) }
    val displayFamily = rememberNeptuneFontFamily(if (isArabic) spec.type.displayAr else spec.type.display)
    val textFamily = rememberNeptuneFontFamily(if (isArabic) spec.type.textAr else spec.type.text)
    val typography = remember(spec, isArabic, displayFamily, textFamily) {
        neptuneTypography(spec.type, displayFamily, textFamily)
    }
    val reduced = reducedMotion ?: rememberSystemReducedMotion()
    MaterialTheme(
        colorScheme = spec.colorScheme,
        typography = typography,
        shapes = Shapes(
            extraSmall = spec.shape.rXs,
            small = spec.shape.rSm,
            medium = spec.shape.rMd,
            large = spec.shape.rLg,
            extraLarge = spec.shape.rXl,
        ),
    ) {
        CompositionLocalProvider(
            LocalNptColors provides spec.colors,
            LocalNptShape provides spec.shape,
            LocalNptType provides spec.type,
            LocalNptMotion provides spec.motion,
            LocalNptIdentity provides spec.identity,
            LocalNptDensity provides NptDensity(density),
            LocalNptNumerals provides NptNumerals(numerals),
            LocalNptFeedback provides (
                feedback ?: NptFeedback(hapticWeight = hapticWeightFor(spec.identity.contentTone))
                ),
            LocalNptReducedMotion provides reduced,
            content = content,
        )
    }
}

/**
 * Apply a Neptune Odyssey theme from a reference brand id
 * (`"neptune"|"triton"|"nereid"|"proteus"`) **or** a portable `NO1-…`
 * brandprint string — the same dual input the web `applyTheme()` accepts.
 * See the [BrandprintConfig] overload for the parameter semantics.
 *
 * @throws IllegalArgumentException on an unknown brand id or a malformed
 *   brandprint.
 */
@Composable
public fun NeptuneTheme(
    brand: String = "neptune",
    dark: Boolean? = null,
    arabic: Boolean? = null,
    density: NeptuneDensityMode = NeptuneDensityMode.Comfortable,
    numerals: NeptuneNumeralStyle = NeptuneNumeralStyle.Latin,
    feedback: NptFeedback? = null,
    reducedMotion: Boolean? = null,
    content: @Composable () -> Unit,
) {
    val config = remember(brand) {
        if (brand.startsWith("NO1-")) {
            Brandprint.decode(brand)
        } else {
            requireNotNull(brandConfigs[brand]) { "unknown reference brand: $brand" }
        }
    }
    NeptuneTheme(config, dark, arabic, density, numerals, feedback, reducedMotion, content)
}

// --- the accessor object --------------------------------------------------------

/** Read the active Odyssey tokens (the `Theme.of(context).extension<…>()`
 * analog). Only valid inside a [NeptuneTheme] content lambda. */
public object NeptuneTheme {
    public val colors: NptColors
        @Composable @ReadOnlyComposable get() = LocalNptColors.current
    public val shape: NptShape
        @Composable @ReadOnlyComposable get() = LocalNptShape.current
    public val type: NptType
        @Composable @ReadOnlyComposable get() = LocalNptType.current
    public val motion: NptMotion
        @Composable @ReadOnlyComposable get() = LocalNptMotion.current
    public val identity: NptIdentity
        @Composable @ReadOnlyComposable get() = LocalNptIdentity.current
    public val density: NptDensity
        @Composable @ReadOnlyComposable get() = LocalNptDensity.current
    public val numerals: NptNumerals
        @Composable @ReadOnlyComposable get() = LocalNptNumerals.current
    public val feedback: NptFeedback
        @Composable @ReadOnlyComposable get() = LocalNptFeedback.current
    public val reducedMotion: Boolean
        @Composable @ReadOnlyComposable get() = LocalNptReducedMotion.current

    /**
     * A money/number text style: the brand `num` family with tabular figures
     * so digits stay column-aligned. Direction-aware — under RTL it uses the
     * Arabic numeral face, mirroring the web's `dir="rtl"` swap.
     */
    @Composable
    public fun moneyStyle(base: TextStyle = LocalTextStyle.current): TextStyle {
        val t = type
        val rtl = LocalLayoutDirection.current == LayoutDirection.Rtl
        val family = rememberNeptuneFontFamily(if (rtl) t.numAr else t.num)
        return base.copy(
            fontFamily = family ?: base.fontFamily,
            fontFeatureSettings = "tnum",
        )
    }

    /** Apply the numerals lever to [text] — swaps ASCII digits for Eastern
     * Arabic glyphs when the tenant opted in. */
    @Composable
    @ReadOnlyComposable
    public fun formatDigits(text: String): String = numerals.format(text)
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The brand identity layer — what makes Odyssey look like Odyssey and not
// generic Material (Compose port of neptune_flutter_ui's identity.dart).
// Ports the web token levers (themes.css) that sit ABOVE the M3 colour scheme:
//   · glass    — --npt-glass-tint / --npt-glass-blur (per-brand translucency)
//   · motif    — --npt-motif (sonar tide-rings, coastal arcs, grid-spark,
//                shield guilloché)
//   · shadows  — --npt-elev-1/2/3/5 and the primary key-light glow
//   · levers   — login shell / dashboard hero / content tone names
// Everything resolves from the active ColorScheme at composition time, so
// custom brandprint seeds get the same treatment as the reference brands.

package ly.neptune.odyssey.ui.theme

import androidx.compose.material3.ColorScheme
import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/** The four signature motif families (themes.css `--npt-motif`). */
public enum class NptMotifKind {
    /** Neptune — sonar tide-rings: concentric hairline rings radiating from
     * the top-trailing corner. */
    SonarRings,

    /** Triton — coastal arcs: a tiled wave of soft arc crests. */
    CoastalArcs,

    /** Nereid — grid-spark: a fine luminous grid. */
    GridSpark,

    /** Proteus — shield guilloché: a diagonal crosshatch weave. */
    Guilloche,
}

/** One box-shadow recipe: colour, blur radius, vertical offset and spread
 * (the web elevation tokens never offset horizontally; negative [spread]
 * shrinks the shadow shape, CSS box-shadow semantics). */
@Immutable
public data class NptShadow(
    public val color: Color,
    public val blurRadius: Dp,
    public val offsetY: Dp,
    public val spread: Dp = 0.dp,
)

/** Brand identity levers + material recipes. Read via `NeptuneTheme.identity`. */
@Immutable
public data class NptIdentity(
    /** The brand's signature background pattern. */
    public val motif: NptMotifKind,
    /** Base opacity multiplier for the motif (web `--npt-motif-strength`). */
    public val motifStrength: Float,
    /** Glass mixes `tertiary` instead of `primary` into the pane (Triton). */
    public val glassOnTertiary: Boolean,
    /** Fraction of accent colour mixed into the glass pane (web 7–12%). */
    public val glassMixRatio: Float,
    /** Opacity of the surface component of the glass pane (web 62–76%). */
    public val glassSurfaceOpacity: Float,
    /** Backdrop blur radius in px (web `--npt-glass-blur`, 14–22). */
    public val glassBlur: Dp,
    /** Named treatment levers (informational; drive app-level composition). */
    public val dashboardHero: String,
    public val loginShell: String,
    public val contentTone: String,
) {
    // --- glass ----------------------------------------------------------------

    /**
     * The translucent glass pane colour (web `--npt-glass-tint`):
     * `color-mix(in oklab, accent R%, color-mix(surface A%, transparent))`.
     * Composited: alpha = R + (1-R)·A, colour = lerp(surface, accent, R/alpha).
     */
    public fun glassTint(scheme: ColorScheme): Color {
        val accent = if (glassOnTertiary) scheme.tertiary else scheme.primary
        val alpha = glassMixRatio + (1 - glassMixRatio) * glassSurfaceOpacity
        val w = glassMixRatio / alpha
        return lerp(scheme.surface, accent, w).copy(alpha = alpha)
    }

    /** The dock/nav glass (web dock: `color-mix(surface-container 86%, transparent)`). */
    public fun dockGlass(scheme: ColorScheme): Color =
        scheme.surfaceContainer.copy(alpha = 0.86f)

    // --- elevation ------------------------------------------------------------
    // Web tokens: e1 `0 1px 3px .20` · e2 `0 2px 6px .18` · e3 `0 8px 20px .20`
    // · e5 `0 28px 60px .30`. Light mode = a dark cast shadow. Dark mode is a
    // GLOW, not a shadow: a black shadow at 18–30% alpha barely registers on an
    // already-dark surface, so the colour lerps 35% toward `primary`, the
    // directional offset drops and the blur widens — raised surfaces read as
    // lit rather than shadowed (rulebook §3.4).

    private fun isDark(s: ColorScheme): Boolean = s.surface.luminance() < 0.5f

    private fun elevation(
        s: ColorScheme,
        lightAlpha: Float,
        lightBlur: Dp,
        lightOffset: Dp,
        darkAlpha: Float,
        darkBlur: Dp,
        darkOffset: Dp,
    ): List<NptShadow> {
        // Compose's ColorScheme has no `shadow` role; the Flutter/generated
        // schemes pin it to pure black, so the recipes anchor there too.
        val shadowBase = Color.Black
        if (!isDark(s)) {
            return listOf(
                NptShadow(shadowBase.copy(alpha = lightAlpha), lightBlur, lightOffset),
            )
        }
        val glow = lerp(shadowBase, s.primary, 0.35f)
        return listOf(NptShadow(glow.copy(alpha = darkAlpha), darkBlur, darkOffset))
    }

    public fun elevation1(s: ColorScheme): List<NptShadow> = elevation(
        s,
        lightAlpha = 0.20f, lightBlur = 3.dp, lightOffset = 1.dp,
        darkAlpha = 0.16f, darkBlur = 6.dp, darkOffset = 0.5.dp,
    )

    public fun elevation2(s: ColorScheme): List<NptShadow> = elevation(
        s,
        lightAlpha = 0.18f, lightBlur = 6.dp, lightOffset = 2.dp,
        darkAlpha = 0.20f, darkBlur = 12.dp, darkOffset = 1.dp,
    )

    public fun elevation3(s: ColorScheme): List<NptShadow> = elevation(
        s,
        lightAlpha = 0.20f, lightBlur = 20.dp, lightOffset = 8.dp,
        darkAlpha = 0.26f, darkBlur = 32.dp, darkOffset = 3.dp,
    )

    public fun elevation5(s: ColorScheme): List<NptShadow> = elevation(
        s,
        lightAlpha = 0.30f, lightBlur = 60.dp, lightOffset = 28.dp,
        darkAlpha = 0.34f, darkBlur = 76.dp, darkOffset = 10.dp,
    )

    /** The primary key-light glow used under hero/selected surfaces
     * (web `--npt-glow-primary`). Already a glow — dark mode just runs it a
     * touch stronger. */
    public fun glowPrimary(s: ColorScheme): List<NptShadow> = listOf(
        NptShadow(
            s.primary.copy(alpha = if (isDark(s)) 0.36f else 0.28f),
            blurRadius = 22.dp,
            offsetY = 8.dp,
        ),
    )
}

// ColorScheme has no brightness flag; the surface role's luminance is an
// unambiguous light/dark discriminator for every Odyssey palette (light
// surfaces are ≥0.9 L, dark surfaces ≤0.2 L).
private fun Color.luminance(): Float =
    0.2126f * red + 0.7152f * green + 0.0722f * blue

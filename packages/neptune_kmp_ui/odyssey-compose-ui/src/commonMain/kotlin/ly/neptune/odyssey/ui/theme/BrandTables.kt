// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Per-brand extension data for the four reference brands, resolved from the
// single source of truth (themes.css) via `node tools/codegen.mjs` — see
// odyssey-tokens' generated/BrandData.g.kt. Only the semantic mappings
// (motif↔glassTint lever, haptic↔contentTone lever) live here.

package ly.neptune.odyssey.ui.theme

import androidx.compose.animation.core.CubicBezierEasing
import ly.neptune.odyssey.tokens.BrandprintConfig
import ly.neptune.odyssey.tokens.NptCubic
import ly.neptune.odyssey.tokens.generated.genGlass
import ly.neptune.odyssey.tokens.generated.genMotion
import ly.neptune.odyssey.tokens.generated.genShape
import ly.neptune.odyssey.tokens.generated.genType
import androidx.compose.ui.unit.dp

private fun NptCubic.toEasing(): CubicBezierEasing =
    CubicBezierEasing(x1.toFloat(), y1.toFloat(), x2.toFloat(), y2.toFloat())

/** Corner family per brand — generated. */
internal val brandShape: Map<String, NptShape> = genShape
    .mapValues { (_, c) ->
        NptShape(
            xs = c.xs.dp,
            sm = c.sm.dp,
            md = c.md.dp,
            lg = c.lg.dp,
            xl = c.xl.dp,
            xxl = c.xxl.dp,
        )
    }

/** Type set per brand (Latin + Arabic faces) — generated. Under RTL the web
 * maps `num` → `text-ar`, so `numAr` mirrors `textAr`. */
internal val brandType: Map<String, NptType> = genType.mapValues { (_, t) ->
    NptType(
        display = t.display,
        text = t.text,
        num = t.num,
        displayAr = t.displayAr,
        textAr = t.textAr,
        numAr = t.textAr,
        displayWeight = t.displayWeight,
        displayTracking = t.displayTracking,
    )
}

/** Motion presets keyed by the motion lever — generated. */
internal val motionPresets: Map<String, NptMotion> = genMotion.mapValues { (_, m) ->
    NptMotion(
        standard = m.standard.toEasing(),
        emphasized = m.emphasized.toEasing(),
        spring = m.spring.toEasing(),
        fastMs = m.fastMs,
        standardMs = m.standardMs,
        slowMs = m.slowMs,
        glassBlur = m.glassBlurPx.dp,
    )
}

internal fun motionFor(lever: String): NptMotion =
    motionPresets[lever] ?: motionPresets.getValue("smooth-fluid")

/** Default haptic weight per `contentTone` lever (R6) — formal/authoritative
 * brands land lighter, warm/hospitable brands land heavier. */
private val hapticWeightByContentTone: Map<String, NptHapticWeight> = mapOf(
    "formal-authoritative" to NptHapticWeight.Light,
    "warm-hospitable" to NptHapticWeight.Heavy,
    "light-instant" to NptHapticWeight.Medium,
    "clear-calm" to NptHapticWeight.Medium,
)

internal fun hapticWeightFor(contentTone: String): NptHapticWeight =
    hapticWeightByContentTone[contentTone] ?: NptHapticWeight.Medium

/** Identity recipes keyed by the glass-tint lever — glass numbers generated
 * from themes.css; the motif painter mapping is semantic and lives here. */
private val motifByGlassTint: Map<String, NptMotifKind> = mapOf(
    "oceanic" to NptMotifKind.SonarRings,
    "warm-amber" to NptMotifKind.CoastalArcs,
    "violet-luminous" to NptMotifKind.GridSpark,
    "navy-steel" to NptMotifKind.Guilloche,
)

/** Resolve the [NptIdentity] for a brandprint config (reference or custom). */
internal fun identityFor(cfg: BrandprintConfig): NptIdentity {
    val g = genGlass[cfg.glassTint] ?: genGlass.getValue("oceanic")
    return NptIdentity(
        motif = motifByGlassTint[cfg.glassTint] ?: NptMotifKind.SonarRings,
        motifStrength = g.motifStrength.toFloat(),
        glassOnTertiary = g.onTertiary,
        glassMixRatio = g.mixRatio.toFloat(),
        glassSurfaceOpacity = g.surfaceOpacity.toFloat(),
        glassBlur = g.blurPx.dp,
        dashboardHero = cfg.dashboardHero,
        loginShell = cfg.loginShell,
        contentTone = cfg.contentTone,
    )
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Value types instantiated by the GENERATED brand tables
// (generated/BrandData.g.kt, emitted by tools/codegen.mjs from themes.css).
// Deliberately Compose-free: :odyssey-tokens stays pure Kotlin so the
// determinism core is usable from any Kotlin consumer and golden tests run on
// every target.

package ly.neptune.odyssey.tokens

/** Resolved role→ARGB maps for one brand: light and dark mode. Keys are the
 * short M3 role names ("primary", "on-primary", …, incl. the Odyssey success
 * roles). */
public data class NptSchemePair(
    public val light: Map<String, Int>,
    public val dark: Map<String, Int>,
)

/** A brand type set: Latin display/text/num faces, Arabic display/text faces,
 * display weight (100..900) and display tracking (em). */
public data class NptTypeSet(
    public val display: String,
    public val text: String,
    public val num: String,
    public val displayAr: String,
    public val textAr: String,
    public val displayWeight: Int,
    public val displayTracking: Double,
)

/** Cubic-bézier control points (x1, y1, x2, y2) — mirrors CSS cubic-bezier(). */
public data class NptCubic(
    public val x1: Double,
    public val y1: Double,
    public val x2: Double,
    public val y2: Double,
)

/** A motion preset (keyed by the motion lever): easing cubics, durations in
 * ms, and the brand glass blur in px. */
public data class NptMotionSpec(
    public val standard: NptCubic,
    public val emphasized: NptCubic,
    public val spring: NptCubic,
    public val fastMs: Int,
    public val standardMs: Int,
    public val slowMs: Int,
    public val glassBlurPx: Double,
)

/** A glass/identity recipe (keyed by the glassTint lever): whether the tint
 * accent is tertiary (Triton) or primary, the accent mix ratio, the
 * translucent surface opacity, blur px, and the brand motif strength. */
public data class NptGlassSpec(
    public val onTertiary: Boolean,
    public val mixRatio: Double,
    public val surfaceOpacity: Double,
    public val blurPx: Double,
    public val motifStrength: Double,
)

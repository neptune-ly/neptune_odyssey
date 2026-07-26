// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Seed -> palette: the v1 OKLCH ramp (Kotlin port of color/palette.ts /
// color/palette.dart). ONE palette-generation algorithm shared by every
// platform (docs/11 "Determinism"). Used for CUSTOM seeds (the configurator);
// the four reference brands ship their pinned canonical palette. Pinned for
// v1 — any change bumps the brandprint version (NO2-).

package ly.neptune.odyssey.tokens

// Where a role's hue comes from: a seed channel or a fixed hue in degrees.
private sealed interface HueSource {
    data class Channel(val name: String) : HueSource
    data class Fixed(val deg: Double) : HueSource
}

// Chroma is either an absolute value or a multiplier of the source seed chroma.
private sealed interface ChromaSpec {
    data class Abs(val v: Double) : ChromaSpec
    data class Mult(val v: Double) : ChromaSpec
}

private class Recipe(val l: Double, val c: ChromaSpec, val hue: HueSource)

// Fixed semantic hues (error/success are brand-invariant for trust + legibility).
private const val ERROR_H = 27.0
private const val SUCCESS_H = 152.0

private val PRIMARY: HueSource = HueSource.Channel("primary")
private val TERTIARY: HueSource = HueSource.Channel("tertiary")
private val NEUTRAL: HueSource = HueSource.Channel("neutral")
private val ERROR_HUE: HueSource = HueSource.Fixed(ERROR_H)
private val SUCCESS_HUE: HueSource = HueSource.Fixed(SUCCESS_H)

private fun abs(v: Double): ChromaSpec = ChromaSpec.Abs(v)
private fun mult(v: Double): ChromaSpec = ChromaSpec.Mult(v)

// Light-mode ramp (role -> recipe).
private val LIGHT: Map<String, Recipe> = mapOf(
    "primary" to Recipe(0.48, mult(1.0), PRIMARY),
    "on-primary" to Recipe(0.99, abs(0.02), PRIMARY),
    "primary-container" to Recipe(0.91, mult(0.47), PRIMARY),
    "on-primary-container" to Recipe(0.22, mult(0.87), PRIMARY),
    "secondary" to Recipe(0.5, abs(0.06), PRIMARY),
    "on-secondary" to Recipe(0.99, abs(0.02), PRIMARY),
    "secondary-container" to Recipe(0.92, abs(0.035), PRIMARY),
    "on-secondary-container" to Recipe(0.25, abs(0.05), PRIMARY),
    "tertiary" to Recipe(0.55, mult(1.0), TERTIARY),
    "on-tertiary" to Recipe(0.99, abs(0.02), TERTIARY),
    "tertiary-container" to Recipe(0.9, mult(0.6), TERTIARY),
    "on-tertiary-container" to Recipe(0.26, mult(0.8), TERTIARY),
    "error" to Recipe(0.52, abs(0.2), ERROR_HUE),
    "on-error" to Recipe(0.99, abs(0.02), ERROR_HUE),
    "error-container" to Recipe(0.92, abs(0.07), ERROR_HUE),
    "on-error-container" to Recipe(0.28, abs(0.16), ERROR_HUE),
    "success" to Recipe(0.58, abs(0.13), SUCCESS_HUE),
    "on-success" to Recipe(0.99, abs(0.02), SUCCESS_HUE),
    "success-container" to Recipe(0.9, abs(0.07), SUCCESS_HUE),
    "on-success-container" to Recipe(0.26, abs(0.1), SUCCESS_HUE),
    "background" to Recipe(0.985, abs(0.006), NEUTRAL),
    "on-background" to Recipe(0.16, abs(0.02), NEUTRAL),
    "surface" to Recipe(0.985, abs(0.006), NEUTRAL),
    "on-surface" to Recipe(0.16, abs(0.02), NEUTRAL),
    "surface-variant" to Recipe(0.9, abs(0.018), NEUTRAL),
    "on-surface-variant" to Recipe(0.4, abs(0.025), NEUTRAL),
    "outline" to Recipe(0.62, abs(0.02), NEUTRAL),
    "outline-variant" to Recipe(0.86, abs(0.015), NEUTRAL),
    "surface-container-lowest" to Recipe(1.0, abs(0.0), NEUTRAL),
    "surface-container-low" to Recipe(0.965, abs(0.006), NEUTRAL),
    "surface-container" to Recipe(0.945, abs(0.008), NEUTRAL),
    "surface-container-high" to Recipe(0.925, abs(0.01), NEUTRAL),
    "surface-container-highest" to Recipe(0.905, abs(0.012), NEUTRAL),
    "inverse-surface" to Recipe(0.24, abs(0.02), NEUTRAL),
    "inverse-on-surface" to Recipe(0.96, abs(0.006), NEUTRAL),
    "inverse-primary" to Recipe(0.82, mult(0.8), PRIMARY),
    "scrim" to Recipe(0.08, abs(0.02), NEUTRAL),
)

// Dark-mode ramp.
private val DARK: Map<String, Recipe> = mapOf(
    "primary" to Recipe(0.8, mult(0.8), PRIMARY),
    "on-primary" to Recipe(0.2, mult(0.67), PRIMARY),
    "primary-container" to Recipe(0.36, mult(0.8), PRIMARY),
    "on-primary-container" to Recipe(0.9, mult(0.47), PRIMARY),
    "secondary" to Recipe(0.82, abs(0.04), PRIMARY),
    "on-secondary" to Recipe(0.22, abs(0.04), PRIMARY),
    "secondary-container" to Recipe(0.34, abs(0.04), PRIMARY),
    "on-secondary-container" to Recipe(0.9, abs(0.035), PRIMARY),
    "tertiary" to Recipe(0.82, mult(0.8), TERTIARY),
    "on-tertiary" to Recipe(0.22, mult(0.6), TERTIARY),
    "tertiary-container" to Recipe(0.34, mult(0.7), TERTIARY),
    "on-tertiary-container" to Recipe(0.9, mult(0.6), TERTIARY),
    "error" to Recipe(0.78, abs(0.13), ERROR_HUE),
    "on-error" to Recipe(0.24, abs(0.1), ERROR_HUE),
    "error-container" to Recipe(0.36, abs(0.14), ERROR_HUE),
    "on-error-container" to Recipe(0.92, abs(0.06), ERROR_HUE),
    "success" to Recipe(0.78, abs(0.12), SUCCESS_HUE),
    "on-success" to Recipe(0.22, abs(0.08), SUCCESS_HUE),
    "success-container" to Recipe(0.34, abs(0.1), SUCCESS_HUE),
    "on-success-container" to Recipe(0.9, abs(0.07), SUCCESS_HUE),
    "background" to Recipe(0.13, abs(0.012), NEUTRAL),
    "on-background" to Recipe(0.92, abs(0.01), NEUTRAL),
    "surface" to Recipe(0.13, abs(0.012), NEUTRAL),
    "on-surface" to Recipe(0.92, abs(0.01), NEUTRAL),
    "surface-variant" to Recipe(0.34, abs(0.02), NEUTRAL),
    "on-surface-variant" to Recipe(0.78, abs(0.02), NEUTRAL),
    "outline" to Recipe(0.58, abs(0.02), NEUTRAL),
    "outline-variant" to Recipe(0.32, abs(0.02), NEUTRAL),
    "surface-container-lowest" to Recipe(0.09, abs(0.012), NEUTRAL),
    "surface-container-low" to Recipe(0.16, abs(0.014), NEUTRAL),
    "surface-container" to Recipe(0.18, abs(0.016), NEUTRAL),
    "surface-container-high" to Recipe(0.22, abs(0.018), NEUTRAL),
    "surface-container-highest" to Recipe(0.27, abs(0.02), NEUTRAL),
    "inverse-surface" to Recipe(0.92, abs(0.01), NEUTRAL),
    "inverse-on-surface" to Recipe(0.2, abs(0.02), NEUTRAL),
    "inverse-primary" to Recipe(0.48, mult(1.0), PRIMARY),
    "scrim" to Recipe(0.0, abs(0.0), NEUTRAL),
)

private fun resolveHue(src: HueSource, primaryH: Double, tertiaryH: Double): Double = when (src) {
    is HueSource.Fixed -> src.deg
    is HueSource.Channel -> if (src.name == "tertiary") tertiaryH else primaryH
    // primary + neutral both ride the primary hue
}

private fun resolveChroma(c: ChromaSpec, seedC: Double): Double = when (c) {
    is ChromaSpec.Abs -> c.v
    is ChromaSpec.Mult -> seedC * c.v
}

private fun isTertiary(src: HueSource): Boolean = src is HueSource.Channel && src.name == "tertiary"

/**
 * Generate a full 37-role palette (role -> "#rrggbb") from primary + tertiary
 * seeds via the v1 ramp. Used for custom (non-reference) seeds.
 */
public fun generatePalette(primary: Oklch, tertiary: Oklch, mode: String): Map<String, String> {
    val ramp = if (mode == "light") LIGHT else DARK
    val out = LinkedHashMap<String, String>()
    for ((role, recipe) in ramp) {
        val hue = resolveHue(recipe.hue, primary.h, tertiary.h)
        val seedC = if (isTertiary(recipe.hue)) tertiary.c else primary.c
        val c = resolveChroma(recipe.c, seedC)
        out[role] = oklchToHex(Oklch(recipe.l, c, hue))
    }
    return out
}

/** Same as [generatePalette] but returns 0xAARRGGBB ints per role. */
public fun generatePaletteArgb(primary: Oklch, tertiary: Oklch, mode: String): Map<String, Int> {
    val ramp = if (mode == "light") LIGHT else DARK
    val out = LinkedHashMap<String, Int>()
    for ((role, recipe) in ramp) {
        val hue = resolveHue(recipe.hue, primary.h, tertiary.h)
        val seedC = if (isTertiary(recipe.hue)) tertiary.c else primary.c
        val c = resolveChroma(recipe.c, seedC)
        out[role] = oklchToArgb(Oklch(recipe.l, c, hue))
    }
    return out
}

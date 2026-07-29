// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// OKLCH <-> sRGB converter (Kotlin port of color/oklch.ts, byte-identical with
// the Dart port in neptune_flutter_ui/lib/src/color/oklch.dart). The SAME math
// ships on every platform so custom seeds resolve identically. CSS Color 4
// reference path: OKLab -> LMS -> XYZ(D65) -> linear sRGB -> gamma-encoded
// sRGB (and back, for turning a client's logo colours into brandprint seeds —
// see NptSeedExtractor).

package ly.neptune.odyssey.tokens

import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.pow
import kotlin.math.roundToInt
import kotlin.math.sin
import kotlin.math.sqrt

/** An OKLCH colour: perceptual lightness 0..1, chroma ~0..0.4, hue degrees 0..360. */
public data class Oklch(public val l: Double, public val c: Double, public val h: Double)

private val oklabToLms = arrayOf(
    doubleArrayOf(1.0, 0.3963377773761749, 0.2158037573099136),
    doubleArrayOf(1.0, -0.1055613458156586, -0.0638541728258133),
    doubleArrayOf(1.0, -0.0894841775298119, -1.2914855480194092),
)

private val lmsToXyz = arrayOf(
    doubleArrayOf(1.2268798733741557, -0.5578149965554813, 0.2813910501772159),
    doubleArrayOf(-0.0405757452148008, 1.1122868293970594, -0.0717110580655164),
    doubleArrayOf(-0.0763729366746601, -0.4214933324022432, 1.5869240198367816),
)

private val xyzToLinSrgb = arrayOf(
    doubleArrayOf(3.2409699419045226, -1.537383177570094, -0.4986107602930034),
    doubleArrayOf(-0.9692436362808796, 1.8759675015077202, 0.04155505740717559),
    doubleArrayOf(0.05563007969699366, -0.20397695888897652, 1.0569715142428786),
)

private fun mul(m: Array<DoubleArray>, v: DoubleArray): DoubleArray = doubleArrayOf(
    m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2],
    m[1][0] * v[0] + m[1][1] * v[1] + m[1][2] * v[2],
    m[2][0] * v[0] + m[2][1] * v[1] + m[2][2] * v[2],
)

private fun clamp01(x: Double): Double = if (x < 0) 0.0 else if (x > 1) 1.0 else x

/** Linear-light sRGB channel -> gamma-encoded sRGB (0..1). */
private fun encodeSrgb(x: Double): Double {
    val c = clamp01(x)
    return if (c <= 0.0031308) 12.92 * c else 1.055 * c.pow(1 / 2.4) - 0.055
}

/** OKLCH -> linear-light sRGB (unclamped). Returns [r, g, b]. */
public fun oklchToLinearSrgb(o: Oklch): DoubleArray {
    val hr = o.h * PI / 180
    val lab = doubleArrayOf(o.l, o.c * cos(hr), o.c * sin(hr))
    val lms0 = mul(oklabToLms, lab)
    val lms = doubleArrayOf(
        lms0[0] * lms0[0] * lms0[0],
        lms0[1] * lms0[1] * lms0[1],
        lms0[2] * lms0[2] * lms0[2],
    )
    val xyz = mul(lmsToXyz, lms)
    return mul(xyzToLinSrgb, xyz)
}

/** True if the OKLCH colour is inside the sRGB gamut (no channel clamped). */
public fun inSrgbGamut(c: Oklch): Boolean {
    val rgb = oklchToLinearSrgb(c)
    val lo = -1e-4
    val hi = 1 + 1e-4
    return rgb[0] >= lo && rgb[0] <= hi &&
        rgb[1] >= lo && rgb[1] <= hi &&
        rgb[2] >= lo && rgb[2] <= hi
}

/** OKLCH -> sRGB 0..255 integer channels (per-channel clamp). Returns [r, g, b]. */
public fun oklchToRgb255(c: Oklch): IntArray {
    val lin = oklchToLinearSrgb(c)
    return intArrayOf(
        (encodeSrgb(lin[0]) * 255).roundToInt(),
        (encodeSrgb(lin[1]) * 255).roundToInt(),
        (encodeSrgb(lin[2]) * 255).roundToInt(),
    )
}

private fun hex2(n: Int): String = n.toString(16).padStart(2, '0')

/** OKLCH -> "#rrggbb" lowercase. */
public fun oklchToHex(c: Oklch): String {
    val rgb = oklchToRgb255(c)
    return "#${hex2(rgb[0])}${hex2(rgb[1])}${hex2(rgb[2])}"
}

/** OKLCH -> 0xAARRGGBB 32-bit ARGB int (alpha = 0xFF). */
public fun oklchToArgb(c: Oklch): Int {
    val rgb = oklchToRgb255(c)
    return (0xFF shl 24) or (rgb[0] shl 16) or (rgb[1] shl 8) or rgb[2]
}

// --- inverse: sRGB -> OKLCH ---------------------------------------------------

private val linSrgbToXyz = arrayOf(
    doubleArrayOf(0.41239079926595934, 0.357584339383878, 0.1804807884018343),
    doubleArrayOf(0.21263900587151027, 0.715168678767756, 0.07219231536073371),
    doubleArrayOf(0.01933081871559182, 0.11919477979462598, 0.9505321522496607),
)

private val xyzToLms = arrayOf(
    doubleArrayOf(0.8189330101, 0.3618667424, -0.1288597137),
    doubleArrayOf(0.0329845436, 0.9293118715, 0.0361456387),
    doubleArrayOf(0.0482003018, 0.2643662691, 0.6338517070),
)

private val lmsToOklab = arrayOf(
    doubleArrayOf(0.2104542553, 0.7936177850, -0.0040720468),
    doubleArrayOf(1.9779984951, -2.4285922050, 0.4505937099),
    doubleArrayOf(0.0259040371, 0.7827717662, -0.8086757660),
)

/** Gamma-encoded sRGB channel (0..1) -> linear-light sRGB. */
private fun decodeSrgb(c: Double): Double =
    if (c <= 0.04045) c / 12.92 else ((c + 0.055) / 1.055).pow(2.4)

/**
 * sRGB 0..255 integer channels -> OKLCH. The exact inverse of [oklchToRgb255] —
 * round-trips a colour through OKLCH and back to the same byte values
 * (± rounding). Use to turn an extracted brand colour (e.g. a client logo's
 * dominant colour) into brandprint seeds.
 */
public fun rgb255ToOklch(r: Int, g: Int, b: Int): Oklch {
    val lin = doubleArrayOf(decodeSrgb(r / 255.0), decodeSrgb(g / 255.0), decodeSrgb(b / 255.0))
    val xyz = mul(linSrgbToXyz, lin)
    val lms0 = mul(xyzToLms, xyz)
    val lms = doubleArrayOf(
        lms0[0].pow(1.0 / 3.0),
        lms0[1].pow(1.0 / 3.0),
        lms0[2].pow(1.0 / 3.0),
    )
    val lab = mul(lmsToOklab, lms)
    val c = sqrt(lab[1] * lab[1] + lab[2] * lab[2])
    var h = atan2(lab[2], lab[1]) * 180 / PI
    if (h < 0) h += 360
    return Oklch(lab[0], c, h)
}

/** "#rrggbb"/"#rrggbbaa" (alpha ignored) -> OKLCH. */
public fun hexToOklch(hex: String): Oklch {
    val s = hex.removePrefix("#")
    val n = s.substring(0, 6).toInt(16)
    return rgb255ToOklch((n shr 16) and 0xFF, (n shr 8) and 0xFF, n and 0xFF)
}

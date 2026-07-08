// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Dominant-colour extraction from a logo image — the Kotlin port of
// tools/client-demo/extract_colors.py's algorithm (via the Dart port in
// neptune_flutter_ui/lib/src/color/seed_extractor.dart), so any Kotlin
// consumer can turn a client's logo into brand seeds. Takes raw decoded RGBA
// pixels; has no UI/IO dependency itself.
//
// NOTE (rulebook §9): pixels sampled from a real image file must be
// colour-matched to sRGB BEFORE decoding — design-tool exports are routinely
// tagged Display P3, and reading P3 bytes as sRGB shifts hues badly.

package ly.neptune.odyssey.tokens

/**
 * Two dominant colours extracted from an image: the most-frequent saturated
 * colour ([primary]) and the most-frequent saturated colour sufficiently
 * distinct from it ([accent]).
 */
public class NptExtractedSeeds(
    public val primary: Oklch,
    public val accent: Oklch,
    public val primaryHex: String,
    public val accentHex: String,
)

private fun saturation(r: Int, g: Int, b: Int): Double {
    val mx = maxOf(r, g, b)
    val mn = minOf(r, g, b)
    return if (mx == 0) 0.0 else (mx - mn).toDouble() / mx
}

private fun dist(a: IntArray, b: IntArray): Double {
    var sum = 0
    for (i in 0 until 3) {
        val d = a[i] - b[i]
        sum += d * d
    }
    return sum.toDouble()
}

/**
 * Extracts [NptExtractedSeeds] from raw RGBA8888 pixel bytes. [width]/[height]
 * describe the image; [sampleStep] skips pixels for speed on large images
 * (4 = every 4th pixel in each axis).
 */
public fun extractSeedsFromRgba(
    rgba: ByteArray,
    width: Int,
    height: Int,
    sampleStep: Int = 4,
): NptExtractedSeeds {
    val buckets = LinkedHashMap<Int, Int>() // packed (r<<16|g<<8|b) bucket -> count
    val bucketRgb = HashMap<Int, IntArray>()

    var y = 0
    while (y < height) {
        var x = 0
        while (x < width) {
            val i = (y * width + x) * 4
            if (i + 3 < rgba.size) {
                val r = rgba[i].toInt() and 0xFF
                val g = rgba[i + 1].toInt() and 0xFF
                val b = rgba[i + 2].toInt() and 0xFF
                val a = rgba[i + 3].toInt() and 0xFF
                if (a >= 128) {
                    val mx = maxOf(r, g, b)
                    val mn = minOf(r, g, b)
                    val sat = if (mx == 0) 0.0 else (mx - mn).toDouble() / mx
                    val nearWhite = mx > 250 && mn > 235
                    if (sat >= 0.18 && !nearWhite) {
                        val br = (r / 8) * 8
                        val bg = (g / 8) * 8
                        val bb = (b / 8) * 8
                        val key = (br shl 16) or (bg shl 8) or bb
                        buckets[key] = (buckets[key] ?: 0) + 1
                        bucketRgb[key] = intArrayOf(br, bg, bb)
                    }
                }
            }
            x += sampleStep
        }
        y += sampleStep
    }

    if (buckets.isEmpty()) {
        // Fallback: a neutral navy/teal pair so the caller always gets a result.
        return NptExtractedSeeds(
            primary = hexToOklch("#1D5AB0"),
            accent = hexToOklch("#008388"),
            primaryHex = "#1D5AB0",
            accentHex = "#008388",
        )
    }

    val sorted = buckets.entries.sortedByDescending { it.value }

    val primaryRgb = bucketRgb.getValue(sorted.first().key)
    var accentRgb = primaryRgb
    for (e in sorted.drop(1)) {
        val rgb = bucketRgb.getValue(e.key)
        if (dist(rgb, primaryRgb) > 3600 && // ~60px euclidean, matches the .py
            saturation(rgb[0], rgb[1], rgb[2]) > 0.25
        ) {
            accentRgb = rgb
            break
        }
    }

    fun hexOf(rgb: IntArray): String =
        "#" + rgb.joinToString("") { it.toString(16).padStart(2, '0') }.uppercase()

    val primaryHex = hexOf(primaryRgb)
    val accentHex = hexOf(accentRgb)
    return NptExtractedSeeds(
        primary = hexToOklch(primaryHex),
        accent = hexToOklch(accentHex),
        primaryHex = primaryHex,
        accentHex = accentHex,
    )
}

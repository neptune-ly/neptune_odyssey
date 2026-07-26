// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Inverse-path tests (mirrors color_inverse_test.dart): hex→OKLCH→hex must
// round-trip within ±1 per channel, and the seed extractor must pick the two
// dominant saturated colours from synthetic RGBA pixels.

package ly.neptune.odyssey.tokens

import kotlin.math.abs
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ColorInverseTest {
    @Test
    fun hexRoundTripsThroughOklch() {
        val hexes = listOf(
            "#1d5ab0", "#008187", "#c2181d", "#208548",
            "#364680", "#ee4037", "#f5a623", "#7b2d8b",
            "#000000", "#ffffff", "#808080",
        )
        for (hex in hexes) {
            val o = hexToOklch(hex)
            val back = oklchToHex(o)
            val e = hex.removePrefix("#").toInt(16)
            val a = back.removePrefix("#").toInt(16)
            for (shift in intArrayOf(16, 8, 0)) {
                val ec = (e shr shift) and 0xFF
                val ac = (a shr shift) and 0xFF
                assertTrue(abs(ec - ac) <= 1, "$hex -> $back (channel off by ${abs(ec - ac)})")
            }
        }
    }

    @Test
    fun referenceSeedsResolveToPinnedPrimaries() {
        // The neptune primary seed is the same L/C/H the pinned palette was
        // generated from — the converter must land on the identical ARGB.
        assertEquals(0xFF1D5AB0.toInt(), oklchToArgb(Oklch(0.48, 0.15, 258.0)))
    }

    @Test
    fun seedExtractorFindsDominantAndAccent() {
        // 40×40 synthetic logo: 3/4 navy, 1/4 red, fully opaque.
        val w = 40
        val h = 40
        val rgba = ByteArray(w * h * 4)
        for (y in 0 until h) {
            for (x in 0 until w) {
                val i = (y * w + x) * 4
                val navy = x < 30
                rgba[i] = (if (navy) 54 else 238).toByte()
                rgba[i + 1] = (if (navy) 70 else 64).toByte()
                rgba[i + 2] = (if (navy) 128 else 55).toByte()
                rgba[i + 3] = 255.toByte()
            }
        }
        val seeds = extractSeedsFromRgba(rgba, w, h, sampleStep = 1)
        // Buckets quantise to /8*8: navy (54,70,128)->(48,64,128), red (238,64,55)->(232,64,48).
        assertEquals("#304080", seeds.primaryHex.lowercase())
        assertEquals("#e84030", seeds.accentHex.lowercase())
    }

    @Test
    fun seedExtractorFallsBackOnEmptyInput() {
        val seeds = extractSeedsFromRgba(ByteArray(0), 0, 0)
        assertEquals("#1D5AB0", seeds.primaryHex)
        assertEquals("#008388", seeds.accentHex)
    }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Golden gate for the OKLCH→sRGB port: the Kotlin converter must reproduce
// the pinned ARGB of every brand×mode×role sample (the same fixtures the Dart
// port is golden-tested against). Exactness is asserted; the roadmap contract
// allows ≤1 LSB per channel, so if a non-JVM target ever diverges by one LSB
// (pow ULP differences), relax via CHANNEL_TOLERANCE with a comment — never
// silently.

package ly.neptune.odyssey.tokens

import ly.neptune.odyssey.tokens.generated.genSchemes
import ly.neptune.odyssey.tokens.generated.goldenOklchSamples
import ly.neptune.odyssey.tokens.generated.goldenResolvedRoles
import kotlin.math.abs
import kotlin.test.Test
import kotlin.test.assertTrue
import kotlin.test.fail

private const val CHANNEL_TOLERANCE = 0

private fun hex(argb: Int): String = "0x" + argb.toUInt().toString(16).uppercase()

private fun assertArgbClose(expected: Int, actual: Int, context: String) {
    if (expected == actual) return
    for (shift in intArrayOf(16, 8, 0)) {
        val e = (expected shr shift) and 0xFF
        val a = (actual shr shift) and 0xFF
        if (abs(e - a) > CHANNEL_TOLERANCE) {
            fail("$context: expected ${hex(expected)}, got ${hex(actual)}")
        }
    }
}

class OklchGoldenTest {
    @Test
    fun converterReproducesGoldenArgbSamples() {
        assertTrue(goldenOklchSamples.size >= 296, "fixture unexpectedly small")
        for (s in goldenOklchSamples) {
            assertArgbClose(
                expected = s.argb,
                actual = oklchToArgb(Oklch(s.l, s.c, s.h)),
                context = "${s.brand}/${s.mode}/${s.role} oklch(${s.l} ${s.c} ${s.h})",
            )
        }
    }

    @Test
    fun converterReproducesEveryResolvedRole() {
        // The roadmap promotion gate: the Kotlin math must reproduce
        // tokens.resolved.json (≤1 LSB) for every brand × mode × role.
        assertTrue(goldenResolvedRoles.size == 4 * 2 * 37, "resolved-role fixture wrong size")
        for (s in goldenResolvedRoles) {
            assertArgbClose(
                expected = s.argb,
                actual = oklchToArgb(Oklch(s.l, s.c, s.h)),
                context = "resolved ${s.brand}/${s.mode}/${s.role} oklch(${s.l} ${s.c} ${s.h})",
            )
        }
    }

    @Test
    fun generatedSchemesMatchResolvedRoles() {
        for (s in goldenResolvedRoles) {
            val pair = genSchemes.getValue(s.brand)
            val map = if (s.mode == "light") pair.light else pair.dark
            assertArgbClose(
                expected = s.argb,
                actual = map.getValue(s.role),
                context = "genSchemes ${s.brand}/${s.mode}/${s.role}",
            )
        }
    }

    @Test
    fun hexAndArgbAgree() {
        for (s in goldenOklchSamples) {
            val hexStr = oklchToHex(Oklch(s.l, s.c, s.h))
            val fromHex = 0xFF000000.toInt() or hexStr.removePrefix("#").toInt(16)
            assertArgbClose(fromHex, oklchToArgb(Oklch(s.l, s.c, s.h)), "hex/argb ${s.role}")
        }
    }
}

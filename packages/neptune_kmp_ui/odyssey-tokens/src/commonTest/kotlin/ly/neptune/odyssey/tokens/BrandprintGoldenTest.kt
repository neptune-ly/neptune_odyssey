// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Golden gate for the brandprint codec port — mirrors
// packages/neptune_flutter_ui/test/brandprint_golden_test.dart assertion for
// assertion: encode(config) must equal the golden string exactly, decode must
// re-encode idempotently, and malformed inputs must throw.

package ly.neptune.odyssey.tokens

import ly.neptune.odyssey.tokens.generated.goldenBrandprints
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

class BrandprintGoldenTest {
    @Test
    fun encodeConfigMatchesGoldenString() {
        assertEquals(4, goldenBrandprints.size)
        for (g in goldenBrandprints) {
            assertEquals(g.brandprint, Brandprint.encode(g.config), g.brand)
        }
    }

    @Test
    fun decodeGoldenReEncodesToGolden() {
        for (g in goldenBrandprints) {
            val decoded = Brandprint.decode(g.brandprint)
            assertEquals(g.brandprint, Brandprint.encode(decoded), g.brand)
        }
    }

    @Test
    fun decodedLeversSurviveTheWire() {
        for (g in goldenBrandprints) {
            val d = Brandprint.decode(g.brandprint)
            assertEquals(g.config.fontDisplay, d.fontDisplay, g.brand)
            assertEquals(g.config.loginShell, d.loginShell, g.brand)
            assertEquals(g.config.dashboardHero, d.dashboardHero, g.brand)
            assertEquals(g.config.contentTone, d.contentTone, g.brand)
            assertEquals(g.config.glassTint, d.glassTint, g.brand)
            assertEquals(g.config.motion, d.motion, g.brand)
            assertEquals(g.config.corners, d.corners, g.brand)
            assertEquals(g.config.displayWeight, d.displayWeight, g.brand)
        }
    }

    @Test
    fun throwsOnBadPrefix() {
        val valid = goldenBrandprints.first { it.brand == "triton" }.brandprint
        assertFailsWith<BrandprintFormatException> {
            Brandprint.decode("XX1-" + valid.substring(4))
        }
    }

    @Test
    fun throwsOnChecksumMismatch() {
        val valid = goldenBrandprints.first { it.brand == "triton" }.brandprint
        // Flip a payload character (not the prefix) to corrupt the checksum.
        val body = valid.substring(4)
        val mutated = (if (body[0] == 'A') "B" else "A") + body.substring(1)
        assertFailsWith<BrandprintFormatException> {
            Brandprint.decode("NO1-$mutated")
        }
    }

    @Test
    fun throwsOnBadLength() {
        // 'NO1-' + base64url of a 4-byte payload -> wrong length.
        assertFailsWith<BrandprintFormatException> {
            Brandprint.decode("NO1-AQIDBA")
        }
    }

    @Test
    fun unknownRegistryValueEncodesAsIndexZero() {
        // _ix falls back to 0 (the TS/Dart behaviour) — never throws on encode.
        val base = goldenBrandprints.first().config
        val cfg = base.copy(fontDisplay = "Comic Sans MS")
        val decoded = Brandprint.decode(Brandprint.encode(cfg))
        assertEquals(kFonts[0], decoded.fontDisplay)
        assertTrue(Brandprint.encode(cfg).startsWith("NO1-"))
    }
}

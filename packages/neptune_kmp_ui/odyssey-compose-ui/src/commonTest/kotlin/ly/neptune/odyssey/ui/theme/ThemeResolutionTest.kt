// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Theme resolution (the non-composable core of NeptuneTheme) — mirrors
// neptune_flutter_ui's theme_test.dart: reference brands resolve to the
// pinned palettes byte-identically, a golden brandprint is equivalent to its
// reference brand, custom seeds run the ramp deterministically.

package ly.neptune.odyssey.ui.theme

import androidx.compose.ui.graphics.Color
import ly.neptune.odyssey.tokens.Brandprint
import ly.neptune.odyssey.tokens.BrandprintConfig
import ly.neptune.odyssey.tokens.Corners
import ly.neptune.odyssey.tokens.Seed
import ly.neptune.odyssey.tokens.brandConfigs
import ly.neptune.odyssey.tokens.generated.genSchemes
import ly.neptune.odyssey.tokens.kBrands
import androidx.compose.material3.ColorScheme
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

// material3 ColorScheme has no equals(); compare the roles Odyssey drives.
private fun assertSchemesEqual(expected: ColorScheme, actual: ColorScheme) {
    assertEquals(expected.primary, actual.primary, "primary")
    assertEquals(expected.onPrimary, actual.onPrimary, "onPrimary")
    assertEquals(expected.primaryContainer, actual.primaryContainer, "primaryContainer")
    assertEquals(expected.secondary, actual.secondary, "secondary")
    assertEquals(expected.tertiary, actual.tertiary, "tertiary")
    assertEquals(expected.onTertiaryContainer, actual.onTertiaryContainer, "onTertiaryContainer")
    assertEquals(expected.error, actual.error, "error")
    assertEquals(expected.surface, actual.surface, "surface")
    assertEquals(expected.onSurface, actual.onSurface, "onSurface")
    assertEquals(expected.surfaceContainer, actual.surfaceContainer, "surfaceContainer")
    assertEquals(expected.outline, actual.outline, "outline")
    assertEquals(expected.outlineVariant, actual.outlineVariant, "outlineVariant")
    assertEquals(expected.inversePrimary, actual.inversePrimary, "inversePrimary")
    assertEquals(expected.scrim, actual.scrim, "scrim")
}

class ThemeResolutionTest {
    @Test
    fun referenceBrandsResolveToPinnedSchemes() {
        for (brand in kBrands) {
            val cfg = brandConfigs.getValue(brand)
            for (dark in listOf(false, true)) {
                val spec = resolveNeptuneTheme(cfg, dark)
                val roles = if (dark) genSchemes.getValue(brand).dark else genSchemes.getValue(brand).light
                assertEquals(Color(roles.getValue("primary")), spec.colorScheme.primary, "$brand primary")
                assertEquals(Color(roles.getValue("surface")), spec.colorScheme.surface, "$brand surface")
                assertEquals(Color(roles.getValue("tertiary")), spec.colorScheme.tertiary, "$brand tertiary")
                assertEquals(Color(roles.getValue("success")), spec.colors.success, "$brand success")
                assertEquals(Color(roles.getValue("outline-variant")), spec.colorScheme.outlineVariant, "$brand outlineVariant")
            }
        }
    }

    @Test
    fun goldenBrandprintResolvesLikeItsReferenceBrand() {
        // The triton brandprint must produce the exact pinned triton palette
        // after the decode→quantised-seed match — Flutter asserts
        // fromBrandprint(golden) == light('triton'). encode(brandConfigs) is
        // itself golden-locked to brandprints.golden.json in :odyssey-tokens.
        val print = Brandprint.encode(brandConfigs.getValue("triton"))
        val decoded = Brandprint.decode(print)
        val fromPrint = resolveNeptuneTheme(decoded, dark = false)
        val fromBrand = resolveNeptuneTheme(brandConfigs.getValue("triton"), dark = false)
        assertSchemesEqual(fromBrand.colorScheme, fromPrint.colorScheme)
        assertEquals(fromBrand.colors, fromPrint.colors)
        assertEquals(fromBrand.shape, fromPrint.shape)
        assertEquals(fromBrand.type, fromPrint.type)
    }

    @Test
    fun customSeedsGenerateDeterministically() {
        val cfg = BrandprintConfig(
            primary = Seed(l = 0.45, c = 0.14, h = 210),
            tertiary = Seed(l = 0.60, c = 0.11, h = 40),
            corners = Corners(xs = 10, sm = 14, md = 18, lg = 26, xl = 34, xxl = 46),
            displayWeight = 800,
            displayTracking = -0.015,
            fontDisplay = "Sora",
            fontText = "Hanken Grotesk",
            fontNum = "Sora",
            loginShell = "depth-emblem",
            dashboardHero = "balance-cards",
            contentTone = "clear-calm",
            glassTint = "oceanic",
            motion = "smooth-fluid",
        )
        val a = resolveNeptuneTheme(cfg, dark = false)
        val b = resolveNeptuneTheme(cfg, dark = false)
        assertSchemesEqual(a.colorScheme, b.colorScheme)
        // Not a reference brand: differs from every pinned primary.
        for (brand in kBrands) {
            assertNotEquals(
                Color(genSchemes.getValue(brand).light.getValue("primary")),
                a.colorScheme.primary,
                brand,
            )
        }
        // Custom corners/type flow through.
        assertEquals(10f, a.shape.xs.value)
        assertEquals("Sora", a.type.display)
        assertEquals(800, a.type.displayWeight)
    }

    @Test
    fun customConfigRoundTripsThroughItsBrandprint() {
        val cfg = brandConfigs.getValue("nereid")
        val print = Brandprint.encode(cfg)
        val spec = resolveNeptuneTheme(Brandprint.decode(print), dark = true)
        assertEquals(
            Color(genSchemes.getValue("nereid").dark.getValue("primary")),
            spec.colorScheme.primary,
        )
    }

    @Test
    fun identityAndMotionResolvePerBrand() {
        val triton = resolveNeptuneTheme(brandConfigs.getValue("triton"), dark = false)
        assertTrue(triton.identity.glassOnTertiary, "triton glass rides tertiary")
        assertEquals(NptMotifKind.CoastalArcs, triton.identity.motif)
        assertEquals(280, triton.motion.fastMs)
        val nereid = resolveNeptuneTheme(brandConfigs.getValue("nereid"), dark = false)
        assertEquals(NptMotifKind.GridSpark, nereid.identity.motif)
        assertEquals(22f, nereid.identity.glassBlur.value)
    }

    @Test
    fun numeralsFormatSwapsDigits() {
        val n = NptNumerals(NeptuneNumeralStyle.EasternArabic)
        assertEquals("٢,٤٨٤.٠٠", n.format("2,484.00"))
        assertEquals("abc", n.format("abc"))
        assertEquals("2,484.00", NptNumerals(NeptuneNumeralStyle.Latin).format("2,484.00"))
    }

    @Test
    fun unknownBrandThrows() {
        assertFailsWith<IllegalArgumentException> {
            requireNotNull(brandConfigs["atlantis"]) { "unknown reference brand: atlantis" }
        }
    }
}

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
import ly.neptune.odyssey.tokens.generated.genOdyssey3Schemes
import ly.neptune.odyssey.tokens.generated.genSchemes
import ly.neptune.odyssey.tokens.kBrands
import androidx.compose.material3.ColorScheme
import androidx.compose.ui.text.font.FontWeight
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
    assertEquals(expected.onPrimaryContainer, actual.onPrimaryContainer, "onPrimaryContainer")
    assertEquals(expected.surfaceTint, actual.surfaceTint, "surfaceTint")
    assertEquals(expected.secondary, actual.secondary, "secondary")
    assertEquals(expected.onSecondary, actual.onSecondary, "onSecondary")
    assertEquals(expected.secondaryContainer, actual.secondaryContainer, "secondaryContainer")
    assertEquals(expected.onSecondaryContainer, actual.onSecondaryContainer, "onSecondaryContainer")
    assertEquals(expected.tertiary, actual.tertiary, "tertiary")
    assertEquals(expected.onTertiary, actual.onTertiary, "onTertiary")
    assertEquals(expected.tertiaryContainer, actual.tertiaryContainer, "tertiaryContainer")
    assertEquals(expected.onTertiaryContainer, actual.onTertiaryContainer, "onTertiaryContainer")
    assertEquals(expected.error, actual.error, "error")
    assertEquals(expected.onError, actual.onError, "onError")
    assertEquals(expected.errorContainer, actual.errorContainer, "errorContainer")
    assertEquals(expected.onErrorContainer, actual.onErrorContainer, "onErrorContainer")
    assertEquals(expected.background, actual.background, "background")
    assertEquals(expected.onBackground, actual.onBackground, "onBackground")
    assertEquals(expected.surface, actual.surface, "surface")
    assertEquals(expected.onSurface, actual.onSurface, "onSurface")
    assertEquals(expected.surfaceVariant, actual.surfaceVariant, "surfaceVariant")
    assertEquals(expected.onSurfaceVariant, actual.onSurfaceVariant, "onSurfaceVariant")
    assertEquals(expected.surfaceContainer, actual.surfaceContainer, "surfaceContainer")
    assertEquals(expected.surfaceContainerLowest, actual.surfaceContainerLowest, "surfaceContainerLowest")
    assertEquals(expected.surfaceContainerLow, actual.surfaceContainerLow, "surfaceContainerLow")
    assertEquals(expected.surfaceContainerHigh, actual.surfaceContainerHigh, "surfaceContainerHigh")
    assertEquals(expected.surfaceContainerHighest, actual.surfaceContainerHighest, "surfaceContainerHighest")
    assertEquals(expected.surfaceDim, actual.surfaceDim, "surfaceDim")
    assertEquals(expected.surfaceBright, actual.surfaceBright, "surfaceBright")
    assertEquals(expected.outline, actual.outline, "outline")
    assertEquals(expected.outlineVariant, actual.outlineVariant, "outlineVariant")
    assertEquals(expected.inverseSurface, actual.inverseSurface, "inverseSurface")
    assertEquals(expected.inverseOnSurface, actual.inverseOnSurface, "inverseOnSurface")
    assertEquals(expected.inversePrimary, actual.inversePrimary, "inversePrimary")
    assertEquals(expected.scrim, actual.scrim, "scrim")
}

private fun assertOdyssey3Roles(roles: Map<String, Int>, spec: ResolvedNeptuneTheme) {
    fun c(role: String) = Color(roles.getValue(role))
    val scheme = spec.colorScheme
    assertEquals(c("primary"), scheme.primary)
    assertEquals(c("on-primary"), scheme.onPrimary)
    assertEquals(c("primary-container"), scheme.primaryContainer)
    assertEquals(c("on-primary-container"), scheme.onPrimaryContainer)
    assertEquals(c("secondary"), scheme.secondary)
    assertEquals(c("on-secondary"), scheme.onSecondary)
    assertEquals(c("secondary-container"), scheme.secondaryContainer)
    assertEquals(c("on-secondary-container"), scheme.onSecondaryContainer)
    assertEquals(c("tertiary"), scheme.tertiary)
    assertEquals(c("on-tertiary"), scheme.onTertiary)
    assertEquals(c("tertiary-container"), scheme.tertiaryContainer)
    assertEquals(c("on-tertiary-container"), scheme.onTertiaryContainer)
    assertEquals(c("background"), scheme.background)
    assertEquals(c("on-background"), scheme.onBackground)
    assertEquals(c("surface"), scheme.surface)
    assertEquals(c("on-surface"), scheme.onSurface)
    assertEquals(c("surface-variant"), scheme.surfaceVariant)
    assertEquals(c("on-surface-variant"), scheme.onSurfaceVariant)
    assertEquals(c("surface-container-lowest"), scheme.surfaceContainerLowest)
    assertEquals(c("surface-container-low"), scheme.surfaceContainerLow)
    assertEquals(c("surface-container"), scheme.surfaceContainer)
    assertEquals(c("surface-container-high"), scheme.surfaceContainerHigh)
    assertEquals(c("surface-container-highest"), scheme.surfaceContainerHighest)
    assertEquals(c("inverse-surface"), scheme.inverseSurface)
    assertEquals(c("inverse-on-surface"), scheme.inverseOnSurface)
    assertEquals(c("inverse-primary"), scheme.inversePrimary)
    assertEquals(c("error"), scheme.error)
    assertEquals(c("on-error"), scheme.onError)
    assertEquals(c("error-container"), scheme.errorContainer)
    assertEquals(c("on-error-container"), scheme.onErrorContainer)
    assertEquals(c("outline"), scheme.outline)
    assertEquals(c("outline-variant"), scheme.outlineVariant)
    assertEquals(c("scrim"), scheme.scrim)
    assertEquals(c("success"), spec.colors.success)
    assertEquals(c("on-success"), spec.colors.onSuccess)
    assertEquals(c("success-container"), spec.colors.successContainer)
    assertEquals(c("on-success-container"), spec.colors.onSuccessContainer)
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
    fun odyssey3PublicProfilesUseCompleteGeneratedSchemes() {
        val cfg = brandConfigs.getValue("neptune")
        val products = mapOf(
            NeptuneOdyssey3Product.Wallet to "core",
            NeptuneOdyssey3Product.Drive to "drive",
            NeptuneOdyssey3Product.Orbit to "orbit",
        )
        for ((product, key) in products) {
            for (dark in listOf(false, true)) {
                val spec = resolveNeptuneTheme(cfg, dark, product)
                assertOdyssey3Roles(
                    genOdyssey3Schemes.getValue(key).getValue(if (dark) "dark" else "light"),
                    spec,
                )
            }
        }
    }

    @Test
    fun nullAndBankingKeepTenantColorSchemesAndSuccessRoles() {
        val cfg = brandConfigs.getValue("triton")
        for (dark in listOf(false, true)) {
            val v1 = resolveNeptuneTheme(cfg, dark)
            val banking = resolveNeptuneTheme(cfg, dark, NeptuneOdyssey3Product.Banking)
            assertSchemesEqual(v1.colorScheme, banking.colorScheme)
            assertEquals(v1.colors, banking.colors)
        }
    }

    @Test
    fun odyssey3RoutesFoundationWithoutChangingV1TenantTokens() {
        val cfg = brandConfigs.getValue("triton")
        val v1 = resolveNeptuneTheme(cfg, dark = false)
        val o3 = resolveNeptuneTheme(cfg, dark = false, odyssey3 = NeptuneOdyssey3Product.Banking)

        assertEquals(v1.colorScheme.primary, o3.colorScheme.primary, "bank palette remains tenant-owned")
        assertEquals(v1.shape, resolveNeptuneTheme(cfg, dark = false).shape, "v1 shape is unchanged")
        assertEquals("Hanken Grotesk", o3.type.text)
        assertEquals("Beiruti", o3.type.textAr)
        assertEquals(4f, o3.shape.xs.value)
        assertEquals(8f, o3.shape.sm.value)
        assertEquals(16f, o3.shape.md.value)
        assertEquals(24f, o3.shape.lg.value)
        assertEquals(32f, o3.shape.xl.value)
        assertEquals(999f, o3.shape.full.value)
        assertEquals(16f, o3.shape.control.value)
        assertEquals("Hanken Grotesk", o3.type.numAr)

        val en = neptuneTypography(o3.type, null, null, odyssey3 = true)
        val ar = neptuneTypography(o3.type, null, null, odyssey3 = true, arabic = true, numericFamily = androidx.compose.ui.text.font.FontFamily.Monospace)
        assertEquals(androidx.compose.ui.text.font.FontFamily.Monospace, ar.displaySmall.fontFamily)
        for (typography in listOf(en, ar)) {
            for (style in listOf(typography.displayLarge, typography.headlineLarge, typography.titleLarge,
                typography.bodyLarge, typography.labelLarge, typography.bodySmall)) {
                assertEquals(0f, style.letterSpacing.value, "O3 uses explicit native zero tracking")
            }
        }
        assertEquals(32, en.headlineLarge.fontSize.value.toInt())
        assertEquals(40, en.headlineLarge.lineHeight.value.toInt())
        assertEquals(24, en.titleLarge.fontSize.value.toInt())
        assertEquals(20, en.titleMedium.fontSize.value.toInt())
        assertEquals(16, en.bodyLarge.fontSize.value.toInt())
        assertEquals(24, en.bodyLarge.lineHeight.value.toInt())
        assertEquals(36, en.displaySmall.fontSize.value.toInt())
        assertEquals(FontWeight.W600, en.displaySmall.fontWeight)
        assertEquals(20, ar.bodyLarge.fontSize.value.toInt())
        assertEquals(28, ar.bodyLarge.lineHeight.value.toInt())
        assertEquals(18, ar.labelLarge.fontSize.value.toInt())
        assertEquals(24, ar.labelLarge.lineHeight.value.toInt())
        assertEquals(16, ar.bodySmall.fontSize.value.toInt())
        assertEquals(22, ar.bodySmall.lineHeight.value.toInt())
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
    fun odyssey3MotionUsesCanonicalDurationsAndReducedMode() {
        val cfg = brandConfigs.getValue("triton")
        val v1 = resolveNeptuneTheme(cfg, dark = false)
        for (product in NeptuneOdyssey3Product.entries) {
            val full = resolveNeptuneTheme(cfg, false, product).motion
            val reduced = resolveNeptuneTheme(cfg, false, product, reducedMotion = true).motion
            assertEquals(listOf(120, 200, 320, 600), listOf(full.fastMs, full.standardMs, full.slowMs, full.celebrateMs))
            assertEquals(listOf(0, 0, 0, 0), listOf(reduced.fastMs, reduced.standardMs, reduced.slowMs, reduced.celebrateMs))
            assertEquals(v1.motion.standard, full.standard)
            assertEquals(v1.motion.glassBlur, full.glassBlur)
        }
        assertEquals(v1.motion, resolveNeptuneTheme(cfg, false, reducedMotion = true).motion)
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

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The canonical BrandprintConfig table for the four reference brands
// (mirrors brandprints.golden.json and neptune_flutter_ui's brand_tables.dart)
// plus reference-seed matching with the brandprint quantisation tolerance.

package ly.neptune.odyssey.tokens

/** The four reference brand ids in canonical order. */
public val kBrands: List<String> = listOf("neptune", "triton", "nereid", "proteus")

/** The canonical brandprint config per reference brand (brandprints.golden.json). */
public val brandConfigs: Map<String, BrandprintConfig> = mapOf(
    "neptune" to BrandprintConfig(
        primary = Seed(l = 0.48, c = 0.15, h = 258),
        tertiary = Seed(l = 0.55, c = 0.10, h = 200),
        corners = Corners(xs = 8, sm = 12, md = 16, lg = 24, xl = 32, xxl = 44),
        displayWeight = 700,
        displayTracking = -0.02,
        fontDisplay = "Hanken Grotesk",
        fontText = "Hanken Grotesk",
        fontNum = "Hanken Grotesk",
        loginShell = "depth-emblem",
        dashboardHero = "balance-cards",
        contentTone = "clear-calm",
        glassTint = "oceanic",
        motion = "smooth-fluid",
    ),
    "triton" to BrandprintConfig(
        primary = Seed(l = 0.50, c = 0.12, h = 162),
        tertiary = Seed(l = 0.62, c = 0.12, h = 86),
        corners = Corners(xs = 12, sm = 18, md = 26, lg = 34, xl = 44, xxl = 56),
        displayWeight = 700,
        displayTracking = -0.01,
        fontDisplay = "Bricolage Grotesque",
        fontText = "Hanken Grotesk",
        fontNum = "Hanken Grotesk",
        loginShell = "arcade-arches",
        dashboardHero = "warm-balance-cards",
        contentTone = "warm-hospitable",
        glassTint = "warm-amber",
        motion = "calm-graceful",
    ),
    "nereid" to BrandprintConfig(
        primary = Seed(l = 0.52, c = 0.18, h = 292),
        tertiary = Seed(l = 0.60, c = 0.16, h = 350),
        corners = Corners(xs = 4, sm = 8, md = 12, lg = 18, xl = 26, xxl = 36),
        displayWeight = 600,
        displayTracking = -0.03,
        fontDisplay = "Space Grotesk",
        fontText = "Hanken Grotesk",
        fontNum = "Space Grotesk",
        loginShell = "light-grid-spark",
        dashboardHero = "wallet-hero",
        contentTone = "light-instant",
        glassTint = "violet-luminous",
        motion = "light-quick-crisp",
    ),
    "proteus" to BrandprintConfig(
        primary = Seed(l = 0.42, c = 0.13, h = 248),
        tertiary = Seed(l = 0.66, c = 0.12, h = 85),
        corners = Corners(xs = 6, sm = 10, md = 14, lg = 20, xl = 28, xxl = 38),
        displayWeight = 700,
        displayTracking = -0.02,
        fontDisplay = "Sora",
        fontText = "Hanken Grotesk",
        fontNum = "Sora",
        loginShell = "shield-guilloche",
        dashboardHero = "restrained-balance",
        contentTone = "formal-authoritative",
        glassTint = "navy-steel",
        motion = "stable-minimal-authoritative",
    ),
)

private fun seedClose(a: Seed, b: Seed): Boolean {
    // L quantised to 1/255, C to 0.001, H integer degrees.
    return kotlin.math.abs(a.l - b.l) <= 1 / 255.0 + 1e-9 &&
        kotlin.math.abs(a.c - b.c) <= 0.001 + 1e-9 &&
        a.h == b.h
}

/**
 * Return the reference brand id whose seeds match [primary]/[tertiary] within
 * the brandprint quantisation tolerance, or null for a custom seed set.
 */
public fun matchReferenceBrand(primary: Seed, tertiary: Seed): String? {
    for (brand in kBrands) {
        val cfg = brandConfigs.getValue(brand)
        if (seedClose(cfg.primary, primary) && seedClose(cfg.tertiary, tertiary)) {
            return brand
        }
    }
    return null
}

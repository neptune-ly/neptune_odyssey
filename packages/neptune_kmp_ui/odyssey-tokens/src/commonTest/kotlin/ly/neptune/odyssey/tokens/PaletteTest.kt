// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The v1 seed→palette ramp: structure and invariants. The per-recipe numbers
// are a line-for-line port of palette.ts/palette.dart; the float math under
// them is covered by OklchGoldenTest.

package ly.neptune.odyssey.tokens

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

class PaletteTest {
    private val primary = Oklch(0.48, 0.15, 258.0)
    private val tertiary = Oklch(0.55, 0.10, 200.0)

    @Test
    fun generatesAll37RolesInBothModes() {
        assertEquals(37, generatePaletteArgb(primary, tertiary, "light").size)
        assertEquals(37, generatePaletteArgb(primary, tertiary, "dark").size)
    }

    @Test
    fun isDeterministic() {
        assertEquals(
            generatePaletteArgb(primary, tertiary, "light"),
            generatePaletteArgb(primary, tertiary, "light"),
        )
    }

    @Test
    fun hexAndArgbVariantsAgree() {
        val hex = generatePalette(primary, tertiary, "light")
        val argb = generatePaletteArgb(primary, tertiary, "light")
        for ((role, h) in hex) {
            assertEquals(h, "#" + (argb.getValue(role) and 0xFFFFFF).toString(16).padStart(6, '0'), role)
        }
    }

    @Test
    fun errorAndSuccessAreBrandInvariant() {
        // Fixed semantic hues + absolute chroma: identical whatever the seeds.
        val a = generatePaletteArgb(primary, tertiary, "light")
        val b = generatePaletteArgb(Oklch(0.52, 0.18, 292.0), Oklch(0.60, 0.16, 350.0), "light")
        for (role in listOf(
            "error", "on-error", "error-container", "on-error-container",
            "success", "on-success", "success-container", "on-success-container",
        )) {
            assertEquals(a.getValue(role), b.getValue(role), role)
        }
        // …while brand-driven roles differ.
        assertNotEquals(a.getValue("primary"), b.getValue("primary"))
    }

    @Test
    fun neutralRolesRideThePrimaryHueNotTertiary() {
        val a = generatePaletteArgb(primary, tertiary, "light")
        val b = generatePaletteArgb(primary, Oklch(0.60, 0.16, 350.0), "light")
        assertEquals(a.getValue("surface"), b.getValue("surface"))
        assertEquals(a.getValue("outline"), b.getValue("outline"))
        assertNotEquals(a.getValue("tertiary"), b.getValue("tertiary"))
    }

    @Test
    fun primaryRoleReproducesTheRampRecipe() {
        // light primary recipe is L=0.48, chroma ×1, primary hue — with the
        // neptune seed this must land on the pinned neptune primary.
        val palette = generatePaletteArgb(primary, tertiary, "light")
        assertEquals(0xFF1D5AB0.toInt(), palette.getValue("primary"))
    }
}

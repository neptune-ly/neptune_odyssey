// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

package ly.neptune.odyssey.tokens

import kotlin.test.Test
import kotlin.test.assertEquals

class GlanceTest {
    @Test
    fun scaleMatchesTheFlutterTwin() {
        // Mirrors neptune_flutter_ui/test/glance_test.dart. A change on one side is a change on both.
        val g = NptGlance.standard
        assertEquals(30f, g.figure)
        assertEquals(13f, g.unit)
        assertEquals(11f, g.eyebrow)
        assertEquals(0.08f, g.eyebrowTracking)
        assertEquals(12f, g.provenance)
        assertEquals(14f, g.rowTitle)
        assertEquals(12f, g.rowMeta)
        assertEquals(0.10f, g.roundInsetFraction)
        assertEquals(12f, g.sectionGap)
        assertEquals(6f, g.rowGap)
        assertEquals(48f, g.minTouch)
    }

    @Test
    fun insetIsATenthOfTheDiameter() {
        assertEquals(20f, NptGlance.standard.insetFor(200f))
    }
}

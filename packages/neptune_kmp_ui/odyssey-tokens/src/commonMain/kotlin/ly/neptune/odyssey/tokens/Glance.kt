// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The wrist scale — the Kotlin twin of neptune_flutter_ui's `NptGlance`
// (2.26.0). Pure Kotlin, Compose-free, like everything in :odyssey-tokens, so
// a Wear OS or KMP consumer can read it from any target. The numbers are the
// design system's; a host that cannot depend on this module copies them and
// pins the copy with a test (neptune-mobile's `GlanceScaleTest` does).

package ly.neptune.odyssey.tokens

/**
 * What a wrist, a tile or a complication draws with. Sizes in sp/dp as plain
 * floats; the consumer applies its own unit type.
 *
 * Not derived from the phone type ramp by a factor: a wrist needs different
 * proportions, not smaller ones. Four registers — the figure, its unit, the
 * line that dates it, the rows under it — and the one rule a round face
 * imposes.
 */
public data class NptGlance(
    /** The balance itself. Readable at arm's length in one second. */
    public val figure: Float = 30f,
    /** The currency, beside the figure at a lower baseline. */
    public val unit: Float = 13f,
    /** Eyebrow over the figure: account label + tail. Uppercase, tracked. */
    public val eyebrow: Float = 11f,
    /** Eyebrow tracking, in em. */
    public val eyebrowTracking: Float = 0.08f,
    /** The "as of" / stale / hidden line under the figure. */
    public val provenance: Float = 12f,
    public val rowTitle: Float = 14f,
    public val rowMeta: Float = 12f,
    public val figureLineHeight: Float = 1.15f,
    public val rowLineHeight: Float = 1.3f,
    /** Safe-area inset on a round face, as a fraction of the diameter. */
    public val roundInsetFraction: Float = 0.10f,
    public val sectionGap: Float = 12f,
    public val rowGap: Float = 6f,
    /** The platform minimum touch target on a wrist. */
    public val minTouch: Float = 48f,
    /** The direction glyph's disc beside a row. */
    public val rowGlyph: Float = 20f,
) {
    /** The safe-area inset for a face of [diameter], on every side. */
    public fun insetFor(diameter: Float): Float = diameter * roundInsetFraction

    public companion object {
        /** One instance for every brand: a brand colours and typesets a glance, it does not resize it. */
        public val standard: NptGlance = NptGlance()
    }
}

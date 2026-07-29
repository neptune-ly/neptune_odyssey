// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Brand face resolution. The 9 reference faces (all OFL Google Fonts — the
// exact set in the brandprint font registry, kFonts) ship inside this package
// as Compose resources, so the same brandprint renders the same type on every
// platform with no network fetch (the google_fonts analog, offline).
// Custom-brand faces register at runtime via [NeptuneFontRegistry.register];
// an unknown family name falls back to the platform default (mirrors the
// Flutter name-only fallback).

package ly.neptune.odyssey.ui.theme

import androidx.compose.runtime.Composable
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import ly.neptune.odyssey.ui.resources.Res
import ly.neptune.odyssey.ui.resources.bricolage_grotesque_400
import ly.neptune.odyssey.ui.resources.bricolage_grotesque_500
import ly.neptune.odyssey.ui.resources.bricolage_grotesque_600
import ly.neptune.odyssey.ui.resources.bricolage_grotesque_700
import ly.neptune.odyssey.ui.resources.bricolage_grotesque_800
import ly.neptune.odyssey.ui.resources.hanken_grotesk_400
import ly.neptune.odyssey.ui.resources.hanken_grotesk_500
import ly.neptune.odyssey.ui.resources.hanken_grotesk_600
import ly.neptune.odyssey.ui.resources.hanken_grotesk_700
import ly.neptune.odyssey.ui.resources.hanken_grotesk_800
import ly.neptune.odyssey.ui.resources.ibm_plex_sans_arabic_400
import ly.neptune.odyssey.ui.resources.ibm_plex_sans_arabic_500
import ly.neptune.odyssey.ui.resources.ibm_plex_sans_arabic_600
import ly.neptune.odyssey.ui.resources.ibm_plex_sans_arabic_700
import ly.neptune.odyssey.ui.resources.noto_kufi_arabic_400
import ly.neptune.odyssey.ui.resources.noto_kufi_arabic_500
import ly.neptune.odyssey.ui.resources.noto_kufi_arabic_600
import ly.neptune.odyssey.ui.resources.noto_kufi_arabic_700
import ly.neptune.odyssey.ui.resources.noto_kufi_arabic_800
import ly.neptune.odyssey.ui.resources.readex_pro_400
import ly.neptune.odyssey.ui.resources.readex_pro_500
import ly.neptune.odyssey.ui.resources.readex_pro_600
import ly.neptune.odyssey.ui.resources.readex_pro_700
import ly.neptune.odyssey.ui.resources.reem_kufi_400
import ly.neptune.odyssey.ui.resources.reem_kufi_500
import ly.neptune.odyssey.ui.resources.reem_kufi_600
import ly.neptune.odyssey.ui.resources.reem_kufi_700
import ly.neptune.odyssey.ui.resources.sora_400
import ly.neptune.odyssey.ui.resources.sora_500
import ly.neptune.odyssey.ui.resources.sora_600
import ly.neptune.odyssey.ui.resources.sora_700
import ly.neptune.odyssey.ui.resources.sora_800
import ly.neptune.odyssey.ui.resources.space_grotesk_400
import ly.neptune.odyssey.ui.resources.space_grotesk_500
import ly.neptune.odyssey.ui.resources.space_grotesk_600
import ly.neptune.odyssey.ui.resources.space_grotesk_700
import ly.neptune.odyssey.ui.resources.tajawal_400
import ly.neptune.odyssey.ui.resources.tajawal_500
import ly.neptune.odyssey.ui.resources.tajawal_700
import ly.neptune.odyssey.ui.resources.tajawal_800
import org.jetbrains.compose.resources.Font

/** Runtime registry for custom-brand faces (families outside the reference
 * set). Register before composing [NeptuneTheme]. */
public object NeptuneFontRegistry {
    private val custom = mutableMapOf<String, FontFamily>()

    /** Map a family name (as carried in a [ly.neptune.odyssey.tokens.BrandprintConfig])
     * to a loaded [FontFamily]. Overrides a bundled face of the same name. */
    public fun register(family: String, fontFamily: FontFamily) {
        custom[family] = fontFamily
    }

    internal fun customFor(family: String): FontFamily? = custom[family]
}

/** Resolve a brand family name to a [FontFamily]: runtime registrations win,
 * then the bundled reference faces, then null (platform default). */
@Composable
internal fun rememberNeptuneFontFamily(family: String): FontFamily? {
    NeptuneFontRegistry.customFor(family)?.let { return it }
    return when (family) {
        "Hanken Grotesk" -> FontFamily(
            Font(Res.font.hanken_grotesk_400, FontWeight.W400),
            Font(Res.font.hanken_grotesk_500, FontWeight.W500),
            Font(Res.font.hanken_grotesk_600, FontWeight.W600),
            Font(Res.font.hanken_grotesk_700, FontWeight.W700),
            Font(Res.font.hanken_grotesk_800, FontWeight.W800),
        )
        "Bricolage Grotesque" -> FontFamily(
            Font(Res.font.bricolage_grotesque_400, FontWeight.W400),
            Font(Res.font.bricolage_grotesque_500, FontWeight.W500),
            Font(Res.font.bricolage_grotesque_600, FontWeight.W600),
            Font(Res.font.bricolage_grotesque_700, FontWeight.W700),
            Font(Res.font.bricolage_grotesque_800, FontWeight.W800),
        )
        "Space Grotesk" -> FontFamily(
            Font(Res.font.space_grotesk_400, FontWeight.W400),
            Font(Res.font.space_grotesk_500, FontWeight.W500),
            Font(Res.font.space_grotesk_600, FontWeight.W600),
            Font(Res.font.space_grotesk_700, FontWeight.W700),
        )
        "Sora" -> FontFamily(
            Font(Res.font.sora_400, FontWeight.W400),
            Font(Res.font.sora_500, FontWeight.W500),
            Font(Res.font.sora_600, FontWeight.W600),
            Font(Res.font.sora_700, FontWeight.W700),
            Font(Res.font.sora_800, FontWeight.W800),
        )
        "IBM Plex Sans Arabic" -> FontFamily(
            Font(Res.font.ibm_plex_sans_arabic_400, FontWeight.W400),
            Font(Res.font.ibm_plex_sans_arabic_500, FontWeight.W500),
            Font(Res.font.ibm_plex_sans_arabic_600, FontWeight.W600),
            Font(Res.font.ibm_plex_sans_arabic_700, FontWeight.W700),
        )
        "Reem Kufi" -> FontFamily(
            Font(Res.font.reem_kufi_400, FontWeight.W400),
            Font(Res.font.reem_kufi_500, FontWeight.W500),
            Font(Res.font.reem_kufi_600, FontWeight.W600),
            Font(Res.font.reem_kufi_700, FontWeight.W700),
        )
        "Tajawal" -> FontFamily(
            Font(Res.font.tajawal_400, FontWeight.W400),
            Font(Res.font.tajawal_500, FontWeight.W500),
            Font(Res.font.tajawal_700, FontWeight.W700),
            Font(Res.font.tajawal_800, FontWeight.W800),
        )
        "Readex Pro" -> FontFamily(
            Font(Res.font.readex_pro_400, FontWeight.W400),
            Font(Res.font.readex_pro_500, FontWeight.W500),
            Font(Res.font.readex_pro_600, FontWeight.W600),
            Font(Res.font.readex_pro_700, FontWeight.W700),
        )
        "Noto Kufi Arabic" -> FontFamily(
            Font(Res.font.noto_kufi_arabic_400, FontWeight.W400),
            Font(Res.font.noto_kufi_arabic_500, FontWeight.W500),
            Font(Res.font.noto_kufi_arabic_600, FontWeight.W600),
            Font(Res.font.noto_kufi_arabic_700, FontWeight.W700),
            Font(Res.font.noto_kufi_arabic_800, FontWeight.W800),
        )
        else -> null
    }
}

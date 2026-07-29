// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The SHOTS-analog (rulebook §5): pixel-exact engine renders of every gallery
// section × 4 brands × light/dark × LTR/RTL, written as PNGs and gated by
// tools/blank_check.py + eyes-on review. Uses ImageComposeScene (software
// Skia) — no window, no screen-capture permissions, identical bytes in CI.
//
// Two passes per shot: measure the section's natural height first, then
// render at exactly that height (a fixed tall canvas would trip the blank
// gate's flat-band detector on short sections).

package ly.neptune.odyssey.gallery

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.dp
import androidx.compose.ui.use
import ly.neptune.odyssey.tokens.kBrands
import org.jetbrains.skia.EncodedImageFormat
import java.io.File

private const val WIDTH_DP = 430
private const val SCALE = 2f

@OptIn(ExperimentalComposeUiApi::class)
private fun renderSection(
    out: File,
    section: GallerySection,
    brand: String,
    dark: Boolean,
    rtl: Boolean,
) {
    val widthPx = (WIDTH_DP * SCALE).toInt()
    val density = Density(SCALE)

    // Pass 1 — measure the section's laid-out height.
    var contentHeightPx = 0
    ImageComposeScene(widthPx, 6000, density) {
        GalleryFrame(brand, dark, rtl, reducedMotion = true) {
            Box(
                Modifier
                    .fillMaxWidth()
                    .onSizeChanged { contentHeightPx = it.height }
                    .padding(16.dp),
            ) {
                section.content()
            }
        }
    }.use { it.render() }

    val heightPx = (contentHeightPx + (32 * SCALE).toInt()).coerceIn(200, 6000)

    // Pass 2 — render at the measured height.
    ImageComposeScene(widthPx, heightPx, density) {
        GalleryFrame(brand, dark, rtl, reducedMotion = true) {
            Box(Modifier.fillMaxWidth().padding(16.dp)) {
                section.content()
            }
        }
    }.use { scene ->
        val image = scene.render()
        val png = image.encodeToData(EncodedImageFormat.PNG)
            ?: error("PNG encode failed for ${section.slug}")
        val mode = if (dark) "dark" else "light"
        val dir = if (rtl) "rtl" else "ltr"
        File(out, "${brand}_${mode}_${dir}_${section.slug}.png").writeBytes(png.bytes)
    }
}

fun main(args: Array<String>) {
    val out = File(args.firstOrNull() ?: "build/shots")
    out.mkdirs()
    var count = 0
    for (brand in kBrands) {
        for (dark in listOf(false, true)) {
            for (rtl in listOf(false, true)) {
                for (section in gallerySections()) {
                    renderSection(out, section, brand, dark, rtl)
                    count++
                }
            }
        }
    }
    println("renderShots: wrote $count PNGs to ${out.absolutePath}")
}

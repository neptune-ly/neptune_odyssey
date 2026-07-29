// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

package ly.neptune.odyssey.gallery

import androidx.compose.runtime.getValue
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.window.ComposeViewport
import ly.neptune.odyssey.ui.resources.Res
import ly.neptune.odyssey.ui.resources.hanken_grotesk_400
import ly.neptune.odyssey.ui.resources.hanken_grotesk_700
import org.jetbrains.compose.resources.ExperimentalResourceApi
import org.jetbrains.compose.resources.preloadFont

@OptIn(ExperimentalComposeUiApi::class, ExperimentalResourceApi::class)
fun main() {
    ComposeViewport(viewportContainerId = "gallery") {
        // Warm the initial brand's faces (neptune = Hanken Grotesk) before the
        // first text frame, so the browser never flashes the default font —
        // the consumer pattern documented in README §Web.
        val text by preloadFont(Res.font.hanken_grotesk_400)
        val display by preloadFont(Res.font.hanken_grotesk_700)
        if (text != null && display != null) {
            GalleryApp()
        }
    }
}

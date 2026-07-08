// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The reference gallery shell: brand × mode × direction switchers around the
// section list. This is the surface the SHOTS-analog sweep renders and the
// in-context proof that the identity layer reads as Odyssey, not generic
// Material (rulebook §3).

package ly.neptune.odyssey.gallery

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.tokens.kBrands
import ly.neptune.odyssey.ui.components.NeptuneButton
import ly.neptune.odyssey.ui.components.NeptuneButtonStyle
import ly.neptune.odyssey.ui.identity.NeptuneEyebrow
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/** One gallery section: a titled block of composed components. */
data class GallerySection(val slug: String, val title: String, val content: @Composable () -> Unit)

/** A fixed theme frame around gallery content — also used by the shots sweep. */
@Composable
fun GalleryFrame(
    brand: String,
    dark: Boolean,
    rtl: Boolean,
    reducedMotion: Boolean? = null,
    content: @Composable () -> Unit,
) {
    CompositionLocalProvider(
        LocalLayoutDirection provides if (rtl) LayoutDirection.Rtl else LayoutDirection.Ltr,
    ) {
        NeptuneTheme(brand = brand, dark = dark, arabic = rtl, reducedMotion = reducedMotion) {
            Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.surface)) {
                content()
            }
        }
    }
}

/** The interactive gallery app (desktop/Android/browser/iOS entry points). */
@Composable
fun GalleryApp() {
    var brand by remember { mutableStateOf("neptune") }
    var dark by remember { mutableStateOf(false) }
    var rtl by remember { mutableStateOf(false) }

    GalleryFrame(brand = brand, dark = dark, rtl = rtl) {
        Column(
            Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            NeptuneEyebrow("Neptune Odyssey · Compose Multiplatform")
            Row(
                Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                for (b in kBrands) {
                    NeptuneButton(
                        label = b,
                        onClick = { brand = b },
                        variant = if (b == brand) NeptuneButtonStyle.Filled else NeptuneButtonStyle.Outlined,
                    )
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                NeptuneButton(
                    label = if (dark) "Dark ✓" else "Dark",
                    onClick = { dark = !dark },
                    variant = if (dark) NeptuneButtonStyle.Tonal else NeptuneButtonStyle.Outlined,
                )
                NeptuneButton(
                    label = if (rtl) "RTL ✓" else "RTL",
                    onClick = { rtl = !rtl },
                    variant = if (rtl) NeptuneButtonStyle.Tonal else NeptuneButtonStyle.Outlined,
                )
            }
            for (section in gallerySections()) {
                Spacer(Modifier.height(12.dp))
                Text(section.title, style = MaterialTheme.typography.headlineSmall)
                section.content()
            }
            Spacer(Modifier.height(48.dp))
        }
    }
}

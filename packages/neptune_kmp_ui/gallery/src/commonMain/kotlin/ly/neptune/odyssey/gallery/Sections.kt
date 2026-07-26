// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Gallery sections. Every core component appears here in at least one state —
// the SHOTS-analog sweep renders each section × 4 brands × light/dark ×
// LTR/RTL, so a component missing from a section is a component that never
// gets pixel-verified.

package ly.neptune.odyssey.gallery

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.components.NeptuneButton
import ly.neptune.odyssey.ui.components.NeptuneButtonStyle
import ly.neptune.odyssey.ui.components.NeptuneCard
import ly.neptune.odyssey.ui.components.NeptuneCardVariant
import ly.neptune.odyssey.ui.components.NeptuneCta
import ly.neptune.odyssey.ui.identity.NeptuneEyebrow
import ly.neptune.odyssey.ui.identity.NeptuneGlass
import ly.neptune.odyssey.ui.identity.NeptuneMotifLayer
import ly.neptune.odyssey.ui.identity.nptHeroGradient
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme

fun gallerySections(): List<GallerySection> = listOf(
    identitySection,
    buttonsSection,
    cardsSection,
    typeSection,
) + componentSections() + wave1Sections() + wave2Sections() + wave3Sections()

private val identitySection = GallerySection("identity", "Identity layer") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        val scheme = MaterialTheme.colorScheme
        val direction = LocalLayoutDirection.current
        // 135° hero gradient + motif + glow.
        Box(
            Modifier
                .fillMaxWidth()
                .height(140.dp)
                .nptShadow(NeptuneTheme.identity.glowPrimary(scheme), NeptuneTheme.shape.rXl)
                .clip(NeptuneTheme.shape.rXl)
                .drawBehind { drawRect(nptHeroGradient(scheme, size, direction)) },
        ) {
            NeptuneMotifLayer(Modifier.matchParentSize(), color = scheme.onPrimary)
            Column(
                Modifier.fillMaxWidth().height(140.dp).padding(horizontal = 24.dp),
                verticalArrangement = Arrangement.Center,
            ) {
                NeptuneEyebrow("Hero gradient + motif", color = scheme.onPrimary)
            }
        }
        NeptuneGlass(
            Modifier.fillMaxWidth(),
            contentPadding = PaddingValues(24.dp),
        ) {
            Column(Modifier.fillMaxWidth()) {
                NeptuneEyebrow("Glass pane")
                Text("Backdrop-blurred, brand-tinted, hairline-sealed.")
            }
        }
    }
}

private val buttonsSection = GallerySection("buttons", "Buttons & CTA") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            NeptuneButton("Filled", onClick = {})
            NeptuneButton("Tonal", onClick = {}, variant = NeptuneButtonStyle.Tonal)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            NeptuneButton("Outlined", onClick = {}, variant = NeptuneButtonStyle.Outlined)
            NeptuneButton("Text", onClick = {}, variant = NeptuneButtonStyle.Text)
            NeptuneButton("Busy", onClick = {}, busy = true)
        }
        NeptuneCta("Open an account", onClick = {}, arrow = true)
        NeptuneCta("Tonal action", onClick = {}, tonal = true, arrow = true)
    }
}

private val cardsSection = GallerySection("cards", "Cards") {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        NeptuneCard(Modifier.fillMaxWidth()) { Text("Standard card") }
        NeptuneCard(Modifier.fillMaxWidth(), variant = NeptuneCardVariant.Elevated) { Text("Elevated card") }
        NeptuneCard(Modifier.fillMaxWidth(), variant = NeptuneCardVariant.Tonal, motif = true) {
            Text("Tonal card with motif")
        }
        NeptuneCard(Modifier.fillMaxWidth(), variant = NeptuneCardVariant.Glass) { Text("Glass card") }
    }
}

private val typeSection = GallerySection("type", "Type & money") {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        NeptuneEyebrow("Eyebrow · display face")
        Text("Display large", style = MaterialTheme.typography.displaySmall)
        Text("Title medium — the workhorse", style = MaterialTheme.typography.titleMedium)
        Text(
            NeptuneTheme.formatDigits("24,850.75 LYD"),
            style = NeptuneTheme.moneyStyle(MaterialTheme.typography.headlineMedium),
        )
    }
}

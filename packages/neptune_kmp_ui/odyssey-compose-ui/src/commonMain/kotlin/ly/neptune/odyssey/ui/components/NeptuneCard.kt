// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The brand-shaped content surface. Web counterpart: `<npt-card variant=…>` ·
// Flutter: `NeptuneCard`. `standard` = surface-container-low · `elevated` =
// surface-container + elevation-2 · `tonal` = secondary-container · `glass` =
// the translucent brand pane. Corner = brand `lg`, padding 24 — exactly the
// web recipe.

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.identity.NeptuneGlass
import ly.neptune.odyssey.ui.identity.NeptuneMotifLayer
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/** The web `<npt-card>` variants. */
public enum class NeptuneCardVariant { Standard, Elevated, Tonal, Glass }

/**
 * [motif] overlays the brand motif (web hero-card treatment, strength ~0.65).
 */
@Composable
public fun NeptuneCard(
    modifier: Modifier = Modifier,
    variant: NeptuneCardVariant = NeptuneCardVariant.Standard,
    contentPadding: PaddingValues = PaddingValues(24.dp),
    motif: Boolean = false,
    onClick: (() -> Unit)? = null,
    content: @Composable BoxScope.() -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val identity = NeptuneTheme.identity
    val shape = NeptuneTheme.shape.rLg

    val clickableModifier = if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier

    val body: @Composable BoxScope.() -> Unit = {
        if (motif) {
            NeptuneMotifLayer(Modifier.matchParentSize(), color = LocalContentColor.current, strength = 0.65f)
        }
        Box(Modifier.padding(contentPadding), content = content)
    }

    if (variant == NeptuneCardVariant.Glass) {
        NeptuneGlass(modifier = modifier.then(clickableModifier), shape = shape) {
            body()
        }
        return
    }

    val (bg, fg) = when (variant) {
        NeptuneCardVariant.Standard -> scheme.surfaceContainerLow to scheme.onSurface
        NeptuneCardVariant.Elevated -> scheme.surfaceContainer to scheme.onSurface
        NeptuneCardVariant.Tonal -> scheme.secondaryContainer to scheme.onSecondaryContainer
        NeptuneCardVariant.Glass -> error("handled above")
    }
    val shadow = if (variant == NeptuneCardVariant.Elevated) {
        Modifier.nptShadow(identity.elevation2(scheme), shape)
    } else {
        Modifier
    }

    Box(
        modifier = modifier
            .then(shadow)
            .clip(shape)
            .background(bg)
            .then(clickableModifier),
    ) {
        CompositionLocalProvider(LocalContentColor provides fg) {
            body()
        }
    }
}

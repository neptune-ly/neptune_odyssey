// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Real Odyssey glass (web `npt-card[glass]` / `--npt-glass-tint`): a
// backdrop-blurred pane tinted with the brand accent, sealed with a hairline
// `outlineVariant` border. Use only on approved surfaces — nav, hero, auth,
// overlays — never on tables/forms (docs/06 §3).
//
// Compose has no cross-platform backdrop-blur primitive, so the blur is
// implemented with Haze (an internal dependency — no Haze type appears in
// this API). Backdrop blur needs to know what's behind the pane: mark the
// content underneath with [nptGlassBackground] inside a [NptGlassScope]
// (shell/template components do this for you and publish the scope via
// [LocalNptGlassScope]). Without a scope the pane falls back to a more
// opaque tint — never to transparent.

package ly.neptune.odyssey.ui.identity

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.ProvidableCompositionLocal
import androidx.compose.runtime.remember
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.dp
import dev.chrisbanes.haze.HazeState
import dev.chrisbanes.haze.HazeStyle
import dev.chrisbanes.haze.HazeTint
import dev.chrisbanes.haze.hazeEffect
import dev.chrisbanes.haze.hazeSource
import ly.neptune.odyssey.ui.theme.NeptuneTheme

/** Connects glass panes to the content rendered behind them. Create one per
 * screen/shell with [rememberNptGlassScope]. */
public class NptGlassScope internal constructor(internal val hazeState: HazeState)

/** Create a glass scope for one background↔pane pairing. */
@Composable
public fun rememberNptGlassScope(): NptGlassScope {
    val state = remember { HazeState() }
    return remember(state) { NptGlassScope(state) }
}

/** The ambient glass scope. Shell/template composables provide it so leaf
 * glass surfaces (dock, app bar) find their backdrop automatically. */
public val LocalNptGlassScope: ProvidableCompositionLocal<NptGlassScope?> =
    staticCompositionLocalOf { null }

/** Mark this element as glass backdrop content — everything it draws can be
 * blurred behind [NeptuneGlass] panes of the same [scope]. */
public fun Modifier.nptGlassBackground(scope: NptGlassScope): Modifier =
    hazeSource(state = scope.hazeState)

/**
 * The Odyssey glass pane. [dock] uses the dock/nav recipe
 * (`surfaceContainer @ 86%`) instead of the tinted card glass.
 *
 * Web counterpart: `npt-card[glass]` / the dock pane · Flutter: `NeptuneGlass`.
 */
@Composable
public fun NeptuneGlass(
    modifier: Modifier = Modifier,
    shape: Shape? = null,
    dock: Boolean = false,
    scope: NptGlassScope? = LocalNptGlassScope.current,
    contentPadding: PaddingValues = PaddingValues(0.dp),
    content: @Composable BoxScope.() -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val identity = NeptuneTheme.identity
    val paneShape = shape ?: NeptuneTheme.shape.rLg
    val tint = if (dock) identity.dockGlass(scheme) else identity.glassTint(scheme)

    val paneModifier = if (scope != null) {
        // σ ≈ blur/2 (CSS blur(px) ≈ 2σ) — the Flutter BackdropFilter parity.
        Modifier.hazeEffect(state = scope.hazeState) {
            blurRadius = identity.glassBlur / 2
            noiseFactor = 0f
            style = HazeStyle(
                backgroundColor = scheme.surface,
                tints = listOf(HazeTint(tint)),
                blurRadius = identity.glassBlur / 2,
                noiseFactor = 0f,
                // No blur available (e.g. software rendering): keep the pane
                // legible with a denser tint — never transparent.
                fallbackTint = HazeTint(tint.copy(alpha = (tint.alpha + 0.24f).coerceAtMost(1f))),
            )
        }
    } else {
        Modifier.background(tint.copy(alpha = (tint.alpha + 0.24f).coerceAtMost(1f)))
    }

    Box(
        modifier = modifier
            .clip(paneShape)
            .then(paneModifier)
            .border(width = 1.dp, color = scheme.outlineVariant, shape = paneShape)
            .padding(contentPadding),
        content = content,
    )
}

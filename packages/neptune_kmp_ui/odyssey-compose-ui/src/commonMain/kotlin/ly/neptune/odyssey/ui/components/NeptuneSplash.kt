// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// R6: the branded splash/launch screen — the ambient welcome backdrop (the
// same radial wash + drifting orbs as NeptuneWelcome, so a cold-start app
// visually continues into its own welcome screen rather than jump-cutting),
// a large brand mark, and a loader beneath. Flutter: neptune_splash.dart.
// Theme-only, RTL-safe, reduced-motion safe (the backdrop and loaders park
// on their static frames).

package ly.neptune.odyssey.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ly.neptune.odyssey.ui.identity.nptShadow
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptShadow
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/**
 * A full-bleed branded splash screen — the cold-start/launch moment before
 * the app has enough state to show real content: [NeptuneAmbientBackdrop]
 * behind a large 88dp `primary` mark (carrying [brandInitial] in the display
 * face over a primary key-light glow), the [brandName], and a loader
 * beneath.
 *
 * Flutter: `NeptuneSplashScreen` (neptune_splash.dart).
 *
 * Pass [logo] to show a real brand mark instead of the generated
 * initial-in-a-square (mirrors [NeptuneWelcome]'s `lockup` override — when
 * set, [brandInitial] is ignored). [loaderStyle] picks the waiting indicator
 * — Pulse (the default) is the quietest, a good fit for a moment the user
 * can't interact with yet. [caption] is an optional line under the loader
 * (e.g. "Loading your account…").
 */
@Composable
public fun NeptuneSplashScreen(
    brandInitial: String,
    brandName: String,
    modifier: Modifier = Modifier,
    logo: (@Composable () -> Unit)? = null,
    loaderStyle: NeptuneLoaderStyle = NeptuneLoaderStyle.Pulse,
    caption: String? = null,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val shape = NeptuneTheme.shape
    val type = NeptuneTheme.type
    val display = rememberNeptuneFontFamily(type.display)

    val nameStyle = typography.headlineSmall.copy(
        fontFamily = display ?: typography.headlineSmall.fontFamily,
        fontWeight = FontWeight.W800,
        letterSpacing = (type.displayTracking * 24).sp,
        color = scheme.onSurface,
    )

    Box(modifier.fillMaxSize()) {
        NeptuneAmbientBackdrop(Modifier.matchParentSize())
        Box(
            Modifier
                .fillMaxSize()
                .windowInsetsPadding(WindowInsets.safeDrawing),
            contentAlignment = Alignment.Center,
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                if (logo != null) {
                    logo()
                } else {
                    Box(
                        Modifier
                            .size(88.dp)
                            // The mark's key-light glow: primary at 28%,
                            // blur 32, y-offset 14 (the Flutter BoxShadow).
                            .nptShadow(
                                listOf(
                                    NptShadow(
                                        color = scheme.primary.copy(alpha = 0.28f),
                                        blurRadius = 32.dp,
                                        offsetY = 14.dp,
                                    ),
                                ),
                                shape.rXl,
                            )
                            .clip(shape.rXl)
                            .background(scheme.primary),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            brandInitial,
                            style = nameStyle.copy(
                                color = scheme.onPrimary,
                                fontSize = 44.sp,
                                lineHeight = 44.sp,
                            ),
                        )
                    }
                }
                Spacer(Modifier.height(20.dp))
                Text(brandName, style = nameStyle)
                Spacer(Modifier.height(40.dp))
                neptuneLoaderFor(loaderStyle, size = 48.dp)
                if (caption != null) {
                    Spacer(Modifier.height(16.dp))
                    Text(
                        caption,
                        style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
                    )
                }
            }
        }
    }
}

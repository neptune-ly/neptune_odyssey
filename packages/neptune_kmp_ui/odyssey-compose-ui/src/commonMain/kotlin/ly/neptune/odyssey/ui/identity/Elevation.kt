// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Painting the web elevation tokens (`--npt-elev-1/2/3/5`) and the primary
// key-light glow as exact box-shadows — Compose's Modifier.shadow() cannot
// express a tinted, offset, blurred shadow recipe, so these draw the shape's
// outline through a gaussian blur mask behind the content (the Flutter
// BoxShadow analog, identical radius→sigma conversion on every target).

package ly.neptune.odyssey.ui.identity

import androidx.compose.runtime.Stable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import ly.neptune.odyssey.ui.platform.applyBlurMask
import ly.neptune.odyssey.ui.theme.NptShadow

/**
 * Draw [shadows] (one of the `NptIdentity.elevation1/2/3/5` or `glowPrimary`
 * recipes) behind this element, following [shape]'s outline.
 *
 * ```
 * Modifier.nptShadow(NeptuneTheme.identity.elevation2(scheme), NeptuneTheme.shape.rLg)
 * ```
 */
@Stable
public fun Modifier.nptShadow(shadows: List<NptShadow>, shape: Shape): Modifier {
    if (shadows.isEmpty()) return this
    return drawBehind {
        drawIntoCanvas { canvas ->
            for (shadow in shadows) {
                val paint = Paint().apply {
                    color = shadow.color
                    applyBlurMask(shadow.blurRadius.toPx())
                }
                val spread = shadow.spread.toPx()
                // CSS spread: grow (or shrink, when negative) the shadow shape
                // around its centre before blurring.
                val shadowSize = Size(
                    (size.width + 2 * spread).coerceAtLeast(0f),
                    (size.height + 2 * spread).coerceAtLeast(0f),
                )
                val outline = shape.createOutline(shadowSize, layoutDirection, this)
                canvas.save()
                canvas.translate(-spread, shadow.offsetY.toPx() - spread)
                when (outline) {
                    is Outline.Rectangle -> canvas.drawRect(outline.rect, paint)
                    is Outline.Rounded -> canvas.drawPath(
                        Path().apply { addRoundRect(outline.roundRect) },
                        paint,
                    )
                    is Outline.Generic -> canvas.drawPath(outline.path, paint)
                }
                canvas.restore()
            }
        }
    }
}

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// The brand's signature motif as a fill layer (web
// `background-image: var(--npt-motif)`; Flutter NeptuneMotifLayer). Place
// inside a Box over a hero or card surface; it never handles input.
// Opacities are the web's per-motif ink levels × the brand motif strength ×
// the caller's strength (web uses 1.0 on emblems, ~0.65–0.8 on cards,
// ~0.055 on tinted page washes).

package ly.neptune.odyssey.ui.identity

import androidx.compose.foundation.Canvas
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.clipRect
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.unit.dp
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.NptMotifKind
import kotlin.math.hypot
import kotlin.math.max

/**
 * Paints the active brand's motif. [color] defaults to the ambient
 * `onSurface`; on gradient heroes pass `onPrimary`. [strength] multiplies the
 * brand's base motif strength. Size the layer with [modifier] (e.g.
 * `Modifier.matchParentSize()` inside a Box).
 *
 * Web counterpart: `--npt-motif` · Flutter: `NeptuneMotifLayer`.
 */
@Composable
public fun NeptuneMotifLayer(
    modifier: Modifier = Modifier,
    color: Color? = null,
    strength: Float = 1f,
) {
    val identity = NeptuneTheme.identity
    val ink = color ?: MaterialTheme.colorScheme.onSurface
    val effective = identity.motifStrength * strength
    Canvas(modifier) {
        drawNptMotif(identity.motif, ink, effective)
    }
}

/** Draw [kind] into this scope at [strength] (already brand-multiplied). */
public fun DrawScope.drawNptMotif(kind: NptMotifKind, color: Color, strength: Float) {
    if (strength <= 0f) return
    when (kind) {
        NptMotifKind.SonarRings -> sonar(color, strength)
        NptMotifKind.CoastalArcs -> arcs(color, strength)
        NptMotifKind.GridSpark -> grid(color, strength)
        NptMotifKind.Guilloche -> guilloche(color, strength)
    }
}

private fun ink(color: Color, alpha: Float, strength: Float): Color =
    color.copy(alpha = (alpha * strength).coerceIn(0f, 1f))

/** Neptune — repeating radial rings at (86%, 6%), 1.5px ink every 27px. */
private fun DrawScope.sonar(color: Color, strength: Float) {
    val center = Offset(size.width * 0.86f, size.height * 0.06f)
    val paint = ink(color, 0.11f, strength)
    val stroke = Stroke(width = 1.5.dp.toPx())
    val step = 27.dp.toPx()
    // Cover to the farthest corner.
    var maxR = 0f
    for (c in listOf(
        Offset.Zero,
        Offset(size.width, 0f),
        Offset(0f, size.height),
        Offset(size.width, size.height),
    )) {
        maxR = max(maxR, hypot(c.x - center.x, c.y - center.y))
    }
    var r = 0.75.dp.toPx()
    while (r <= maxR) {
        drawCircle(paint, radius = r, center = center, style = stroke)
        r += step
    }
}

/** Triton — 40×32 tiles, each an arc crest rising from the tile's bottom
 * centre (ring at r≈12.75, 1.5px ink). */
private fun DrawScope.arcs(color: Color, strength: Float) {
    val paint = ink(color, 0.13f, strength)
    val stroke = Stroke(width = 1.5.dp.toPx())
    val tw = 40.dp.toPx()
    val th = 32.dp.toPx()
    val radius = 12.75.dp.toPx()
    var y = 0f
    while (y < size.height) {
        var x = 0f
        while (x < size.width) {
            clipRect(x, y, x + tw, y + th) {
                drawCircle(paint, radius = radius, center = Offset(x + tw / 2, y + th), style = stroke)
            }
            x += tw
        }
        y += th
    }
}

/** Nereid — a fine 23×23 luminous grid, 1px ink. */
private fun DrawScope.grid(color: Color, strength: Float) {
    val paint = ink(color, 0.08f, strength)
    val width = 1.dp.toPx()
    val cell = 23.dp.toPx()
    val half = 0.5.dp.toPx()
    var x = half
    while (x < size.width) {
        drawLine(paint, Offset(x, 0f), Offset(x, size.height), strokeWidth = width)
        x += cell
    }
    var y = half
    while (y < size.height) {
        drawLine(paint, Offset(0f, y), Offset(size.width, y), strokeWidth = width)
        y += cell
    }
}

/** Proteus — ±45° guilloché crosshatch, 1px ink every 12px. */
private fun DrawScope.guilloche(color: Color, strength: Float) {
    val paint = ink(color, 0.07f, strength)
    val width = 1.dp.toPx()
    val step = 12.dp.toPx()
    val diag = size.width + size.height
    for (dir in floatArrayOf(45f, -45f)) {
        rotate(degrees = dir, pivot = Offset(size.width / 2, size.height / 2)) {
            translate(size.width / 2, size.height / 2) {
                var x = -diag
                while (x <= diag) {
                    drawLine(paint, Offset(x, -diag), Offset(x, diag), strokeWidth = width)
                    x += step
                }
            }
        }
    }
}

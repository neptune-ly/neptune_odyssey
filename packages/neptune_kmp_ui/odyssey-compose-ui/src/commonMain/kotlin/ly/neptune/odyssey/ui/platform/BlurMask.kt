// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Blur-mask bridge for painting the exact web elevation/glow recipes
// (CSS box-shadow / Flutter BoxShadow equivalents). Android uses
// android.graphics.BlurMaskFilter; every Skia target (desktop/iOS/web) uses
// skiko's MaskFilter — both convert radius→sigma with Skia's own formula, so
// the rendered spread matches Flutter byte-for-byte.

package ly.neptune.odyssey.ui.platform

import androidx.compose.ui.graphics.Paint

/** Apply a normal-style gaussian blur mask of [radiusPx] to [paint]. */
internal expect fun Paint.applyBlurMask(radiusPx: Float)

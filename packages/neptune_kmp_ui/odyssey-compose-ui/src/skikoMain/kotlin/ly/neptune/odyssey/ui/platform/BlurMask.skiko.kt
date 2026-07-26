// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

package ly.neptune.odyssey.ui.platform

import androidx.compose.ui.graphics.Paint
import org.jetbrains.skia.FilterBlurMode
import org.jetbrains.skia.MaskFilter

internal actual fun Paint.applyBlurMask(radiusPx: Float) {
    if (radiusPx <= 0f) return
    // Skia's SkBlurMask::ConvertRadiusToSigma — the same conversion Android's
    // BlurMaskFilter applies internally, keeping all targets identical.
    val sigma = radiusPx * 0.57735f + 0.5f
    asFrameworkPaint().maskFilter = MaskFilter.makeBlur(FilterBlurMode.NORMAL, sigma)
}

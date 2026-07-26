// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

package ly.neptune.odyssey.ui.platform

import android.graphics.BlurMaskFilter
import androidx.compose.ui.graphics.Paint

internal actual fun Paint.applyBlurMask(radiusPx: Float) {
    if (radiusPx <= 0f) return
    asFrameworkPaint().maskFilter = BlurMaskFilter(radiusPx, BlurMaskFilter.Blur.NORMAL)
}

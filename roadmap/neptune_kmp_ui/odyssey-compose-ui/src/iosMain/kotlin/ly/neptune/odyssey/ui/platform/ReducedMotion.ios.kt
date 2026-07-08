// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

package ly.neptune.odyssey.ui.platform

import androidx.compose.runtime.Composable
import platform.UIKit.UIAccessibilityIsReduceMotionEnabled

@Composable
public actual fun rememberSystemReducedMotion(): Boolean =
    UIAccessibilityIsReduceMotionEnabled()

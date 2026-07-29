// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

package ly.neptune.odyssey.ui.platform

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember

private fun prefersReducedMotion(): Boolean =
    js("window.matchMedia('(prefers-reduced-motion: reduce)').matches") as Boolean

@Composable
public actual fun rememberSystemReducedMotion(): Boolean =
    remember { prefersReducedMotion() }

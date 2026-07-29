// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Platform reduced-motion detection (the MediaQuery.disableAnimations /
// prefers-reduced-motion analog). Every animated Odyssey composable freezes
// to its documented static frame when this is true.

package ly.neptune.odyssey.ui.platform

import androidx.compose.runtime.Composable

/** True when the platform accessibility settings ask for reduced motion. */
@Composable
public expect fun rememberSystemReducedMotion(): Boolean

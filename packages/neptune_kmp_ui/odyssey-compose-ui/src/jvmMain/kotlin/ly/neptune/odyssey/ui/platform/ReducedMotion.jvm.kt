// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

package ly.neptune.odyssey.ui.platform

import androidx.compose.runtime.Composable

// Desktop OSes expose no portable reduced-motion signal; consumers can force
// it via NeptuneTheme(reducedMotion = true) / LocalNptReducedMotion.
@Composable
public actual fun rememberSystemReducedMotion(): Boolean = false

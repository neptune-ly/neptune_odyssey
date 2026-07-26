// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

package ly.neptune.odyssey.gallery

import androidx.compose.ui.window.ComposeUIViewController
import platform.UIKit.UIViewController

/** Embed the gallery in an iOS host app (SwiftUI: `UIViewControllerRepresentable`). */
public fun MainViewController(): UIViewController = ComposeUIViewController { GalleryApp() }

// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

package ly.neptune.odyssey.gallery

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge

public class GalleryActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            GalleryApp()
        }
    }
}

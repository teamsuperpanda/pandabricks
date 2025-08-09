package com.yourcompany.pandabricks

import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge without using deprecated setStatusBarColor/setNavigationBarColor APIs.
        // This lets content draw behind system bars and controls icon appearance via insets controller.
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // Configure system bar icon appearance (light/dark) based on a simple heuristic.
        // You can replace this with dynamic theme detection from Flutter via a platform channel if needed.
        val insetsController = WindowInsetsControllerCompat(window, window.decorView)
        // Example: assume dark content (light icons off). Set to true for light status bar icons if your background is light.
        val isLightBackground = false
        insetsController.isAppearanceLightStatusBars = isLightBackground
        insetsController.isAppearanceLightNavigationBars = isLightBackground

        super.onCreate(savedInstanceState)
    }
}

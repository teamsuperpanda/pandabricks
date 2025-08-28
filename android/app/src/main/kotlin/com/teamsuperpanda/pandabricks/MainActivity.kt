package com.teamsuperpanda.pandabricks

import android.os.Bundle
import android.graphics.Color
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)

		// Enable edge-to-edge display and let the app handle insets.
		// This avoids using deprecated Window APIs and is compatible with Android 15.
		WindowCompat.setDecorFitsSystemWindows(window, false)

		// Make status and navigation bars transparent so content can extend into
		// system gesture areas. Apps should handle safe insets in their UI.
		window.statusBarColor = Color.TRANSPARENT
		window.navigationBarColor = Color.TRANSPARENT

		// Use WindowInsetsControllerCompat to control appearance (light/dark icons)
		val insetsController = WindowInsetsControllerCompat(window, window.decorView)
		// Do not modify system bars appearance here; let Flutter or UI decide.
		// insetsController.isAppearanceLightStatusBars = true // optional
	}
}

package com.teamsuperpanda.pandabricks

import android.os.Bundle
import androidx.core.view.WindowCompat
import android.view.Window
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		// Try to call WindowCompat.enableEdgeToEdge(window) if present (newer core versions); fallback gracefully.
		try {
			val m = WindowCompat::class.java.getMethod("enableEdgeToEdge", Window::class.java)
			m.invoke(null, window)
		} catch (_: NoSuchMethodException) {
			// Fallback: just disable decor fitting. Avoid touching status/navigation bar colors directly.
			@Suppress("DEPRECATION")
			WindowCompat.setDecorFitsSystemWindows(window, false)
		}
		super.onCreate(savedInstanceState)
	}
}

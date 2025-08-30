package com.teamsuperpanda.pandabricks

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		// Single modern API; no legacy fallback or deprecated calls.
		WindowCompat.enableEdgeToEdge(window)
		super.onCreate(savedInstanceState)
	}
}

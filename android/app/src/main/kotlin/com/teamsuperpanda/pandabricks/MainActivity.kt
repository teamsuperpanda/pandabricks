package com.teamsuperpanda.pandabricks

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		// Enable edge-to-edge display for Android 15+ compatibility
		(this as androidx.activity.ComponentActivity).enableEdgeToEdge()
		
		super.onCreate(savedInstanceState)
	}
}

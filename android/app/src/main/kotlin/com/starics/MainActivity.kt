package com.starics

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import androidx.core.view.WindowCompat

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Allow drawing edge-to-edge; Flutter will handle padding with MediaQuery.
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
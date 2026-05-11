package com.milliganco.cloudlaugh

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.milliganco.cloudlaugh/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                if (call.method == "pinWidget") {
                    result.success(tryPinWidget())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun tryPinWidget(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val wm = AppWidgetManager.getInstance(this)
        if (!wm.isRequestPinAppWidgetSupported) return false
        val provider = ComponentName(this, LaughWidgetProvider::class.java)
        wm.requestPinAppWidget(provider, null, null)
        return true
    }
}

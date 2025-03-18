package com.example.sim_card_code

import android.content.Context
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** SimCardCodePlugin */
class SimCardCodePlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sim_card_code")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getSimCountryCode" -> getSimCountryCode(result)
      else -> result.notImplemented()
    }
  }

  private fun getSimCountryCode(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      manager?.let {
        val countryId = it.simCountryIso
        if (countryId != null && countryId.isNotEmpty()) {
          result.success(countryId.uppercase())
          return
        }
      }
      result.success(null)
    } catch (e: Exception) {
      result.error("SIM_COUNTRY_CODE_ERROR", e.message, null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
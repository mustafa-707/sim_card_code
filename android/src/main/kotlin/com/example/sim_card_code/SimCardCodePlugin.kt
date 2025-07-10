package com.example.sim_card_code

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
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
      "getSimOperatorName" -> getSimOperatorName(result)
      "getSimOperatorCode" -> getSimOperatorCode(result)
      "getSimSerialNumber" -> getSimSerialNumber(result)
      "getSimState" -> getSimState(result)
      "getPhoneNumber" -> getPhoneNumber(result)
      "getNetworkOperatorName" -> getNetworkOperatorName(result)
      "getNetworkCountryCode" -> getNetworkCountryCode(result)
      "getNetworkType" -> getNetworkType(result)
      "isRoaming" -> isRoaming(result)
      "hasSimCard" -> hasSimCard(result)
      "getSimCount" -> getSimCount(result)
      "getAllSimInfo" -> getAllSimInfo(result)
      "isDualSim" -> isDualSim(result)
      "getDeviceId" -> getDeviceId(result)
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

  private fun getSimOperatorName(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val operatorName = manager?.simOperatorName
      result.success(if (operatorName.isNullOrEmpty()) null else operatorName)
    } catch (e: Exception) {
      result.error("SIM_OPERATOR_NAME_ERROR", e.message, null)
    }
  }

  private fun getSimOperatorCode(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val operatorCode = manager?.simOperator
      result.success(if (operatorCode.isNullOrEmpty()) null else operatorCode)
    } catch (e: Exception) {
      result.error("SIM_OPERATOR_CODE_ERROR", e.message, null)
    }
  }

  private fun getSimSerialNumber(result: Result) {
    try {
      if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
        result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
        return
      }
      
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val serialNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        manager?.simSerialNumber
      } else {
        @Suppress("DEPRECATION")
        manager?.simSerialNumber
      }
      result.success(if (serialNumber.isNullOrEmpty()) null else serialNumber)
    } catch (e: Exception) {
      result.error("SIM_SERIAL_NUMBER_ERROR", e.message, null)
    }
  }

  private fun getSimState(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val state = when (manager?.simState) {
        TelephonyManager.SIM_STATE_ABSENT -> "ABSENT"
        TelephonyManager.SIM_STATE_PIN_REQUIRED -> "PIN_REQUIRED"
        TelephonyManager.SIM_STATE_PUK_REQUIRED -> "PUK_REQUIRED"
        TelephonyManager.SIM_STATE_NETWORK_LOCKED -> "NETWORK_LOCKED"
        TelephonyManager.SIM_STATE_READY -> "READY"
        TelephonyManager.SIM_STATE_NOT_READY -> "NOT_READY"
        TelephonyManager.SIM_STATE_PERM_DISABLED -> "PERM_DISABLED"
        TelephonyManager.SIM_STATE_CARD_IO_ERROR -> "CARD_IO_ERROR"
        TelephonyManager.SIM_STATE_CARD_RESTRICTED -> "CARD_RESTRICTED"
        else -> "UNKNOWN"
      }
      result.success(state)
    } catch (e: Exception) {
      result.error("SIM_STATE_ERROR", e.message, null)
    }
  }

  private fun getPhoneNumber(result: Result) {
    try {
      if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
        result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
        return
      }
      
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val phoneNumber = manager?.line1Number
      result.success(if (phoneNumber.isNullOrEmpty()) null else phoneNumber)
    } catch (e: Exception) {
      result.error("PHONE_NUMBER_ERROR", e.message, null)
    }
  }

  private fun getNetworkOperatorName(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val networkOperator = manager?.networkOperatorName
      result.success(if (networkOperator.isNullOrEmpty()) null else networkOperator)
    } catch (e: Exception) {
      result.error("NETWORK_OPERATOR_ERROR", e.message, null)
    }
  }

  private fun getNetworkCountryCode(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val countryCode = manager?.networkCountryIso
      result.success(if (countryCode.isNullOrEmpty()) null else countryCode.uppercase())
    } catch (e: Exception) {
      result.error("NETWORK_COUNTRY_CODE_ERROR", e.message, null)
    }
  }

  private fun getNetworkType(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val networkType = when (manager?.networkType) {
        TelephonyManager.NETWORK_TYPE_GPRS -> "GPRS"
        TelephonyManager.NETWORK_TYPE_EDGE -> "EDGE"
        TelephonyManager.NETWORK_TYPE_UMTS -> "UMTS"
        TelephonyManager.NETWORK_TYPE_HSDPA -> "HSDPA"
        TelephonyManager.NETWORK_TYPE_HSUPA -> "HSUPA"
        TelephonyManager.NETWORK_TYPE_HSPA -> "HSPA"
        TelephonyManager.NETWORK_TYPE_CDMA -> "CDMA"
        TelephonyManager.NETWORK_TYPE_EVDO_0 -> "EVDO_0"
        TelephonyManager.NETWORK_TYPE_EVDO_A -> "EVDO_A"
        TelephonyManager.NETWORK_TYPE_1xRTT -> "1xRTT"
        TelephonyManager.NETWORK_TYPE_LTE -> "LTE"
        TelephonyManager.NETWORK_TYPE_EHRPD -> "EHRPD"
        TelephonyManager.NETWORK_TYPE_HSPAP -> "HSPAP"
        else -> "UNKNOWN"
      }
      result.success(networkType)
    } catch (e: Exception) {
      result.error("NETWORK_TYPE_ERROR", e.message, null)
    }
  }

  private fun isRoaming(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      result.success(manager?.isNetworkRoaming ?: false)
    } catch (e: Exception) {
      result.error("ROAMING_ERROR", e.message, null)
    }
  }

  private fun hasSimCard(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val hasSimCard = manager?.simState != TelephonyManager.SIM_STATE_ABSENT
      result.success(hasSimCard)
    } catch (e: Exception) {
      result.error("HAS_SIM_ERROR", e.message, null)
    }
  }

  private fun getSimCount(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val simCount = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        manager?.phoneCount ?: 1
      } else {
        1
      }
      result.success(simCount)
    } catch (e: Exception) {
      result.error("SIM_COUNT_ERROR", e.message, null)
    }
  }

  private fun isDualSim(result: Result) {
    try {
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val isDualSim = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        (manager?.phoneCount ?: 1) > 1
      } else {
        false
      }
      result.success(isDualSim)
    } catch (e: Exception) {
      result.error("DUAL_SIM_ERROR", e.message, null)
    }
  }
  private fun getAllSimInfo(result: Result) {
    try {
      if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
        result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
        return
      }

      val simInfoList = mutableListOf<Map<String, Any?>>()

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
        val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager?
        val subscriptionInfoList = subscriptionManager?.activeSubscriptionInfoList
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?

        subscriptionInfoList?.forEach { subscriptionInfo ->
          
          val subTelephonyManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            telephonyManager?.createForSubscriptionId(subscriptionInfo.subscriptionId)
          } else {
            telephonyManager
          }

          
          val operatorCode = subTelephonyManager?.simOperator
          
          
          val serialNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
              subTelephonyManager?.simSerialNumber
            } catch (e: Exception) {
              null
            }
          } else {
            null
          }

          
          val simState = when (subTelephonyManager?.simState) {
            TelephonyManager.SIM_STATE_ABSENT -> "ABSENT"
            TelephonyManager.SIM_STATE_PIN_REQUIRED -> "PIN_REQUIRED"
            TelephonyManager.SIM_STATE_PUK_REQUIRED -> "PUK_REQUIRED"
            TelephonyManager.SIM_STATE_NETWORK_LOCKED -> "NETWORK_LOCKED"
            TelephonyManager.SIM_STATE_READY -> "READY"
            TelephonyManager.SIM_STATE_NOT_READY -> "NOT_READY"
            TelephonyManager.SIM_STATE_PERM_DISABLED -> "PERM_DISABLED"
            TelephonyManager.SIM_STATE_CARD_IO_ERROR -> "CARD_IO_ERROR"
            TelephonyManager.SIM_STATE_CARD_RESTRICTED -> "CARD_RESTRICTED"
            else -> "UNKNOWN"
          }


          val phoneNumber = try {
            when {

              Build.VERSION.SDK_INT >= Build.VERSION_CODES.N -> {
                subTelephonyManager?.line1Number?.takeIf { it.isNotEmpty() }
              }

              Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1 -> {

                val phoneNumberFromSub = subscriptionInfo.number?.takeIf { it.isNotEmpty() }
                phoneNumberFromSub ?: subTelephonyManager?.line1Number?.takeIf { it.isNotEmpty() }
              }
              else -> {
                subTelephonyManager?.line1Number?.takeIf { it.isNotEmpty() }
              }
            }
          } catch (e: Exception) {

            try {

              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                subscriptionManager?.getPhoneNumber(subscriptionInfo.subscriptionId)?.takeIf { it.isNotEmpty() }
              } else {
                null
              }
            } catch (e2: Exception) {
              null
            }
          }

          val simInfo = mapOf(
            "slotIndex" to subscriptionInfo.simSlotIndex,
            "subscriptionId" to subscriptionInfo.subscriptionId,
            "displayName" to subscriptionInfo.displayName?.toString(),
            "carrierName" to subscriptionInfo.carrierName?.toString(),
            "countryIso" to subscriptionInfo.countryIso?.uppercase(),
            "isNetworkRoaming" to subscriptionInfo.dataRoaming,
            "phoneNumber" to phoneNumber,
            "operatorCode" to operatorCode,
            "serialNumber" to serialNumber,
            "simState" to simState
          )
          simInfoList.add(simInfo)
        }
      } else {

        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?

        val simState = when (telephonyManager?.simState) {
          TelephonyManager.SIM_STATE_ABSENT -> "ABSENT"
          TelephonyManager.SIM_STATE_PIN_REQUIRED -> "PIN_REQUIRED"
          TelephonyManager.SIM_STATE_PUK_REQUIRED -> "PUK_REQUIRED"
          TelephonyManager.SIM_STATE_NETWORK_LOCKED -> "NETWORK_LOCKED"
          TelephonyManager.SIM_STATE_READY -> "READY"
          TelephonyManager.SIM_STATE_NOT_READY -> "NOT_READY"
          TelephonyManager.SIM_STATE_PERM_DISABLED -> "PERM_DISABLED"
          TelephonyManager.SIM_STATE_CARD_IO_ERROR -> "CARD_IO_ERROR"
          TelephonyManager.SIM_STATE_CARD_RESTRICTED -> "CARD_RESTRICTED"
          else -> "UNKNOWN"
        }

        val simInfo = mapOf(
          "slotIndex" to 0,
          "subscriptionId" to 0,
          "displayName" to telephonyManager?.simOperatorName,
          "carrierName" to telephonyManager?.simOperatorName,
          "countryIso" to telephonyManager?.simCountryIso?.uppercase(),
          "isNetworkRoaming" to (telephonyManager?.isNetworkRoaming ?: false),
          "phoneNumber" to telephonyManager?.line1Number,
          "operatorCode" to telephonyManager?.simOperator,
          "serialNumber" to null,
          "simState" to simState
        )
        simInfoList.add(simInfo)
      }

      result.success(simInfoList)
    } catch (e: Exception) {
      result.error("ALL_SIM_INFO_ERROR", e.message, null)
    }
  }

  private fun getDeviceId(result: Result) {
    try {
      if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
        result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
        return
      }
      
      val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?
      val deviceId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        manager?.imei ?: manager?.meid
      } else {
        @Suppress("DEPRECATION")
        manager?.deviceId
      }
      result.success(if (deviceId.isNullOrEmpty()) null else deviceId)
    } catch (e: Exception) {
      result.error("DEVICE_ID_ERROR", e.message, null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
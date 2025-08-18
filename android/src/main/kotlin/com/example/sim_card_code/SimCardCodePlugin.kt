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
      "isEsim" -> isEsim(result)
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
      val phoneNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        // API 33+: Use SubscriptionManager.getPhoneNumber()
        try {
          val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager?
          val subscriptionId = SubscriptionManager.getDefaultSubscriptionId()
          subscriptionManager?.getPhoneNumber(subscriptionId)?.takeIf { it.isNotEmpty() }
        } catch (e: Exception) {
          null
        }
      } else {
        // Below API 33: Use deprecated method
        try {
          manager?.line1Number?.takeIf { it.isNotEmpty() }
        } catch (e: Exception) {
          null
        }
      }

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

  /*
  * To make it equivalent to telephony manager which points to the default SIM used for voice calls
  * we use subscription ID of default voice call SIM
  * because the telephony manager also points the default SIM for voice calls to check is Network Roaming
  */
  private fun isEsim(result : Result){

    // First check if the permission is given or not
    if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
      result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
      return
    }

    // check the build version we are using 28 because e-sim was added in Android 9 (Api 28)
    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P){
      try {
        val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager?
        val defaultSubId = SubscriptionManager.getDefaultVoiceSubscriptionId()

        // if no sim simply return false
        if(defaultSubId == SubscriptionManager.INVALID_SUBSCRIPTION_ID){
         return result.success(true)
        }

        val subscriptionInfo =  subscriptionManager?.getActiveSubscriptionInfo(defaultSubId)

        // call result callback with flag value for e-sim
       result.success( subscriptionInfo?.isEmbedded ?: false)

      }catch (e:SecurityException){
        result.error("Permission Denied",e.message?:"Unknow Error",null)
      }
      catch (e:Exception){
        result.error("ESIM_ERROR",e.message,null)
      }
    }else{
      result.success(false)
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
          // Get whether the sim is e-sim or not
          val isEmbedded = if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.P){
            subscriptionInfo.isEmbedded
          }else{
            false
          }

          // Get individual TelephonyManager for each subscription
          val subTelephonyManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            telephonyManager?.createForSubscriptionId(subscriptionInfo.subscriptionId)
          } else {
            telephonyManager
          }

          // Get operator code using TelephonyManager
          val operatorCode = subTelephonyManager?.simOperator
          
          // Get SIM serial number
          val serialNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
              subTelephonyManager?.simSerialNumber
            } catch (e: Exception) {
              null
            }
          } else {
            null
          }

          // Get SIM state
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

          // Get phone number - this might be empty for many carriers
          val phoneNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // API 33+: Use SubscriptionManager.getPhoneNumber()
            try {
              subscriptionManager?.getPhoneNumber(subscriptionInfo.subscriptionId)?.takeIf { it.isNotEmpty() }
            } catch (e: Exception) {
              null
            }
          } else {
            // Below API 33: Use deprecated method
            try {
              subTelephonyManager?.line1Number?.takeIf { it.isNotEmpty() }
            } catch (e: Exception) {
              null
            }
          }

          val simInfo = mapOf(
            "isEsim" to isEmbedded,
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
        // Fallback for older Android versions
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
          "isEsim" to false, // older version dont have e-sim feature
          "slotIndex" to 0,
          "subscriptionId" to 0,
          "displayName" to telephonyManager?.simOperatorName,
          "carrierName" to telephonyManager?.simOperatorName,
          "countryIso" to telephonyManager?.simCountryIso?.uppercase(),
          "isNetworkRoaming" to (telephonyManager?.isNetworkRoaming ?: false),
          "phoneNumber" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            try {
              val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager?
              val subscriptionId = SubscriptionManager.getDefaultSubscriptionId()
              subscriptionManager?.getPhoneNumber(subscriptionId)?.takeIf { it.isNotEmpty() }
            } catch (e: Exception) {
              null
            }
          } else {
            try {
              telephonyManager?.line1Number?.takeIf { it.isNotEmpty() }
            } catch (e: Exception) {
              null
            }
          },
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
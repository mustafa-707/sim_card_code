import Flutter
import UIKit
import CoreTelephony

public class SimCardCodePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sim_card_code", binaryMessenger: registrar.messenger())
    let instance = SimCardCodePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSimCountryCode":
      getSimCountryCode(result: result)
    case "getSimOperatorName":
      getSimOperatorName(result: result)
    case "getSimOperatorCode":
      getSimOperatorCode(result: result)
    case "getSimSerialNumber":
      getSimSerialNumber(result: result)
    case "getSimState":
      getSimState(result: result)
    case "getPhoneNumber":
      getPhoneNumber(result: result)
    case "getNetworkOperatorName":
      getNetworkOperatorName(result: result)
    case "getNetworkCountryCode":
      getNetworkCountryCode(result: result)
    case "getNetworkType":
      getNetworkType(result: result)
    case "isRoaming":
      isRoaming(result: result)
    case "hasSimCard":
      hasSimCard(result: result)
    case "getSimCount":
      getSimCount(result: result)
    case "getAllSimInfo":
      getAllSimInfo(result: result)
    case "isDualSim":
      isDualSim(result: result)
    case "getDeviceId":
      getDeviceId(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Helper method to get fallback country code from locale
  private func getFallbackCountryCode() -> String? {
    // Try iOS 16+ method first
    if #available(iOS 16.0, *) {
      return Locale.current.region?.identifier
    }
    
    // Fallback for older iOS versions
    if let regionCode = Locale.current.regionCode {
      return regionCode
    }
    
    // Last resort: extract from locale identifier
    let localeIdentifier = Locale.current.identifier
    let components = localeIdentifier.components(separatedBy: "_")
    if components.count > 1 {
      return components[1]
    }
    
    return nil
  }

  private func getSimCountryCode(result: @escaping FlutterResult) {
    let networkInfo = CTTelephonyNetworkInfo()
    var countryCode: String? = nil

    // A set of known invalid placeholder values
    let invalidCountryCodes = ["--", ""]

    // First try to get country code from SIM card data
    if #available(iOS 12.0, *) {
      // Use compactMap to find the first valid country code
      countryCode = networkInfo.serviceSubscriberCellularProviders?.values.compactMap { carrier in
        guard let isoCountryCode = carrier.isoCountryCode, !invalidCountryCodes.contains(isoCountryCode) else {
          return nil
        }
        return isoCountryCode.uppercased()
      }.first
    } else {
      // Fallback for older iOS versions with the same check
      if let carrier = networkInfo.subscriberCellularProvider,
         let isoCountryCode = carrier.isoCountryCode,
         !invalidCountryCodes.contains(isoCountryCode) {
        countryCode = isoCountryCode.uppercased()
      }
    }

    // If no valid country code from SIM, fall back to Locale for all iOS versions
    if countryCode == nil {
      countryCode = getFallbackCountryCode()
    }

    // Return the found country code or nil if none was found
    result(countryCode)
  }

  private func getSimOperatorName(result: @escaping FlutterResult) {
    do {
      let networkInfo = CTTelephonyNetworkInfo()
      var operatorName: String? = nil
      
      if #available(iOS 12.0, *) {
        if let carriers = networkInfo.serviceSubscriberCellularProviders {
          for (_, carrierValue) in carriers {
            if let carrierName = carrierValue.carrierName, !carrierName.isEmpty {
              operatorName = carrierName
              break
            }
          }
        }
      } else {
        if let carrier = networkInfo.subscriberCellularProvider,
           let carrierName = carrier.carrierName,
           !carrierName.isEmpty {
          operatorName = carrierName
        }
      }
      
      result(operatorName)
    } catch {
      result(FlutterError(code: "SIM_OPERATOR_NAME_ERROR",
                         message: "Error getting operator name: \(error.localizedDescription)",
                         details: nil))
    }
  }
  
  private func getSimOperatorCode(result: @escaping FlutterResult) {
    do {
      let networkInfo = CTTelephonyNetworkInfo()
      var operatorCode: String? = nil
      
      if #available(iOS 12.0, *) {
        if let carriers = networkInfo.serviceSubscriberCellularProviders {
          for (_, carrierValue) in carriers {
            if let mobileCountryCode = carrierValue.mobileCountryCode,
               let mobileNetworkCode = carrierValue.mobileNetworkCode,
               !mobileCountryCode.isEmpty && !mobileNetworkCode.isEmpty {
              operatorCode = mobileCountryCode + mobileNetworkCode
              break
            }
          }
        }
      } else {
        if let carrier = networkInfo.subscriberCellularProvider,
           let mobileCountryCode = carrier.mobileCountryCode,
           let mobileNetworkCode = carrier.mobileNetworkCode,
           !mobileCountryCode.isEmpty && !mobileNetworkCode.isEmpty {
          operatorCode = mobileCountryCode + mobileNetworkCode
        }
      }
      
      result(operatorCode)
    } catch {
      result(FlutterError(code: "SIM_OPERATOR_CODE_ERROR",
                         message: "Error getting operator code: \(error.localizedDescription)",
                         details: nil))
    }
  }
  
  private func getSimSerialNumber(result: @escaping FlutterResult) {
    // SIM serial number is not accessible on iOS for privacy reasons
    result(FlutterError(code: "NOT_AVAILABLE_ON_IOS",
                       message: "SIM serial number is not available on iOS for privacy reasons",
                       details: nil))
  }
  
  private func getSimState(result: @escaping FlutterResult) {
    do {
      let networkInfo = CTTelephonyNetworkInfo()
      var simState = "UNKNOWN"
      
      if #available(iOS 12.0, *) {
        if let carriers = networkInfo.serviceSubscriberCellularProviders {
          for (_, carrierValue) in carriers {
            if carrierValue.carrierName != nil {
              simState = "READY"
              break
            }
          }
        } else {
          simState = "ABSENT"
        }
      } else {
        if let carrier = networkInfo.subscriberCellularProvider {
          if carrier.carrierName != nil {
            simState = "READY"
          }
        } else {
          simState = "ABSENT"
        }
      }
      
      result(simState)
    } catch {
      result(FlutterError(code: "SIM_STATE_ERROR",
                         message: "Error getting SIM state: \(error.localizedDescription)",
                         details: nil))
    }
  }
  
  private func getPhoneNumber(result: @escaping FlutterResult) {
    // Phone number is not accessible on iOS for privacy reasons
    result(FlutterError(code: "NOT_AVAILABLE_ON_IOS",
                       message: "Phone number is not available on iOS for privacy reasons",
                       details: nil))
  }
  
  private func getNetworkOperatorName(result: @escaping FlutterResult) {
    // Same as getSimOperatorName on iOS
    getSimOperatorName(result: result)
  }
  
  private func getNetworkCountryCode(result: @escaping FlutterResult) {
    // Same as getSimCountryCode on iOS - will use locale fallback
    getSimCountryCode(result: result)
  }
  
  private func getNetworkType(result: @escaping FlutterResult) {
    do {
      let networkInfo = CTTelephonyNetworkInfo()
      var networkType = "UNKNOWN"
      
      if #available(iOS 12.0, *) {
        if let radioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology {
          for (_, technology) in radioAccessTechnology {
            networkType = mapRadioAccessTechnology(technology)
            break
          }
        }
      } else {
        if let technology = networkInfo.currentRadioAccessTechnology {
          networkType = mapRadioAccessTechnology(technology)
        }
      }
      
      result(networkType)
    } catch {
      result(FlutterError(code: "NETWORK_TYPE_ERROR",
                         message: "Error getting network type: \(error.localizedDescription)",
                         details: nil))
    }
  }
  
  private func mapRadioAccessTechnology(_ technology: String) -> String {
    switch technology {
    case CTRadioAccessTechnologyGPRS:
      return "GPRS"
    case CTRadioAccessTechnologyEdge:
      return "EDGE"
    case CTRadioAccessTechnologyWCDMA:
      return "UMTS"
    case CTRadioAccessTechnologyHSDPA:
      return "HSDPA"
    case CTRadioAccessTechnologyHSUPA:
      return "HSUPA"
    case CTRadioAccessTechnologyCDMA1x:
      return "CDMA"
    case CTRadioAccessTechnologyCDMAEVDORev0:
      return "EVDO_0"
    case CTRadioAccessTechnologyCDMAEVDORevA:
      return "EVDO_A"
    case CTRadioAccessTechnologyCDMAEVDORevB:
      return "EVDO_B"
    case CTRadioAccessTechnologyeHRPD:
      return "EHRPD"
    case CTRadioAccessTechnologyLTE:
      return "LTE"
    default:
      if #available(iOS 14.1, *) {
        if technology == CTRadioAccessTechnologyNR || technology == CTRadioAccessTechnologyNRNSA {
          return "5G"
        }
      }
      return "UNKNOWN"
    }
  }
  
  private func isRoaming(result: @escaping FlutterResult) {
    // Roaming status is not directly accessible on iOS
    result(FlutterError(code: "NOT_AVAILABLE_ON_IOS",
                       message: "Roaming status is not available on iOS",
                       details: nil))
  }
  
  private func hasSimCard(result: @escaping FlutterResult) {
    do {
      let networkInfo = CTTelephonyNetworkInfo()
      var hasSimCard = false
      
      if #available(iOS 12.0, *) {
        if let carriers = networkInfo.serviceSubscriberCellularProviders {
          hasSimCard = !carriers.isEmpty
        }
      } else {
        hasSimCard = networkInfo.subscriberCellularProvider != nil
      }
      
      result(hasSimCard)
    } catch {
      result(FlutterError(code: "HAS_SIM_ERROR",
                         message: "Error checking SIM card: \(error.localizedDescription)",
                         details: nil))
    }
  }
  
  private func getSimCount(result: @escaping FlutterResult) {
    do {
      let networkInfo = CTTelephonyNetworkInfo()
      var simCount = 0
      
      if #available(iOS 12.0, *) {
        if let carriers = networkInfo.serviceSubscriberCellularProviders {
          simCount = carriers.count
        }
      } else {
        simCount = networkInfo.subscriberCellularProvider != nil ? 1 : 0
      }
      
      result(simCount)
    } catch {
      result(FlutterError(code: "SIM_COUNT_ERROR",
                         message: "Error getting SIM count: \(error.localizedDescription)",
                         details: nil))
    }
  }
  
  private func isDualSim(result: @escaping FlutterResult) {
    do {
      let networkInfo = CTTelephonyNetworkInfo()
      var isDualSim = false
      
      if #available(iOS 12.0, *) {
        if let carriers = networkInfo.serviceSubscriberCellularProviders {
          isDualSim = carriers.count > 1
        }
      }
      
      result(isDualSim)
    } catch {
      result(FlutterError(code: "DUAL_SIM_ERROR",
                         message: "Error checking dual SIM: \(error.localizedDescription)",
                         details: nil))
    }
  }
  
  private func getAllSimInfo(result: @escaping FlutterResult) {
    do {
      let networkInfo = CTTelephonyNetworkInfo()
      var simInfoList: [[String: Any?]] = []
      
      // A set of known invalid placeholder values
      let invalidCountryCodes = ["--", ""]
      
      if #available(iOS 12.0, *) {
        if let carriers = networkInfo.serviceSubscriberCellularProviders {
          var slotIndex = 0
          for (key, carrier) in carriers {
            var countryIso = carrier.isoCountryCode?.uppercased()
            
            // Use locale fallback if country code is invalid or nil
            if countryIso == nil || invalidCountryCodes.contains(countryIso!) {
              countryIso = getFallbackCountryCode()
            }
            
            let simInfo: [String: Any?] = [
              "slotIndex": slotIndex,
              "subscriptionId": slotIndex,
              "displayName": carrier.carrierName,
              "carrierName": carrier.carrierName,
              "countryIso": countryIso,
              "isNetworkRoaming": nil, // Not available on iOS
              "phoneNumber": nil // Not available on iOS
            ]
            simInfoList.append(simInfo)
            slotIndex += 1
          }
        }
      } else {
        if let carrier = networkInfo.subscriberCellularProvider {
          var countryIso = carrier.isoCountryCode?.uppercased()
          
          // Use locale fallback if country code is invalid or nil
          if countryIso == nil || invalidCountryCodes.contains(countryIso!) {
            countryIso = getFallbackCountryCode()
          }
          
          let simInfo: [String: Any?] = [
            "slotIndex": 0,
            "subscriptionId": 0,
            "displayName": carrier.carrierName,
            "carrierName": carrier.carrierName,
            "countryIso": countryIso,
            "isNetworkRoaming": nil, // Not available on iOS
            "phoneNumber": nil // Not available on iOS
          ]
          simInfoList.append(simInfo)
        }
      }
      
      result(simInfoList)
    } catch {
      result(FlutterError(code: "ALL_SIM_INFO_ERROR",
                         message: "Error getting all SIM info: \(error.localizedDescription)",
                         details: nil))
    }
  }
  
  private func getDeviceId(result: @escaping FlutterResult) {
    // Device ID (IMEI/MEID) is not accessible on iOS for privacy reasons
    result(FlutterError(code: "NOT_AVAILABLE_ON_IOS",
                       message: "Device ID is not available on iOS for privacy reasons",
                       details: nil))
  }
}
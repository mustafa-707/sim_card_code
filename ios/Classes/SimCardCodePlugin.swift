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
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getSimCountryCode(result: @escaping FlutterResult) {
    do {
      let networkInfo = CTTelephonyNetworkInfo()
      var countryCode: String? = nil
      
      if #available(iOS 12.0, *) {
        
        if let carriers = networkInfo.serviceSubscriberCellularProviders {
          for (_, carrierValue) in carriers {
            if let isoCountryCode = carrierValue.isoCountryCode, !isoCountryCode.isEmpty {
              countryCode = isoCountryCode.uppercased()
              break
            }
          }
        }
      } else {
        
        if let carrier = networkInfo.subscriberCellularProvider, 
           let isoCountryCode = carrier.isoCountryCode, 
           !isoCountryCode.isEmpty {
          countryCode = isoCountryCode.uppercased()
        }
      }
      
      result(countryCode)
    } catch {
      
      result(FlutterError(code: "SIM_COUNTRY_CODE_ERROR", 
                          message: "Error getting country: \(error.localizedDescription)", 
                          details: nil))
    }
  }
}
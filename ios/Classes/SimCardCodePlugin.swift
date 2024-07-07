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
    let networkInfo = CTTelephonyNetworkInfo()
    var carrier: CTCarrier?

    if #available(iOS 12.0, *) {
      if let carriers = networkInfo.serviceSubscriberCellularProviders {
        for (_, carrierValue) in carriers {
          if let isoCountryCode = carrierValue.isoCountryCode {
            carrier = carrierValue
            break
          }
        }
      }
    } else {
      carrier = networkInfo.subscriberCellularProvider
    }

    if let carrier = carrier, let countryCode = carrier.isoCountryCode {
      result(countryCode)
    } else {
      let flutterError = FlutterError(code: "SIM_COUNTRY_CODE_ERROR", message: "Error getting country", details: nil)
      result(flutterError)
    }
  }

}

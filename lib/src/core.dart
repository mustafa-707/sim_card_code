part of '../sim_card_code.dart';

class SimCardInfo {
  static const MethodChannel _channel = MethodChannel('sim_card_code');

  static Future<String?> get simCountryCode async {
    try {
      final countryCode = await _channel.invokeMethod(
        'getSimCountryCode',
      );
      if (countryCode == null) {
        throw Exception('Country Code is null');
      }
      return countryCode.toString();
    } catch (e) {
      return null;
    }
  }
}

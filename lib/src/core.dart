part of '../sim_card_code.dart';

/// Represents SIM card information
class SimCardInfo {
  final String? countryCode;
  final String? operatorName;
  final String? operatorCode;
  final String? serialNumber;
  final String? phoneNumber;
  final SimState? simState;
  final int? slotIndex;
  final int? subscriptionId;
  final String? displayName;
  final String? carrierName;
  final bool? isRoaming;

  const SimCardInfo({
    this.countryCode,
    this.operatorName,
    this.operatorCode,
    this.serialNumber,
    this.phoneNumber,
    this.simState,
    this.slotIndex,
    this.subscriptionId,
    this.displayName,
    this.carrierName,
    this.isRoaming,
  });

  factory SimCardInfo.fromMap(Map<String, dynamic> map) {
    return SimCardInfo(
      countryCode: map['countryIso'] as String?,
      operatorName: map['carrierName'] as String?,
      operatorCode: map['operatorCode'] as String?,
      serialNumber: map['serialNumber'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      slotIndex: map['slotIndex'] as int?,
      subscriptionId: map['subscriptionId'] as int?,
      displayName: map['displayName'] as String?,
      carrierName: map['carrierName'] as String?,
      isRoaming: map['isNetworkRoaming'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'countryCode': countryCode,
      'operatorName': operatorName,
      'operatorCode': operatorCode,
      'serialNumber': serialNumber,
      'phoneNumber': phoneNumber,
      'simState': simState?.name,
      'slotIndex': slotIndex,
      'subscriptionId': subscriptionId,
      'displayName': displayName,
      'carrierName': carrierName,
      'isRoaming': isRoaming,
    };
  }

  @override
  String toString() {
    return 'SimCardInfo(countryCode: $countryCode, operatorName: $operatorName, '
        'operatorCode: $operatorCode, phoneNumber: $phoneNumber, '
        'simState: $simState, slotIndex: $slotIndex)';
  }
}

/// Represents network information
class NetworkInfo {
  final String? operatorName;
  final String? countryCode;
  final String? networkType;
  final bool isRoaming;

  const NetworkInfo({
    this.operatorName,
    this.countryCode,
    this.networkType,
    this.isRoaming = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'operatorName': operatorName,
      'countryCode': countryCode,
      'networkType': networkType,
      'isRoaming': isRoaming,
    };
  }

  @override
  String toString() {
    return 'NetworkInfo(operatorName: $operatorName, countryCode: $countryCode, '
        'networkType: $networkType, isRoaming: $isRoaming)';
  }
}

/// SIM card states
enum SimState {
  absent,
  pinRequired,
  pukRequired,
  networkLocked,
  ready,
  notReady,
  permDisabled,
  cardIoError,
  cardRestricted,
  unknown,
}

/// Extension to convert string to SimState
extension SimStateExtension on SimState {
  static SimState fromString(String state) {
    switch (state.toUpperCase()) {
      case 'ABSENT':
        return SimState.absent;
      case 'PIN_REQUIRED':
        return SimState.pinRequired;
      case 'PUK_REQUIRED':
        return SimState.pukRequired;
      case 'NETWORK_LOCKED':
        return SimState.networkLocked;
      case 'READY':
        return SimState.ready;
      case 'NOT_READY':
        return SimState.notReady;
      case 'PERM_DISABLED':
        return SimState.permDisabled;
      case 'CARD_IO_ERROR':
        return SimState.cardIoError;
      case 'CARD_RESTRICTED':
        return SimState.cardRestricted;
      default:
        return SimState.unknown;
    }
  }
}

/// Main class for SIM card operations
class SimCardManager {
  static const MethodChannel _channel = MethodChannel('sim_card_code');

  /// Get SIM country code (ISO 3166-1 alpha-2)
  static Future<String?> get simCountryCode async {
    try {
      final countryCode = await _channel.invokeMethod('getSimCountryCode');
      log('SIM country code: $countryCode');
      return countryCode as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get SIM operator name (carrier name)
  static Future<String?> get simOperatorName async {
    try {
      final operatorName = await _channel.invokeMethod('getSimOperatorName');
      return operatorName as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get SIM operator code (MCC+MNC)
  static Future<String?> get simOperatorCode async {
    try {
      final operatorCode = await _channel.invokeMethod('getSimOperatorCode');
      return operatorCode as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get SIM serial number (ICCID)
  /// Requires READ_PHONE_STATE permission
  static Future<String?> get simSerialNumber async {
    try {
      final serialNumber = await _channel.invokeMethod('getSimSerialNumber');
      return serialNumber as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get current SIM state
  static Future<SimState> get simState async {
    try {
      final state = await _channel.invokeMethod('getSimState');
      return SimStateExtension.fromString(state as String);
    } catch (e) {
      return SimState.unknown;
    }
  }

  /// Get phone number associated with SIM
  /// Requires READ_PHONE_STATE permission
  /// Note: May return null or empty on many devices
  static Future<String?> get phoneNumber async {
    try {
      final phoneNumber = await _channel.invokeMethod('getPhoneNumber');
      return phoneNumber as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get network operator name
  static Future<String?> get networkOperatorName async {
    try {
      final operatorName =
          await _channel.invokeMethod('getNetworkOperatorName');
      return operatorName as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get network country code
  static Future<String?> get networkCountryCode async {
    try {
      final countryCode = await _channel.invokeMethod('getNetworkCountryCode');
      return countryCode as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get current network type (2G, 3G, 4G, etc.)
  static Future<String?> get networkType async {
    try {
      final networkType = await _channel.invokeMethod('getNetworkType');
      return networkType as String?;
    } catch (e) {
      return null;
    }
  }

  /// Check if device is roaming
  static Future<bool> get isRoaming async {
    try {
      final roaming = await _channel.invokeMethod('isRoaming');
      return roaming as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if device has SIM card
  static Future<bool> get hasSimCard async {
    try {
      final hasSim = await _channel.invokeMethod('hasSimCard');
      return hasSim as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get number of SIM cards in device
  static Future<int> get simCount async {
    try {
      final count = await _channel.invokeMethod('getSimCount');
      return count as int? ?? 1;
    } catch (e) {
      return 1;
    }
  }

  /// Check if device supports dual SIM
  static Future<bool> get isDualSim async {
    try {
      final isDual = await _channel.invokeMethod('isDualSim');
      return isDual as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get device ID (IMEI/MEID)
  /// Requires READ_PHONE_STATE permission
  static Future<String?> get deviceId async {
    try {
      final deviceId = await _channel.invokeMethod('getDeviceId');
      return deviceId as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get information for all SIM cards (dual SIM support)
  /// Requires READ_PHONE_STATE permission
  static Future<List<SimCardInfo>> get allSimInfo async {
    try {
      final result = await _channel.invokeMethod('getAllSimInfo');
      if (result == null) return [];

      final List<dynamic> simList = result as List<dynamic>;
      return simList
          .map((sim) => SimCardInfo.fromMap(Map<String, dynamic>.from(sim)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get comprehensive network information
  static Future<NetworkInfo> get networkInfo async {
    try {
      final operatorName = await networkOperatorName;
      final countryCode = await networkCountryCode;
      final netType = await networkType;
      final roaming = await isRoaming;

      return NetworkInfo(
        operatorName: operatorName,
        countryCode: countryCode,
        networkType: netType,
        isRoaming: roaming,
      );
    } catch (e) {
      return const NetworkInfo();
    }
  }

  /// Get basic SIM information (for single SIM devices)
  static Future<SimCardInfo?> get basicSimInfo async {
    try {
      final countryCode = await simCountryCode;
      final operatorName = await simOperatorName;
      final operatorCode = await simOperatorCode;
      final phoneNumber = await SimCardManager.phoneNumber;
      final state = await simState;
      final roaming = await isRoaming;

      if (countryCode == null && operatorName == null) {
        return null; // No SIM detected
      }

      return SimCardInfo(
        countryCode: countryCode,
        operatorName: operatorName,
        operatorCode: operatorCode,
        phoneNumber: phoneNumber,
        simState: state,
        isRoaming: roaming,
      );
    } catch (e) {
      return null;
    }
  }

  /// Convenience method - equivalent to simCountryCode for backward compatibility
  @Deprecated('Use simCountryCode instead')
  static Future<String?> getSimCountryCode() => simCountryCode;
}

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
      // Fix: Add SimState parsing
      simState: map['simState'] != null
          ? SimStateExtension.fromString(map['simState'] as String)
          : null,
      slotIndex: map['slotIndex'] as int?,
      subscriptionId: map['subscriptionId'] as int?,
      displayName: map['displayName'] as String?,
      carrierName: map['carrierName'] as String?,
      isRoaming: map['isNetworkRoaming'] is int
          ? (map['isNetworkRoaming'] as int) == 1
          : map['isNetworkRoaming'] as bool?,
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

class SimCardManager {
  static const MethodChannel _channel = MethodChannel('sim_card_code');

  static Future<T?> _invoke<T>(String method) async {
    try {
      final result = await _channel.invokeMethod(method);
      return result as T?;
    } catch (_) {
      return null;
    }
  }

  // Caches
  static String? _simCountryCode;
  static String? _simOperatorName;
  static String? _simOperatorCode;
  static String? _simSerialNumber;
  static String? _phoneNumber;
  static SimState? _simState;
  static String? _networkOperatorName;
  static String? _networkCountryCode;
  static String? _networkType;
  static bool? _isRoaming;
  static bool? _hasSimCard;
  static int? _simCount;
  static bool? _isDualSim;
  static String? _deviceId;
  static List<SimCardInfo>? _allSimInfo;

  static Future<String?> get simCountryCode async =>
      _simCountryCode ??= await _invoke<String>('getSimCountryCode');

  static Future<String?> get simOperatorName async =>
      _simOperatorName ??= await _invoke<String>('getSimOperatorName');

  static Future<String?> get simOperatorCode async =>
      _simOperatorCode ??= await _invoke<String>('getSimOperatorCode');

  static Future<String?> get simSerialNumber async =>
      _simSerialNumber ??= await _invoke<String>('getSimSerialNumber');

  static Future<String?> get phoneNumber async =>
      _phoneNumber ??= await _invoke<String>('getPhoneNumber');

  static Future<SimState> get simState async {
    if (_simState != null) return _simState!;
    final result = await _invoke<String>('getSimState');
    return _simState = SimStateExtension.fromString(result ?? '');
  }

  static Future<String?> get networkOperatorName async =>
      _networkOperatorName ??= await _invoke<String>('getNetworkOperatorName');

  static Future<String?> get networkCountryCode async =>
      _networkCountryCode ??= await _invoke<String>('getNetworkCountryCode');

  static Future<String?> get networkType async =>
      _networkType ??= await _invoke<String>('getNetworkType');

  static Future<bool> get isRoaming async =>
      _isRoaming ??= await _invoke<bool>('isRoaming') ?? false;

  static Future<bool> get hasSimCard async =>
      _hasSimCard ??= await _invoke<bool>('hasSimCard') ?? false;

  static Future<int> get simCount async =>
      _simCount ??= await _invoke<int>('getSimCount') ?? 1;

  static Future<bool> get isDualSim async =>
      _isDualSim ??= await _invoke<bool>('isDualSim') ?? false;

  static Future<String?> get deviceId async =>
      _deviceId ??= await _invoke<String>('getDeviceId');

  static Future<List<SimCardInfo>> get allSimInfo async {
    if (_allSimInfo != null) return _allSimInfo!;
    final result = await _invoke<List<dynamic>>('getAllSimInfo');
    _allSimInfo = result == null
        ? []
        : result
            .map((sim) => SimCardInfo.fromMap(Map<String, dynamic>.from(sim)))
            .toList();
    return _allSimInfo!;
  }

  static Future<NetworkInfo> get networkInfo async {
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
  }

  static Future<SimCardInfo?> get basicSimInfo async {
    final countryCode = await simCountryCode;
    final operatorName = await simOperatorName;

    if (countryCode == null && operatorName == null) return null;

    return SimCardInfo(
      countryCode: countryCode,
      operatorName: operatorName,
      operatorCode: await simOperatorCode,
      phoneNumber: await phoneNumber,
      simState: await simState,
      isRoaming: await isRoaming,
    );
  }

  // Add method to clear cache for fresh data
  static void clearCache() {
    _simCountryCode = null;
    _simOperatorName = null;
    _simOperatorCode = null;
    _simSerialNumber = null;
    _phoneNumber = null;
    _simState = null;
    _networkOperatorName = null;
    _networkCountryCode = null;
    _networkType = null;
    _isRoaming = null;
    _hasSimCard = null;
    _simCount = null;
    _isDualSim = null;
    _deviceId = null;
    _allSimInfo = null;
  }

  @Deprecated('Use simCountryCode instead')
  static Future<String?> getSimCountryCode() => simCountryCode;
}

part of '../sim_card_code.dart';

/// Represents SIM card information.
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
  final bool? isEsim;

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
    this.isEsim,
  });

  factory SimCardInfo.fromMap(Map<String, dynamic> map) {
    return SimCardInfo(
      countryCode: map['countryIso'] as String?,
      operatorName: map['carrierName'] as String?,
      operatorCode: map['operatorCode'] as String?,
      serialNumber: map['serialNumber'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      simState: map['simState'] != null
          ? SimStateExtension.fromString(map['simState'] as String)
          : null,
      slotIndex: map['slotIndex'] as int?,
      subscriptionId: map['subscriptionId'] as int?,
      displayName: map['displayName'] as String?,
      carrierName: map['carrierName'] as String?,
      isEsim: map['isEsim'] as bool?,
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
      'isEsim': isEsim,
    };
  }

  @override
  String toString() {
    return 'SimCardInfo(countryCode: $countryCode, operatorName: $operatorName, '
        'operatorCode: $operatorCode, phoneNumber: $phoneNumber, '
        'simState: $simState, slotIndex: $slotIndex, isEsim : $isEsim)';
  }
}

/// Represents network information.
class NetworkInfo {
  final String? operatorName;
  final String? countryCode;

  /// Raw network technology string (e.g. `"LTE"`, `"5G"`).
  ///
  /// For a typed value use [type]; for the cellular generation use
  /// [generation].
  final String? networkType;
  final bool isRoaming;

  const NetworkInfo({
    this.operatorName,
    this.countryCode,
    this.networkType,
    this.isRoaming = false,
  });

  /// The network technology as a typed [NetworkType].
  NetworkType get type => NetworkTypeExtension.fromString(networkType);

  /// The cellular generation (2G–5G) of the current network.
  NetworkGeneration get generation => type.generation;

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
        'networkType: $networkType, generation: ${generation.label}, '
        'isRoaming: $isRoaming)';
  }
}

/// SIM card states.
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

/// Extension to convert a platform string to a [SimState].
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

/// Cellular network access technology.
enum NetworkType {
  gprs,
  edge,
  umts,
  cdma,
  oneXrtt,
  hsdpa,
  hsupa,
  hspa,
  hspap,
  evdo0,
  evdoA,
  evdoB,
  ehrpd,
  lte,
  nr,
  unknown,
}

/// Extension to parse a platform string into a [NetworkType] and to derive its
/// [NetworkGeneration].
extension NetworkTypeExtension on NetworkType {
  static NetworkType fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'GPRS':
        return NetworkType.gprs;
      case 'EDGE':
        return NetworkType.edge;
      case 'UMTS':
        return NetworkType.umts;
      case 'CDMA':
        return NetworkType.cdma;
      case '1XRTT':
        return NetworkType.oneXrtt;
      case 'HSDPA':
        return NetworkType.hsdpa;
      case 'HSUPA':
        return NetworkType.hsupa;
      case 'HSPA':
        return NetworkType.hspa;
      case 'HSPAP':
        return NetworkType.hspap;
      case 'EVDO_0':
        return NetworkType.evdo0;
      case 'EVDO_A':
        return NetworkType.evdoA;
      case 'EVDO_B':
        return NetworkType.evdoB;
      case 'EHRPD':
        return NetworkType.ehrpd;
      case 'LTE':
        return NetworkType.lte;
      case '5G':
      case 'NR':
        return NetworkType.nr;
      default:
        return NetworkType.unknown;
    }
  }

  /// The cellular generation this technology belongs to.
  NetworkGeneration get generation {
    switch (this) {
      case NetworkType.gprs:
      case NetworkType.edge:
      case NetworkType.cdma:
      case NetworkType.oneXrtt:
        return NetworkGeneration.g2;
      case NetworkType.umts:
      case NetworkType.hsdpa:
      case NetworkType.hsupa:
      case NetworkType.hspa:
      case NetworkType.hspap:
      case NetworkType.evdo0:
      case NetworkType.evdoA:
      case NetworkType.evdoB:
      case NetworkType.ehrpd:
        return NetworkGeneration.g3;
      case NetworkType.lte:
        return NetworkGeneration.g4;
      case NetworkType.nr:
        return NetworkGeneration.g5;
      case NetworkType.unknown:
        return NetworkGeneration.unknown;
    }
  }
}

/// Mobile network generation (2G–5G).
enum NetworkGeneration { g2, g3, g4, g5, unknown }

/// Extension providing a human-readable label for a [NetworkGeneration].
extension NetworkGenerationExtension on NetworkGeneration {
  /// Short label, e.g. `"4G"`.
  String get label {
    switch (this) {
      case NetworkGeneration.g2:
        return '2G';
      case NetworkGeneration.g3:
        return '3G';
      case NetworkGeneration.g4:
        return '4G';
      case NetworkGeneration.g5:
        return '5G';
      case NetworkGeneration.unknown:
        return 'Unknown';
    }
  }
}

/// What kind of cellular change triggered a [SimCardChangeEvent].
enum SimChangeType {
  /// A SIM / subscription was inserted, removed or swapped.
  sim,

  /// The serving network, operator or roaming state changed.
  network,

  /// The change could not be classified.
  unknown,
}

/// An event emitted by [SimCardManager.onChanged] when cellular state changes.
///
/// The plugin's internal cache is cleared automatically before each event, so
/// reading any [SimCardManager] getter after receiving an event returns fresh
/// data.
class SimCardChangeEvent {
  /// The category of change that occurred.
  final SimChangeType type;

  const SimCardChangeEvent(this.type);

  @override
  String toString() => 'SimCardChangeEvent($type)';
}

/// Thrown by [SimCardManager] methods when [SimCardManager.throwOnError] is
/// enabled and an underlying platform call fails.
///
/// When `throwOnError` is `false` (the default) failures resolve to `null`
/// instead, preserving backward-compatible behavior.
class SimCardException implements Exception {
  /// A stable error code, e.g. `PERMISSION_DENIED` or `SIM_STATE_ERROR`.
  final String code;

  /// An optional human-readable description.
  final String? message;

  const SimCardException(this.code, [this.message]);

  @override
  String toString() =>
      'SimCardException($code)${message != null ? ': $message' : ''}';
}

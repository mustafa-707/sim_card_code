part of '../sim_card_code.dart';

/// Entry point of the plugin — reads SIM card and cellular network information.
///
/// All members are `static`. Getters cache their result; call [clearCache] to
/// force a refresh, or listen to [onChanged] which clears the cache for you.
class SimCardManager {
  static const MethodChannel _channel = MethodChannel('sim_card_code');
  static const EventChannel _eventChannel =
      EventChannel('sim_card_code/events');

  /// When `true`, failed platform calls throw a [SimCardException] instead of
  /// resolving to `null`.
  ///
  /// Defaults to `false` for backward compatibility. Enable it when you need to
  /// tell failure modes apart (e.g. permission denied vs. no SIM present):
  ///
  /// ```dart
  /// SimCardManager.throwOnError = true;
  /// try {
  ///   final number = await SimCardManager.phoneNumber;
  /// } on SimCardException catch (e) {
  ///   if (e.code == 'PERMISSION_DENIED') { /* ask for permission */ }
  /// }
  /// ```
  static bool throwOnError = false;

  static Future<T?> _invoke<T>(
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    try {
      final result = await _channel.invokeMethod(method, arguments);
      return result as T?;
    } on PlatformException catch (e) {
      if (throwOnError) throw SimCardException(e.code, e.message);
      return null;
    } catch (e) {
      if (throwOnError) throw SimCardException('UNKNOWN', e.toString());
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
  static bool? _isEsim;
  static String? _deviceId;
  static List<SimCardInfo>? _allSimInfo;
  static bool? _supportsEsim;

  static Stream<SimCardChangeEvent>? _onChanged;

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

  /// The raw network technology string (e.g. `"LTE"`, `"5G"`).
  ///
  /// For a typed value use [networkInfo] (`NetworkInfo.type`) or
  /// [networkGeneration].
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

  /// Whether the default SIM is an eSIM.
  static Future<bool> get isEsim async =>
      _isEsim ??= await _invoke<bool>('isEsim') ?? false;

  /// Whether the device supports eSIM functionality based on hardware
  /// capabilities.
  ///
  /// Note: on iOS below 16.0, actual eSIM usage may also depend on region
  /// restrictions, carrier policies, and device management profiles.
  ///
  /// ⚠️ On iOS, `supportsEsim` requires the `com.apple.developer.esim-access`
  /// entitlement. Without it the check **always returns `false`**, even on
  /// devices that support eSIM.
  static Future<bool> get supportsEsim async =>
      _supportsEsim ??= await _invoke<bool>('supportsEsim') ?? false;

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

  /// Returns full information for a single SIM identified by its
  /// [subscriptionId] — useful on multi-SIM devices where the default-SIM
  /// getters (e.g. [simCountryCode], [isEsim]) are not enough.
  ///
  /// On Android the data is read from
  /// `TelephonyManager.createForSubscriptionId`, so values reflect the
  /// requested SIM rather than the default voice/data SIM. Valid subscription
  /// ids can be obtained from [allSimInfo] (`SimCardInfo.subscriptionId`).
  ///
  /// Returns `null` when the subscription is not active, on Android < 22, or
  /// on iOS — iOS exposes no integer subscription id, so use [allSimInfo]
  /// there instead.
  ///
  /// Requires the `READ_PHONE_STATE` permission on Android.
  ///
  /// This result is not cached; each call queries the platform.
  static Future<SimCardInfo?> simInfoForSubscription(int subscriptionId) async {
    final result = await _invoke<Map<dynamic, dynamic>>(
      'getSimInfoForSubscription',
      {'subscriptionId': subscriptionId},
    );
    if (result == null) return null;
    return SimCardInfo.fromMap(Map<String, dynamic>.from(result));
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

  /// The cellular generation (2G–5G) of the current network.
  static Future<NetworkGeneration> get networkGeneration async =>
      NetworkTypeExtension.fromString(await networkType).generation;

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
      isEsim: await isEsim,
    );
  }

  /// A broadcast stream of cellular changes — SIM insert/remove/swap, and
  /// network/operator/roaming changes.
  ///
  /// The internal cache is cleared automatically before each event is
  /// delivered, so any getter read inside your listener returns fresh data:
  ///
  /// ```dart
  /// SimCardManager.onChanged.listen((event) async {
  ///   final info = await SimCardManager.basicSimInfo; // already fresh
  /// });
  /// ```
  ///
  /// The stream is lazily created and shared across listeners.
  static Stream<SimCardChangeEvent> get onChanged {
    return _onChanged ??= _eventChannel
        .receiveBroadcastStream()
        .map<SimCardChangeEvent>((dynamic event) {
      clearCache();
      return SimCardChangeEvent(_parseChangeType(event));
    });
  }

  static SimChangeType _parseChangeType(dynamic raw) {
    switch (raw?.toString()) {
      case 'sim':
        return SimChangeType.sim;
      case 'network':
        return SimChangeType.network;
      default:
        return SimChangeType.unknown;
    }
  }

  /// Clears every cached value so the next read queries the platform again.
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
    _isEsim = null;
    _isDualSim = null;
    _deviceId = null;
    _allSimInfo = null;
    _supportsEsim = null;
  }

  @Deprecated('Use simCountryCode instead')
  static Future<String?> getSimCountryCode() => simCountryCode;
}

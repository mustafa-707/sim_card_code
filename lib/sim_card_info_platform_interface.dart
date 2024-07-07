import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sim_card_info_method_channel.dart';

abstract class SimCardInfoPlatform extends PlatformInterface {
  /// Constructs a SimCardInfoPlatform.
  SimCardInfoPlatform() : super(token: _token);

  static final Object _token = Object();

  static SimCardInfoPlatform _instance = MethodChannelSimCardInfo();

  /// The default instance of [SimCardInfoPlatform] to use.
  ///
  /// Defaults to [MethodChannelSimCardInfo].
  static SimCardInfoPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SimCardInfoPlatform] when
  /// they register themselves.
  static set instance(SimCardInfoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

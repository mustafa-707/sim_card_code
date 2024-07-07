import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sim_card_info_platform_interface.dart';

/// An implementation of [SimCardInfoPlatform] that uses method channels.
class MethodChannelSimCardInfo extends SimCardInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sim_card_info');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

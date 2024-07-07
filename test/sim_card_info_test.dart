import 'package:flutter_test/flutter_test.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:sim_card_info/sim_card_info_platform_interface.dart';
import 'package:sim_card_info/sim_card_info_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSimCardInfoPlatform
    with MockPlatformInterfaceMixin
    implements SimCardInfoPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SimCardInfoPlatform initialPlatform = SimCardInfoPlatform.instance;

  test('$MethodChannelSimCardInfo is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSimCardInfo>());
  });

  test('getPlatformVersion', () async {
    SimCardInfo simCardInfoPlugin = SimCardInfo();
    MockSimCardInfoPlatform fakePlatform = MockSimCardInfoPlatform();
    SimCardInfoPlatform.instance = fakePlatform;

    expect(await simCardInfoPlugin.getPlatformVersion(), '42');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk_platform_interface.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNetworkInternationalPaymentSdkPlatform
    with MockPlatformInterfaceMixin
    implements NetworkInternationalPaymentSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NetworkInternationalPaymentSdkPlatform initialPlatform = NetworkInternationalPaymentSdkPlatform.instance;

  test('$MethodChannelNetworkInternationalPaymentSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNetworkInternationalPaymentSdk>());
  });

  test('getPlatformVersion', () async {
    NetworkInternationalPaymentSdk networkInternationalPaymentSdkPlugin = NetworkInternationalPaymentSdk();
    MockNetworkInternationalPaymentSdkPlatform fakePlatform = MockNetworkInternationalPaymentSdkPlatform();
    NetworkInternationalPaymentSdkPlatform.instance = fakePlatform;

    expect(await networkInternationalPaymentSdkPlugin.getPlatformVersion(), '42');
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'network_international_payment_sdk_platform_interface.dart';

/// An implementation of [NetworkInternationalPaymentSdkPlatform] that uses method channels.
class MethodChannelNetworkInternationalPaymentSdk extends NetworkInternationalPaymentSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('network_international_payment_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

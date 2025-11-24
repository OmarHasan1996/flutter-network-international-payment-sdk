import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'network_international_payment_sdk_platform_interface.dart';

/// An implementation of [NetworkInternationalPaymentSdkPlatform] that uses method channels.
class MethodChannelNetworkInternationalPaymentSdk extends NetworkInternationalPaymentSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('network_international_payment_sdk');

  @override
  Future<Map<dynamic, dynamic>?> startCardPayment({
    required Map<String, dynamic> orderDetails,
    String? merchantId,
    bool? showOrderAmount,
    bool? showCancelAlert,
    Map<String, dynamic>? theme,
  }) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('startCardPayment', {
      'orderDetails': orderDetails,
      'merchantId': merchantId,
      'showOrderAmount': showOrderAmount,
      'showCancelAlert': showCancelAlert,
      'theme': theme,
    });
    return result;
  }

  @override
  Future<Map<dynamic, dynamic>?> startSavedCardPayment({
    required Map<String, dynamic> orderDetails,
    String? merchantId,
    String? cvv,
  }) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('startSavedCardPayment', {
      'orderDetails': orderDetails,
      'merchantId': merchantId,
      'cvv': cvv,
    });
    return result;
  }
}

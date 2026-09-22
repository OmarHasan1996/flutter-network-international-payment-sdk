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
    bool? showOrderAmount,
    bool? showCancelAlert,
    Map<String, dynamic>? theme,
    Map<String, dynamic>? googlePayConfig,
  }) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('startCardPayment', {
      'orderDetails': orderDetails,
      'showOrderAmount': showOrderAmount,
      'showCancelAlert': showCancelAlert,
      'theme': theme,
      'googlePayConfig': googlePayConfig,
    });
    return result;
  }

  @override
  Future<Map<dynamic, dynamic>?> startSavedCardPayment({
    required Map<String, dynamic> orderDetails,
    String? cvv,
    Map<String, dynamic>? theme,
  }) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('startSavedCardPayment', {
      'orderDetails': orderDetails,
      'cvv': cvv,
      'theme': theme,
    });
    return result;
  }

  @override
  Future<Map<dynamic, dynamic>?> startApplePay({
    required Map<String, dynamic> orderDetails,
    required Map<String, dynamic> applePayConfig,
    Map<String, dynamic>? theme,
  }) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('startApplePay', {
      'orderDetails': orderDetails,
      'applePayConfig': applePayConfig,
      'theme': theme,
    });
    return result;
  }

  @override
  Future<Map<dynamic, dynamic>?> startSamsungPay({
    required Map<String, dynamic> orderDetails,
    required Map<String, dynamic> samsungPayConfig,
  }) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('startSamsungPay', {
      'orderDetails': orderDetails,
      'samsungPayConfig': samsungPayConfig,
    });
    return result;
  }
}

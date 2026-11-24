import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'network_international_payment_sdk_platform_interface.dart';
import 'src/messages.g.dart';

/// An implementation of [NetworkInternationalPaymentSdkPlatform] that uses Pigeon native interop.
class MethodChannelNetworkInternationalPaymentSdk extends NetworkInternationalPaymentSdkPlatform {
  @visibleForTesting
  final NetworkInternationalPaymentSdkApi api = NetworkInternationalPaymentSdkApi();

  @override
  Future<Map<dynamic, dynamic>?> startCardPayment({
    required Map<String, dynamic> orderDetails,
    bool? showOrderAmount,
    bool? showCancelAlert,
    Map<String, dynamic>? theme,
    Map<String, dynamic>? googlePayConfig,
  }) async {
    final response = await api.startCardPayment(
      CardPaymentRequest(
        orderDetailsJson: jsonEncode(orderDetails),
        showOrderAmount: showOrderAmount,
        showCancelAlert: showCancelAlert,
        themeMap: theme?.cast<String?, Object?>(),
        googlePayConfigMap: googlePayConfig?.cast<String?, Object?>(),
      ),
    );
    return {'status': response.status, 'reason': response.reason};
  }

  @override
  Future<Map<dynamic, dynamic>?> startSavedCardPayment({
    required Map<String, dynamic> orderDetails,
    String? cvv,
    Map<String, dynamic>? theme,
  }) async {
    final response = await api.startSavedCardPayment(
      SavedCardPaymentRequest(
        orderDetailsJson: jsonEncode(orderDetails),
        cvv: cvv,
        themeMap: theme?.cast<String?, Object?>(),
      ),
    );
    return {'status': response.status, 'reason': response.reason};
  }

  @override
  Future<Map<dynamic, dynamic>?> startApplePay({
    required Map<String, dynamic> orderDetails,
    required Map<String, dynamic> applePayConfig,
    Map<String, dynamic>? theme,
  }) async {
    final response = await api.startApplePay(
      ApplePayRequest(
        orderDetailsJson: jsonEncode(orderDetails),
        applePayConfigMap: applePayConfig.cast<String?, Object?>(),
        themeMap: theme?.cast<String?, Object?>(),
      ),
    );
    return {'status': response.status, 'reason': response.reason};
  }

  @override
  Future<Map<dynamic, dynamic>?> startSamsungPay({
    required Map<String, dynamic> orderDetails,
    required Map<String, dynamic> samsungPayConfig,
  }) async {
    final response = await api.startSamsungPay(
      SamsungPayRequest(
        orderDetailsJson: jsonEncode(orderDetails),
        samsungPayConfigMap: samsungPayConfig.cast<String?, Object?>(),
      ),
    );
    return {'status': response.status, 'reason': response.reason};
  }
}

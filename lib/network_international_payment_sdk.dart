import 'dart:convert';
import 'dart:io' show Platform;

import 'package:network_international_payment_sdk/apple_pay_config.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk_platform_interface.dart';
import 'package:network_international_payment_sdk/payment_result.dart';
import 'package:network_international_payment_sdk/payment_status.dart';
import 'package:network_international_payment_sdk/theme.dart';

class NetworkInternationalPaymentSdk {
  /// Initiates a card payment for a new card.
  Future<PaymentResult> startCardPayment({
    Map<String, dynamic>? orderDetails,
    String? base64orderData,
    String? merchantId,
    bool? showOrderAmount,
    bool? showCancelAlert,
    NITheme? theme,
  }) async {
    final finalOrderDetails = _prepareOrderDetails(orderDetails, base64orderData);

    final resultMap = await NetworkInternationalPaymentSdkPlatform.instance.startCardPayment(
      orderDetails: finalOrderDetails,
      merchantId: merchantId,
      showOrderAmount: showOrderAmount,
      showCancelAlert: showCancelAlert,
      theme: theme?.toMap(),
    );

    if (resultMap == null) {
      return PaymentResult(PaymentStatus.unknown, "Did not receive a response from the native side.");
    }
    
    return PaymentResult.fromMap(resultMap);
  }

  /// Initiates a payment using a saved card.
  Future<PaymentResult> startSavedCardPayment({
    Map<String, dynamic>? orderDetails,
    String? base64orderData,
    String? merchantId, // Used as serviceId on Android
    String? cvv, // Optional CVV
  }) async {
    final finalOrderDetails = _prepareOrderDetails(orderDetails, base64orderData);

    final resultMap = await NetworkInternationalPaymentSdkPlatform.instance.startSavedCardPayment(
      orderDetails: finalOrderDetails,
      merchantId: merchantId,
      cvv: cvv,
    );

    if (resultMap == null) {
      return PaymentResult(PaymentStatus.unknown, "Did not receive a response from the native side.");
    }

    return PaymentResult.fromMap(resultMap);
  }
  
  /// (iOS Only) Initiates a payment using Apple Pay.
  Future<PaymentResult> startApplePay({
    Map<String, dynamic>? orderDetails,
    String? base64orderData,
    required PKPaymentRequest applePayConfig,
  }) async {
    if (!Platform.isIOS) {
      return PaymentResult(PaymentStatus.failed, "Apple Pay is only supported on iOS.");
    }
    final finalOrderDetails = _prepareOrderDetails(orderDetails, base64orderData);

    final resultMap = await NetworkInternationalPaymentSdkPlatform.instance.startApplePay(
      orderDetails: finalOrderDetails,
      applePayConfig: applePayConfig.toMap(),
    );

    if (resultMap == null) {
      return PaymentResult(PaymentStatus.unknown, "Did not receive a response from the native side.");
    }

    return PaymentResult.fromMap(resultMap);
  }

  /// Helper to process order details from either a map or a base64 string.
  Map<String, dynamic> _prepareOrderDetails(Map<String, dynamic>? orderDetails, String? base64orderData) {
    if (orderDetails != null) {
      return orderDetails;
    } else if (base64orderData != null && base64orderData.trim().isNotEmpty) {
      try {
        final decodedJson = utf8.decode(base64.decode(base64orderData.trim()));
        return json.decode(decodedJson) as Map<String, dynamic>;
      } catch (e) {
        throw ArgumentError(
            'Failed to decode base64orderData. Make sure it is a valid base64 encoded JSON string. Error: $e');
      }
    } else {
      throw ArgumentError(
          'Either orderDetails (as a Map) or base64orderData (as a String) must be provided.');
    }
  }
}

import 'dart:convert';

import 'package:network_international_payment_sdk/network_international_payment_sdk_platform_interface.dart';
import 'package:network_international_payment_sdk/payment_result.dart';
import 'package:network_international_payment_sdk/payment_status.dart';

class NetworkInternationalPaymentSdk {
  Future<PaymentResult> startPayment({
    Map<String, dynamic>? orderDetails,
    String? base64orderData,
    required String merchantId,
  }) async {
    Map<String, dynamic> finalOrderDetails;
    if (orderDetails != null) {
      finalOrderDetails = orderDetails;
    } else if (base64orderData != null && base64orderData.trim().isNotEmpty) {
      try {
        final decodedJson = utf8.decode(base64.decode(base64orderData.trim()));
        finalOrderDetails = json.decode(decodedJson) as Map<String, dynamic>;
      } catch (e) {
        throw ArgumentError(
            'Failed to decode base64orderData. Make sure it is a valid base64 encoded JSON string. Error: $e');
      }
    } else {
      throw ArgumentError(
          'Either orderDetails (as a Map) or base64orderData (as a String) must be provided.');
    }

    final resultMap = await NetworkInternationalPaymentSdkPlatform.instance.startPayment(
      orderDetails: finalOrderDetails,
      merchantId: merchantId,
    );

    if (resultMap == null) {
      return PaymentResult(PaymentStatus.UNKNOWN, "Did not receive a response from the native side.");
    }
    
    return PaymentResult.fromMap(resultMap);
  }
}

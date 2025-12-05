import 'package:flutter_test/flutter_test.dart';
import 'package:network_international_payment_sdk/apple_pay_config.dart';
import 'package:network_international_payment_sdk/google_pay_config.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk_platform_interface.dart';
import 'package:network_international_payment_sdk/payment_status.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// A mock implementation of the platform interface.
class MockNetworkInternationalPaymentSdkPlatform
    with MockPlatformInterfaceMixin
    implements NetworkInternationalPaymentSdkPlatform {

  @override
  Future<Map?> startCardPayment({
    required Map<String, dynamic> orderDetails,
    bool? showOrderAmount,
    bool? showCancelAlert,
    Map<String, dynamic>? theme,
    Map<String, dynamic>? googlePayConfig,
  }) async {
    expect(orderDetails['testKey'], 'testValue');
    if (googlePayConfig != null) {
      expect(googlePayConfig['merchantGatewayId'], 'test_google_pay_id');
    }
    return {'status': 'SUCCESS', 'reason': 'Payment was successful'};
  }

  @override
  Future<Map<dynamic, dynamic>?> startSavedCardPayment({
    required Map<String, dynamic> orderDetails,
    String? cvv,
  }) async {
    expect(orderDetails['testKey'], 'testValue');
    expect(cvv, '123');
    return {'status': 'SUCCESS', 'reason': 'Saved card payment successful'};
  }

  @override
  Future<Map<dynamic, dynamic>?> startApplePay({
    required Map<String, dynamic> orderDetails,
    required Map<String, dynamic> applePayConfig,
  }) async {
    expect(orderDetails['testKey'], 'testValue');
    expect(applePayConfig['merchantIdentifier'], 'test_apple_pay_id');
    return {'status': 'FAILED', 'reason': 'Apple Pay is only supported on iOS.'};
  }

  @override
  Future<Map<dynamic, dynamic>?> startSamsungPay({required Map<String, dynamic> orderDetails, required Map<String, dynamic> samsungPayConfig}) {
    // TODO: implement startSamsungPay
    throw UnimplementedError();
  }
}

void main() {
  late MockNetworkInternationalPaymentSdkPlatform fakePlatform;
  late NetworkInternationalPaymentSdk plugin;

  setUp(() {
    fakePlatform = MockNetworkInternationalPaymentSdkPlatform();
    NetworkInternationalPaymentSdkPlatform.instance = fakePlatform;
    plugin = NetworkInternationalPaymentSdk();
  });

  test('startCardPayment returns a successful PaymentResult', () async {
    final paymentResult = await plugin.startCardPayment(
      orderDetails: {'testKey': 'testValue'},
    );
    expect(paymentResult.status, PaymentStatus.success);
    expect(paymentResult.reason, 'Payment was successful');
  });

  test('startCardPayment with GooglePay returns a successful PaymentResult', () async {
    final paymentResult = await plugin.startCardPayment(
      orderDetails: {'testKey': 'testValue'},
      googlePayConfig: GooglePayConfig(merchantGatewayId: 'test_google_pay_id'),
    );
    expect(paymentResult.status, PaymentStatus.success);
  });

  test('startSavedCardPayment returns a successful PaymentResult', () async {
    final paymentResult = await plugin.startSavedCardPayment(
      orderDetails: {'testKey': 'testValue'},
      cvv: '123',
    );
    expect(paymentResult.status, PaymentStatus.success);
    expect(paymentResult.reason, 'Saved card payment successful');
  });

  test('startApplePay returns a successful PaymentResult', () async {
    final paymentResult = await plugin.startApplePay(
      orderDetails: {'testKey': 'testValue'},
      applePayConfig: PKPaymentRequest(
        merchantIdentifier: 'test_apple_pay_id',
        paymentSummaryItems: [],
      ),
    );
    expect(paymentResult.status, PaymentStatus.failed);
    expect(paymentResult.reason, 'Apple Pay is only supported on iOS.');
  });
}

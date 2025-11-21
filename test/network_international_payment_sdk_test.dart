import 'package:flutter_test/flutter_test.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk_platform_interface.dart';
import 'package:network_international_payment_sdk/payment_result.dart';
import 'package:network_international_payment_sdk/payment_status.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// 1. A mock implementation of the platform interface.
class MockNetworkInternationalPaymentSdkPlatform
    with MockPlatformInterfaceMixin
    implements NetworkInternationalPaymentSdkPlatform {

  // 2. We are mocking the native `startCardPayment` call.
  // It will return a successful result map.
  @override
  Future<Map?> startCardPayment({
    required Map<String, dynamic> orderDetails,
    String? merchantId,
  }) async {
    // 3. We check that the correct parameters are passed from the public-facing method.
    expect(merchantId, 'test_merchant');
    expect(orderDetails['testKey'], 'testValue');
    
    return {'status': 'SUCCESS', 'reason': 'Payment was successful'};
  }
}

void main() {
  // The mock platform instance to use for all tests.
  late MockNetworkInternationalPaymentSdkPlatform fakePlatform;
  // The instance of the plugin to test.
  late NetworkInternationalPaymentSdk plugin;

  setUp(() {
    fakePlatform = MockNetworkInternationalPaymentSdkPlatform();
    NetworkInternationalPaymentSdkPlatform.instance = fakePlatform;
    plugin = NetworkInternationalPaymentSdk();
  });

  test('startCardPayment returns a successful PaymentResult', () async {
    // 4. Define the input for the test.
    final testOrderDetails = {'testKey': 'testValue'};
    final testMerchantId = 'test_merchant';

    // 5. Call the public method.
    final paymentResult = await plugin.startCardPayment(
      orderDetails: testOrderDetails,
      merchantId: testMerchantId,
    );

    // 6. Verify that the result is correctly parsed into a PaymentResult object.
    expect(paymentResult, isA<PaymentResult>());
    expect(paymentResult.status, PaymentStatus.SUCCESS);
    expect(paymentResult.reason, 'Payment was successful');
  });
  
   test('startCardPayment handles base64 decoding', () async {
    // Test base64 decoding logic.
    final testOrderDetails = {'testKey': 'testValue'};
    final base64Order = 'eyJ0ZXN0S2V5IjoidGVzdFZhbHVlIn0='; // {"testKey":"testValue"}
    final testMerchantId = 'test_merchant';

    final paymentResult = await plugin.startCardPayment(
      base64orderData: base64Order,
      merchantId: testMerchantId,
    );

    expect(paymentResult, isA<PaymentResult>());
    expect(paymentResult.status, PaymentStatus.SUCCESS);
  });
}

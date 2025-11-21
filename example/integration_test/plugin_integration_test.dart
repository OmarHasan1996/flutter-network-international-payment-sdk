// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing


import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';
import 'package:network_international_payment_sdk/payment_result.dart';
import 'package:network_international_payment_sdk/payment_status.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('startCardPayment test', (WidgetTester tester) async {
    final NetworkInternationalPaymentSdk plugin = NetworkInternationalPaymentSdk();
    final PaymentResult paymentResult = await plugin.startCardPayment();
    // The version string depends on the host platform running the test, so
    // just assert that some non-empty string is returned.
    expect(paymentResult.status, PaymentStatus.FAILED);
  });
}

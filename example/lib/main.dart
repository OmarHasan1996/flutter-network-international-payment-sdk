import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:network_international_payment_sdk/apple_pay_config.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';
import 'package:network_international_payment_sdk/payment_result.dart';
import 'package:network_international_payment_sdk/payment_status.dart';
import 'package:network_international_payment_sdk/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PaymentResult _paymentResult = PaymentResult(PaymentStatus.unknown, "Result will be shown here");
  final _networkInternationalPaymentSdkPlugin = NetworkInternationalPaymentSdk();


  Future<void> _startCardPayment() async {
    PaymentResult paymentResult;
    try {
      var orderDetails = {'':''};
      var orderDataBase64 = 'eyjfpe......=';
      var merchantId = '';
      final iosTheme = NIThemeIOS(
        cardPreviewColor: "#171618",
        cardPreviewLabelColor: "#FFFFFF",
        payPageBackgroundColor: "#F8F8F8",
        payPageLabelColor: "#000000",
        textFieldLabelColor: "#000000",
        textFieldPlaceholderColor: "#808080",
        payPageDividerColor: "#dbdbdc",
        payButtonBackgroundColor: "#007AFF",
        payButtonTitleColor: "#FFFFFF",
        payButtonActivityIndicatorColor: "#FFFFFF",
        payPageTitleColor: "#000000",
      );

      final result = await _networkInternationalPaymentSdkPlugin.startCardPayment(
        // orderDetails: orderDetails,
        base64orderData: orderDataBase64,
        merchantId: merchantId,
        showOrderAmount: false,
        showCancelAlert: true,
        theme: NITheme(ios: iosTheme)
      );
      paymentResult = result;
    } on PlatformException catch (e) {
      paymentResult = PaymentResult(PaymentStatus.failed, 'Platform error: ${e.message} (${e.details})');
    } catch (e) {
      paymentResult = PaymentResult(PaymentStatus.failed, 'Application error: $e');
    }

    if (!mounted) return;

    setState(() {
      _paymentResult = paymentResult;
    });
  }

  Future<void> _startSavedCardPayment() async {
    PaymentResult paymentResult;
    try {
      var orderDetails = {
        "action": "SALE",
        "amount": {
          "currencyCode": "AED",
          "value": 140
        },
        "savedCard": {
          "maskedPan": "230377******0275",
          "expiry": "2025-08",
          "cardholderName": "test",
          "scheme": "MASTERCARD",
          "cardToken": "card token",
          "recaptureCsc": false
        }
      };
      var merchantId = '';

      final result = await _networkInternationalPaymentSdkPlugin.startSavedCardPayment(
        orderDetails: orderDetails,
        merchantId: merchantId,
      );
      paymentResult = result;
    } on PlatformException catch (e) {
      paymentResult = PaymentResult(PaymentStatus.failed, 'Platform error: ${e.message} (${e.details})');
    } catch (e) {
      paymentResult = PaymentResult(PaymentStatus.failed, 'Application error: $e');
    }

    if (!mounted) return;

    setState(() {
      _paymentResult = paymentResult;
    });
  }

  Future<void> _startApplePayPayment() async {
    PaymentResult paymentResult;
    try {
      var orderDataBase64 = 'eyJfaWQiOiJ1cm46b3JkZXI6ZjY4MmIzZmMtZmY2MS00YTVmLWJkNmMtYzg0OGE2MzY0ODg5IiwiX2xpbmtzIjp7ImNhbmNlbCI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvZjY4MmIzZmMtZmY2MS00YTVmLWJkNmMtYzg0OGE2MzY0ODg5L2NhbmNlbCJ9LCJjbnA6cGF5bWVudC1saW5rIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy9mNjgyYjNmYy1mZjYxLTRhNWYtYmQ2Yy1jODQ4YTYzNjQ4ODkvcGF5bWVudC1saW5rIn0sInBheW1lbnQtYXV0aG9yaXphdGlvbiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9wYXltZW50QXV0aG9yaXphdGlvbiJ9LCJzZWxmIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy9mNjgyYjNmYy1mZjYxLTRhNWYtYmQ2Yy1jODQ4YTYzNjQ4ODkifSwidGVuYW50LWJyYW5kIjp7ImhyZWYiOiJodHRwOi8vY29uZmlnLXNlcnZpY2UvY29uZmlnL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL2NvbmZpZ3MvdGVuYW50LWJyYW5kIn0sInBheW1lbnQiOnsiaHJlZiI6Imh0dHBzOi8vcGF5cGFnZS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tLz9jb2RlPWM5OTg1Zjc0YmM4NTVmMGYifSwibWVyY2hhbnQtYnJhbmQiOnsiaHJlZiI6Imh0dHA6Ly9jb25maWctc2VydmljZS9jb25maWcvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvY29uZmlncy9tZXJjaGFudC1icmFuZCJ9fSwidHlwZSI6IlNJTkdMRSIsIm1lcmNoYW50RGVmaW5lZERhdGEiOnt9LCJhY3Rpb24iOiJTQUxFIiwiYW1vdW50Ijp7ImN1cnJlbmN5Q29kZSI6IkFFRCIsInZhbHVlIjoyMDAwMH0sImxhbmd1YWdlIjoiZW4iLCJtZXJjaGFudEF0dHJpYnV0ZXMiOnt9LCJlbWFpbEFkZHJlc3MiOiJvbWFyLnN1aGFpbC5oYXNhbkBnbWFpbC5jb20iLCJyZWZlcmVuY2UiOiJmNjgyYjNmYy1mZjYxLTRhNWYtYmQ2Yy1jODQ4YTYzNjQ4ODkiLCJvdXRsZXRJZCI6Ijc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MCIsImNyZWF0ZURhdGVUaW1lIjoiMjAyNS0xMS0yNFQxMToyNjo0MC4yMjM2ODEyMjRaIiwicGF5bWVudE1ldGhvZHMiOnsiY2FyZCI6WyJNQVNURVJDQVJEIiwiVklTQSJdLCJ3YWxsZXQiOlsiQVBQTEVfUEFZIl19LCJiaWxsaW5nQWRkcmVzcyI6eyJmaXJzdE5hbWUiOiJvbWFyIiwibGFzdE5hbWUiOiJoYXNhbiJ9LCJzaGlwcGluZ0FkZHJlc3MiOnsiZmlyc3ROYW1lIjoib21hciIsImxhc3ROYW1lIjoiaGFzYW4ifSwicmVmZXJyZXIiOiJ1cm46RWNvbTpmNjgyYjNmYy1mZjYxLTRhNWYtYmQ2Yy1jODQ4YTYzNjQ4ODkiLCJtZXJjaGFudE9yZGVyUmVmZXJlbmNlIjoiUElNTlAzVkI3QyIsIm1lcmNoYW50RGV0YWlscyI6eyJyZWZlcmVuY2UiOiIzMWJlM2UxZC02NTI4LTQ0ZTAtODg1My1iMGM4YTI0NmJkZTAiLCJuYW1lIjoiRU5PQyBMaW5rIiwiY29tcGFueVVybCI6Imh0dHBzOi8vd3d3Lm5ldHdvcmsuYWUiLCJlbWFpbCI6ImRhbmllbEBlbm9jbGluay5hZSIsIm1vYmlsZSI6Iis5NzE1NjQyMjk4NDIifSwiaXNTcGxpdFBheW1lbnQiOmZhbHNlLCJpc1NhbXN1bmdQYXlWMiI6ZmFsc2UsImlzU2F1ZGlQYXltZW50RW5hYmxlZCI6ZmFsc2UsInBheW91dERldGFpbHMiOnsiZXJyb3IiOiJQYXlvdXRzIHZpYSBnYXRld2F5IGlzIGRpc2FibGVkIn0sImZvcm1hdHRlZE9yZGVyU3VtbWFyeSI6e30sImZvcm1hdHRlZEFtb3VudCI6ItivLtilLuKAjyAyMDAiLCJmb3JtYXR0ZWRPcmlnaW5hbEFtb3VudCI6IiIsIl9lbWJlZGRlZCI6eyJwYXltZW50IjpbeyJfaWQiOiJ1cm46cGF5bWVudDoxZDBjYjQyYS03NDY2LTRiOTYtODg5ZS1iNDhlNmZjMzk4N2MiLCJfbGlua3MiOnsiY25wOmFwcGxlX3BheV93ZWJfdmFsaWRhdGVfc2Vzc2lvbiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvZjY4MmIzZmMtZmY2MS00YTVmLWJkNmMtYzg0OGE2MzY0ODg5L3BheW1lbnRzLzFkMGNiNDJhLTc0NjYtNGI5Ni04ODllLWI0OGU2ZmMzOTg3Yy9hcHBsZS1wYXkvdmFsaWRhdGUtc2Vzc2lvbiJ9LCJwYXltZW50OmFwcGxlX3BheSI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvZjY4MmIzZmMtZmY2MS00YTVmLWJkNmMtYzg0OGE2MzY0ODg5L3BheW1lbnRzLzFkMGNiNDJhLTc0NjYtNGI5Ni04ODllLWI0OGU2ZmMzOTg3Yy9hcHBsZS1wYXkifSwic2VsZiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvZjY4MmIzZmMtZmY2MS00YTVmLWJkNmMtYzg0OGE2MzY0ODg5L3BheW1lbnRzLzFkMGNiNDJhLTc0NjYtNGI5Ni04ODllLWI0OGU2ZmMzOTg3YyJ9LCJwYXltZW50OmNhcmQiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvb3JkZXJzL2Y2ODJiM2ZjLWZmNjEtNGE1Zi1iZDZjLWM4NDhhNjM2NDg4OS9wYXltZW50cy8xZDBjYjQyYS03NDY2LTRiOTYtODg5ZS1iNDhlNmZjMzk4N2MvY2FyZCJ9LCJwYXltZW50OnNhdmVkLWNhcmQiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvb3JkZXJzL2Y2ODJiM2ZjLWZmNjEtNGE1Zi1iZDZjLWM4NDhhNjM2NDg4OS9wYXltZW50cy8xZDBjYjQyYS03NDY2LTRiOTYtODg5ZS1iNDhlNmZjMzk4N2Mvc2F2ZWQtY2FyZCJ9LCJjdXJpZXMiOlt7Im5hbWUiOiJjbnAiLCJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL2RvY3MvcmVscy97cmVsfSIsInRlbXBsYXRlZCI6dHJ1ZX1dfSwicmVmZXJlbmNlIjoiMWQwY2I0MmEtNzQ2Ni00Yjk2LTg4OWUtYjQ4ZTZmYzM5ODdjIiwic3RhdGUiOiJTVEFSVEVEIiwiYW1vdW50Ijp7ImN1cnJlbmN5Q29kZSI6IkFFRCIsInZhbHVlIjoyMDAwMH0sInVwZGF0ZURhdGVUaW1lIjoiMjAyNS0xMS0yNFQxMToyNjo0MC4yMjM2ODEyMjRaIiwib3V0bGV0SWQiOiI3N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAiLCJvcmRlclJlZmVyZW5jZSI6ImY2ODJiM2ZjLWZmNjEtNGE1Zi1iZDZjLWM4NDhhNjM2NDg4OSIsIm1lcmNoYW50T3JkZXJSZWZlcmVuY2UiOiJQSU1OUDNWQjdDIn1dfX0=';

      // 1. Create the Apple Pay Configuration
      final applePayConfig = PKPaymentRequest(
        merchantIdentifier: 'merchant.ae.enoc.dev', // IMPORTANT: Replace with your actual merchant ID
        countryCode: 'AE',
        currencyCode: 'AED',
        paymentSummaryItems: [
          // PKPaymentSummaryItem(label: 'Test Item', amount: 100.0),
          // PKPaymentSummaryItem(label: 'ENOC', amount: 100.0),
        ],
      );

      // 2. Call the plugin method
      final result = await _networkInternationalPaymentSdkPlugin.startApplePay(
        base64orderData: orderDataBase64,
        applePayConfig: applePayConfig,
      );
      paymentResult = result;
    } on PlatformException catch (e) {
      paymentResult = PaymentResult(PaymentStatus.failed, 'Platform error: ${e.message} (${e.details})');
    } catch (e) {
      paymentResult = PaymentResult(PaymentStatus.failed, 'Application error: $e');
    }

    if (!mounted) return;

    setState(() {
      _paymentResult = paymentResult;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin Network International Payment Sdk'),
        ),
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const .all(16.0),
                child: Column(
                  crossAxisAlignment: .center,
                  mainAxisSize: .max,
                  mainAxisAlignment: .center,
                  children: [
                    ElevatedButton(
                      onPressed: _startCardPayment,
                      child: const Text('Start card Payment'),
                    ),
                    ElevatedButton(
                      onPressed: _startSavedCardPayment,
                      child: const Text('Start saved card Payment'),
                    ),
                    ElevatedButton(
                      onPressed: _startApplePayPayment,
                      child: const Text('Start Apple Pay Payment'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Payment Result:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_paymentResult.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

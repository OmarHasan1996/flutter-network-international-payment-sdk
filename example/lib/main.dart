import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:network_international_payment_sdk/apple_pay_config.dart';
import 'package:network_international_payment_sdk/google_pay_config.dart';
import 'package:network_international_payment_sdk/samsung_pay_config.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';
import 'package:network_international_payment_sdk/payment_result.dart';
import 'package:network_international_payment_sdk/payment_status.dart';
import 'package:network_international_payment_sdk/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
  final _orderDataBase64 = 'eyJfaWQiOiJ1cm46b3JkZXI6NmJhNGZmMjItY2U1Zi00ODI2LTg2ZTAtNzNjODJjMGIzNzcxIiwiX2xpbmtzIjp7ImNhbmNlbCI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvNmJhNGZmMjItY2U1Zi00ODI2LTg2ZTAtNzNjODJjMGIzNzcxL2NhbmNlbCJ9LCJjbnA6cGF5bWVudC1saW5rIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy82YmE0ZmYyMi1jZTVmLTQ4MjYtODZlMC03M2M4MmMwYjM3NzEvcGF5bWVudC1saW5rIn0sInBheW1lbnQtYXV0aG9yaXphdGlvbiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9wYXltZW50QXV0aG9yaXphdGlvbiJ9LCJzZWxmIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy82YmE0ZmYyMi1jZTVmLTQ4MjYtODZlMC03M2M4MmMwYjM3NzEifSwidGVuYW50LWJyYW5kIjp7ImhyZWYiOiJodHRwOi8vY29uZmlnLXNlcnZpY2UvY29uZmlnL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL2NvbmZpZ3MvdGVuYW50LWJyYW5kIn0sInBheW1lbnQiOnsiaHJlZiI6Imh0dHBzOi8vcGF5cGFnZS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tLz9jb2RlPWY4YmU4NWYyYTQzNmY3YzkifSwibWVyY2hhbnQtYnJhbmQiOnsiaHJlZiI6Imh0dHA6Ly9jb25maWctc2VydmljZS9jb25maWcvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvY29uZmlncy9tZXJjaGFudC1icmFuZCJ9fSwidHlwZSI6IlNJTkdMRSIsIm1lcmNoYW50RGVmaW5lZERhdGEiOnt9LCJhY3Rpb24iOiJTQUxFIiwiYW1vdW50Ijp7ImN1cnJlbmN5Q29kZSI6IkFFRCIsInZhbHVlIjo1MDAwMH0sImxhbmd1YWdlIjoiZW4iLCJtZXJjaGFudEF0dHJpYnV0ZXMiOnt9LCJlbWFpbEFkZHJlc3MiOiJvbWFyLnN1aGFpbC5oYXNhbkBnbWFpbC5jb20iLCJyZWZlcmVuY2UiOiI2YmE0ZmYyMi1jZTVmLTQ4MjYtODZlMC03M2M4MmMwYjM3NzEiLCJvdXRsZXRJZCI6Ijc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MCIsImNyZWF0ZURhdGVUaW1lIjoiMjAyNS0xMi0wNVQwNToyMjowMy41Mzg4Njc5OTdaIiwicGF5bWVudE1ldGhvZHMiOnsiY2FyZCI6WyJNQVNURVJDQVJEIiwiVklTQSJdLCJ3YWxsZXQiOlsiQVBQTEVfUEFZIl19LCJiaWxsaW5nQWRkcmVzcyI6eyJmaXJzdE5hbWUiOiJvbWFyIiwibGFzdE5hbWUiOiJoYXNhbiJ9LCJzaGlwcGluZ0FkZHJlc3MiOnsiZmlyc3ROYW1lIjoib21hciIsImxhc3ROYW1lIjoiaGFzYW4ifSwicmVmZXJyZXIiOiJ1cm46RWNvbTo2YmE0ZmYyMi1jZTVmLTQ4MjYtODZlMC03M2M4MmMwYjM3NzEiLCJtZXJjaGFudE9yZGVyUmVmZXJlbmNlIjoiUEkwU0ZCR1ZaOCIsIm1lcmNoYW50RGV0YWlscyI6eyJyZWZlcmVuY2UiOiIzMWJlM2UxZC02NTI4LTQ0ZTAtODg1My1iMGM4YTI0NmJkZTAiLCJuYW1lIjoiRU5PQyBMaW5rIiwiY29tcGFueVVybCI6Imh0dHBzOi8vd3d3Lm5ldHdvcmsuYWUiLCJlbWFpbCI6ImRhbmllbEBlbm9jbGluay5hZSIsIm1vYmlsZSI6Iis5NzE1NjQyMjk4NDIifSwiaXNTcGxpdFBheW1lbnQiOmZhbHNlLCJpc1NhbXN1bmdQYXlWMiI6ZmFsc2UsImlzU2F1ZGlQYXltZW50RW5hYmxlZCI6ZmFsc2UsInBheW91dERldGFpbHMiOnsiZXJyb3IiOiJQYXlvdXRzIHZpYSBnYXRld2F5IGlzIGRpc2FibGVkIn0sImZvcm1hdHRlZE9yZGVyU3VtbWFyeSI6e30sImZvcm1hdHRlZEFtb3VudCI6ItivLtilLuKAjyA1MDAiLCJmb3JtYXR0ZWRPcmlnaW5hbEFtb3VudCI6IiIsIl9lbWJlZGRlZCI6eyJwYXltZW50IjpbeyJfaWQiOiJ1cm46cGF5bWVudDo3YmE0MGEzZC1mMjhmLTRiNGQtYmIzZi0xYWIyMGRmN2VkNzgiLCJfbGlua3MiOnsiY25wOmFwcGxlX3BheV93ZWJfdmFsaWRhdGVfc2Vzc2lvbiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvNmJhNGZmMjItY2U1Zi00ODI2LTg2ZTAtNzNjODJjMGIzNzcxL3BheW1lbnRzLzdiYTQwYTNkLWYyOGYtNGI0ZC1iYjNmLTFhYjIwZGY3ZWQ3OC9hcHBsZS1wYXkvdmFsaWRhdGUtc2Vzc2lvbiJ9LCJwYXltZW50OmFwcGxlX3BheSI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvNmJhNGZmMjItY2U1Zi00ODI2LTg2ZTAtNzNjODJjMGIzNzcxL3BheW1lbnRzLzdiYTQwYTNkLWYyOGYtNGI0ZC1iYjNmLTFhYjIwZGY3ZWQ3OC9hcHBsZS1wYXkifSwic2VsZiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvNmJhNGZmMjItY2U1Zi00ODI2LTg2ZTAtNzNjODJjMGIzNzcxL3BheW1lbnRzLzdiYTQwYTNkLWYyOGYtNGI0ZC1iYjNmLTFhYjIwZGY3ZWQ3OCJ9LCJwYXltZW50OmNhcmQiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvb3JkZXJzLzZiYTRmZjIyLWNlNWYtNDgyNi04NmUwLTczYzgyYzBiMzc3MS9wYXltZW50cy83YmE0MGEzZC1mMjhmLTRiNGQtYmIzZi0xYWIyMGRmN2VkNzgvY2FyZCJ9LCJwYXltZW50OnNhdmVkLWNhcmQiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvb3JkZXJzLzZiYTRmZjIyLWNlNWYtNDgyNi04NmUwLTczYzgyYzBiMzc3MS9wYXltZW50cy83YmE0MGEzZC1mMjhmLTRiNGQtYmIzZi0xYWIyMGRmN2VkNzgvc2F2ZWQtY2FyZCJ9LCJjdXJpZXMiOlt7Im5hbWUiOiJjbnAiLCJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL2RvY3MvcmVscy97cmVsfSIsInRlbXBsYXRlZCI6dHJ1ZX1dfSwicmVmZXJlbmNlIjoiN2JhNDBhM2QtZjI4Zi00YjRkLWJiM2YtMWFiMjBkZjdlZDc4Iiwic3RhdGUiOiJTVEFSVEVEIiwiYW1vdW50Ijp7ImN1cnJlbmN5Q29kZSI6IkFFRCIsInZhbHVlIjo1MDAwMH0sInVwZGF0ZURhdGVUaW1lIjoiMjAyNS0xMi0wNVQwNToyMjowMy41Mzg4Njc5OTdaIiwib3V0bGV0SWQiOiI3N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAiLCJvcmRlclJlZmVyZW5jZSI6IjZiYTRmZjIyLWNlNWYtNDgyNi04NmUwLTczYzgyYzBiMzc3MSIsIm1lcmNoYW50T3JkZXJSZWZlcmVuY2UiOiJQSTBTRkJHVlo4In1dfX0=';


  Future<void> _startCardPayment({bool withGooglePay = false}) async {
    PaymentResult paymentResult;
    try {
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

      final googlePayConfig = withGooglePay && Platform.isAndroid
          ? GooglePayConfig(
              environment: GooglePayEnvironment.test,
              merchantGatewayId: 'YOUR_GOOGLE_PAY_GATEWAY_MERCHANT_ID', // Replace with your ID
              isEmailRequired: false,
              billingAddressConfig: BillingAddressConfig(isRequired: false, isPhoneNumberRequired: false)
            )
          : null;

      final result = await _networkInternationalPaymentSdkPlugin.startCardPayment(
        base64orderData: _orderDataBase64,
        showOrderAmount: false,
        showCancelAlert: true,
        theme: NITheme(ios: iosTheme),
        googlePayConfig: googlePayConfig,
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

      final result = await _networkInternationalPaymentSdkPlugin.startSavedCardPayment(
        orderDetails: orderDetails,
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

      final applePayConfig = PKPaymentRequest(
        merchantIdentifier: 'your_apple-merchant-identifier', // IMPORTANT: Replace with your actual merchant ID
        countryCode: 'AE',
        currencyCode: 'AED',
        paymentSummaryItems: [
        ],
      );

      final result = await _networkInternationalPaymentSdkPlugin.startApplePay(
        base64orderData: _orderDataBase64,
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
  Future<void> _startSamsungPayPayment() async {
    PaymentResult paymentResult;
    try {
      final samsungPayConfig = SamsungPayConfig(
        serviceId: 'YOUR_SAMSUNG_PAY_SERVICE_ID', // Replace with your ID
        merchantName: 'Your Merchant Name',
      );

      final result = await _networkInternationalPaymentSdkPlugin.startSamsungPay(
        base64orderData: _orderDataBase64,
        samsungPayConfig: samsungPayConfig,
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
                      onPressed: ()=>_startCardPayment(withGooglePay: true),
                      child: const Text('Start card Payment with Google Pay'),
                    ),
                    ElevatedButton(
                      onPressed: _startSavedCardPayment,
                      child: const Text('Start saved card Payment'),
                    ),
                    ElevatedButton(
                      onPressed: _startApplePayPayment,
                      child: const Text('Start Apple Pay Payment'),
                    ),
                    ElevatedButton(
                      onPressed: _startSamsungPayPayment,
                      child: const Text('Start Samsung Pay Payment'),
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

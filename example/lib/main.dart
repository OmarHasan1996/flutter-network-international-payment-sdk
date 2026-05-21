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
  final _orderDataBase64 = 'eyJfaWQiOiJ1cm46b3JkZXI6YjI5MzRlNTEtNDg5Zi00NTJhLTgwNDQtZjUzYjA3NzQzOTFlIiwiX2xpbmtzIjp7ImNhbmNlbCI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvYjI5MzRlNTEtNDg5Zi00NTJhLTgwNDQtZjUzYjA3NzQzOTFlL2NhbmNlbCJ9LCJjbnA6cGF5bWVudC1saW5rIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy9iMjkzNGU1MS00ODlmLTQ1MmEtODA0NC1mNTNiMDc3NDM5MWUvcGF5bWVudC1saW5rIn0sInBheW1lbnQtYXV0aG9yaXphdGlvbiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9wYXltZW50QXV0aG9yaXphdGlvbiJ9LCJzZWxmIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy9iMjkzNGU1MS00ODlmLTQ1MmEtODA0NC1mNTNiMDc3NDM5MWUifSwidGVuYW50LWJyYW5kIjp7ImhyZWYiOiJodHRwOi8vY29uZmlnLXNlcnZpY2UvY29uZmlnL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL2NvbmZpZ3MvdGVuYW50LWJyYW5kIn0sInBheW1lbnQiOnsiaHJlZiI6Imh0dHBzOi8vcGF5cGFnZS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3YyP2NvZGU9OWQyNzgzMTExNjAyM2YyOSJ9LCJtZXJjaGFudC1icmFuZCI6eyJocmVmIjoiaHR0cDovL2NvbmZpZy1zZXJ2aWNlL2NvbmZpZy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9jb25maWdzL21lcmNoYW50LWJyYW5kIn19LCJzYXZlZENhcmQiOnsibWFza2VkUGFuIjoiNDAwMDAwKioqKioqMDAwMiIsImV4cGlyeSI6IjIwMzItMTIiLCJjYXJkaG9sZGVyTmFtZSI6Im9tYXIiLCJzY2hlbWUiOiJWSVNBIiwiY2FyZFRva2VuIjoiZEc5clpXNXBlbVZrVUdGdUx5OTJNUzh2VTBoUFYxOU9UMDVGTHk4d01EQXdNREF3TkRJd01EQXdNREF3IiwicmVjYXB0dXJlQ3NjIjp0cnVlfSwidHlwZSI6IlNJTkdMRSIsIm1lcmNoYW50RGVmaW5lZERhdGEiOnt9LCJhY3Rpb24iOiJTQUxFIiwiYW1vdW50Ijp7ImN1cnJlbmN5Q29kZSI6IkFFRCIsInZhbHVlIjo1MDAwMH0sImxhbmd1YWdlIjoiZW4iLCJtZXJjaGFudEF0dHJpYnV0ZXMiOnt9LCJlbWFpbEFkZHJlc3MiOiJvbWFyLnN1aGFpbC5oYXNhbkBnbWFpbC5jb20iLCJyZWZlcmVuY2UiOiJiMjkzNGU1MS00ODlmLTQ1MmEtODA0NC1mNTNiMDc3NDM5MWUiLCJvdXRsZXRJZCI6Ijc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MCIsImNyZWF0ZURhdGVUaW1lIjoiMjAyNi0wNS0yMVQwNzozNTowMC44Njc1OTYyOTZaIiwicGF5bWVudE1ldGhvZHMiOnsiY2FyZCI6WyJNQVNURVJDQVJEIiwiVklTQSJdLCJ3YWxsZXQiOlsiQVBQTEVfUEFZIl19LCJiaWxsaW5nQWRkcmVzcyI6eyJmaXJzdE5hbWUiOiJvbWFyIiwibGFzdE5hbWUiOiJoYXNhbiJ9LCJzaGlwcGluZ0FkZHJlc3MiOnsiZmlyc3ROYW1lIjoib21hciIsImxhc3ROYW1lIjoiaGFzYW4ifSwicmVmZXJyZXIiOiJ1cm46RWNvbTpiMjkzNGU1MS00ODlmLTQ1MmEtODA0NC1mNTNiMDc3NDM5MWUiLCJtZXJjaGFudE9yZGVyUmVmZXJlbmNlIjoiUElCRktYMFcyUSIsIm1lcmNoYW50RGV0YWlscyI6eyJyZWZlcmVuY2UiOiIzMWJlM2UxZC02NTI4LTQ0ZTAtODg1My1iMGM4YTI0NmJkZTAiLCJuYW1lIjoiRU5PQyBMaW5rIiwiY29tcGFueVVybCI6Imh0dHBzOi8vd3d3Lm5ldHdvcmsuYWUiLCJlbWFpbCI6ImRhbmllbEBlbm9jbGluay5hZSIsIm1vYmlsZSI6Iis5NzE1NjQyMjk4NDIifSwiaXNTcGxpdFBheW1lbnQiOmZhbHNlLCJpc1NhbXN1bmdQYXlWMiI6ZmFsc2UsImlzU2F1ZGlQYXltZW50RW5hYmxlZCI6ZmFsc2UsInBheW91dERldGFpbHMiOnsic3RhdHVzIjoiUGF5b3V0cyB2aWEgZ2F0ZXdheSBpcyBkaXNhYmxlZCJ9LCJmb3JtYXR0ZWRPcmRlclN1bW1hcnkiOnt9LCJmb3JtYXR0ZWRBbW91bnQiOiLYry7YpS7igI8gNTAwIiwiZm9ybWF0dGVkT3JpZ2luYWxBbW91bnQiOiIiLCJfZW1iZWRkZWQiOnsicGF5bWVudCI6W3siX2lkIjoidXJuOnBheW1lbnQ6MzNmNzRkZjEtZjFjYS00Njg3LWIyOGItNWU4M2MzZjk5Y2I1IiwiX2xpbmtzIjp7ImNucDphcHBsZV9wYXlfd2ViX3ZhbGlkYXRlX3Nlc3Npb24iOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvb3JkZXJzL2IyOTM0ZTUxLTQ4OWYtNDUyYS04MDQ0LWY1M2IwNzc0MzkxZS9wYXltZW50cy8zM2Y3NGRmMS1mMWNhLTQ2ODctYjI4Yi01ZTgzYzNmOTljYjUvYXBwbGUtcGF5L3ZhbGlkYXRlLXNlc3Npb24ifSwicGF5bWVudDphcHBsZV9wYXkiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvb3JkZXJzL2IyOTM0ZTUxLTQ4OWYtNDUyYS04MDQ0LWY1M2IwNzc0MzkxZS9wYXltZW50cy8zM2Y3NGRmMS1mMWNhLTQ2ODctYjI4Yi01ZTgzYzNmOTljYjUvYXBwbGUtcGF5In0sInNlbGYiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvb3JkZXJzL2IyOTM0ZTUxLTQ4OWYtNDUyYS04MDQ0LWY1M2IwNzc0MzkxZS9wYXltZW50cy8zM2Y3NGRmMS1mMWNhLTQ2ODctYjI4Yi01ZTgzYzNmOTljYjUifSwicGF5bWVudDpjYXJkIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy9iMjkzNGU1MS00ODlmLTQ1MmEtODA0NC1mNTNiMDc3NDM5MWUvcGF5bWVudHMvMzNmNzRkZjEtZjFjYS00Njg3LWIyOGItNWU4M2MzZjk5Y2I1L2NhcmQifSwicGF5bWVudDpzYXZlZC1jYXJkIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy9iMjkzNGU1MS00ODlmLTQ1MmEtODA0NC1mNTNiMDc3NDM5MWUvcGF5bWVudHMvMzNmNzRkZjEtZjFjYS00Njg3LWIyOGItNWU4M2MzZjk5Y2I1L3NhdmVkLWNhcmQifSwiY3VyaWVzIjpbeyJuYW1lIjoiY25wIiwiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS9kb2NzL3JlbHMve3JlbH0iLCJ0ZW1wbGF0ZWQiOnRydWV9XX0sInJlZmVyZW5jZSI6IjMzZjc0ZGYxLWYxY2EtNDY4Ny1iMjhiLTVlODNjM2Y5OWNiNSIsInN0YXRlIjoiU1RBUlRFRCIsImFtb3VudCI6eyJjdXJyZW5jeUNvZGUiOiJBRUQiLCJ2YWx1ZSI6NTAwMDB9LCJ1cGRhdGVEYXRlVGltZSI6IjIwMjYtMDUtMjFUMDc6MzU6MDAuODY3NTk2Mjk2WiIsIm91dGxldElkIjoiNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwIiwib3JkZXJSZWZlcmVuY2UiOiJiMjkzNGU1MS00ODlmLTQ1MmEtODA0NC1mNTNiMDc3NDM5MWUiLCJtZXJjaGFudE9yZGVyUmVmZXJlbmNlIjoiUElCRktYMFcyUSJ9XX19';


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
              merchantGatewayId: 'YOUR_GOOGLE_PAY_GATEWAY_ERCHANT_ID', // Replace with your I
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
        merchantIdentifier: 'merchant.ae.enoc.staging', // IMPORTANT: Replace with your actual merchant ID
        countryCode: 'AE',
        currencyCode: 'AED',
        paymentSummaryItems: [
          PKPaymentSummaryItem(label: 'Subtotal', amount: 500.0),
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

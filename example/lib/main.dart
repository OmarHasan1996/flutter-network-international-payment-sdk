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
  final _orderDataBase64 = 'eyJfaWQiOiJ1cm46b3JkZXI6ZTYwYzFlYjctMTJkOS00NDgzLWI1NWYtYTNmNzJkYTU3MGRhIiwiX2xpbmtzIjp7ImNhbmNlbCI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzZjOTFkNjc1LTBkNDgtNGZlNC1iNzExLTZkNWU3YTIyOGNhMS9vcmRlcnMvZTYwYzFlYjctMTJkOS00NDgzLWI1NWYtYTNmNzJkYTU3MGRhL2NhbmNlbCJ9LCJjbnA6cGF5bWVudC1saW5rIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNmM5MWQ2NzUtMGQ0OC00ZmU0LWI3MTEtNmQ1ZTdhMjI4Y2ExL29yZGVycy9lNjBjMWViNy0xMmQ5LTQ0ODMtYjU1Zi1hM2Y3MmRhNTcwZGEvcGF5bWVudC1saW5rIn0sInBheW1lbnQtYXV0aG9yaXphdGlvbiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9wYXltZW50QXV0aG9yaXphdGlvbiJ9LCJzZWxmIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNmM5MWQ2NzUtMGQ0OC00ZmU0LWI3MTEtNmQ1ZTdhMjI4Y2ExL29yZGVycy9lNjBjMWViNy0xMmQ5LTQ0ODMtYjU1Zi1hM2Y3MmRhNTcwZGEifSwidGVuYW50LWJyYW5kIjp7ImhyZWYiOiJodHRwOi8vY29uZmlnLXNlcnZpY2UvY29uZmlnL291dGxldHMvNmM5MWQ2NzUtMGQ0OC00ZmU0LWI3MTEtNmQ1ZTdhMjI4Y2ExL2NvbmZpZ3MvdGVuYW50LWJyYW5kIn0sInBheW1lbnQiOnsiaHJlZiI6Imh0dHBzOi8vcGF5cGFnZS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3YyP2NvZGU9YjliODQwZjFhYTVjMmI3ZCJ9LCJtZXJjaGFudC1icmFuZCI6eyJocmVmIjoiaHR0cDovL2NvbmZpZy1zZXJ2aWNlL2NvbmZpZy9vdXRsZXRzLzZjOTFkNjc1LTBkNDgtNGZlNC1iNzExLTZkNWU3YTIyOGNhMS9jb25maWdzL21lcmNoYW50LWJyYW5kIn19LCJ0eXBlIjoiU0lOR0xFIiwibWVyY2hhbnREZWZpbmVkRGF0YSI6e30sImFjdGlvbiI6IlNBTEUiLCJhbW91bnQiOnsiY3VycmVuY3lDb2RlIjoiQUVEIiwidmFsdWUiOjUwMDAwfSwibGFuZ3VhZ2UiOiJlbiIsIm1lcmNoYW50QXR0cmlidXRlcyI6e30sImVtYWlsQWRkcmVzcyI6Im9tYXIuc3VoYWlsLmhhc2FuQGdtYWlsLmNvbSIsInJlZmVyZW5jZSI6ImU2MGMxZWI3LTEyZDktNDQ4My1iNTVmLWEzZjcyZGE1NzBkYSIsIm91dGxldElkIjoiNmM5MWQ2NzUtMGQ0OC00ZmU0LWI3MTEtNmQ1ZTdhMjI4Y2ExIiwiY3JlYXRlRGF0ZVRpbWUiOiIyMDI2LTAyLTI3VDA1OjA0OjE5LjU0NDA2NDAyMFoiLCJwYXltZW50TWV0aG9kcyI6eyJjYXJkIjpbIk1BU1RFUkNBUkQiLCJWSVNBIl0sIndhbGxldCI6WyJBUFBMRV9QQVkiXX0sImJpbGxpbmdBZGRyZXNzIjp7ImZpcnN0TmFtZSI6Ik9tYXIiLCJsYXN0TmFtZSI6Ikhhc2FuIn0sInNoaXBwaW5nQWRkcmVzcyI6eyJmaXJzdE5hbWUiOiJPbWFyIiwibGFzdE5hbWUiOiJIYXNhbiJ9LCJyZWZlcnJlciI6InVybjpFY29tOmU2MGMxZWI3LTEyZDktNDQ4My1iNTVmLWEzZjcyZGE1NzBkYSIsIm1lcmNoYW50T3JkZXJSZWZlcmVuY2UiOiJQSUZTOFBHNUhLIiwibWVyY2hhbnREZXRhaWxzIjp7InJlZmVyZW5jZSI6ImRiNGY2OTY4LTE3NDctNGFjZS1hYzQxLWIxYjNlMTJkY2QzYiIsIm5hbWUiOiJFTk9DIExpbmsgTExDIiwiY29tcGFueVVybCI6Imh0dHBzOi8vd3d3LmVub2NsaW5rLmFlIiwiZW1haWwiOiJyYXNoaWQua2hvb3J5QGVwcGNvdWFlLmNvbSIsIm1vYmlsZSI6Iis5NzE1NTg4Mzk4NDcifSwiaXNTcGxpdFBheW1lbnQiOmZhbHNlLCJpc1NhbXN1bmdQYXlWMiI6ZmFsc2UsImlzU2F1ZGlQYXltZW50RW5hYmxlZCI6ZmFsc2UsInBheW91dERldGFpbHMiOnsic3RhdHVzIjoiUGF5b3V0cyB2aWEgZ2F0ZXdheSBpcyBkaXNhYmxlZCJ9LCJmb3JtYXR0ZWRPcmRlclN1bW1hcnkiOnt9LCJmb3JtYXR0ZWRBbW91bnQiOiLYry7YpS7igI8gNTAwIiwiZm9ybWF0dGVkT3JpZ2luYWxBbW91bnQiOiIiLCJfZW1iZWRkZWQiOnsicGF5bWVudCI6W3siX2lkIjoidXJuOnBheW1lbnQ6ZTQ2NDAyMWUtYzQzMi00YzNhLTk5OGYtOWVjYzcwZjdhZjMyIiwiX2xpbmtzIjp7ImNucDphcHBsZV9wYXlfd2ViX3ZhbGlkYXRlX3Nlc3Npb24iOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy82YzkxZDY3NS0wZDQ4LTRmZTQtYjcxMS02ZDVlN2EyMjhjYTEvb3JkZXJzL2U2MGMxZWI3LTEyZDktNDQ4My1iNTVmLWEzZjcyZGE1NzBkYS9wYXltZW50cy9lNDY0MDIxZS1jNDMyLTRjM2EtOTk4Zi05ZWNjNzBmN2FmMzIvYXBwbGUtcGF5L3ZhbGlkYXRlLXNlc3Npb24ifSwicGF5bWVudDphcHBsZV9wYXkiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy82YzkxZDY3NS0wZDQ4LTRmZTQtYjcxMS02ZDVlN2EyMjhjYTEvb3JkZXJzL2U2MGMxZWI3LTEyZDktNDQ4My1iNTVmLWEzZjcyZGE1NzBkYS9wYXltZW50cy9lNDY0MDIxZS1jNDMyLTRjM2EtOTk4Zi05ZWNjNzBmN2FmMzIvYXBwbGUtcGF5In0sInNlbGYiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy82YzkxZDY3NS0wZDQ4LTRmZTQtYjcxMS02ZDVlN2EyMjhjYTEvb3JkZXJzL2U2MGMxZWI3LTEyZDktNDQ4My1iNTVmLWEzZjcyZGE1NzBkYS9wYXltZW50cy9lNDY0MDIxZS1jNDMyLTRjM2EtOTk4Zi05ZWNjNzBmN2FmMzIifSwicGF5bWVudDpjYXJkIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNmM5MWQ2NzUtMGQ0OC00ZmU0LWI3MTEtNmQ1ZTdhMjI4Y2ExL29yZGVycy9lNjBjMWViNy0xMmQ5LTQ0ODMtYjU1Zi1hM2Y3MmRhNTcwZGEvcGF5bWVudHMvZTQ2NDAyMWUtYzQzMi00YzNhLTk5OGYtOWVjYzcwZjdhZjMyL2NhcmQifSwicGF5bWVudDpzYXZlZC1jYXJkIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNmM5MWQ2NzUtMGQ0OC00ZmU0LWI3MTEtNmQ1ZTdhMjI4Y2ExL29yZGVycy9lNjBjMWViNy0xMmQ5LTQ0ODMtYjU1Zi1hM2Y3MmRhNTcwZGEvcGF5bWVudHMvZTQ2NDAyMWUtYzQzMi00YzNhLTk5OGYtOWVjYzcwZjdhZjMyL3NhdmVkLWNhcmQifSwiY3VyaWVzIjpbeyJuYW1lIjoiY25wIiwiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS9kb2NzL3JlbHMve3JlbH0iLCJ0ZW1wbGF0ZWQiOnRydWV9XX0sInJlZmVyZW5jZSI6ImU0NjQwMjFlLWM0MzItNGMzYS05OThmLTllY2M3MGY3YWYzMiIsInN0YXRlIjoiU1RBUlRFRCIsImFtb3VudCI6eyJjdXJyZW5jeUNvZGUiOiJBRUQiLCJ2YWx1ZSI6NTAwMDB9LCJ1cGRhdGVEYXRlVGltZSI6IjIwMjYtMDItMjdUMDU6MDQ6MTkuNTQ0MDY0MDIwWiIsIm91dGxldElkIjoiNmM5MWQ2NzUtMGQ0OC00ZmU0LWI3MTEtNmQ1ZTdhMjI4Y2ExIiwib3JkZXJSZWZlcmVuY2UiOiJlNjBjMWViNy0xMmQ5LTQ0ODMtYjU1Zi1hM2Y3MmRhNTcwZGEiLCJtZXJjaGFudE9yZGVyUmVmZXJlbmNlIjoiUElGUzhQRzVISyJ9XX19';


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

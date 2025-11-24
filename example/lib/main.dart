import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
      var orderDetails = {
        "_id": "urn:order:76fb9d52-a3ef-42d3-8b4e-90092f57534c",
        "_links": {
          "cnp:payment-link": {
            "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/orders/76fb9d52-a3ef-42d3-8b4e-90092f57534c/payment-link"
          },
          "payment-authorization": {
            "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/paymentAuthorization"
          },
          "self": {
            "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/orders/76fb9d52-a3ef-42d3-8b4e-90092f57534c"
          },
          "tenant-brand": {
            "href": "http://config-service/config/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/configs/tenant-brand"
          },
          "payment": {
            "href": "https://paypage.sandbox.ngenius-payments.com/?code=8ad2daf8bc86d0a9"
          },
          "merchant-brand": {
            "href": "http://config-service/config/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/configs/merchant-brand"
          }
        },
        "action": "PURCHASE",
        "amount": {
          "currencyCode": "AED",
          "value": 1000
        },
        "language": "en",
        "merchantAttributes": {
          "redirectUrl": "https://yoursite.com"
        },
        "emailAddress": "",
        "reference": "76fb9d52-a3ef-42d3-8b4e-90092f57534c",
        "outletId": "5edab6d7-5946-43f4-b8c7-06b29c272bdd",
        "createDateTime": "2019-04-17T08:15:18.912Z",
        "paymentMethods": {
          "card": [
            "DINERS_CLUB_INTERNATIONAL",
            "AMERICAN_EXPRESS",
            "MASTERCARD",
            "MASTERCARD",
            "VISA",
            "VISA"
          ],
          "wallet": [
            "APPLE_PAY",
            "SAMSUNG_PAY"
          ]
        },
        "referrer": "urn:Ecom:76fb9d52-a3ef-42d3-8b4e-90092f57534c",
        "formattedAmount": "د.إ.‏ 10",
        "formattedOrderSummary": {},
        "_embedded": {
          "payment": [
            {
              "_id": "urn:payment:2fff837f-9a39-4a02-8435-9aaa7cb6b558",
              "_links": {
                "payment:apple_pay": {
                  "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/orders/76fb9d52-a3ef-42d3-8b4e-90092f57534c/payments/2fff837f-9a39-4a02-8435-9aaa7cb6b558/apple-pay"
                },
                "self": {
                  "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/orders/76fb9d52-a3ef-42d3-8b4e-90092f57534c/payments/2fff837f-9a39-4a02-8435-9aaa7cb6b558"
                },
                "payment:card": {
                  "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/orders/76fb9d52-a3ef-42d3-8b4e-90092f57534c/payments/2fff837f-9a39-4a02-8435-9aaa7cb6b558/card"
                },
                "payment:samsung_pay": {
                  "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/orders/76fb9d52-a3ef-42d3-8b4e-90092f57534c/payments/2fff837f-9a39-4a02-8435-9aaa7cb6b558/samsung-pay"
                },
                "payment:saved-card": {
                  "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/orders/76fb9d52-a3ef-42d3-8b4e-90092f57534c/payments/2fff837f-9a39-4a02-8435-9aaa7cb6b558/saved-card"
                },
                "curies": [
                  {
                    "name": "cnp",
                    "href": "https://api-gateway.sandbox.ngenius-payments.com/docs/rels/{rel}",
                    "templated": true
                  }
                ]
              },
              "state": "STARTED",
              "amount": {
                "currencyCode": "AED",
                "value": 1000
              },
              "updateDateTime": "2019-04-17T08:15:18.912Z",
              "outletId": "5edab6d7-5946-43f4-b8c7-06b29c272bdd",
              "orderReference": "76fb9d52-a3ef-42d3-8b4e-90092f57534c"
            }
          ]
        }
      };
      var orderDataBase64 = 'eyJfaWQiOiJ1cm46b3JkZXI6MTExZWE3NjQtYmIwZC00NDlkLWEzZDgtNDA2NTYzMDk0YmFjIiwiX2xpbmtzIjp7ImNhbmNlbCI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvMTExZWE3NjQtYmIwZC00NDlkLWEzZDgtNDA2NTYzMDk0YmFjL2NhbmNlbCJ9LCJjbnA6cGF5bWVudC1saW5rIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy8xMTFlYTc2NC1iYjBkLTQ0OWQtYTNkOC00MDY1NjMwOTRiYWMvcGF5bWVudC1saW5rIn0sInBheW1lbnQtYXV0aG9yaXphdGlvbiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9wYXltZW50QXV0aG9yaXphdGlvbiJ9LCJzZWxmIjp7ImhyZWYiOiJodHRwczovL2FwaS1nYXRld2F5LnNhbmRib3gubmdlbml1cy1wYXltZW50cy5jb20vdHJhbnNhY3Rpb25zL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL29yZGVycy8xMTFlYTc2NC1iYjBkLTQ0OWQtYTNkOC00MDY1NjMwOTRiYWMifSwidGVuYW50LWJyYW5kIjp7ImhyZWYiOiJodHRwOi8vY29uZmlnLXNlcnZpY2UvY29uZmlnL291dGxldHMvNzdlYmJjMTgtYWY2Mi00OWNhLTk3MzEtYTNhNmRhYmNmYzgwL2NvbmZpZ3MvdGVuYW50LWJyYW5kIn0sInBheW1lbnQiOnsiaHJlZiI6Imh0dHBzOi8vcGF5cGFnZS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tLz9jb2RlPTI0M2Y3NmUwZjQ3MjU0YTQifSwibWVyY2hhbnQtYnJhbmQiOnsiaHJlZiI6Imh0dHA6Ly9jb25maWctc2VydmljZS9jb25maWcvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvY29uZmlncy9tZXJjaGFudC1icmFuZCJ9fSwidHlwZSI6IlNJTkdMRSIsIm1lcmNoYW50RGVmaW5lZERhdGEiOnt9LCJhY3Rpb24iOiJTQUxFIiwiYW1vdW50Ijp7ImN1cnJlbmN5Q29kZSI6IkFFRCIsInZhbHVlIjoxMDAwMH0sImxhbmd1YWdlIjoiZW4iLCJtZXJjaGFudEF0dHJpYnV0ZXMiOnt9LCJlbWFpbEFkZHJlc3MiOiJvbWFyLnN1aGFpbC5oYXNhbkBnbWFpbC5jb20iLCJyZWZlcmVuY2UiOiIxMTFlYTc2NC1iYjBkLTQ0OWQtYTNkOC00MDY1NjMwOTRiYWMiLCJvdXRsZXRJZCI6Ijc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MCIsImNyZWF0ZURhdGVUaW1lIjoiMjAyNS0xMS0yNFQwNjo1MToyMi42MzgzMTI0NjdaIiwicGF5bWVudE1ldGhvZHMiOnsiY2FyZCI6WyJNQVNURVJDQVJEIiwiVklTQSJdLCJ3YWxsZXQiOlsiQVBQTEVfUEFZIl19LCJiaWxsaW5nQWRkcmVzcyI6eyJmaXJzdE5hbWUiOiJvbWFyIiwibGFzdE5hbWUiOiJoYXNhbiJ9LCJzaGlwcGluZ0FkZHJlc3MiOnsiZmlyc3ROYW1lIjoib21hciIsImxhc3ROYW1lIjoiaGFzYW4ifSwicmVmZXJyZXIiOiJ1cm46RWNvbToxMTFlYTc2NC1iYjBkLTQ0OWQtYTNkOC00MDY1NjMwOTRiYWMiLCJtZXJjaGFudE9yZGVyUmVmZXJlbmNlIjoiUElGTksyUzZCWSIsIm1lcmNoYW50RGV0YWlscyI6eyJyZWZlcmVuY2UiOiIzMWJlM2UxZC02NTI4LTQ0ZTAtODg1My1iMGM4YTI0NmJkZTAiLCJuYW1lIjoiRU5PQyBMaW5rIiwiY29tcGFueVVybCI6Imh0dHBzOi8vd3d3Lm5ldHdvcmsuYWUiLCJlbWFpbCI6ImRhbmllbEBlbm9jbGluay5hZSIsIm1vYmlsZSI6Iis5NzE1NjQyMjk4NDIifSwiaXNTcGxpdFBheW1lbnQiOmZhbHNlLCJpc1NhbXN1bmdQYXlWMiI6ZmFsc2UsImlzU2F1ZGlQYXltZW50RW5hYmxlZCI6ZmFsc2UsInBheW91dERldGFpbHMiOnsiZXJyb3IiOiJQYXlvdXRzIHZpYSBnYXRld2F5IGlzIGRpc2FibGVkIn0sImZvcm1hdHRlZE9yZGVyU3VtbWFyeSI6e30sImZvcm1hdHRlZEFtb3VudCI6ItivLtilLuKAjyAxMDAiLCJmb3JtYXR0ZWRPcmlnaW5hbEFtb3VudCI6IiIsIl9lbWJlZGRlZCI6eyJwYXltZW50IjpbeyJfaWQiOiJ1cm46cGF5bWVudDpkNGMyMzBmMy1iYWY5LTRiOTctOTFiZi0zMWIxNjg1N2MxYjEiLCJfbGlua3MiOnsiY25wOmFwcGxlX3BheV93ZWJfdmFsaWRhdGVfc2Vzc2lvbiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvMTExZWE3NjQtYmIwZC00NDlkLWEzZDgtNDA2NTYzMDk0YmFjL3BheW1lbnRzL2Q0YzIzMGYzLWJhZjktNGI5Ny05MWJmLTMxYjE2ODU3YzFiMS9hcHBsZS1wYXkvdmFsaWRhdGUtc2Vzc2lvbiJ9LCJwYXltZW50OmFwcGxlX3BheSI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvMTExZWE3NjQtYmIwZC00NDlkLWEzZDgtNDA2NTYzMDk0YmFjL3BheW1lbnRzL2Q0YzIzMGYzLWJhZjktNGI5Ny05MWJmLTMxYjE2ODU3YzFiMS9hcHBsZS1wYXkifSwic2VsZiI6eyJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL3RyYW5zYWN0aW9ucy9vdXRsZXRzLzc3ZWJiYzE4LWFmNjItNDljYS05NzMxLWEzYTZkYWJjZmM4MC9vcmRlcnMvMTExZWE3NjQtYmIwZC00NDlkLWEzZDgtNDA2NTYzMDk0YmFjL3BheW1lbnRzL2Q0YzIzMGYzLWJhZjktNGI5Ny05MWJmLTMxYjE2ODU3YzFiMSJ9LCJwYXltZW50OmNhcmQiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvb3JkZXJzLzExMWVhNzY0LWJiMGQtNDQ5ZC1hM2Q4LTQwNjU2MzA5NGJhYy9wYXltZW50cy9kNGMyMzBmMy1iYWY5LTRiOTctOTFiZi0zMWIxNjg1N2MxYjEvY2FyZCJ9LCJwYXltZW50OnNhdmVkLWNhcmQiOnsiaHJlZiI6Imh0dHBzOi8vYXBpLWdhdGV3YXkuc2FuZGJveC5uZ2VuaXVzLXBheW1lbnRzLmNvbS90cmFuc2FjdGlvbnMvb3V0bGV0cy83N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAvb3JkZXJzLzExMWVhNzY0LWJiMGQtNDQ5ZC1hM2Q4LTQwNjU2MzA5NGJhYy9wYXltZW50cy9kNGMyMzBmMy1iYWY5LTRiOTctOTFiZi0zMWIxNjg1N2MxYjEvc2F2ZWQtY2FyZCJ9LCJjdXJpZXMiOlt7Im5hbWUiOiJjbnAiLCJocmVmIjoiaHR0cHM6Ly9hcGktZ2F0ZXdheS5zYW5kYm94Lm5nZW5pdXMtcGF5bWVudHMuY29tL2RvY3MvcmVscy97cmVsfSIsInRlbXBsYXRlZCI6dHJ1ZX1dfSwicmVmZXJlbmNlIjoiZDRjMjMwZjMtYmFmOS00Yjk3LTkxYmYtMzFiMTY4NTdjMWIxIiwic3RhdGUiOiJTVEFSVEVEIiwiYW1vdW50Ijp7ImN1cnJlbmN5Q29kZSI6IkFFRCIsInZhbHVlIjoxMDAwMH0sInVwZGF0ZURhdGVUaW1lIjoiMjAyNS0xMS0yNFQwNjo1MToyMi42MzgzMTI0NjdaIiwib3V0bGV0SWQiOiI3N2ViYmMxOC1hZjYyLTQ5Y2EtOTczMS1hM2E2ZGFiY2ZjODAiLCJvcmRlclJlZmVyZW5jZSI6IjExMWVhNzY0LWJiMGQtNDQ5ZC1hM2Q4LTQwNjU2MzA5NGJhYyIsIm1lcmNoYW50T3JkZXJSZWZlcmVuY2UiOiJQSUZOSzJTNkJZIn1dfX0=';
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
        orderDetails: orderDetails,
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

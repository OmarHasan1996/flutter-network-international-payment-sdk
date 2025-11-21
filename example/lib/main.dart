import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';
import 'package:network_international_payment_sdk/payment_result.dart';
import 'package:network_international_payment_sdk/payment_status.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PaymentResult _paymentResult = PaymentResult(PaymentStatus.UNKNOWN, "Result will be shown here");
  final _networkInternationalPaymentSdkPlugin = NetworkInternationalPaymentSdk();


  Future<void> _startCardPayment() async {
    PaymentResult paymentResult;
    try {
      var orderDetails = {'': ''};
      var orderDataBase64 = '';
      var merchantId = '';

      final result = await _networkInternationalPaymentSdkPlugin.startCardPayment(
        orderDetails: orderDetails,
        base64orderData: orderDataBase64,
        merchantId: merchantId, 
      );
      paymentResult = result;
    } on PlatformException catch (e) {
      paymentResult = PaymentResult(PaymentStatus.FAILED, 'Platform error: ${e.message} (${e.details})');
    } catch (e) {
      paymentResult = PaymentResult(PaymentStatus.FAILED, 'Application error: $e');
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

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/src/main/kotlin/com/enoc/network_international_payment_sdk/Messages.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.enoc.network_international_payment_sdk',
  ),
  swiftOut: 'ios/network_international_payment_sdk/Sources/network_international_payment_sdk/Messages.g.swift',
  swiftOptions: SwiftOptions(),
))
class PaymentResultData {
  final String status;
  final String? reason;

  PaymentResultData({required this.status, this.reason});
}

class CardPaymentRequest {
  final String orderDetailsJson;
  final bool? showOrderAmount;
  final bool? showCancelAlert;
  final Map<String?, Object?>? themeMap;
  final Map<String?, Object?>? googlePayConfigMap;

  CardPaymentRequest({
    required this.orderDetailsJson,
    this.showOrderAmount,
    this.showCancelAlert,
    this.themeMap,
    this.googlePayConfigMap,
  });
}

class SavedCardPaymentRequest {
  final String orderDetailsJson;
  final String? cvv;
  final Map<String?, Object?>? themeMap;

  SavedCardPaymentRequest({
    required this.orderDetailsJson,
    this.cvv,
    this.themeMap,
  });
}

class ApplePayRequest {
  final String orderDetailsJson;
  final Map<String?, Object?> applePayConfigMap;
  final Map<String?, Object?>? themeMap;

  ApplePayRequest({
    required this.orderDetailsJson,
    required this.applePayConfigMap,
    this.themeMap,
  });
}

class SamsungPayRequest {
  final String orderDetailsJson;
  final Map<String?, Object?> samsungPayConfigMap;

  SamsungPayRequest({
    required this.orderDetailsJson,
    required this.samsungPayConfigMap,
  });
}

@HostApi()
abstract class NetworkInternationalPaymentSdkApi {
  @async
  PaymentResultData startCardPayment(CardPaymentRequest request);

  @async
  PaymentResultData startSavedCardPayment(SavedCardPaymentRequest request);

  @async
  PaymentResultData startApplePay(ApplePayRequest request);

  @async
  PaymentResultData startSamsungPay(SamsungPayRequest request);
}

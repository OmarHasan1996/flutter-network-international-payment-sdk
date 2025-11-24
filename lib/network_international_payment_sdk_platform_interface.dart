import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'network_international_payment_sdk_method_channel.dart';

abstract class NetworkInternationalPaymentSdkPlatform extends PlatformInterface {
  /// Constructs a NetworkInternationalPaymentSdkPlatform.
  NetworkInternationalPaymentSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static NetworkInternationalPaymentSdkPlatform _instance = MethodChannelNetworkInternationalPaymentSdk();

  /// The default instance of [NetworkInternationalPaymentSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelNetworkInternationalPaymentSdk].
  static NetworkInternationalPaymentSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NetworkInternationalPaymentSdkPlatform] when
  /// they register themselves.
  static set instance(NetworkInternationalPaymentSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<dynamic, dynamic>?> startCardPayment({
    required Map<String, dynamic> orderDetails,
    String? merchantId,
    bool? showOrderAmount,
    bool? showCancelAlert,
    Map<String, dynamic>? theme,
  }) {
    throw UnimplementedError('startCardPayment() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> startSavedCardPayment({
    required Map<String, dynamic> orderDetails,
    String? merchantId,
    String? cvv,
  }) {
    throw UnimplementedError('startSavedCardPayment() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> startApplePay({
    required Map<String, dynamic> orderDetails,
    required Map<String, dynamic> applePayConfig,
  }) {
    throw UnimplementedError('startApplePay() has not been implemented.');
  }
}

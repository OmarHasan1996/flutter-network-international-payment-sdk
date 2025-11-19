
import 'network_international_payment_sdk_platform_interface.dart';

class NetworkInternationalPaymentSdk {
  Future<String?> getPlatformVersion() {
    return NetworkInternationalPaymentSdkPlatform.instance.getPlatformVersion();
  }
}

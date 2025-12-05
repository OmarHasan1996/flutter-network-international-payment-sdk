/// Configuration for enabling Samsung Pay on Android.
class SamsungPayConfig {
  /// Your Samsung Pay service ID.
  final String serviceId;

  /// The name of your merchant, to be displayed on the Samsung Pay sheet.
  final String merchantName;

  /// Creates a new configuration for Samsung Pay.
  SamsungPayConfig({required this.serviceId, required this.merchantName});

  /// Converts the config to a map for the method channel.
  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'merchantName': merchantName,
    };
  }
}

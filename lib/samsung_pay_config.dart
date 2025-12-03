/// Configuration for enabling Samsung Pay on Android.
class SamsungPayConfig {
  /// Your Samsung Pay service ID.
  final String serviceId;

  /// Creates a new configuration for Samsung Pay.
  SamsungPayConfig({required this.serviceId});

  /// Converts the config to a map for the method channel.
  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
    };
  }
}

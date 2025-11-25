/// Enum for Google Pay environments.
enum GooglePayEnvironment {
  production,
  test,
}

/// Enum for the billing address format.
enum BillingAddressFormat {
  min,
  full,
}

/// Configuration for the billing address in a Google Pay request.
class BillingAddressConfig {
  /// Indicates whether a billing address is required.
  final bool isRequired;

  /// The format of the billing address.
  final BillingAddressFormat format;

  /// Indicates whether a phone number is required in the billing address.
  final bool isPhoneNumberRequired;

  const BillingAddressConfig({
    this.isRequired = false,
    this.format = BillingAddressFormat.min,
    this.isPhoneNumberRequired = false,
  });

  /// Converts the config to a map for the method channel.
  Map<String, dynamic> toMap() {
    return {
      'isRequired': isRequired,
      'format': format.name,
      'isPhoneNumberRequired': isPhoneNumberRequired,
    };
  }
}

/// Configuration for enabling Google Pay on Android.
class GooglePayConfig {
  /// The environment for Google Pay.
  final GooglePayEnvironment environment;

  /// Your Google Pay merchant gateway ID.
  final String merchantGatewayId;

  /// Indicates whether the user's email is required.
  final bool isEmailRequired;

  /// Configuration for the billing address.
  final BillingAddressConfig billingAddressConfig;

  /// Creates a new configuration for Google Pay.
  GooglePayConfig({
    this.environment = GooglePayEnvironment.test,
    required this.merchantGatewayId,
    this.isEmailRequired = false,
    this.billingAddressConfig = const BillingAddressConfig(),
  });

  /// Converts the config to a map for the method channel.
  Map<String, dynamic> toMap() {
    return {
      'environment': environment.name,
      'merchantGatewayId': merchantGatewayId,
      'isEmailRequired': isEmailRequired,
      'billingAddressConfig': billingAddressConfig.toMap(),
    };
  }
}

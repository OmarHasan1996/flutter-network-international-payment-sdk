/// A Dart representation of the Apple Pay PKPaymentRequest.
class PKPaymentRequest {
  /// Your Apple Pay merchant identifier.
  final String merchantIdentifier;
  
  /// The two-letter ISO 3166 country code for the country where the payment is processed.
  final String countryCode;
  
  /// The three-letter ISO 4217 currency code for the payment.
  final String currencyCode;
  
  /// The list of items in the user's cart.
  final List<PKPaymentSummaryItem> paymentSummaryItems;

  PKPaymentRequest({
    required this.merchantIdentifier,
    this.countryCode = "AE",
    this.currencyCode = "AED",
    required this.paymentSummaryItems,
  });

  /// Converts the request to a map that can be sent over the method channel.
  Map<String, dynamic> toMap() {
    return {
      'merchantIdentifier': merchantIdentifier,
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'paymentSummaryItems': paymentSummaryItems.map((item) => item.toMap()).toList(),
    };
  }
}

/// Represents an item in the payment summary.
class PKPaymentSummaryItem {
  /// A short, localized description of the item.
  final String label;

  /// The cost of the item.
  final double amount;

  PKPaymentSummaryItem({required this.label, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'amount': amount,
    };
  }
}

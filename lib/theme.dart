/// A class to hold platform-specific theme customizations.
class NITheme {
  /// The iOS-specific theme customizations.
  final NIThemeIOS? ios;

  /// Creates a new NITheme.
  NITheme({this.ios});

  /// Converts the theme to a map that can be sent over the method channel.
  Map<String, dynamic> toMap() {
    return {
      'ios': ios?.toMap(),
    };
  }
}

/// iOS-specific theme properties.
/// See the N-Genius iOS SDK documentation for details on these properties.
class NIThemeIOS {
  /// Color of the card preview.
  final String? cardPreviewColor;

  /// Color of labels in the card preview.
  final String? cardPreviewLabelColor;

  /// Background color of the payment page.
  final String? payPageBackgroundColor;

  /// Color of labels in the payment page.
  final String? payPageLabelColor;

  /// Color of labels in text fields.
  final String? textFieldLabelColor;

  /// Color of placeholder text in text fields.
  final String? textFieldPlaceholderColor;

  /// Color of dividers in the payment page.
  final String? payPageDividerColor;

  /// Background color of the payment button.
  final String? payButtonBackgroundColor;

  /// Color of the payment button title.
  final String? payButtonTitleColor;

  /// Color of the payment button title when highlighted.
  final String? payButtonTitleColorHighlighted;

  /// Color of the payment button's activity indicator.
  final String? payButtonActivityIndicatorColor;

  /// Color of the title in the payment page.
  final String? payPageTitleColor;

  /// Creates a new NIThemeIOS.
  NIThemeIOS({
    this.cardPreviewColor,
    this.cardPreviewLabelColor,
    this.payPageBackgroundColor,
    this.payPageLabelColor,
    this.textFieldLabelColor,
    this.textFieldPlaceholderColor,
    this.payPageDividerColor,
    this.payButtonBackgroundColor,
    this.payButtonTitleColor,
    this.payButtonTitleColorHighlighted,
    this.payButtonActivityIndicatorColor,
    this.payPageTitleColor,
  });

  /// Converts the theme to a map that can be sent over the method channel.
  Map<String, String> toMap() {
    return {
      if (cardPreviewColor != null) 'cardPreviewColor': cardPreviewColor!,
      if (cardPreviewLabelColor != null) 'cardPreviewLabelColor': cardPreviewLabelColor!,
      if (payPageBackgroundColor != null) 'payPageBackgroundColor': payPageBackgroundColor!,
      if (payPageLabelColor != null) 'payPageLabelColor': payPageLabelColor!,
      if (textFieldLabelColor != null) 'textFieldLabelColor': textFieldLabelColor!,
      if (textFieldPlaceholderColor != null) 'textFieldPlaceholderColor': textFieldPlaceholderColor!,
      if (payPageDividerColor != null) 'payPageDividerColor': payPageDividerColor!,
      if (payButtonBackgroundColor != null) 'payButtonBackgroundColor': payButtonBackgroundColor!,
      if (payButtonTitleColor != null) 'payButtonTitleColor': payButtonTitleColor!,
      if (payButtonTitleColorHighlighted != null) 'payButtonTitleColorHighlighted': payButtonTitleColorHighlighted!,
      if (payButtonActivityIndicatorColor != null) 'payButtonActivityIndicatorColor': payButtonActivityIndicatorColor!,
      if (payPageTitleColor != null) 'payPageTitleColor': payPageTitleColor!,
    };
  }
}

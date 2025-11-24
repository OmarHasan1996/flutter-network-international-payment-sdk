/// A class to hold platform-specific theme customizations.
class NITheme {
  final NIThemeIOS? ios;

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
  final String? cardPreviewColor;
  final String? cardPreviewLabelColor;
  final String? payPageBackgroundColor;
  final String? payPageLabelColor;
  final String? textFieldLabelColor;
  final String? textFieldPlaceholderColor;
  final String? payPageDividerColor;
  final String? payButtonBackgroundColor;
  final String? payButtonTitleColor;
  final String? payButtonTitleColorHighlighted;
  final String? payButtonActivityIndicatorColor;
  final String? payPageTitleColor;

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

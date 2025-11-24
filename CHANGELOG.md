## 1.1.0

* Added UI customization options (`showOrderAmount`, `showCancelAlert`).
* Added dynamic color theming for iOS via the `NITheme` object.
* Updated documentation to explain static color theming on Android.
* Made the `merchantId` parameter optional.

## 1.0.1

* Refactored `PaymentStatus` enum to use `lowerCamelCase` to align with Dart conventions.
* Improved mapping from native status strings to the Dart enum.

## 1.0.0

* Initial release of the N-Genius / Network International Payments SDK Flutter plugin.
* Supports card payments on both Android and iOS.
* Provides a structured `PaymentResult` for handling payment outcomes.

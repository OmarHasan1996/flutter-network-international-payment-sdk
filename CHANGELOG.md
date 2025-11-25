## 1.5.0

* Android: Add Google Pay support.

## 1.4.0

* Android: Migrate to modern `PaymentsLauncher` and `SavedCardPaymentLauncher` APIs.

## 1.3.0

* Added `startApplePay` method to support Apple Pay on iOS.

## 1.2.0

* Added `startSavedCardPayment` method to support payments with saved cards.

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

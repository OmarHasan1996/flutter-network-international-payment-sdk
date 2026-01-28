# N-Genius Flutter SDK

A Flutter plugin to provide an easy-to-use integration for handling payments using N-Genius native SDKs in Flutter applications.

## 📱 Platform Compatibility
- **Android** ✅
- **iOS** ✅ (Minimum deployment target: iOS 14.0)

---

## ⚙️ Android Configuration

### 1. Add JitPack Repository
Since the N-Genius Android SDK is a JitPack dependency, you must add the JitPack repository to your project-level `android/build.gradle` or `android/build.gradle.kts` file.

#### For Groovy DSL (`build.gradle`)

```groovy
// android/build.gradle
allprojects {
    repositories {
        // ... other repositories
        maven { url 'https://jitpack.io' } // Add this line
    }
}
```

#### For Kotlin DSL (`build.gradle.kts`)

```kotlin
// android/build.gradle.kts
allprojects {
    repositories {
        // ... other repositories
        maven { url = uri("https://jitpack.io") } // Add this line
    }
}
```

### 2. Update AndroidManifest.xml

To support #Samsung Pay, you must add the following `<queries>` and `<meta-data>` tags to your `android/app/src/main/AndroidManifest.xml` file. 

```xml
<manifest ...>
    <queries>
        <package android:name="com.samsung.android.spay" />
        <package android:name="com.samsung.android.samsungpay.gear" /> 
    </queries>

    <application ...>
        <!-- Samsung Pay SDK API Level -->
        <meta-data
            android:name="spay_sdk_api_level"
            android:value="2.18" />
        
        <!-- Set to 'Y' for testing, 'N' for release -->
        <meta-data
            android:name="debug_mode"
            android:value="Y" /> 

        <!-- Replace with your key from the Samsung Pay Developers portal -->
        <meta-data
            android:name="spay_debug_api_key"
            android:value="YOUR_SPAY_DEBUG_API_KEY" />
        
        <!-- ... other activity and meta-data ... -->
    </application>
</manifest>
```

### 3. ProGuard Rules (if applicable)
This also related to #Samsung Pay
If you use ProGuard, add the following rules to your `proguard-rules.pro` file:

```
-dontwarn com.samsung.android.sdk.samsungpay.** 
-keep class com.samsung.android.sdk.** { *; } 
-keep interface com.samsung.android.sdk.** { *; }
```

## 🍏 iOS Configuration

The N-Genius iOS SDK (`NISdk`) is included as a dependency. You just need to ensure your `ios/Podfile` targets the correct platform version:

```ruby
# ios/Podfile

platform :ios, '12.0' # Ensure your platform target is 12.0 or higher

# ... rest of your Podfile
```

After adding the source, run `pod install` in your `ios` directory.

---

## 🚀 How to Use

### 1. Get the Order Details

For security reasons, you must call the N-Genius APIs from your server to create an order. This will give you the `orderDetails` JSON object required by the SDK.

- **Step 1: Get an Access Token:** [Request an Access Token](https://docs.ngenius-payments.com/reference/request-an-access-token-direct)
- **Step 2: Create an Order:** [Create an Order API](https://docs.ngenius-payments.com/reference/two-stage-payments-orders)

### 2. Call a Payment Method

#### `startCardPayment` (New Card)
This method also supports enabling Google Pay on Android.


```dart
await _networkInternationalPaymentSdkPlugin.startCardPayment(
  orderDetails: _orderDetails, //Map<String, dynamic>?
  googlePayConfig: GooglePayConfig( // Optional: to enable Google Pay
    merchantGatewayId: 'YOUR_GOOGLE_PAY_GATEWAY_ID',
  ),
);
```

#### `startSavedCardPayment` (for saved cards)

For saved card payments, use the `startSavedCardPayment` method and optionally provide the user's CVV if required by your order configuration.

```dart
await _networkInternationalPaymentSdkPlugin.startSavedCardPayment(
  orderDetails: _orderDetails, //Map<String, dynamic>?
  cvv: "123", // Optional
);
```

#### `startApplePay` (iOS Only)

This method initiates a payment with Apple Pay. You must provide a `PKPaymentRequest` object.

```dart
import 'package:network_international_payment_sdk/apple_pay_config.dart';

// ...

final applePayConfig = PKPaymentRequest(
  merchantIdentifier: 'YOUR_APPLE_PAY_MERCHANT_ID',
  paymentSummaryItems: [
    PKPaymentSummaryItem(label: 'Your Product', amount: 10.00),
  ],
);

final PaymentResult result = await paymentSdk.startApplePay(
  orderDetails: orderDetails, 
  applePayConfig: applePayConfig,
);
```

#### `startSamsungPay` (Android Only)

```dart
import 'package:network_international_payment_sdk/samsung_pay_config.dart';

// ...
final samsungPayConfig = SamsungPayConfig(
  serviceId: 'YOUR_SAMSUNG_PAY_SERVICE_ID',
  merchantName: 'Your Merchant Name',
);

await _networkInternationalPaymentSdkPlugin.startSamsungPay(
  orderDetails: _orderDetails, //Map<String, dynamic>?
  samsungPayConfig: samsungPayConfig,
);
```

### Using `base64orderData`

As an alternative to passing the `orderDetails` map, you can provide a Base64-encoded string of the order details JSON for either payment method.
---

### 🎨 UI Customization & Other Options

You can customize the native payment UI by passing the following optional parameters to `startCardPayment`:

| Parameter | Type | Description |
|---|---|---|
| `showOrderAmount`| `bool?` | Show/hide the order amount on the pay button. Defaults to `true`. |
| `showCancelAlert`| `bool?` | Show/hide a confirmation alert when the user cancels. Defaults to `true`. |
| `theme` | `NITheme?` | Platform-specific UI color customizations. |

#### iOS Color Customization

For iOS, you can customize colors dynamically by passing an `NIThemeIOS` object to the `theme` parameter. Colors should be provided as hex strings (e.g., `"#RRGGBB"`).

```dart
import 'package:network_international_payment_sdk/theme.dart';

// ...

await paymentSdk.startCardPayment(
  // ... other parameters
  theme: NITheme(
    ios: NIThemeIOS(
      payButtonBackgroundColor: "#000000", // Black
      payButtonTitleColor: "#FFFFFF",      // White
      // ... and any other iOS color properties
    ),
  ),
);
```

#### Android Color Customization

For Android, colors must be customized statically by overriding the color resources in your app's `android/app/src/main/res/values/colors.xml` file. You cannot change them at runtime.

Create the `colors.xml` file if it doesn't exist and add the colors you wish to override. For example:

```xml
<!-- android/app/src/main/res/values/colors.xml -->
<resources>
    <color name="payment_sdk_toolbar_color">#000000</color>
    <color name="payment_sdk_pay_button_background_color">#4885ED</color>
</resources>
```

**Available Android Color Resources:**
* `payment_sdk_toolbar_color`
* `payment_sdk_toolbar_text_color`
* `payment_sdk_toolbar_icon_color`
* `payment_sdk_pay_button_background_color`
* `payment_sdk_pay_button_text_color`
* `payment_sdk_progress_loader_color`
* `payment_sdk_card_center_color`
* `payment_sdk_floating_hint_color`

---

## 🔄 Handling the Payment Response

The plugin returns a `PaymentResult` object, which contains a `status` (a `PaymentStatus` enum) and an optional `reason` string.

### `PaymentStatus` Enum Values

| Status | Description |
|---|---|
| `SUCCESS` | The payment was successful (Android & iOS). |
| `FAILED` | The payment failed. Check the `reason` for more details. |
| `CANCELLED` | The user cancelled the payment flow. |
| `AUTHORISED` | (Android Only) The payment was authorized. |
| `POST_AUTH_REVIEW` | (Android Only) The payment is under review after authorization. |
| `PARTIALLY_AUTHORISED`| (Android Only) The payment was partially authorized. |
| `PARTIAL_AUTH_DECLINED`| (Android Only) The partial authorization was declined. |
| `PARTIAL_AUTH_DECLINE_FAILED`| (Android Only) The partial authorization decline failed. |
| `UNKNOWN` | An unknown status was received. |


---

### Testing

You can use N-Genius test cards for payments in the sandbox environment:
[Sandbox Test Environment](https://docs.ngenius-payments.com/reference/sandbox-test-environment)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

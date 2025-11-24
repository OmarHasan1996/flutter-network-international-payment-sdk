# N-Genius Flutter SDK

A Flutter plugin to provide an easy-to-use integration for handling payments using N-Genius native SDKs in Flutter applications.

## 📱 Platform Compatibility
- **Android** ✅
- **iOS** ✅ (Minimum deployment target: iOS 12.0)

---

## ⚙️ Android Configuration

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

---

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

### 1. Get the Order Details JSON

For security reasons, you must call the N-Genius APIs from your server to create an order. This will give you the `orderDetails` JSON object required by the SDK.

- **Step 1: Get an Access Token:** [Request an Access Token](https://docs.ngenius-payments.com/reference/request-an-access-token-direct)
- **Step 2: Create an Order:** [Create an Order API](https://docs.ngenius-payments.com/reference/two-stage-payments-orders)

### 2. Call `startCardPayment` (for new cards)

Pass the `orderDetails` map to the `startCardPayment` method. The `merchantId` is optional.

```dart
import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';
import 'package:network_international_payment_sdk/payment_result.dart';
import 'package:network_international_payment_sdk/payment_status.dart';
// ...

Future<void> makePayment() async {
  final paymentSdk = NetworkInternationalPaymentSdk();

  // This must be fetched from your server.
  final Map<String, dynamic> orderDetails = await getOrderDetailsFromServer();

  try {
    final PaymentResult result = await paymentSdk.startCardPayment(
      // The merchantId is optional and primarily used for specific Android payment flows.
      merchantId: "YOUR_MERCHANT_ID", // Can be null
      
      // The map containing the JSON data from your server.
      orderDetails: orderDetails, 
    );

    if (result.status == PaymentStatus.success || result.status == PaymentStatus.authorised) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction Successful")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction Failed: ${result.status} - ${result.reason}")));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
  }
}

### 3. Call `startSavedCardPayment` (for saved cards)

For saved card payments, use the `startSavedCardPayment` method and optionally provide the user's CVV.

```dart
final PaymentResult result = await paymentSdk.startSavedCardPayment(
  merchantId: "YOUR_MERCHANT_ID", // Optional
  orderDetails: orderDetails, 
  cvv: "123", // Optional
);
```

### Using `base64orderData`

As an alternative to passing the `orderDetails` map, you can provide a Base64-encoded string of the order details JSON for either payment method.

```dart
final String base64EncodedOrder = "eyJfX2lkIjoi..."

final PaymentResult result = await paymentSdk.startCardPayment(
  merchantId: "YOUR_MERCHANT_ID", // Can be null
  base64orderData: base64EncodedOrder,
);
```

### 🎨 UI Customization

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

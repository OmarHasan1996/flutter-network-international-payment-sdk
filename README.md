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

The N-Genius iOS SDK (`NISdk`) is hosted on a private podspec repository. You must add the required sources at the top of your `ios/Podfile`:

```ruby
# ios/Podfile

# Add the N-Genius private podspec repository and the main CocoaPods repository
source 'https://github.com/network-international/pods-specs.git'
source 'https://cdn.cocoapods.org/'

platform :ios, '12.0' # Ensure your platform target is 12.0 or higher

# ... rest of your Podfile
```

After adding the source, run `pod install` in your `ios` directory.

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

## 🚀 How to Use

### 1. Get the Order Details JSON

For security reasons, you must call the N-Genius APIs from your server to create an order. This will give you the `orderDetails` JSON object required by the SDK.

- **Step 1: Get an Access Token:** [Request an Access Token](https://docs.ngenius-payments.com/reference/request-an-access-token-direct)
- **Step 2: Create an Order:** [Create an Order API](https://docs.ngenius-payments.com/reference/two-stage-payments-orders)

### 2. Call `startPayment`

Pass the `orderDetails` map and your `merchantId` to the `startPayment` method.

```dart
import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';

// ...

Future<void> makePayment() async {
  final paymentSdk = NetworkInternationalPaymentSdk();

  // This must be fetched from your server.
  final Map<String, dynamic> orderDetails = await getOrderDetailsFromServer();

  try {
    final PaymentResult result = await paymentSdk.startPayment(
      // The merchantId is required for the Android SDK and is ignored on iOS.
      merchantId: "YOUR_MERCHANT_ID", 
      
      // The map containing the JSON data from your server.
      orderDetails: orderDetails, 
    );

    if (result.status == PaymentStatus.SUCCESS || result.status == PaymentStatus.AUTHORISED) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction Successful")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction Failed: ${result.status} - ${result.reason}")));
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
  }
}
```

### Using `base64orderData`

As an alternative to passing the `orderDetails` map, you can provide a Base64-encoded string of the order details JSON. The plugin will handle decoding it.

```dart
final String base64EncodedOrder = "eyJfX2lkIjoi..."

final PaymentResult result = await paymentSdk.startPayment(
  merchantId: "YOUR_MERCHANT_ID",
  base64orderData: base64EncodedOrder,
);
```

### Testing

You can use N-Genius test cards for payments in the sandbox environment:
[Sandbox Test Environment](https://docs.ngenius-payments.com/reference/sandbox-test-environment)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

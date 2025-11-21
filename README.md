# N-Genius Payments Flutter SDK

A Flutter plugin that provides an easy-to-use interface for handling payments using the N-Genius native SDKs on both Android and iOS.

## 📱 Platform Compatibility
- **Android** ✅
- **iOS** ✅ (Minimum deployment target: iOS 12.0)

---

## ⚙️ Android Configuration

Since the N-Genius Android SDK is a JitPack dependency, you must add the JitPack repository to your project-level `android/build.gradle` file:

```gradle
// android/build.gradle
allprojects {
    repositories {
        // ... other repositories
        maven { url 'https://jitpack.io' } // Add this line
    }
}
```

---

## 🍏 iOS Configuration

The N-Genius iOS SDK (`NISdk`) is hosted on a private podspec repository. You must add it as a source at the top of your `ios/Podfile`:

```ruby
# ios/Podfile

# Add these two lines at the top
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/network-international/pods-specs.git'

platform :ios, '12.0' # Ensure your platform target is 12.0 or higher

# ... rest of your Podfile
```

After adding the source, run `pod install` in your `ios` directory.

---

## 🔄 Handling the Payment Response

The plugin returns a `PaymentResult` object, which contains a `status` and an optional `reason`.

```dart
class PaymentResult {
  final PaymentStatus status;
  final String? reason;
}
```

### `PaymentStatus` Enum

| Status | Description |
|---|---|
| `SUCCESS` | The payment was successful. |
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

### 1. Get the Order Details

For security reasons, you must call the N-Genius APIs from your server to create an order. This will give you the `orderDetails` JSON object required by the SDK.

- **Step 1: Get an Access Token:** [Request an Access Token](https://docs.ngenius-payments.com/reference/request-an-access-token-direct)
- **Step 2: Create an Order:** [Create an Order API](https://docs.ngenius-payments.com/reference/two-stage-payments-orders)

### 2. Call `startPayment`

Pass the `orderDetails` and your `merchantId` to the `startPayment` method.

```dart
import 'package:network_international_payment_sdk/network_international_payment_sdk.dart';
import 'dart:io' show Platform;

// ...

Future<void> makePayment() async {
  final paymentSdk = NetworkInternationalPaymentSdk();

  // IMPORTANT: The structure of orderDetails is DIFFERENT for Android and iOS.
  // You must get the correct JSON structure from your server based on the platform.
  final Map<String, dynamic> orderDetails = await getOrderDetailsForPlatform();

  try {
    final PaymentResult result = await paymentSdk.startPayment(
      // The merchantId is required for the Android SDK.
      merchantId: "YOUR_MERCHANT_ID", 
      
      // This map contains the JSON data from your server.
      orderDetails: orderDetails, 
    );

    if (result.status == PaymentStatus.SUCCESS || result.status == PaymentStatus.AUTHORISED) {
      print("Payment Successful!");
    } else {
      print("Payment Failed or Cancelled. Status: ${result.status}, Reason: ${result.reason}");
    }

  } catch (e) {
    print("An error occurred: $e");
  }
}

```

### Using `base64orderData`

As an alternative to passing the `orderDetails` map, you can provide a Base64-encoded string of the order details JSON. The plugin will handle decoding it for you.

```dart
final String base64EncodedOrder = "eyJfX2lkIjoi..."

final PaymentResult result = await paymentSdk.startPayment(
  merchantId: "YOUR_MERCHANT_ID",
  base64orderData: base64EncodedOrder,
);
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

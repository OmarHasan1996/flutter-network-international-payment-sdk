import Flutter
import UIKit
import NISdk
import os.log

public class NetworkInternationalPaymentSdkPlugin: NSObject, FlutterPlugin, CardPaymentDelegate {
    private var methodChannel: FlutterMethodChannel!
    static var flutterResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "network_international_payment_sdk", binaryMessenger: registrar.messenger())
        let instance = NetworkInternationalPaymentSdkPlugin()
        instance.methodChannel = channel
        NISdk.initialize()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "startPayment" {
            if NetworkInternationalPaymentSdkPlugin.flutterResult != nil {
                result(FlutterError(code: "ALREADY_ACTIVE", message: "A payment is already in progress.", details: nil))
                return
            }
            NetworkInternationalPaymentSdkPlugin.flutterResult = result
            handlePayment(call: call)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func handlePayment(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let orderDetails = args["orderDetails"] as? [String: Any] else {
            let error = FlutterError(code: "INVALID_ARGUMENTS", message: "orderDetails (as a Map) is required", details: nil)
            NetworkInternationalPaymentSdkPlugin.flutterResult?(error)
            NetworkInternationalPaymentSdkPlugin.flutterResult = nil
            return
        }

        // Log the dictionary we received from Flutter to help debug the data.
        if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: "com.enoc.networkInternationalPaymentSdkExample", category: "Payment");
            logger.info("Attempting to create OrderResponse from the following dictionary: \(orderDetails, privacy: .public)")
        } else {
            os_log("N-Genius Plugin: Attempting to create OrderResponse from dictionary: %{public}@", log: OSLog.default, type: .info, orderDetails as CVarArg)
        }

        do {
            let orderData = try JSONSerialization.data(withJSONObject: orderDetails, options: [])
            let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: orderData)

            DispatchQueue.main.async {
                guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                    let error = FlutterError(code: "NO_ROOT_VIEW_CONTROLLER", message: "Could not get root view controller", details: nil)
                    NetworkInternationalPaymentSdkPlugin.flutterResult?(error)
                    NetworkInternationalPaymentSdkPlugin.flutterResult = nil
                    return
                }

                // IMPORTANT: This do-catch block will NOT prevent the fatalError crash inside the SDK.
                do {
                    let sharedSDKInstance = NISdk.sharedInstance
                    sharedSDKInstance.showCardPaymentViewWith(cardPaymentDelegate: self,
                                                              overParent: rootViewController,
                                                              for: orderResponse)
                } catch {
                    // This catch block is unlikely to be reached for the fatalError crash.
                    let error = FlutterError(code: "SDK_RUNTIME_ERROR", message: "An unexpected error occurred when showing the payment view: \(error)", details: nil)
                    NetworkInternationalPaymentSdkPlugin.flutterResult?(error)
                    NetworkInternationalPaymentSdkPlugin.flutterResult = nil
                }
            }
        } catch {
            let errorMessage = "Failed to create OrderResponse from the provided 'orderDetails' map. Please check the map's structure and data types match the SDK's expected OrderResponse format. Decoding Error: \(error)"
            let error = FlutterError(code: "DECODING_ERROR", message: errorMessage, details: error.localizedDescription)
            NetworkInternationalPaymentSdkPlugin.flutterResult?(error)
            NetworkInternationalPaymentSdkPlugin.flutterResult = nil
        }
    }

    // MARK: - CardPaymentDelegate

    public func paymentDidComplete(with status: PaymentStatus) {
        guard let result = NetworkInternationalPaymentSdkPlugin.flutterResult else { return }

        let paymentResult: [String: String]
        switch status {
        case .PaymentSuccess:
            paymentResult = ["status": "SUCCESS", "reason": "Payment was successful"]
        case .PaymentFailed:
            paymentResult = ["status": "FAILED", "reason": "Payment failed"]
        case .PaymentCancelled:
            paymentResult = ["status": "CANCELLED", "reason": "Payment was cancelled by the user"]
        @unknown default:
            paymentResult = ["status": "UNKNOWN", "reason": "An unknown payment status was received"]
        }

        result(paymentResult)
        NetworkInternationalPaymentSdkPlugin.flutterResult = nil
    }

    public func authorizationDidComplete(with status: AuthorizationStatus) {
        if status == .AuthFailed {
            guard let result = NetworkInternationalPaymentSdkPlugin.flutterResult else { return }
            let paymentResult: [String: String] = [
                "status": "FAILED",
                "reason": "Auth Failed"
            ]
            result(paymentResult)
            NetworkInternationalPaymentSdkPlugin.flutterResult = nil
        }
    }
}

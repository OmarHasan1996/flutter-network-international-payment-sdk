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
        if call.method == "startCardPayment" {
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

        let showOrderAmount = args["showOrderAmount"] as? Bool
        let showCancelAlert = args["showCancelAlert"] as? Bool
        let theme = args["theme"] as? [String: [String: String]]

        let sharedSDKInstance = NISdk.sharedInstance
        if let showAmount = showOrderAmount {
            sharedSDKInstance.shouldShowOrderAmount = showAmount
        }
        if let showPrompt = showCancelAlert {
            sharedSDKInstance.shouldShowCancelAlert = showPrompt
        }

        if let iosTheme = theme?["ios"] {
            let sdkColors = NISdkColors()

            let mapping: [String: (String) -> Void] = [
                "cardPreviewColor": { sdkColors.cardPreviewColor = self.hexStringToUIColor(hex: $0) },
                "cardPreviewLabelColor": { sdkColors.cardPreviewLabelColor = self.hexStringToUIColor(hex: $0) },
                "payPageBackgroundColor": { sdkColors.payPageBackgroundColor = self.hexStringToUIColor(hex: $0) },
                "payPageLabelColor": { sdkColors.payPageLabelColor = self.hexStringToUIColor(hex: $0) },
                "textFieldLabelColor": { sdkColors.textFieldLabelColor = self.hexStringToUIColor(hex: $0) },
                "textFieldPlaceholderColor": { sdkColors.textFieldPlaceholderColor = self.hexStringToUIColor(hex: $0) },
                "payPageDividerColor": { sdkColors.payPageDividerColor = self.hexStringToUIColor(hex: $0) },
                "payButtonBackgroundColor": { sdkColors.payButtonBackgroundColor = self.hexStringToUIColor(hex: $0) },
                "payButtonTitleColor": { sdkColors.payButtonTitleColor = self.hexStringToUIColor(hex: $0) },
                "payButtonTitleColorHighlighted": { sdkColors.payButtonTitleColorHighlighted = self.hexStringToUIColor(hex: $0) },
                "payButtonActivityIndicatorColor": { sdkColors.payButtonActivityIndicatorColor = self.hexStringToUIColor(hex: $0) },
                "payPageTitleColor": { sdkColors.payPageTitleColor = self.hexStringToUIColor(hex: $0) }
            ]

            for (key, applyColor) in mapping {
                if let hex = iosTheme[key] {
                    applyColor(hex)
                }
            }

            sharedSDKInstance.setSDKColors(sdkColors: sdkColors)
        }



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

                do {
                    sharedSDKInstance.showCardPaymentViewWith(cardPaymentDelegate: self,
                                                              overParent: rootViewController,
                                                              for: orderResponse)
                } catch {
                    let error = FlutterError(code: "SDK_RUNTIME_ERROR", message: "An unexpected error occurred when showing the payment view: \(error)", details: nil)
                    NetworkInternationalPaymentSdkPlugin.flutterResult?(error)
                    NetworkInternationalPaymentSdkPlugin.flutterResult = nil
                }
            }
        } catch {
            let errorMessage = "Failed to create OrderResponse from the provided 'orderDetails' map. Check the map's structure and data types. Decoding Error: \(error)"
            let error = FlutterError(code: "DECODING_ERROR", message: errorMessage, details: error.localizedDescription)
            NetworkInternationalPaymentSdkPlugin.flutterResult?(error)
            NetworkInternationalPaymentSdkPlugin.flutterResult = nil
        }
    }

    public func paymentDidComplete(with status: PaymentStatus) {
        guard let result = NetworkInternationalPaymentSdkPlugin.flutterResult else { return }
        let paymentResult: [String: String]
        switch status {
        case .PaymentSuccess: paymentResult = ["status": "SUCCESS", "reason": "Payment was successful"]
        case .PaymentFailed: paymentResult = ["status": "FAILED", "reason": "Payment failed"]
        case .PaymentCancelled: paymentResult = ["status": "CANCELLED", "reason": "Payment was cancelled by the user"]
        @unknown default: paymentResult = ["status": "UNKNOWN", "reason": "An unknown payment status was received"]
        }
        result(paymentResult)
        NetworkInternationalPaymentSdkPlugin.flutterResult = nil
    }

    public func authorizationDidComplete(with status: AuthorizationStatus) {
        if status == .AuthFailed {
            guard let result = NetworkInternationalPaymentSdkPlugin.flutterResult else { return }
            let paymentResult: [String: String] = ["status": "FAILED", "reason": "Auth Failed"]
            result(paymentResult)
            NetworkInternationalPaymentSdkPlugin.flutterResult = nil
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        if ((cString.count) != 6) { return UIColor.gray }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

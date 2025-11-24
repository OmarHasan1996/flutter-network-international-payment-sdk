import Flutter
import UIKit
import NISdk
import os.log
import PassKit

public class NetworkInternationalPaymentSdkPlugin: NSObject, FlutterPlugin, CardPaymentDelegate, ApplePayDelegate {
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
        if NetworkInternationalPaymentSdkPlugin.flutterResult != nil {
            result(FlutterError(code: "ALREADY_ACTIVE", message: "A payment is already in progress.", details: nil))
            return
        }
        NetworkInternationalPaymentSdkPlugin.flutterResult = result

        switch call.method {
        case "startCardPayment":
            handleNewCardPayment(call: call)
        case "startSavedCardPayment":
            handleSavedCardPayment(call: call)
        case "startApplePay":
            handleApplePay(call: call)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleNewCardPayment(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let orderDetails = args["orderDetails"] as? [String: Any] else {
            completePayment(withError: FlutterError(code: "INVALID_ARGUMENTS", message: "orderDetails are required", details: nil))
            return
        }
        
        applyUISettings(from: args)
        
        do {
            let orderData = try JSONSerialization.data(withJSONObject: orderDetails, options: [])
            let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: orderData)

            DispatchQueue.main.async {
                guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                    self.completePayment(withError: FlutterError(code: "NO_ROOT_VIEW_CONTROLLER", message: "Could not get root view controller", details: nil))
                    return
                }

                NISdk.sharedInstance.showCardPaymentViewWith(cardPaymentDelegate: self,
                                                          overParent: rootViewController,
                                                          for: orderResponse)
            }
        } catch {
            let errorMessage = "Failed to create OrderResponse. Error: \(error)"
            completePayment(withError: FlutterError(code: "DECODING_ERROR", message: errorMessage, details: error.localizedDescription))
        }
    }
    
    private func handleSavedCardPayment(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let orderDetails = args["orderDetails"] as? [String: Any] else {
            completePayment(withError: FlutterError(code: "INVALID_ARGUMENTS", message: "orderDetails are required", details: nil))
            return
        }
        
        let cvv = args["cvv"] as? String
        applyUISettings(from: args)

        do {
            let orderData = try JSONSerialization.data(withJSONObject: orderDetails, options: [])
            let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: orderData)

            DispatchQueue.main.async {
                guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                    self.completePayment(withError: FlutterError(code: "NO_ROOT_VIEW_CONTROLLER", message: "Could not get root view controller", details: nil))
                    return
                }

                NISdk.sharedInstance.launchSavedCardPayment(cardPaymentDelegate: self,
                                                           overParent: rootViewController,
                                                           for: orderResponse,
                                                           with: cvv)
            }
        } catch {
            let errorMessage = "Failed to create OrderResponse. Error: \(error)"
            completePayment(withError: FlutterError(code: "DECODING_ERROR", message: errorMessage, details: error.localizedDescription))
        }
    }
    
    private func handleApplePay(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let orderDetails = args["orderDetails"] as? [String: Any],
              let applePayConfig = args["applePayConfig"] as? [String: Any] else {
            completePayment(withError: FlutterError(code: "INVALID_ARGUMENTS", message: "orderDetails and applePayConfig are required", details: nil))
            return
        }
        
        do {
            let orderData = try JSONSerialization.data(withJSONObject: orderDetails, options: [])
            let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: orderData)
            
            var paymentRequest = try PKPaymentRequest(from: applePayConfig)
            
            // Add the total amount from the order to the payment summary.
            if let amountValue = orderResponse.amount?.value {
                let totalAmount = NSDecimalNumber(value: amountValue).dividing(by: 100) // Assuming the amount is in minor units
                paymentRequest.paymentSummaryItems.append(PKPaymentSummaryItem(label: "TOTAL", amount: totalAmount))
            }

            DispatchQueue.main.async {
                guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                    self.completePayment(withError: FlutterError(code: "NO_ROOT_VIEW_CONTROLLER", message: "Could not get root view controller", details: nil))
                    return
                }

                NISdk.sharedInstance.initiateApplePayWith(applePayDelegate: self,
                                                          cardPaymentDelegate: self,
                                                          overParent: rootViewController,
                                                          for: orderResponse,
                                                          with: paymentRequest)
            }
        } catch {
            let errorMessage = "Failed to create payment request for Apple Pay. Error: \(error)"
            completePayment(withError: FlutterError(code: "DECODING_ERROR", message: errorMessage, details: error.localizedDescription))
        }
    }

    // MARK: - CardPaymentDelegate & ApplePayDelegate
    
    public func paymentDidComplete(with status: PaymentStatus) {
        let paymentResult: [String: String]
        switch status {
        case .PaymentSuccess: paymentResult = ["status": "SUCCESS", "reason": "Payment was successful"]
        case .PaymentFailed: paymentResult = ["status": "FAILED", "reason": "Payment failed"]
        case .PaymentCancelled: paymentResult = ["status": "CANCELLED", "reason": "Payment was cancelled by the user"]
        @unknown default: paymentResult = ["status": "UNKNOWN", "reason": "An unknown payment status was received"]
        }
        completePayment(withResult: paymentResult)
    }

    public func authorizationDidComplete(with status: AuthorizationStatus) {
        if status == .AuthFailed {
            let paymentResult: [String: String] = ["status": "FAILED", "reason": "Auth Failed"]
            completePayment(withResult: paymentResult)
        }
    }
}

// MARK: - Private Helpers
private extension NetworkInternationalPaymentSdkPlugin {
    
    /// Applies all UI-related settings from the method call arguments.
    func applyUISettings(from args: [String: Any]) {
        let showOrderAmount = args["showOrderAmount"] as? Bool
        let showCancelAlert = args["showCancelAlert"] as? Bool
        let theme = args["theme"] as? [String: [String: String]]

        let sharedSDKInstance = NISdk.sharedInstance
        if let showAmount = showOrderAmount { sharedSDKInstance.shouldShowOrderAmount = showAmount }
        if let showPrompt = showCancelAlert { sharedSDKInstance.shouldShowCancelAlert = showPrompt }

        if let iosTheme = theme?["ios"] { applyTheme(from: iosTheme) }
    }
    
    /// Configures the SDK's colors from a theme dictionary.
    func applyTheme(from iosTheme: [String: String]) {
        let sdkColors = NISdkColors()
        let colorMapping: [String: (UIColor) -> Void] = [
            "cardPreviewColor": { sdkColors.cardPreviewColor = $0 },
            "cardPreviewLabelColor": { sdkColors.cardPreviewLabelColor = $0 },
            "payPageBackgroundColor": { sdkColors.payPageBackgroundColor = $0 },
            "payPageLabelColor": { sdkColors.payPageLabelColor = $0 },
            "textFieldLabelColor": { sdkColors.textFieldLabelColor = $0 },
            "textFieldPlaceholderColor": { sdkColors.textFieldPlaceholderColor = $0 },
            "payPageDividerColor": { sdkColors.payPageDividerColor = $0 },
            "payButtonBackgroundColor": { sdkColors.payButtonBackgroundColor = $0 },
            "payButtonTitleColor": { sdkColors.payButtonTitleColor = $0 },
            "payButtonTitleColorHighlighted": { sdkColors.payButtonTitleColorHighlighted = $0 },
            "payButtonActivityIndicatorColor": { sdkColors.payButtonActivityIndicatorColor = $0 },
            "payPageTitleColor": { sdkColors.payPageTitleColor = $0 }
        ]

        for (key, applyColor) in colorMapping {
            if let hex = iosTheme[key] {
                applyColor(hexStringToUIColor(hex: hex))
            }
        }

        NISdk.sharedInstance.setSDKColors(sdkColors: sdkColors)
    }
    
    func completePayment(withResult result: Any) {
        guard let flutterResult = NetworkInternationalPaymentSdkPlugin.flutterResult else { return }
        flutterResult(result)
        NetworkInternationalPaymentSdkPlugin.flutterResult = nil
    }
    
    func completePayment(withError error: FlutterError) {
        guard let flutterResult = NetworkInternationalPaymentSdkPlugin.flutterResult else { return }
        flutterResult(error)
        NetworkInternationalPaymentSdkPlugin.flutterResult = nil
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        if ((cString.count) != 6) { return UIColor.gray }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
}

// MARK: - Apple Pay PKPaymentRequest Helper
private extension PKPaymentRequest {
    convenience init(from dictionary: [String: Any]) throws {
        self.init()
        
        guard let merchantId = dictionary["merchantIdentifier"] as? String,
              let countryCode = dictionary["countryCode"] as? String,
              let currencyCode = dictionary["currencyCode"] as? String,
              let summaryItems = dictionary["paymentSummaryItems"] as? [[String: Any]] else {
            throw NSError(domain: "com.enoc.network_international_payment_sdk", code: 100, userInfo: [NSLocalizedDescriptionKey: "Missing required fields in applePayConfig"])
        }
        
        self.merchantIdentifier = merchantId
        self.countryCode = countryCode
        self.currencyCode = currencyCode
        self.merchantCapabilities = [.capability3DS, .capabilityDebit, .capabilityCredit]
        
        self.paymentSummaryItems = summaryItems.map { item -> PKPaymentSummaryItem in
            let label = item["label"] as? String ?? ""
            let amount = item["amount"] as? Double ?? 0.0
            return PKPaymentSummaryItem(label: label, amount: NSDecimalNumber(value: amount))
        }
    }
}
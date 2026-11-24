import Flutter
import UIKit
import NISdk
import os.log
import PassKit

public class NetworkInternationalPaymentSdkPlugin: NSObject, FlutterPlugin, NetworkInternationalPaymentSdkApi, CardPaymentDelegate, ApplePayDelegate {
    private var pendingContinuation: CheckedContinuation<PaymentResultData, Error>?
    private var currentOrderReference: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = NetworkInternationalPaymentSdkPlugin()
        NISdk.sharedInstance.platform = .iOSFlutter
        NetworkInternationalPaymentSdkApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }

    func startCardPayment(request: CardPaymentRequest) async throws -> PaymentResultData {
        return try await withCheckedThrowingContinuation { continuation in
            if pendingContinuation != nil {
                continuation.resume(throwing: PigeonError(code: "ALREADY_ACTIVE", message: "A payment is already in progress.", details: nil))
                return
            }
            pendingContinuation = continuation

            if let showAmount = request.showOrderAmount { NISdk.sharedInstance.shouldShowOrderAmount = showAmount }
            if let showPrompt = request.showCancelAlert { NISdk.sharedInstance.shouldShowCancelAlert = showPrompt }
            if let iosTheme = extractIosTheme(from: request.themeMap) {
                applyTheme(from: iosTheme)
            }

            do {
                guard let orderData = request.orderDetailsJson.data(using: .utf8) else {
                    completePayment(withError: PigeonError(code: "INVALID_ARGUMENTS", message: "Invalid orderDetails JSON string", details: nil))
                    return
                }
                let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: orderData)
                self.currentOrderReference = orderResponse.reference

                DispatchQueue.main.async {
                    guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                        self.completePayment(withError: PigeonError(code: "NO_ROOT_VIEW_CONTROLLER", message: "Could not get root view controller", details: nil))
                        return
                    }

                    NISdk.sharedInstance.showCardPaymentViewWith(cardPaymentDelegate: self,
                                                                 overParent: rootViewController,
                                                                 for: orderResponse)
                }
            } catch {
                let errorMessage = "Failed to create OrderResponse. Error: \(error)"
                completePayment(withError: PigeonError(code: "DECODING_ERROR", message: errorMessage, details: error.localizedDescription))
            }
        }
    }

    func startSavedCardPayment(request: SavedCardPaymentRequest) async throws -> PaymentResultData {
        return try await withCheckedThrowingContinuation { continuation in
            if pendingContinuation != nil {
                continuation.resume(throwing: PigeonError(code: "ALREADY_ACTIVE", message: "A payment is already in progress.", details: nil))
                return
            }
            pendingContinuation = continuation

            if let iosTheme = extractIosTheme(from: request.themeMap) {
                applyTheme(from: iosTheme)
            }

            do {
                guard let orderData = request.orderDetailsJson.data(using: .utf8) else {
                    completePayment(withError: PigeonError(code: "INVALID_ARGUMENTS", message: "Invalid orderDetails JSON string", details: nil))
                    return
                }
                let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: orderData)
                self.currentOrderReference = orderResponse.reference

                DispatchQueue.main.async {
                    guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                        self.completePayment(withError: PigeonError(code: "NO_ROOT_VIEW_CONTROLLER", message: "Could not get root view controller", details: nil))
                        return
                    }

                    NISdk.sharedInstance.launchSavedCardPayment(cardPaymentDelegate: self,
                                                                overParent: rootViewController,
                                                                for: orderResponse,
                                                                with: request.cvv)
                }
            } catch {
                let errorMessage = "Failed to create OrderResponse. Error: \(error)"
                completePayment(withError: PigeonError(code: "DECODING_ERROR", message: errorMessage, details: error.localizedDescription))
            }
        }
    }

    func startApplePay(request: ApplePayRequest) async throws -> PaymentResultData {
        return try await withCheckedThrowingContinuation { continuation in
            if pendingContinuation != nil {
                continuation.resume(throwing: PigeonError(code: "ALREADY_ACTIVE", message: "A payment is already in progress.", details: nil))
                return
            }
            pendingContinuation = continuation

            if let iosTheme = extractIosTheme(from: request.themeMap) {
                applyTheme(from: iosTheme)
            }

            do {
                guard let orderData = request.orderDetailsJson.data(using: .utf8) else {
                    completePayment(withError: PigeonError(code: "INVALID_ARGUMENTS", message: "Invalid orderDetails JSON string", details: nil))
                    return
                }
                let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: orderData)
                self.currentOrderReference = orderResponse.reference

                let applePayDict = extractApplePayDict(from: request.applePayConfigMap)
                var paymentRequest = try PKPaymentRequest(from: applePayDict)

                if let amountValue = orderResponse.amount?.value {
                    let totalAmount = NSDecimalNumber(value: amountValue).dividing(by: 100)
                    paymentRequest.paymentSummaryItems.append(PKPaymentSummaryItem(label: "TOTAL", amount: totalAmount))
                }

                DispatchQueue.main.async {
                    guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                        self.completePayment(withError: PigeonError(code: "NO_ROOT_VIEW_CONTROLLER", message: "Could not get root view controller", details: nil))
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
                completePayment(withError: PigeonError(code: "DECODING_ERROR", message: errorMessage, details: error.localizedDescription))
            }
        }
    }

    func startSamsungPay(request: SamsungPayRequest) async throws -> PaymentResultData {
        return PaymentResultData(status: "FAILED", reason: "Samsung Pay is only supported on Android.")
    }

    // MARK: - CardPaymentDelegate & ApplePayDelegate

    public func paymentDidComplete(with status: PaymentStatus) {
        let paymentResult: PaymentResultData
        switch status {
        case .PaymentSuccess: paymentResult = PaymentResultData(status: "SUCCESS", reason: "Payment was successful")
        case .PaymentFailed: paymentResult = PaymentResultData(status: "FAILED", reason: "Payment failed. REF: \(currentOrderReference ?? "UNKNOWN")")
        case .PaymentCancelled: paymentResult = PaymentResultData(status: "CANCELLED", reason: "Payment was cancelled by the user")
        @unknown default: paymentResult = PaymentResultData(status: "UNKNOWN", reason: "An unknown payment status was received")
        }
        currentOrderReference = nil
        completePayment(withResult: paymentResult)
    }

    public func authorizationDidComplete(with status: AuthorizationStatus) {
        if status == .AuthFailed {
            let paymentResult = PaymentResultData(status: "FAILED", reason: "Auth Failed")
            completePayment(withResult: paymentResult)
        }
    }
}

// MARK: - Private Helpers
private extension NetworkInternationalPaymentSdkPlugin {

    func extractIosTheme(from themeMap: [String?: Any?]?) -> [String: String]? {
        guard let themeMap = themeMap else { return nil }
        for (key, value) in themeMap {
            if key == "ios", let dict = value as? [String: String] {
                return dict
            }
        }
        return nil
    }

    func extractApplePayDict(from configMap: [String?: Any?]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in configMap {
            if let k = key, let v = value {
                result[k] = v
            }
        }
        return result
    }

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

    func completePayment(withResult result: PaymentResultData) {
        guard let continuation = pendingContinuation else { return }
        continuation.resume(returning: result)
        pendingContinuation = nil
    }

    func completePayment(withError error: Error) {
        guard let continuation = pendingContinuation else { return }
        continuation.resume(throwing: error)
        pendingContinuation = nil
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

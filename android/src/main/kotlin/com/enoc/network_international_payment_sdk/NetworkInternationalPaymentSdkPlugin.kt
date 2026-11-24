package com.enoc.network_international_payment_sdk

import android.app.Activity
import android.view.Window
import androidx.activity.ComponentActivity
import androidx.core.view.WindowCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import org.json.JSONObject
import payment.sdk.android.SDKConfig
import payment.sdk.android.core.Order
import payment.sdk.android.core.api.CoroutinesGatewayHttpClient
import payment.sdk.android.googlepay.GooglePayConfig
import payment.sdk.android.payments.PaymentsLauncher
import payment.sdk.android.payments.PaymentsRequest
import payment.sdk.android.payments.PaymentsResult
import payment.sdk.android.samsungpay.SamsungPayClient
import payment.sdk.android.samsungpay.SamsungPayResponse
import payment.sdk.android.savedCard.SavedCardPaymentLauncher
import payment.sdk.android.savedCard.SavedCardPaymentRequest

class NetworkInternationalPaymentSdkPlugin :
    FlutterPlugin,
    ActivityAware,
    NetworkInternationalPaymentSdkApi {

    private var activity: Activity? = null
    private var pendingCallback: ((Result<PaymentResultData>) -> Unit)? = null

    private var paymentsLauncher: PaymentsLauncher? = null
    private var savedCardPaymentLauncher: SavedCardPaymentLauncher? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        NetworkInternationalPaymentSdkApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        NetworkInternationalPaymentSdkApi.setUp(binding.binaryMessenger, null)
    }

    override fun startCardPayment(
        request: CardPaymentRequest,
        callback: (Result<PaymentResultData>) -> Unit
    ) {
        try {
            if (pendingCallback != null) {
                callback(Result.failure(FlutterError("ALREADY_ACTIVE", "A payment is already in progress.", null)))
                return
            }
            pendingCallback = callback

            SDKConfig.shouldShowOrderAmount(request.showOrderAmount ?: true)
            SDKConfig.shouldShowCancelAlert(request.showCancelAlert ?: true)

            val json = JSONObject(request.orderDetailsJson)
            val links = json.optJSONObject("_links")
                ?: throw Exception("_links not found in orderDetails")

            val authUrl = links.optJSONObject("payment-authorization")?.optString("href")
                ?: throw Exception("Authorization URL not found in orderDetails")

            val paymentUrl = links.optJSONObject("payment")?.optString("href")
                ?: throw Exception("Payment URL not found in orderDetails")

            paymentsLauncher?.let { launcher ->
                val requestBuilder = PaymentsRequest.builder()
                    .gatewayAuthorizationUrl(authUrl)
                    .payPageUrl(paymentUrl)

                request.googlePayConfigMap?.let { map ->
                    @Suppress("UNCHECKED_CAST")
                    requestBuilder.setGooglePayConfig(createGooglePayConfig(map as Map<String, Any>))
                }

                launcher.launch(requestBuilder.build())
            } ?: throw IllegalStateException("Plugin is not attached to a ComponentActivity or the launcher could not be initialized.")

        } catch (e: Exception) {
            pendingCallback = null
            callback(Result.failure(FlutterError("LAUNCH_ERROR", e.message ?: "An unknown error occurred", e.localizedMessage)))
        }
    }

    override fun startSavedCardPayment(
        request: SavedCardPaymentRequest,
        callback: (Result<PaymentResultData>) -> Unit
    ) {
        try {
            if (pendingCallback != null) {
                callback(Result.failure(FlutterError("ALREADY_ACTIVE", "A payment is already in progress.", null)))
                return
            }
            pendingCallback = callback

            val json = JSONObject(request.orderDetailsJson)
            val links = json.optJSONObject("_links")
                ?: throw Exception("_links not found in orderDetails")

            val authUrl = links.optJSONObject("payment-authorization")?.optString("href")
                ?: throw Exception("Authorization URL not found in orderDetails")

            val paymentUrl = links.optJSONObject("payment")?.optString("href")
                ?: throw Exception("Payment URL not found in orderDetails")

            savedCardPaymentLauncher?.let { launcher ->
                val req = SavedCardPaymentRequest.builder()
                    .gatewayAuthorizationUrl(authUrl)
                    .payPageUrl(paymentUrl)
                    .apply { request.cvv?.let { setCvv(it) } }
                    .build()
                launcher.launch(req)
            } ?: throw IllegalStateException("Plugin is not attached to a ComponentActivity or the launcher could not be initialized.")

        } catch (e: Exception) {
            pendingCallback = null
            callback(Result.failure(FlutterError("LAUNCH_ERROR", e.message ?: "An unknown error occurred", e.localizedMessage)))
        }
    }

    override fun startApplePay(
        request: ApplePayRequest,
        callback: (Result<PaymentResultData>) -> Unit
    ) {
        callback(Result.success(PaymentResultData("FAILED", "Apple Pay is only supported on iOS.")))
    }

    override fun startSamsungPay(
        request: SamsungPayRequest,
        callback: (Result<PaymentResultData>) -> Unit
    ) {
        try {
            if (pendingCallback != null) {
                callback(Result.failure(FlutterError("ALREADY_ACTIVE", "A payment is already in progress.", null)))
                return
            }
            pendingCallback = callback

            val json = JSONObject(request.orderDetailsJson)
            val samsungPayConfig = request.samsungPayConfigMap

            val serviceId = samsungPayConfig["serviceId"] as? String
                ?: throw IllegalArgumentException("serviceId is required for Samsung Pay")
            val merchantName = samsungPayConfig["merchantName"] as? String
                ?: throw IllegalArgumentException("merchantName is required for Samsung Pay")

            activity?.let { currentActivity ->
                val samsungPayClient = SamsungPayClient(currentActivity, serviceId, CoroutinesGatewayHttpClient())
                samsungPayClient.isSamsungPayAvailable(object : com.samsung.android.sdk.samsungpay.v2.StatusListener {
                    override fun onSuccess(status: Int, bundle: android.os.Bundle?) {
                        if (status == com.samsung.android.sdk.samsungpay.v2.SamsungPay.SPAY_READY) {
                            val order = createOrderFromJson(json)
                            samsungPayClient.startSamsungPay(order, merchantName, object : SamsungPayResponse {
                                override fun onSuccess() {
                                    val cb = pendingCallback
                                    pendingCallback = null
                                    activity?.runOnUiThread {
                                        cb?.invoke(Result.success(PaymentResultData("SUCCESS", "Samsung Pay payment successful")))
                                    }
                                }

                                override fun onFailure(error: String) {
                                    val cb = pendingCallback
                                    pendingCallback = null
                                    activity?.runOnUiThread {
                                        cb?.invoke(Result.success(PaymentResultData("FAILED", error)))
                                    }
                                }
                            })
                        } else {
                            val reason = when (status) {
                                com.samsung.android.sdk.samsungpay.v2.SamsungPay.SPAY_NOT_READY -> "Samsung Pay is installed but not set up. Please add a card."
                                com.samsung.android.sdk.samsungpay.v2.SamsungPay.SPAY_NOT_SUPPORTED -> "This device does not support Samsung Pay."
                                else -> "Samsung Pay is not available on this device. Status code: $status"
                            }
                            val cb = pendingCallback
                            pendingCallback = null
                            activity?.runOnUiThread {
                                cb?.invoke(Result.success(PaymentResultData("FAILED", reason)))
                            }
                        }
                    }

                    override fun onFail(errCode: Int, bundle: android.os.Bundle?) {
                        val cb = pendingCallback
                        pendingCallback = null
                        activity?.runOnUiThread {
                            cb?.invoke(Result.success(PaymentResultData("FAILED", "Samsung Pay status check failed with code: $errCode")))
                        }
                    }
                })
            } ?: throw IllegalStateException("Plugin is not attached to a valid activity")

        } catch (e: Exception) {
            pendingCallback = null
            callback(Result.failure(FlutterError("LAUNCH_ERROR", e.message ?: "An unknown error occurred", e.localizedMessage)))
        }
    }

    private fun createGooglePayConfig(configMap: Map<String, Any>): GooglePayConfig {
        val environmentStr = configMap["environment"] as? String ?: "test"
        val merchantGatewayId = configMap["merchantGatewayId"] as? String
            ?: throw IllegalArgumentException("merchantGatewayId is required for Google Pay")

        val environment = if (environmentStr.equals("production", ignoreCase = true)) {
            GooglePayConfig.Environment.Production
        } else {
            GooglePayConfig.Environment.Test
        }

        @Suppress("UNCHECKED_CAST")
        val billingAddressConfigMap = configMap["billingAddressConfig"] as? Map<String, Any>
        val isRequired = billingAddressConfigMap?.get("isRequired") as? Boolean ?: false
        val isPhoneNumberRequired = billingAddressConfigMap?.get("isPhoneNumberRequired") as? Boolean ?: false
        val formatStr = billingAddressConfigMap?.get("format") as? String ?: "min"
        val format = if (formatStr.equals("full", ignoreCase = true)) {
            GooglePayConfig.Format.Full
        } else {
            GooglePayConfig.Format.Min
        }

        val billingAddressConfig = GooglePayConfig.BillingAddressConfig(
            isRequired,
            format,
            isPhoneNumberRequired
        )

        return GooglePayConfig(
            environment = environment,
            merchantGatewayId = merchantGatewayId,
            isEmailRequired = configMap["isEmailRequired"] as? Boolean ?: false,
            billingAddressConfig = billingAddressConfig
        )
    }

    private fun createOrderFromJson(from: JSONObject): Order {
        val order = Order()
        if (from.has("reference")) order.reference = from.optString("reference")
        if (from.has("outletId")) order.outletId = from.optString("outletId")
        from.optJSONObject("amount")?.let {
            val amount = Order.Amount()
            amount.value = it.optDouble("value")
            amount.currencyCode = it.optString("currencyCode")
            order.amount = amount
        }
        from.optJSONObject("_links")?.let {
            val links = Order.Links()
            it.optJSONObject("payment-authorization")?.let { auth ->
                val href = Order.Href()
                href.href = auth.optString("href")
                links.paymentAuthorizationUrl = href
            }
            it.optJSONObject("payment")?.let { pay ->
                val href = Order.Href()
                href.href = pay.optString("href")
                links.paymentUrl = href
            }
            order.links = links
        }
        return order
    }

    private fun handlePaymentResult(paymentResult: PaymentsResult) {
        val cb = pendingCallback
        pendingCallback = null
        if (cb == null) return

        val resultData = when (paymentResult) {
            is PaymentsResult.Success -> PaymentResultData("SUCCESS", "Payment was successful")
            is PaymentsResult.Authorised -> PaymentResultData("AUTHORISED", "Payment was authorised")
            is PaymentsResult.Failed -> PaymentResultData("FAILED", paymentResult.error)
            is PaymentsResult.Cancelled -> PaymentResultData("CANCELLED", "Payment was cancelled by the user")
            is PaymentsResult.PostAuthReview -> PaymentResultData("POST_AUTH_REVIEW", "Payment requires post-authorization review")
            is PaymentsResult.PartialAuthDeclined -> PaymentResultData("PARTIAL_AUTH_DECLINED", "Partial authorization was declined")
            is PaymentsResult.PartialAuthDeclineFailed -> PaymentResultData("PARTIAL_AUTH_DECLINE_FAILED", "Partial authorization decline failed")
            is PaymentsResult.PartiallyAuthorised -> PaymentResultData("PARTIALLY_AUTHORISED", "Payment was partially authorised")
            else -> PaymentResultData("UNKNOWN", "An unknown payment status was received")
        }

        activity?.runOnUiThread {
            cb.invoke(Result.success(resultData))
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        (binding.activity as? ComponentActivity)?.let {
            paymentsLauncher = PaymentsLauncher(it, ::handlePaymentResult)
            savedCardPaymentLauncher = SavedCardPaymentLauncher(it, ::handlePaymentResult)
        }
        enableEdgeToEdge()
    }

    private fun enableEdgeToEdge() {
        activity?.window?.let { window: Window ->
            WindowCompat.setDecorFitsSystemWindows(window, true)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        paymentsLauncher = null
        savedCardPaymentLauncher = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        (binding.activity as? ComponentActivity)?.let {
            paymentsLauncher = PaymentsLauncher(it, ::handlePaymentResult)
            savedCardPaymentLauncher = SavedCardPaymentLauncher(it, ::handlePaymentResult)
        }
        enableEdgeToEdge()
    }

    override fun onDetachedFromActivity() {
        activity = null
        paymentsLauncher = null
        savedCardPaymentLauncher = null
    }
}

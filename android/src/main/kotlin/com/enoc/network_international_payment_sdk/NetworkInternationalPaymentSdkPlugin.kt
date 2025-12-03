package com.enoc.network_international_payment_sdk

import android.app.Activity
import androidx.activity.ComponentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import payment.sdk.android.SDKConfig
import payment.sdk.android.core.Order
import payment.sdk.android.googlepay.GooglePayConfig
import payment.sdk.android.payments.PaymentsLauncher
import payment.sdk.android.payments.PaymentsRequest
import payment.sdk.android.payments.PaymentsResult
import payment.sdk.android.samsungpay.SamsungPayClient
import payment.sdk.android.samsungpay.SamsungPayResponse
import payment.sdk.android.savedCard.SavedCardPaymentLauncher
import payment.sdk.android.savedCard.SavedCardPaymentRequest
import payment.sdk.android.core.api.CoroutinesGatewayHttpClient

class NetworkInternationalPaymentSdkPlugin:
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    
    private var paymentsLauncher: PaymentsLauncher? = null
    private var savedCardPaymentLauncher: SavedCardPaymentLauncher? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "network_international_payment_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startCardPayment" -> handleNewCardPayment(call, result)
            "startSavedCardPayment" -> handleSavedCardPayment(call, result)
            "startSamsungPay" -> handleSamsungPayPayment(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleNewCardPayment(call: MethodCall, result: Result) {
        try {
            if (pendingResult != null) {
                result.error("ALREADY_ACTIVE", "A payment is already in progress.", null)
                return
            }
            pendingResult = result

            val orderDetails = call.argument<HashMap<String, Any>>("orderDetails")
                ?: throw IllegalArgumentException("orderDetails is required")
            
            val showOrderAmount = call.argument<Boolean>("showOrderAmount")
            val showCancelAlert = call.argument<Boolean>("showCancelAlert")
            SDKConfig.shouldShowOrderAmount(showOrderAmount ?: true)
            SDKConfig.shouldShowCancelAlert(showCancelAlert ?: true)

            val googlePayConfigMap = call.argument<HashMap<String, Any>>("googlePayConfig")

            val links = (orderDetails["_links"] as? HashMap<String, Any>)
                ?: throw Exception("_links not found in orderDetails")

            val authUrl = ((links["payment-authorization"] as? HashMap<String, Any>)?.get("href") as? String)
                ?: throw Exception("Authorization URL not found in orderDetails")

            val paymentUrl = ((links["payment"] as? HashMap<String, Any>)?.get("href") as? String)
                ?: throw Exception("Payment URL not found in orderDetails")

            paymentsLauncher?.let { launcher ->
                val requestBuilder = PaymentsRequest.builder()
                    .gatewayAuthorizationUrl(authUrl)
                    .payPageUrl(paymentUrl)
                
                googlePayConfigMap?.let {
                    requestBuilder.setGooglePayConfig(createGooglePayConfig(it))
                }
                
                launcher.launch(requestBuilder.build())
            } ?: throw IllegalStateException("Plugin is not attached to a ComponentActivity or the launcher could not be initialized.")

        } catch (e: Exception) {
            pendingResult?.error("LAUNCH_ERROR", e.message ?: "An unknown error occurred", e.localizedMessage)
            pendingResult = null
        }
    }
    
    private fun handleSavedCardPayment(call: MethodCall, result: Result) {
        try {
             if (pendingResult != null) {
                result.error("ALREADY_ACTIVE", "A payment is already in progress.", null)
                return
            }
            pendingResult = result

            val orderDetails = call.argument<HashMap<String, Any>>("orderDetails")
                ?: throw IllegalArgumentException("orderDetails is required")
            val cvv = call.argument<String>("cvv")

            val links = (orderDetails["_links"] as? HashMap<String, Any>)
                ?: throw Exception("_links not found in orderDetails")

            val authUrl = ((links["payment-authorization"] as? HashMap<String, Any>)?.get("href") as? String)
                ?: throw Exception("Authorization URL not found in orderDetails")

            val paymentUrl = ((links["payment"] as? HashMap<String, Any>)?.get("href") as? String)
                ?: throw Exception("Payment URL not found in orderDetails")

            savedCardPaymentLauncher?.let { launcher ->
                val request = SavedCardPaymentRequest.builder()
                    .gatewayAuthorizationUrl(authUrl)
                    .payPageUrl(paymentUrl)
                    .apply { cvv?.let { setCvv(it) } }
                    .build()
                launcher.launch(request)
            } ?: throw IllegalStateException("Plugin is not attached to a ComponentActivity or the launcher could not be initialized.")

        } catch (e: Exception) {
            pendingResult?.error("LAUNCH_ERROR", e.message ?: "An unknown error occurred", e.localizedMessage)
            pendingResult = null
        }
    }

    private fun handleSamsungPayPayment(call: MethodCall, result: Result) {
        try {
            if (pendingResult != null) {
                result.error("ALREADY_ACTIVE", "A payment is already in progress.", null)
                return
            }
            pendingResult = result

            val orderDetails = call.argument<HashMap<String, Any>>("orderDetails")
                ?: throw IllegalArgumentException("orderDetails is required")
            val samsungPayConfig = call.argument<HashMap<String, Any>>("samsungPayConfig")
                ?: throw IllegalArgumentException("samsungPayConfig is required")

            val serviceId = samsungPayConfig["serviceId"] as? String
                ?: throw IllegalArgumentException("serviceId is required for Samsung Pay")
            val merchantName = samsungPayConfig["merchantName"] as? String
                ?: throw IllegalArgumentException("merchantName is required for Samsung Pay")

            activity?.let { currentActivity ->
                // SamsungPayClient must be instantiated here with the activity context
                val samsungPayClient = SamsungPayClient(currentActivity, serviceId, CoroutinesGatewayHttpClient())

                samsungPayClient.isSamsungPayAvailable(object : com.samsung.android.sdk.samsungpay.v2.StatusListener {
                    override fun onSuccess(status: Int, bundle: android.os.Bundle?) {
                        if (status == com.samsung.android.sdk.samsungpay.v2.SamsungPay.SPAY_READY) {
                            val order = createOrder(from = orderDetails)
                            samsungPayClient.startSamsungPay(order, merchantName, object : SamsungPayResponse {
                                override fun onSuccess() {
                                    val successResult = mapOf("status" to "SUCCESS", "reason" to "Samsung Pay payment successful")
                                    activity?.runOnUiThread {
                                        pendingResult?.success(successResult)
                                        pendingResult = null
                                    }
                                }

                                override fun onFailure(error: String) {
                                    val error1 = mapOf("status" to "FAILED", "reason" to error)
                                    activity?.runOnUiThread {
                                        pendingResult?.success(error1)
                                        pendingResult = null
                                    }
                                }
                            })
                        } else {
                            val error = mapOf("status" to "FAILED", "reason" to "Samsung Pay is not available on this device.")
                            activity?.runOnUiThread {
                                pendingResult?.success(error)
                                pendingResult = null
                            }
                        }
                    }

                    override fun onFail(errCode: Int, bundle: android.os.Bundle?) {
                        val error = mapOf("status" to "FAILED", "reason" to "Samsung Pay status check failed with code: $errCode")
                        activity?.runOnUiThread {
                            pendingResult?.success(error)
                            pendingResult = null
                        }
                    }
                })
            } ?: throw IllegalStateException("Plugin is not attached to a valid activity")

        } catch (e: Exception) {
            pendingResult?.error("LAUNCH_ERROR", e.message ?: "An unknown error occurred", e.localizedMessage)
            pendingResult = null
        }
    }

    private fun createGooglePayConfig(configMap: HashMap<String, Any>): GooglePayConfig {
        val environmentStr = configMap["environment"] as? String ?: "test"
        val merchantGatewayId = configMap["merchantGatewayId"] as? String
            ?: throw IllegalArgumentException("merchantGatewayId is required for Google Pay")

        val environment = if (environmentStr.equals("production", ignoreCase = true)) {
            GooglePayConfig.Environment.Production
        } else {
            GooglePayConfig.Environment.Test
        }

        val billingAddressConfigMap = configMap["billingAddressConfig"] as? HashMap<String, Any>
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

    private fun createOrder(from: HashMap<String, Any>): Order {
        val order = Order()
        (from["reference"] as? String)?.let { order.reference = it }
        (from["outletId"] as? String)?.let { order.outletId = it }
        (from["amount"] as? HashMap<String, Any>)?.let {
            val amount = Order.Amount()
            amount.value = it["value"] as? Double
            amount.currencyCode = it["currencyCode"] as? String
            order.amount = amount
        }
        (from["_links"] as? HashMap<String, Any>)?.let {
            val links = Order.Links()
            (it["payment-authorization"] as? HashMap<String, String>)?.let {
                val href = Order.Href()
                href.href = it["href"]
                links.paymentAuthorizationUrl = href
            }
            (it["payment"] as? HashMap<String, String>)?.let {
                val href = Order.Href()
                href.href = it["href"]
                links.paymentUrl = href
            }
            order.links = links
        }
        return order
    }

    private fun handlePaymentResult(paymentResult: PaymentsResult) {
        val result = pendingResult
        pendingResult = null
        if (result == null) return

        val resultMap = when (paymentResult) {
            is PaymentsResult.Success -> mapOf("status" to "SUCCESS", "reason" to "Payment was successful")
            is PaymentsResult.Authorised -> mapOf("status" to "AUTHORISED", "reason" to "Payment was authorised")
            is PaymentsResult.Failed -> mapOf("status" to "FAILED", "reason" to paymentResult.error)
            is PaymentsResult.Cancelled -> mapOf("status" to "CANCELLED", "reason" to "Payment was cancelled by the user")
            is PaymentsResult.PostAuthReview -> mapOf("status" to "POST_AUTH_REVIEW", "reason" to "Payment requires post-authorization review")
            is PaymentsResult.PartialAuthDeclined -> mapOf("status" to "PARTIAL_AUTH_DECLINED", "reason" to "Partial authorization was declined")
            is PaymentsResult.PartialAuthDeclineFailed -> mapOf("status" to "PARTIAL_AUTH_DECLINE_FAILED", "reason" to "Partial authorization decline failed")
            is PaymentsResult.PartiallyAuthorised -> mapOf("status" to "PARTIALLY_AUTHORISED", "reason" to "Payment was partially authorised")
            else -> mapOf("status" to "UNKNOWN", "reason" to "An unknown payment status was received")
        }

        activity?.runOnUiThread {
            result.success(resultMap)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        (binding.activity as? ComponentActivity)?.let {
            paymentsLauncher = PaymentsLauncher(it, ::handlePaymentResult)
            savedCardPaymentLauncher = SavedCardPaymentLauncher(it, ::handlePaymentResult)
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
    }

    override fun onDetachedFromActivity() {
        activity = null
        paymentsLauncher = null
        savedCardPaymentLauncher = null
    }
}

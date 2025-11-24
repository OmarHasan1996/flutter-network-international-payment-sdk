package com.enoc.network_international_payment_sdk

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import payment.sdk.android.PaymentClient
import payment.sdk.android.cardpayment.CardPaymentData
import payment.sdk.android.cardpayment.CardPaymentRequest
import payment.sdk.android.core.SDKConfig

class NetworkInternationalPaymentSdkPlugin:
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    companion object {
        private const val CARD_PAYMENT_REQUEST_CODE = 777
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "network_international_payment_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startCardPayment" -> handleNewCardPayment(call, result)
            "startSavedCardPayment" -> handleSavedCardPayment(call, result)
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
            val merchantId = call.argument<String>("merchantId")
            
            // UI flags
            val showOrderAmount = call.argument<Boolean>("showOrderAmount")
            val showCancelAlert = call.argument<Boolean>("showCancelAlert")
            SDKConfig.shouldShowOrderAmount(showOrderAmount ?: true)
            SDKConfig.shouldShowCancelAlert(showCancelAlert ?: true)

            val links = (orderDetails["_links"] as? HashMap<String, Any>)
                ?: throw Exception("_links not found in orderDetails")

            val authUrl = ((links["payment-authorization"] as? HashMap<String, Any>)?.get("href") as? String)
                ?: throw Exception("Authorization URL not found in orderDetails")

            val paymentUrl = ((links["payment"] as? HashMap<String, Any>)?.get("href") as? String)
                ?: throw Exception("Payment URL not found in orderDetails")

            val code = paymentUrl.substringAfter("code=").takeIf { it.isNotEmpty() }
                ?: throw Exception("Code not found or is empty in payment URL")

            activity?.let { currentActivity ->
                val paymentClient = PaymentClient(currentActivity, merchantId)
                paymentClient.launchCardPayment(
                    CardPaymentRequest.Builder()
                        .gatewayUrl(authUrl)
                        .code(code)
                        .build(),
                    CARD_PAYMENT_REQUEST_CODE
                )
            } ?: throw IllegalStateException("Plugin is not attached to a valid activity")

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
            val serviceId = call.argument<String>("merchantId") // Using merchantId as serviceId
            val cvv = call.argument<String>("cvv")

             activity?.let { currentActivity ->
                val paymentClient = PaymentClient(currentActivity, serviceId)
                paymentClient.launchSavedCardPayment(order = orderDetails, cvv = cvv, code = CARD_PAYMENT_REQUEST_CODE)
             } ?: throw IllegalStateException("Plugin is not attached to a valid activity")

        } catch (e: Exception) {
            pendingResult?.error("LAUNCH_ERROR", e.message ?: "An unknown error occurred", e.localizedMessage)
            pendingResult = null
        }
    }

    private fun toPaymentResultMap(data: CardPaymentData?): Map<String, String?> {
        if (data == null) {
            return mapOf("status" to "ERROR", "reason" to "CardPaymentData was null")
        }
        val reason = data.reason.orEmpty()
        val status = when (data.code) {
            CardPaymentData.STATUS_PAYMENT_AUTHORIZED -> "AUTHORISED"
            CardPaymentData.STATUS_PAYMENT_PURCHASED, CardPaymentData.STATUS_PAYMENT_CAPTURED -> "SUCCESS"
            CardPaymentData.STATUS_POST_AUTH_REVIEW -> "POST_AUTH_REVIEW"
            CardPaymentData.STATUS_PARTIAL_AUTH_DECLINED -> "PARTIAL_AUTH_DECLINED"
            CardPaymentData.STATUS_PARTIAL_AUTH_DECLINE_FAILED -> "PARTIAL_AUTH_DECLINE_FAILED"
            CardPaymentData.STATUS_PARTIALLY_AUTHORISED -> "PARTIALLY_AUTHORISED"
            CardPaymentData.STATUS_PAYMENT_FAILED -> "FAILED"
            else -> "UNKNOWN"
        }
        return mapOf("status" to status, "reason" to reason)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != CARD_PAYMENT_REQUEST_CODE) {
            return false
        }

        val result = pendingResult
        pendingResult = null
        if (result == null) {
            return true // Result already handled or lost
        }

        if (resultCode == Activity.RESULT_OK && data != null) {
            val cardPaymentData = CardPaymentData.getFromIntent(data)
            result.success(toPaymentResultMap(cardPaymentData))
        } else {
            result.success(mapOf("status" to "CANCELLED", "reason" to "Payment was cancelled by the user"))
        }

        return true
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}

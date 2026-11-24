package com.enoc.network_international_payment_sdk

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

internal class NetworkInternationalPaymentSdkPluginTest {

    @Test
    fun startCardPayment_withoutOrderDetails_returnsError() {
        val plugin = NetworkInternationalPaymentSdkPlugin()
        val request = CardPaymentRequest(orderDetailsJson = "{}")

        var errorReceived: Throwable? = null
        plugin.startCardPayment(request) { result ->
            errorReceived = result.exceptionOrNull()
        }

        assertTrue(errorReceived is FlutterError)
        assertEquals("LAUNCH_ERROR", (errorReceived as FlutterError).code)
    }

    @Test
    fun startSavedCardPayment_withoutOrderDetails_returnsError() {
        val plugin = NetworkInternationalPaymentSdkPlugin()
        val request = SavedCardPaymentRequest(orderDetailsJson = "{}")

        var errorReceived: Throwable? = null
        plugin.startSavedCardPayment(request) { result ->
            errorReceived = result.exceptionOrNull()
        }

        assertTrue(errorReceived is FlutterError)
        assertEquals("LAUNCH_ERROR", (errorReceived as FlutterError).code)
    }

    @Test
    fun startApplePay_returnsFailedOnAndroid() {
        val plugin = NetworkInternationalPaymentSdkPlugin()
        val request = ApplePayRequest(orderDetailsJson = "{}", applePayConfigMap = emptyMap())

        var resultData: PaymentResultData? = null
        plugin.startApplePay(request) { result ->
            resultData = result.getOrNull()
        }

        assertEquals("FAILED", resultData?.status)
        assertEquals("Apple Pay is only supported on iOS.", resultData?.reason)
    }
}

package com.enoc.network_international_payment_sdk

import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class NetworkInternationalPaymentSdkPluginTest {

    @Test
    fun startCardPayment_withoutOrderDetails_returnsError() = runBlocking {
        val plugin = NetworkInternationalPaymentSdkPlugin()
        val request = CardPaymentRequest(orderDetailsJson = "{}")

        val error = assertFailsWith<FlutterError> {
            plugin.startCardPayment(request)
        }

        assertEquals("LAUNCH_ERROR", error.code)
    }

    @Test
    fun startSavedCardPayment_withoutOrderDetails_returnsError() = runBlocking {
        val plugin = NetworkInternationalPaymentSdkPlugin()
        val request = SavedCardPaymentRequest(orderDetailsJson = "{}")

        val error = assertFailsWith<FlutterError> {
            plugin.startSavedCardPayment(request)
        }

        assertEquals("LAUNCH_ERROR", error.code)
    }

    @Test
    fun startApplePay_returnsFailedOnAndroid() = runBlocking {
        val plugin = NetworkInternationalPaymentSdkPlugin()
        val request = ApplePayRequest(orderDetailsJson = "{}", applePayConfigMap = emptyMap())

        val resultData = plugin.startApplePay(request)

        assertEquals("FAILED", resultData.status)
        assertEquals("Apple Pay is only supported on iOS.", resultData.reason)
    }
}

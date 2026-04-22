package com.enoc.network_international_payment_sdk

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.eq
import org.mockito.Mockito
import kotlin.test.Test

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 */

internal class NetworkInternationalPaymentSdkPluginTest {

    @Test
    fun onMethodCall_unknownMethod_returnsNotImplemented() {
        val plugin = NetworkInternationalPaymentSdkPlugin()

        val call = MethodCall("someUnknownMethod", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }

    @Test
    fun onMethodCall_startCardPayment_withoutOrderDetails_returnsError() {
        val plugin = NetworkInternationalPaymentSdkPlugin()

        val call = MethodCall("startCardPayment", mapOf<String, Any>())
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error(eq("LAUNCH_ERROR"), eq("orderDetails is required"), any())
    }

    @Test
    fun onMethodCall_startSavedCardPayment_withoutOrderDetails_returnsError() {
        val plugin = NetworkInternationalPaymentSdkPlugin()

        val call = MethodCall("startSavedCardPayment", mapOf<String, Any>())
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error(eq("LAUNCH_ERROR"), eq("orderDetails is required"), any())
    }

    @Test
    fun onMethodCall_startSamsungPay_withoutOrderDetails_returnsError() {
        val plugin = NetworkInternationalPaymentSdkPlugin()

        val call = MethodCall("startSamsungPay", mapOf<String, Any>())
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error(eq("LAUNCH_ERROR"), eq("orderDetails is required"), any())
    }

}

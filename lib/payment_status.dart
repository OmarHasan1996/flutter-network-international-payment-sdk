// Represents the final status of a payment.
enum PaymentStatus {
  SUCCESS,
  FAILED,
  CANCELLED,
  UNKNOWN,
  // Detailed statuses from the SDK
  AUTHORISED,
  POST_AUTH_REVIEW,
  PARTIAL_AUTH_DECLINED,
  PARTIAL_AUTH_DECLINE_FAILED,
  PARTIALLY_AUTHORISED
}
// Represents the final status of a payment.
enum PaymentStatus {
  success,
  failed,
  cancelled,
  unknown,
  // Detailed statuses from the SDK
  authorized,
  postAuthReview,
  postAuthDeclined,
  postAuthDeclinedFailed,
  partiallyAuthorized
}
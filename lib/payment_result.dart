// A class to hold the structured result of a payment operation.
import 'package:network_international_payment_sdk/payment_status.dart';

class PaymentResult {
  final PaymentStatus status;
  final String? reason;

  PaymentResult(this.status, this.reason);

  factory PaymentResult.fromMap(Map<dynamic, dynamic> map) {
    final statusString = map['status'] as String? ?? 'UNKNOWN';
    final reason = map['reason'] as String?;
    
    PaymentStatus status;
    switch (statusString) {
      case 'SUCCESS':
        status = PaymentStatus.success;
        break;
      case 'FAILED':
        status = PaymentStatus.failed;
        break;
      case 'CANCELLED':
        status = PaymentStatus.cancelled;
        break;
      case 'AUTHORISED':
        status = PaymentStatus.authorized;
        break;
      case 'POST_AUTH_REVIEW':
        status = PaymentStatus.postAuthReview;
        break;
      case 'PARTIAL_AUTH_DECLINED':
        status = PaymentStatus.partialAuthDeclined;
        break;
      case 'PARTIAL_AUTH_DECLINE_FAILED':
        status = PaymentStatus.partialAuthDeclineFailed;
        break;
      case 'PARTIALLY_AUTHORISED':
        status = PaymentStatus.partiallyAuthorized;
        break;
      default:
        status = PaymentStatus.unknown;
    }
    
    return PaymentResult(status, reason);
  }

  @override
  String toString() => 'PaymentResult(status: $status, reason: $reason)';
}

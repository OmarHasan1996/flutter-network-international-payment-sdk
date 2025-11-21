// A class to hold the structured result of a payment operation.
import 'package:network_international_payment_sdk/payment_status.dart';

class PaymentResult {
  final PaymentStatus status;
  final String? reason;

  PaymentResult(this.status, this.reason);

  factory PaymentResult.fromMap(Map<dynamic, dynamic> map) {
    final statusString = map['status'] as String?;
    final reason = map['reason'] as String?;
    final status = PaymentStatus.values.firstWhere(
          (e) => e.toString() == 'PaymentStatus.$statusString',
      orElse: () => PaymentStatus.UNKNOWN,
    );
    return PaymentResult(status, reason);
  }

  @override
  String toString() => 'PaymentResult(status: $status, reason: $reason)';
}
import 'package:json_annotation/json_annotation.dart';

part 'payment_models.g.dart';

@JsonSerializable()
class Payment {
  final int? id;
  final int studentId;
  final String? studentName;
  final int courseId;
  final String? courseName;
  final double amount;
  final String month;
  final bool paid;

  Payment({
    this.id,
    required this.studentId,
    this.studentName,
    required this.courseId,
    this.courseName,
    required this.amount,
    required this.month,
    required this.paid,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  // Helper getters
  String get statusText => paid ? 'Paid' : 'Unpaid';
  String get formattedMonth {
    final parts = month.split('-');
    if (parts.length == 2) {
      final year = parts[0];
      final monthNum = int.parse(parts[1]);
      const monthNames = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${monthNames[monthNum]} $year';
    }
    return month;
  }
}

@JsonSerializable()
class CreatePaymentRequest {
  final int studentId;
  final int courseId;
  final double amount;
  final String month;
  final bool paid;

  CreatePaymentRequest({
    required this.studentId,
    required this.courseId,
    required this.amount,
    required this.month,
    required this.paid,
  });

  factory CreatePaymentRequest.fromJson(Map<String, dynamic> json) => 
      _$CreatePaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePaymentRequestToJson(this);
}

@JsonSerializable()
class UpdatePaymentRequest {
  final int studentId;
  final int courseId;
  final double amount;
  final String month;
  final bool paid;

  UpdatePaymentRequest({
    required this.studentId,
    required this.courseId,
    required this.amount,
    required this.month,
    required this.paid,
  });

  factory UpdatePaymentRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdatePaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePaymentRequestToJson(this);
}
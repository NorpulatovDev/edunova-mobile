import 'package:json_annotation/json_annotation.dart';

part 'unpaid_models.g.dart';

@JsonSerializable()
class UnpaidPaymentDetail {
  final int? paymentId;
  final String courseName;
  final String teacherName;
  final double amount;
  final String month;

  UnpaidPaymentDetail({
    this.paymentId,
    required this.courseName,
    required this.teacherName,
    required this.amount,
    required this.month,
  });

  factory UnpaidPaymentDetail.fromJson(Map<String, dynamic> json) => 
      _$UnpaidPaymentDetailFromJson(json);
  Map<String, dynamic> toJson() => _$UnpaidPaymentDetailToJson(this);
}

@JsonSerializable()
class UnpaidStudent {
  final int studentId;
  final String studentName;
  final double totalUnpaidAmount;
  final int unpaidPaymentsCount;
  final List<UnpaidPaymentDetail> unpaidPayments;

  UnpaidStudent({
    required this.studentId,
    required this.studentName,
    required this.totalUnpaidAmount,
    required this.unpaidPaymentsCount,
    required this.unpaidPayments,
  });

  factory UnpaidStudent.fromJson(Map<String, dynamic> json) => 
      _$UnpaidStudentFromJson(json);
  Map<String, dynamic> toJson() => _$UnpaidStudentToJson(this);
}

@JsonSerializable()
class PaymentDTO {
  final int? id;
  final int studentId;
  final String studentName;
  final int courseId;
  final String courseName;
  final double amount;
  final String month;
  final bool paid;

  PaymentDTO({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseName,
    required this.amount,
    required this.month,
    required this.paid,
  });

  factory PaymentDTO.fromJson(Map<String, dynamic> json) => 
      _$PaymentDTOFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentDTOToJson(this);
}
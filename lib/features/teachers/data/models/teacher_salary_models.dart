import 'package:json_annotation/json_annotation.dart';

part 'teacher_salary_models.g.dart';

@JsonSerializable()
class PaymentDetail {
  final int paymentId;
  final String studentName;
  final String courseName;
  final double amount;
  final bool paid;

  PaymentDetail({
    required this.paymentId,
    required this.studentName,
    required this.courseName,
    required this.amount,
    required this.paid,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) => 
      _$PaymentDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentDetailToJson(this);
}

@JsonSerializable()
class TeacherSalary {
  final int teacherId;
  final String teacherName;
  final double salaryPercentage;
  final String month;
  final double totalPaymentsReceived;
  final double calculatedSalary;
  final List<PaymentDetail> payments;

  TeacherSalary({
    required this.teacherId,
    required this.teacherName,
    required this.salaryPercentage,
    required this.month,
    required this.totalPaymentsReceived,
    required this.calculatedSalary,
    required this.payments,
  });

  factory TeacherSalary.fromJson(Map<String, dynamic> json) => 
      _$TeacherSalaryFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherSalaryToJson(this);
}
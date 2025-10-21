// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_salary_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentDetail _$PaymentDetailFromJson(Map<String, dynamic> json) =>
    PaymentDetail(
      paymentId: (json['paymentId'] as num).toInt(),
      studentName: json['studentName'] as String,
      courseName: json['courseName'] as String,
      amount: (json['amount'] as num).toDouble(),
      paid: json['paid'] as bool,
    );

Map<String, dynamic> _$PaymentDetailToJson(PaymentDetail instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'studentName': instance.studentName,
      'courseName': instance.courseName,
      'amount': instance.amount,
      'paid': instance.paid,
    };

TeacherSalary _$TeacherSalaryFromJson(Map<String, dynamic> json) =>
    TeacherSalary(
      teacherId: (json['teacherId'] as num).toInt(),
      teacherName: json['teacherName'] as String,
      salaryPercentage: (json['salaryPercentage'] as num).toDouble(),
      month: json['month'] as String,
      totalPaymentsReceived: (json['totalPaymentsReceived'] as num).toDouble(),
      calculatedSalary: (json['calculatedSalary'] as num).toDouble(),
      payments: (json['payments'] as List<dynamic>)
          .map((e) => PaymentDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TeacherSalaryToJson(TeacherSalary instance) =>
    <String, dynamic>{
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'salaryPercentage': instance.salaryPercentage,
      'month': instance.month,
      'totalPaymentsReceived': instance.totalPaymentsReceived,
      'calculatedSalary': instance.calculatedSalary,
      'payments': instance.payments,
    };

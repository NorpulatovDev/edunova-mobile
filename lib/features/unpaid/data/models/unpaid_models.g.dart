// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unpaid_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnpaidPaymentDetail _$UnpaidPaymentDetailFromJson(Map<String, dynamic> json) =>
    UnpaidPaymentDetail(
      paymentId: (json['paymentId'] as num?)?.toInt(),
      courseName: json['courseName'] as String,
      teacherName: json['teacherName'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
    );

Map<String, dynamic> _$UnpaidPaymentDetailToJson(
        UnpaidPaymentDetail instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'courseName': instance.courseName,
      'teacherName': instance.teacherName,
      'amount': instance.amount,
      'month': instance.month,
    };

UnpaidStudent _$UnpaidStudentFromJson(Map<String, dynamic> json) =>
    UnpaidStudent(
      studentId: (json['studentId'] as num).toInt(),
      studentName: json['studentName'] as String,
      totalUnpaidAmount: (json['totalUnpaidAmount'] as num).toDouble(),
      unpaidPaymentsCount: (json['unpaidPaymentsCount'] as num).toInt(),
      unpaidPayments: (json['unpaidPayments'] as List<dynamic>)
          .map((e) => UnpaidPaymentDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnpaidStudentToJson(UnpaidStudent instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'totalUnpaidAmount': instance.totalUnpaidAmount,
      'unpaidPaymentsCount': instance.unpaidPaymentsCount,
      'unpaidPayments': instance.unpaidPayments,
    };

PaymentDTO _$PaymentDTOFromJson(Map<String, dynamic> json) => PaymentDTO(
      id: (json['id'] as num?)?.toInt(),
      studentId: (json['studentId'] as num).toInt(),
      studentName: json['studentName'] as String,
      courseId: (json['courseId'] as num).toInt(),
      courseName: json['courseName'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
      paid: json['paid'] as bool,
    );

Map<String, dynamic> _$PaymentDTOToJson(PaymentDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'courseId': instance.courseId,
      'courseName': instance.courseName,
      'amount': instance.amount,
      'month': instance.month,
      'paid': instance.paid,
    };

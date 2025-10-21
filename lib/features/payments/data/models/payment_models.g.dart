// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      id: (json['id'] as num?)?.toInt(),
      studentId: (json['studentId'] as num).toInt(),
      studentName: json['studentName'] as String?,
      courseId: (json['courseId'] as num).toInt(),
      courseName: json['courseName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
      paid: json['paid'] as bool,
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'courseId': instance.courseId,
      'courseName': instance.courseName,
      'amount': instance.amount,
      'month': instance.month,
      'paid': instance.paid,
    };

CreatePaymentRequest _$CreatePaymentRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePaymentRequest(
      studentId: (json['studentId'] as num).toInt(),
      courseId: (json['courseId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
      paid: json['paid'] as bool,
    );

Map<String, dynamic> _$CreatePaymentRequestToJson(
        CreatePaymentRequest instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'courseId': instance.courseId,
      'amount': instance.amount,
      'month': instance.month,
      'paid': instance.paid,
    };

UpdatePaymentRequest _$UpdatePaymentRequestFromJson(
        Map<String, dynamic> json) =>
    UpdatePaymentRequest(
      studentId: (json['studentId'] as num).toInt(),
      courseId: (json['courseId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
      paid: json['paid'] as bool,
    );

Map<String, dynamic> _$UpdatePaymentRequestToJson(
        UpdatePaymentRequest instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'courseId': instance.courseId,
      'amount': instance.amount,
      'month': instance.month,
      'paid': instance.paid,
    };

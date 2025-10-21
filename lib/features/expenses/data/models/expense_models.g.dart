// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      id: (json['id'] as num?)?.toInt(),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'amount': instance.amount,
      'month': instance.month,
    };

CreateExpenseRequest _$CreateExpenseRequestFromJson(
        Map<String, dynamic> json) =>
    CreateExpenseRequest(
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
    );

Map<String, dynamic> _$CreateExpenseRequestToJson(
        CreateExpenseRequest instance) =>
    <String, dynamic>{
      'description': instance.description,
      'amount': instance.amount,
      'month': instance.month,
    };

UpdateExpenseRequest _$UpdateExpenseRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateExpenseRequest(
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
    );

Map<String, dynamic> _$UpdateExpenseRequestToJson(
        UpdateExpenseRequest instance) =>
    <String, dynamic>{
      'description': instance.description,
      'amount': instance.amount,
      'month': instance.month,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      salaryPercentage: (json['salaryPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'salaryPercentage': instance.salaryPercentage,
    };

CreateTeacherRequest _$CreateTeacherRequestFromJson(
        Map<String, dynamic> json) =>
    CreateTeacherRequest(
      name: json['name'] as String,
      salaryPercentage: (json['salaryPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateTeacherRequestToJson(
        CreateTeacherRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'salaryPercentage': instance.salaryPercentage,
    };

UpdateTeacherRequest _$UpdateTeacherRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateTeacherRequest(
      name: json['name'] as String,
      salaryPercentage: (json['salaryPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$UpdateTeacherRequestToJson(
        UpdateTeacherRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'salaryPercentage': instance.salaryPercentage,
    };

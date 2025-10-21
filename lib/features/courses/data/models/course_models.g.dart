// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      teacherId: (json['teacherId'] as num).toInt(),
      teacherName: json['teacherName'] as String?,
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
      students: (json['students'] as List<dynamic>?)
          ?.map((e) => StudentInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'monthlyFee': instance.monthlyFee,
      'students': instance.students,
    };

StudentInfo _$StudentInfoFromJson(Map<String, dynamic> json) => StudentInfo(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$StudentInfoToJson(StudentInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

CreateCourseRequest _$CreateCourseRequestFromJson(Map<String, dynamic> json) =>
    CreateCourseRequest(
      name: json['name'] as String,
      teacherId: (json['teacherId'] as num).toInt(),
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
    );

Map<String, dynamic> _$CreateCourseRequestToJson(
        CreateCourseRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'teacherId': instance.teacherId,
      'monthlyFee': instance.monthlyFee,
    };

UpdateCourseRequest _$UpdateCourseRequestFromJson(Map<String, dynamic> json) =>
    UpdateCourseRequest(
      name: json['name'] as String,
      teacherId: (json['teacherId'] as num).toInt(),
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
    );

Map<String, dynamic> _$UpdateCourseRequestToJson(
        UpdateCourseRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'teacherId': instance.teacherId,
      'monthlyFee': instance.monthlyFee,
    };

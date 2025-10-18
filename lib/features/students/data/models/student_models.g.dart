// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseInfo _$CourseInfoFromJson(Map<String, dynamic> json) => CourseInfo(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      teacherName: json['teacherName'] as String,
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
    );

Map<String, dynamic> _$CourseInfoToJson(CourseInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'teacherName': instance.teacherName,
      'monthlyFee': instance.monthlyFee,
    };

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      courses: (json['courses'] as List<dynamic>?)
          ?.map((e) => CourseInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'courses': instance.courses,
    };

CreateStudentRequest _$CreateStudentRequestFromJson(
        Map<String, dynamic> json) =>
    CreateStudentRequest(
      name: json['name'] as String,
    );

Map<String, dynamic> _$CreateStudentRequestToJson(
        CreateStudentRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

UpdateStudentRequest _$UpdateStudentRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateStudentRequest(
      name: json['name'] as String,
    );

Map<String, dynamic> _$UpdateStudentRequestToJson(
        UpdateStudentRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

StudentCourseEnrollmentRequest _$StudentCourseEnrollmentRequestFromJson(
        Map<String, dynamic> json) =>
    StudentCourseEnrollmentRequest(
      studentId: (json['studentId'] as num).toInt(),
      courseIds: (json['courseIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$StudentCourseEnrollmentRequestToJson(
        StudentCourseEnrollmentRequest instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'courseIds': instance.courseIds,
    };

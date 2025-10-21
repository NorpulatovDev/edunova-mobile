import 'package:json_annotation/json_annotation.dart';

part 'course_models.g.dart';

@JsonSerializable()
class Course {
  final int? id;
  final String name;
  final int teacherId;
  final String? teacherName;
  final double monthlyFee;
  final List<StudentInfo>? students;

  Course({
    this.id,
    required this.name,
    required this.teacherId,
    this.teacherName,
    required this.monthlyFee,
    this.students,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);

  // Helper getters
  bool get hasStudents => students != null && students!.isNotEmpty;
  int get studentCount => students?.length ?? 0;
}

@JsonSerializable()
class StudentInfo {
  final int id;
  final String name;

  StudentInfo({
    required this.id,
    required this.name,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) => 
      _$StudentInfoFromJson(json);
  Map<String, dynamic> toJson() => _$StudentInfoToJson(this);
}

@JsonSerializable()
class CreateCourseRequest {
  final String name;
  final int teacherId;
  final double monthlyFee;

  CreateCourseRequest({
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  factory CreateCourseRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateCourseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCourseRequestToJson(this);
}

@JsonSerializable()
class UpdateCourseRequest {
  final String name;
  final int teacherId;
  final double monthlyFee;

  UpdateCourseRequest({
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  factory UpdateCourseRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateCourseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCourseRequestToJson(this);
}
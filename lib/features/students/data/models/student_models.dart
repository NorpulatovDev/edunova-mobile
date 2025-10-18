import 'package:json_annotation/json_annotation.dart';

part 'student_models.g.dart';

@JsonSerializable()
class CourseInfo {
  final int id;
  final String name;
  final String teacherName;
  final double monthlyFee;

  CourseInfo({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.monthlyFee,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) => 
      _$CourseInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CourseInfoToJson(this);
}

@JsonSerializable()
class Student {
  final int? id;
  final String name;
  final List<CourseInfo>? courses;

  Student({
    this.id,
    required this.name,
    this.courses,
  });

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);

  // Helper getters
  bool get hasEnrollments => courses != null && courses!.isNotEmpty;
  int get enrollmentCount => courses?.length ?? 0;
  double get totalMonthlyFee => 
      courses?.fold(0.0, (sum, course) => sum??0 + course.monthlyFee) ?? 0.0;
}

@JsonSerializable()
class CreateStudentRequest {
  final String name;

  CreateStudentRequest({
    required this.name,
  });

  factory CreateStudentRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateStudentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateStudentRequestToJson(this);
}

@JsonSerializable()
class UpdateStudentRequest {
  final String name;

  UpdateStudentRequest({
    required this.name,
  });

  factory UpdateStudentRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateStudentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateStudentRequestToJson(this);
}

@JsonSerializable()
class StudentCourseEnrollmentRequest {
  final int studentId;
  final List<int> courseIds;

  StudentCourseEnrollmentRequest({
    required this.studentId,
    required this.courseIds,
  });

  factory StudentCourseEnrollmentRequest.fromJson(Map<String, dynamic> json) => 
      _$StudentCourseEnrollmentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$StudentCourseEnrollmentRequestToJson(this);
}
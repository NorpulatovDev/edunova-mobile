import 'package:json_annotation/json_annotation.dart';

part 'teacher_models.g.dart';

@JsonSerializable()
class Teacher {
  final int? id;
  final String name;
  final double salaryPercentage;

  Teacher({
    this.id,
    required this.name,
    required this.salaryPercentage,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => _$TeacherFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}

@JsonSerializable()
class CreateTeacherRequest {
  final String name;
  final double salaryPercentage;

  CreateTeacherRequest({
    required this.name,
    required this.salaryPercentage,
  });

  factory CreateTeacherRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateTeacherRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTeacherRequestToJson(this);
}

@JsonSerializable()
class UpdateTeacherRequest {
  final String name;
  final double salaryPercentage;

  UpdateTeacherRequest({
    required this.name,
    required this.salaryPercentage,
  });

  factory UpdateTeacherRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateTeacherRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateTeacherRequestToJson(this);
}
part of 'course_bloc.dart';

sealed class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object> get props => [];
}

class LoadCourses extends CourseEvent {}

class CreateCourse extends CourseEvent {
  final String name;
  final int teacherId;
  final double monthlyFee;

  CreateCourse({
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  @override
  List<Object> get props => [name, teacherId, monthlyFee];
}

class UpdateCourse extends CourseEvent {
  final int id;
  final String name;
  final int teacherId;
  final double monthlyFee;

  UpdateCourse({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.monthlyFee,
  });

  @override
  List<Object> get props => [id, name, teacherId, monthlyFee];
}

class DeleteCourse extends CourseEvent {
  final int id;

  DeleteCourse({required this.id});

  @override
  List<Object> get props => [id];
}

class LoadCoursesByStudent extends CourseEvent {
  final int studentId;

  LoadCoursesByStudent({required this.studentId});

  @override
  List<Object> get props => [studentId];
}
part of 'student_bloc.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object> get props => [];
}

class LoadStudentsEvent extends StudentEvent {}

class CreateStudentEvent extends StudentEvent {
  final String name;

  CreateStudentEvent({required this.name});
}

class UpdateStudentEvent extends StudentEvent {
  final int id;
  final String name;

  UpdateStudentEvent({required this.id, required this.name});
}

class DeleteStudentEvent extends StudentEvent {
  final int id;

  DeleteStudentEvent({required this.id});
}

class EnrollStudentInCoursesEvent extends StudentEvent {
  final int studentId;
  final List<int> courseIds;

  EnrollStudentInCoursesEvent({
    required this.studentId,
    required this.courseIds,
  });
}

class AddStudentToCourseEvent extends StudentEvent {
  final int studentId;
  final int courseId;

  AddStudentToCourseEvent({
    required this.studentId,
    required this.courseId,
  });
}

class RemoveStudentFromCourseEvent extends StudentEvent {
  final int studentId;
  final int courseId;

  RemoveStudentFromCourseEvent({
    required this.studentId,
    required this.courseId,
  });
}
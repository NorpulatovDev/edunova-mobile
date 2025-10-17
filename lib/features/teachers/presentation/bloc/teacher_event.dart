part of 'teacher_bloc.dart';

sealed class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object> get props => [];
}

class LoadTeachersEvent extends TeacherEvent {}

class CreateTeacherEvent extends TeacherEvent {
  final String name;
  final double salaryPercentage;

  CreateTeacherEvent({required this.name, required this.salaryPercentage});
}

class UpdateTeacherEvent extends TeacherEvent {
  final int id;
  final String name;
  final double salaryPercentage;

  UpdateTeacherEvent({
    required this.id,
    required this.name,
    required this.salaryPercentage,
  });
}

class DeleteTeacherEvent extends TeacherEvent {
  final int id;

  DeleteTeacherEvent({required this.id});
}

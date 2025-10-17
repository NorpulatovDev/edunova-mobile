part of 'teacher_bloc.dart';

sealed class TeacherState extends Equatable {
  const TeacherState();
  
  @override
  List<Object> get props => [];
}

class TeacherInitialState extends TeacherState {}

class TeacherLoadingState extends TeacherState {}

class TeacherLoadedState extends TeacherState {
  final List<Teacher> teachers;

  TeacherLoadedState({required this.teachers});
}

class TeacherErrorState extends TeacherState {
  final String message;

  TeacherErrorState({required this.message});
}

class TeacherOperationSuccessState extends TeacherState {
  final String message;

  TeacherOperationSuccessState({required this.message});
}
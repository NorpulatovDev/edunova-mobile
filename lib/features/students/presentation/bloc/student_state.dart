part of 'student_bloc.dart';

sealed class StudentState extends Equatable {
  const StudentState();
  
  @override
  List<Object> get props => [];
}

class StudentInitialState extends StudentState {}

class StudentLoadingState extends StudentState {}

class StudentLoadedState extends StudentState {
  final List<Student> students;

  StudentLoadedState({required this.students});
}

class StudentErrorState extends StudentState {
  final String message;

  StudentErrorState({required this.message});
}

class StudentOperationSuccessState extends StudentState {
  final String message;

  StudentOperationSuccessState({required this.message});
}
part of 'course_bloc.dart';

sealed class CourseState extends Equatable {
  const CourseState();
  
  @override
  List<Object> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<Course> courses;

  CourseLoaded({required this.courses});

  @override
  List<Object> get props => [courses];
}

class CourseError extends CourseState {
  final String message;

  CourseError({required this.message});

  @override
  List<Object> get props => [message];
}

class CourseOperationSuccess extends CourseState {
  final String message;

  CourseOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
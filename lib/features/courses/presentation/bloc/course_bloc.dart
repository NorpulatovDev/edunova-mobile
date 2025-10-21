import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/course_models.dart';
import '../../data/repositories/course_repository.dart';

part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepositoryImpl _courseRepository;

  CourseBloc(this._courseRepository) : super(CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<CreateCourse>(_onCreateCourse);
    on<UpdateCourse>(_onUpdateCourse);
    on<DeleteCourse>(_onDeleteCourse);
    on<LoadCoursesByStudent>(_onLoadCoursesByStudent);
  }

  void _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final courses = await _courseRepository.getAllCourses();
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      emit(CourseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onCreateCourse(CreateCourse event, Emitter<CourseState> emit) async {
    try {
      final request = CreateCourseRequest(
        name: event.name,
        teacherId: event.teacherId,
        monthlyFee: event.monthlyFee,
      );
      await _courseRepository.createCourse(request);
      emit(CourseOperationSuccess(message: 'Course created successfully'));
      // Reload courses list
      add(LoadCourses());
    } catch (e) {
      emit(CourseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onUpdateCourse(UpdateCourse event, Emitter<CourseState> emit) async {
    try {
      final request = UpdateCourseRequest(
        name: event.name,
        teacherId: event.teacherId,
        monthlyFee: event.monthlyFee,
      );
      await _courseRepository.updateCourse(event.id, request);
      emit(CourseOperationSuccess(message: 'Course updated successfully'));
      // Reload courses list
      add(LoadCourses());
    } catch (e) {
      emit(CourseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onDeleteCourse(DeleteCourse event, Emitter<CourseState> emit) async {
    try {
      await _courseRepository.deleteCourse(event.id);
      emit(CourseOperationSuccess(message: 'Course deleted successfully'));
      // Reload courses list
      add(LoadCourses());
    } catch (e) {
      emit(CourseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLoadCoursesByStudent(LoadCoursesByStudent event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final courses = await _courseRepository.getCoursesByStudent(event.studentId);
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      emit(CourseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
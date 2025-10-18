import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/student_models.dart';
import '../../data/repositories/student_repository.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepositoryImpl _studentRepository;

  StudentBloc(this._studentRepository) : super(StudentInitialState()) {
    on<LoadStudentsEvent>(_onLoadStudents);
    on<CreateStudentEvent>(_onCreateStudent);
    on<UpdateStudentEvent>(_onUpdateStudent);
    on<DeleteStudentEvent>(_onDeleteStudent);
    on<EnrollStudentInCoursesEvent>(_onEnrollStudentInCourses);
    on<AddStudentToCourseEvent>(_onAddStudentToCourse);
    on<RemoveStudentFromCourseEvent>(_onRemoveStudentFromCourse);
  }

  void _onLoadStudents(LoadStudentsEvent event, Emitter<StudentState> emit) async {
    emit(StudentLoadingState());
    try {
      final students = await _studentRepository.getAllStudents();
      emit(StudentLoadedState(students: students));
    } catch (e) {
      emit(StudentErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onCreateStudent(CreateStudentEvent event, Emitter<StudentState> emit) async {
    try {
      final request = CreateStudentRequest(name: event.name);
      await _studentRepository.createStudent(request);
      emit(StudentOperationSuccessState(message: 'Student created successfully'));
      // Reload students list
      add(LoadStudentsEvent());
    } catch (e) {
      emit(StudentErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onUpdateStudent(UpdateStudentEvent event, Emitter<StudentState> emit) async {
    try {
      final request = UpdateStudentRequest(name: event.name);
      await _studentRepository.updateStudent(event.id, request);
      emit(StudentOperationSuccessState(message: 'Student updated successfully'));
      // Reload students list
      add(LoadStudentsEvent());
    } catch (e) {
      emit(StudentErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onDeleteStudent(DeleteStudentEvent event, Emitter<StudentState> emit) async {
    try {
      await _studentRepository.deleteStudent(event.id);
      emit(StudentOperationSuccessState(message: 'Student deleted successfully'));
      // Reload students list
      add(LoadStudentsEvent());
    } catch (e) {
      emit(StudentErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onEnrollStudentInCourses(EnrollStudentInCoursesEvent event, Emitter<StudentState> emit) async {
    try {
      final request = StudentCourseEnrollmentRequest(
        studentId: event.studentId,
        courseIds: event.courseIds,
      );
      await _studentRepository.enrollInCourses(request);
      emit(StudentOperationSuccessState(message: 'Student enrolled successfully'));
      // Reload students list
      add(LoadStudentsEvent());
    } catch (e) {
      emit(StudentErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onAddStudentToCourse(AddStudentToCourseEvent event, Emitter<StudentState> emit) async {
    try {
      await _studentRepository.addToCourse(event.studentId, event.courseId);
      emit(StudentOperationSuccessState(message: 'Student added to course successfully'));
      // Reload students list
      add(LoadStudentsEvent());
    } catch (e) {
      emit(StudentErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onRemoveStudentFromCourse(RemoveStudentFromCourseEvent event, Emitter<StudentState> emit) async {
    try {
      await _studentRepository.removeFromCourse(event.studentId, event.courseId);
      emit(StudentOperationSuccessState(message: 'Student removed from course successfully'));
      // Reload students list
      add(LoadStudentsEvent());
    } catch (e) {
      emit(StudentErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
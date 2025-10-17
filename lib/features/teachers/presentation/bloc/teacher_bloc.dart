import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/teacher_models.dart';
import '../../data/repositories/teacher_repository.dart';


part 'teacher_event.dart';
part 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepositoryImpl _teacherRepository;

  TeacherBloc(this._teacherRepository) : super(TeacherInitialState()) {
    on<LoadTeachersEvent>(_onLoadTeachers);
    on<CreateTeacherEvent>(_onCreateTeacher);
    on<UpdateTeacherEvent>(_onUpdateTeacher);
    on<DeleteTeacherEvent>(_onDeleteTeacher);
  }

  void _onLoadTeachers(LoadTeachersEvent event, Emitter<TeacherState> emit) async {
    emit(TeacherLoadingState());
    try {
      final teachers = await _teacherRepository.getAllTeachers();
      emit(TeacherLoadedState(teachers: teachers));
    } catch (e) {
      emit(TeacherErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onCreateTeacher(CreateTeacherEvent event, Emitter<TeacherState> emit) async {
    try {
      final request = CreateTeacherRequest(
        name: event.name,
        salaryPercentage: event.salaryPercentage,
      );
      await _teacherRepository.createTeacher(request);
      emit(TeacherOperationSuccessState(message: 'Teacher created successfully'));
      // Reload teachers list
      add(LoadTeachersEvent());
    } catch (e) {
      emit(TeacherErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onUpdateTeacher(UpdateTeacherEvent event, Emitter<TeacherState> emit) async {
    try {
      final request = UpdateTeacherRequest(
        name: event.name,
        salaryPercentage: event.salaryPercentage,
      );
      await _teacherRepository.updateTeacher(event.id, request);
      emit(TeacherOperationSuccessState(message: 'Teacher updated successfully'));
      // Reload teachers list
      add(LoadTeachersEvent());
    } catch (e) {
      emit(TeacherErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onDeleteTeacher(DeleteTeacherEvent event, Emitter<TeacherState> emit) async {
    try {
      await _teacherRepository.deleteTeacher(event.id);
      emit(TeacherOperationSuccessState(message: 'Teacher deleted successfully'));
      // Reload teachers list
      add(LoadTeachersEvent());
    } catch (e) {
      emit(TeacherErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

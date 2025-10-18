import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/unpaid_models.dart';
import '../../data/repositories/unpaid_repository.dart';

part 'unpaid_event.dart';
part 'unpaid_state.dart';

class UnpaidBloc extends Bloc<UnpaidEvent, UnpaidState> {
  final UnpaidPaymentRepositoryImpl _unpaidRepository;

  UnpaidBloc(this._unpaidRepository) : super(UnpaidInitialState()) {
    on<LoadAllUnpaidPaymentsEvent>(_onLoadAllUnpaidPayments);
    on<LoadUnpaidPaymentsByMonthEvent>(_onLoadUnpaidPaymentsByMonth);
    on<LoadUnpaidPaymentsByStudentEvent>(_onLoadUnpaidPaymentsByStudent);
    on<LoadUnpaidStudentsSummaryEvent>(_onLoadUnpaidStudentsSummary);
    on<LoadUnpaidStudentsByMonthEvent>(_onLoadUnpaidStudentsByMonth);
    on<LoadStudentsWithMissingPaymentsEvent>(_onLoadStudentsWithMissingPayments);
    on<LoadCompleteUnpaidSummaryEvent>(_onLoadCompleteUnpaidSummary);
  }

  void _onLoadAllUnpaidPayments(LoadAllUnpaidPaymentsEvent event, Emitter<UnpaidState> emit) async {
    emit(UnpaidLoadingState());
    try {
      final payments = await _unpaidRepository.getAllUnpaidPayments();
      emit(UnpaidPaymentsLoadedState(payments: payments));
    } catch (e) {
      emit(UnpaidErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLoadUnpaidPaymentsByMonth(LoadUnpaidPaymentsByMonthEvent event, Emitter<UnpaidState> emit) async {
    emit(UnpaidLoadingState());
    try {
      final payments = await _unpaidRepository.getUnpaidPaymentsByMonth(event.month);
      emit(UnpaidPaymentsLoadedState(payments: payments));
    } catch (e) {
      emit(UnpaidErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLoadUnpaidPaymentsByStudent(LoadUnpaidPaymentsByStudentEvent event, Emitter<UnpaidState> emit) async {
    emit(UnpaidLoadingState());
    try {
      final payments = await _unpaidRepository.getUnpaidPaymentsByStudent(event.studentId);
      emit(UnpaidPaymentsLoadedState(payments: payments));
    } catch (e) {
      emit(UnpaidErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLoadUnpaidStudentsSummary(LoadUnpaidStudentsSummaryEvent event, Emitter<UnpaidState> emit) async {
    emit(UnpaidLoadingState());
    try {
      final students = await _unpaidRepository.getUnpaidStudentsSummary();
      emit(UnpaidStudentsLoadedState(unpaidStudents: students));
    } catch (e) {
      emit(UnpaidErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLoadUnpaidStudentsByMonth(LoadUnpaidStudentsByMonthEvent event, Emitter<UnpaidState> emit) async {
    emit(UnpaidLoadingState());
    try {
      final students = await _unpaidRepository.getUnpaidStudentsSummaryByMonth(event.month);
      emit(UnpaidStudentsLoadedState(unpaidStudents: students));
    } catch (e) {
      emit(UnpaidErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLoadStudentsWithMissingPayments(LoadStudentsWithMissingPaymentsEvent event, Emitter<UnpaidState> emit) async {
    emit(UnpaidLoadingState());
    try {
      final students = await _unpaidRepository.getStudentsWithMissingPayments(event.month);
      emit(UnpaidStudentsLoadedState(unpaidStudents: students));
    } catch (e) {
      emit(UnpaidErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLoadCompleteUnpaidSummary(LoadCompleteUnpaidSummaryEvent event, Emitter<UnpaidState> emit) async {
    emit(UnpaidLoadingState());
    try {
      final students = await _unpaidRepository.getCompleteUnpaidSummary(event.month);
      emit(UnpaidStudentsLoadedState(unpaidStudents: students));
    } catch (e) {
      emit(UnpaidErrorState(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
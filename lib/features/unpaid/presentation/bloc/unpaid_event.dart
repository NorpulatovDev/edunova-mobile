part of 'unpaid_bloc.dart';

sealed class UnpaidEvent extends Equatable {
  const UnpaidEvent();

  @override
  List<Object> get props => [];
}

class LoadAllUnpaidPaymentsEvent extends UnpaidEvent {}

class LoadUnpaidPaymentsByMonthEvent extends UnpaidEvent {
  final String month;

  LoadUnpaidPaymentsByMonthEvent({required this.month});
}

class LoadUnpaidPaymentsByStudentEvent extends UnpaidEvent {
  final int studentId;

  LoadUnpaidPaymentsByStudentEvent({required this.studentId});
}

class LoadUnpaidStudentsSummaryEvent extends UnpaidEvent {}

class LoadUnpaidStudentsByMonthEvent extends UnpaidEvent {
  final String month;

  LoadUnpaidStudentsByMonthEvent({required this.month});
}

class LoadStudentsWithMissingPaymentsEvent extends UnpaidEvent {
  final String month;

  LoadStudentsWithMissingPaymentsEvent({required this.month});
}

class LoadCompleteUnpaidSummaryEvent extends UnpaidEvent {
  final String month;

  LoadCompleteUnpaidSummaryEvent({required this.month});
}
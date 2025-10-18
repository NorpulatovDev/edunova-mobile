part of 'unpaid_bloc.dart';

sealed class UnpaidState extends Equatable {
  const UnpaidState();
  
  @override
  List<Object> get props => [];
}

class UnpaidInitialState extends UnpaidState {}

class UnpaidLoadingState extends UnpaidState {}

class UnpaidPaymentsLoadedState extends UnpaidState {
  final List<PaymentDTO> payments;

  UnpaidPaymentsLoadedState({required this.payments});
}

class UnpaidStudentsLoadedState extends UnpaidState {
  final List<UnpaidStudent> unpaidStudents;

  UnpaidStudentsLoadedState({required this.unpaidStudents});
}

class UnpaidErrorState extends UnpaidState {
  final String message;

  UnpaidErrorState({required this.message});
}
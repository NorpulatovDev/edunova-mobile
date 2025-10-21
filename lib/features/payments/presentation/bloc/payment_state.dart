part of 'payment_bloc.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();
  
  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<Payment> payments;

  PaymentLoaded({required this.payments});

  @override
  List<Object> get props => [payments];
}

class PaymentError extends PaymentState {
  final String message;

  PaymentError({required this.message});

  @override
  List<Object> get props => [message];
}

class PaymentOperationSuccess extends PaymentState {
  final String message;

  PaymentOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class LoadPayments extends PaymentEvent {}

class LoadPaymentsByMonth extends PaymentEvent {
  final String month;

  LoadPaymentsByMonth({required this.month});

  @override
  List<Object> get props => [month];
}

class CreatePayment extends PaymentEvent {
  final int studentId;
  final int courseId;
  final double amount;
  final String month;
  final bool paid;

  CreatePayment({
    required this.studentId,
    required this.courseId,
    required this.amount,
    required this.month,
    required this.paid,
  });

  @override
  List<Object> get props => [studentId, courseId, amount, month, paid];
}

class UpdatePayment extends PaymentEvent {
  final int id;
  final int studentId;
  final int courseId;
  final double amount;
  final String month;
  final bool paid;

  UpdatePayment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.amount,
    required this.month,
    required this.paid,
  });

  @override
  List<Object> get props => [id, studentId, courseId, amount, month, paid];
}

class DeletePayment extends PaymentEvent {
  final int id;

  DeletePayment({required this.id});

  @override
  List<Object> get props => [id];
}

class TogglePaymentStatus extends PaymentEvent {
  final Payment payment;

  TogglePaymentStatus({required this.payment});

  @override
  List<Object> get props => [payment];
}
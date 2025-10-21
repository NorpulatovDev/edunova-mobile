import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/payment_models.dart';
import '../../data/repositories/payment_repository.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepositoryImpl _paymentRepository;

  PaymentBloc(this._paymentRepository) : super(PaymentInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<LoadPaymentsByMonth>(_onLoadPaymentsByMonth);
    on<CreatePayment>(_onCreatePayment);
    on<UpdatePayment>(_onUpdatePayment);
    on<DeletePayment>(_onDeletePayment);
    on<TogglePaymentStatus>(_onTogglePaymentStatus);
  }

  void _onLoadPayments(LoadPayments event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final payments = await _paymentRepository.getAllPayments();
      emit(PaymentLoaded(payments: payments));
    } catch (e) {
      emit(PaymentError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLoadPaymentsByMonth(LoadPaymentsByMonth event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final payments = await _paymentRepository.getPaymentsByMonth(event.month);
      emit(PaymentLoaded(payments: payments));
    } catch (e) {
      emit(PaymentError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onCreatePayment(CreatePayment event, Emitter<PaymentState> emit) async {
    try {
      final request = CreatePaymentRequest(
        studentId: event.studentId,
        courseId: event.courseId,
        amount: event.amount,
        month: event.month,
        paid: event.paid,
      );
      await _paymentRepository.createPayment(request);
      emit(PaymentOperationSuccess(message: 'Payment created successfully'));
      // Reload payments list
      add(LoadPayments());
    } catch (e) {
      emit(PaymentError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onUpdatePayment(UpdatePayment event, Emitter<PaymentState> emit) async {
    try {
      final request = UpdatePaymentRequest(
        studentId: event.studentId,
        courseId: event.courseId,
        amount: event.amount,
        month: event.month,
        paid: event.paid,
      );
      await _paymentRepository.updatePayment(event.id, request);
      emit(PaymentOperationSuccess(message: 'Payment updated successfully'));
      // Reload payments list
      add(LoadPayments());
    } catch (e) {
      emit(PaymentError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onDeletePayment(DeletePayment event, Emitter<PaymentState> emit) async {
    try {
      await _paymentRepository.deletePayment(event.id);
      emit(PaymentOperationSuccess(message: 'Payment deleted successfully'));
      // Reload payments list
      add(LoadPayments());
    } catch (e) {
      emit(PaymentError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onTogglePaymentStatus(TogglePaymentStatus event, Emitter<PaymentState> emit) async {
    try {
      final payment = event.payment;
      final request = UpdatePaymentRequest(
        studentId: payment.studentId,
        courseId: payment.courseId,
        amount: payment.amount,
        month: payment.month,
        paid: !payment.paid, // Toggle the status
      );
      await _paymentRepository.updatePayment(payment.id!, request);
      final statusText = !payment.paid ? 'marked as paid' : 'marked as unpaid';
      emit(PaymentOperationSuccess(message: 'Payment $statusText'));
      // Reload payments list
      add(LoadPayments());
    } catch (e) {
      emit(PaymentError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
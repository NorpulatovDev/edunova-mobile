import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_models.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getAllPayments();
  Future<List<Payment>> getPaymentsByMonth(String month);
  Future<Payment> getPaymentById(int id);
  Future<Payment> createPayment(CreatePaymentRequest request);
  Future<Payment> updatePayment(int id, UpdatePaymentRequest request);
  Future<void> deletePayment(int id);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepositoryImpl(this._apiClient);

  @override
  Future<List<Payment>> getAllPayments() async {
    try {
      final response = await _apiClient.get('/payments');
      final List<dynamic> data = response.data;
      return data.map((json) => Payment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch payments: ${e.message}');
    }
  }

  @override
  Future<List<Payment>> getPaymentsByMonth(String month) async {
    try {
      final response = await _apiClient.get('/payments/month/$month');
      final List<dynamic> data = response.data;
      return data.map((json) => Payment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch payments for month: ${e.message}');
    }
  }

  @override
  Future<Payment> getPaymentById(int id) async {
    try {
      final response = await _apiClient.get('/payments/$id');
      return Payment.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Payment not found');
      }
      throw Exception('Failed to fetch payment: ${e.message}');
    }
  }

  @override
  Future<Payment> createPayment(CreatePaymentRequest request) async {
    try {
      final response = await _apiClient.post('/payments', data: request.toJson());
      return Payment.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid payment data');
      }
      throw Exception('Failed to create payment: ${e.message}');
    }
  }

  @override
  Future<Payment> updatePayment(int id, UpdatePaymentRequest request) async {
    try {
      final response = await _apiClient.put('/payments/$id', data: request.toJson());
      return Payment.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Payment not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid payment data');
      }
      throw Exception('Failed to update payment: ${e.message}');
    }
  }

  @override
  Future<void> deletePayment(int id) async {
    try {
      await _apiClient.delete('/payments/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Payment not found');
      }
      throw Exception('Failed to delete payment: ${e.message}');
    }
  }
}
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/unpaid_models.dart';

abstract class UnpaidPaymentRepository {
  Future<List<PaymentDTO>> getAllUnpaidPayments();
  Future<List<PaymentDTO>> getUnpaidPaymentsByMonth(String month);
  Future<List<PaymentDTO>> getUnpaidPaymentsByStudent(int studentId);
  Future<List<UnpaidStudent>> getUnpaidStudentsSummary();
  Future<List<UnpaidStudent>> getUnpaidStudentsSummaryByMonth(String month);
  Future<List<UnpaidStudent>> getStudentsWithMissingPayments(String month);
  Future<List<UnpaidStudent>> getCompleteUnpaidSummary(String month);
}

class UnpaidPaymentRepositoryImpl implements UnpaidPaymentRepository {
  final ApiClient _apiClient;

  UnpaidPaymentRepositoryImpl(this._apiClient);

  @override
  Future<List<PaymentDTO>> getAllUnpaidPayments() async {
    try {
      final response = await _apiClient.get('/unpaid/payments');
      final List<dynamic> data = response.data;
      return data.map((json) => PaymentDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch unpaid payments: ${e.message}');
    }
  }

  @override
  Future<List<PaymentDTO>> getUnpaidPaymentsByMonth(String month) async {
    try {
      final response = await _apiClient.get('/unpaid/payments/month/$month');
      final List<dynamic> data = response.data;
      return data.map((json) => PaymentDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch unpaid payments for month: ${e.message}');
    }
  }

  @override
  Future<List<PaymentDTO>> getUnpaidPaymentsByStudent(int studentId) async {
    try {
      final response = await _apiClient.get('/unpaid/payments/student/$studentId');
      final List<dynamic> data = response.data;
      return data.map((json) => PaymentDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch unpaid payments for student: ${e.message}');
    }
  }

  @override
  Future<List<UnpaidStudent>> getUnpaidStudentsSummary() async {
    try {
      final response = await _apiClient.get('/unpaid/students');
      final List<dynamic> data = response.data;
      return data.map((json) => UnpaidStudent.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch unpaid students summary: ${e.message}');
    }
  }

  @override
  Future<List<UnpaidStudent>> getUnpaidStudentsSummaryByMonth(String month) async {
    try {
      final response = await _apiClient.get('/unpaid/students/month/$month');
      final List<dynamic> data = response.data;
      return data.map((json) => UnpaidStudent.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch unpaid students summary for month: ${e.message}');
    }
  }

  @override
  Future<List<UnpaidStudent>> getStudentsWithMissingPayments(String month) async {
    try {
      final response = await _apiClient.get('/unpaid/missing/month/$month');
      final List<dynamic> data = response.data;
      return data.map((json) => UnpaidStudent.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch students with missing payments: ${e.message}');
    }
  }

  @override
  Future<List<UnpaidStudent>> getCompleteUnpaidSummary(String month) async {
    try {
      final response = await _apiClient.get('/unpaid/complete/month/$month');
      final List<dynamic> data = response.data;
      return data.map((json) => UnpaidStudent.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch complete unpaid summary: ${e.message}');
    }
  }
}
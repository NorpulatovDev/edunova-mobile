import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/expense_models.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<List<Expense>> getExpensesByMonth(String month);
  Future<Expense> getExpenseById(int id);
  Future<Expense> createExpense(CreateExpenseRequest request);
  Future<Expense> updateExpense(int id, UpdateExpenseRequest request);
  Future<void> deleteExpense(int id);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ApiClient _apiClient;

  ExpenseRepositoryImpl(this._apiClient);

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      final response = await _apiClient.get('/expenses');
      final List<dynamic> data = response.data;
      return data.map((json) => Expense.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch expenses: ${e.message}');
    }
  }

  @override
  Future<List<Expense>> getExpensesByMonth(String month) async {
    try {
      final response = await _apiClient.get('/expenses/month/$month');
      final List<dynamic> data = response.data;
      return data.map((json) => Expense.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch expenses for month: ${e.message}');
    }
  }

  @override
  Future<Expense> getExpenseById(int id) async {
    try {
      final response = await _apiClient.get('/expenses/$id');
      return Expense.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Expense not found');
      }
      throw Exception('Failed to fetch expense: ${e.message}');
    }
  }

  @override
  Future<Expense> createExpense(CreateExpenseRequest request) async {
    try {
      final response = await _apiClient.post('/expenses', data: request.toJson());
      return Expense.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid expense data');
      }
      throw Exception('Failed to create expense: ${e.message}');
    }
  }

  @override
  Future<Expense> updateExpense(int id, UpdateExpenseRequest request) async {
    try {
      final response = await _apiClient.put('/expenses/$id', data: request.toJson());
      return Expense.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Expense not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid expense data');
      }
      throw Exception('Failed to update expense: ${e.message}');
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    try {
      await _apiClient.delete('/expenses/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Expense not found');
      }
      throw Exception('Failed to delete expense: ${e.message}');
    }
  }
}
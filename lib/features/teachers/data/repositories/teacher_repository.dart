import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/teacher_models.dart';

abstract class TeacherRepository {
  Future<List<Teacher>> getAllTeachers();
  Future<Teacher> getTeacherById(int id);
  Future<Teacher> createTeacher(CreateTeacherRequest request);
  Future<Teacher> updateTeacher(int id, UpdateTeacherRequest request);
  Future<void> deleteTeacher(int id);
}

class TeacherRepositoryImpl implements TeacherRepository {
  final ApiClient _apiClient;

  TeacherRepositoryImpl(this._apiClient);

  @override
  Future<List<Teacher>> getAllTeachers() async {
    try {
      final response = await _apiClient.get('/teachers');
      final List<dynamic> data = response.data;
      return data.map((json) => Teacher.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch teachers: ${e.message}');
    }
  }

  @override
  Future<Teacher> getTeacherById(int id) async {
    try {
      final response = await _apiClient.get('/teachers/$id');
      return Teacher.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      }
      throw Exception('Failed to fetch teacher: ${e.message}');
    }
  }

  @override
  Future<Teacher> createTeacher(CreateTeacherRequest request) async {
    try {
      final response = await _apiClient.post('/teachers', data: request.toJson());
      return Teacher.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid teacher data');
      }
      throw Exception('Failed to create teacher: ${e.message}');
    }
  }

  @override
  Future<Teacher> updateTeacher(int id, UpdateTeacherRequest request) async {
    try {
      final response = await _apiClient.put('/teachers/$id', data: request.toJson());
      return Teacher.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid teacher data');
      }
      throw Exception('Failed to update teacher: ${e.message}');
    }
  }

  @override
  Future<void> deleteTeacher(int id) async {
    try {
      await _apiClient.delete('/teachers/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Teacher not found');
      }
      throw Exception('Failed to delete teacher: ${e.message}');
    }
  }
}
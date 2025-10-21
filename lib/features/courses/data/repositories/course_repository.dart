import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/course_models.dart';

abstract class CourseRepository {
  Future<List<Course>> getAllCourses();
  Future<Course> getCourseById(int id);
  Future<Course> createCourse(CreateCourseRequest request);
  Future<Course> updateCourse(int id, UpdateCourseRequest request);
  Future<void> deleteCourse(int id);
  Future<List<Course>> getCoursesByStudent(int studentId);
}

class CourseRepositoryImpl implements CourseRepository {
  final ApiClient _apiClient;

  CourseRepositoryImpl(this._apiClient);

  @override
  Future<List<Course>> getAllCourses() async {
    try {
      final response = await _apiClient.get('/courses');
      final List<dynamic> data = response.data;
      return data.map((json) => Course.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch courses: ${e.message}');
    }
  }

  @override
  Future<Course> getCourseById(int id) async {
    try {
      final response = await _apiClient.get('/courses/$id');
      return Course.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Course not found');
      }
      throw Exception('Failed to fetch course: ${e.message}');
    }
  }

  @override
  Future<Course> createCourse(CreateCourseRequest request) async {
    try {
      final response = await _apiClient.post('/courses', data: request.toJson());
      return Course.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid course data');
      }
      throw Exception('Failed to create course: ${e.message}');
    }
  }

  @override
  Future<Course> updateCourse(int id, UpdateCourseRequest request) async {
    try {
      final response = await _apiClient.put('/courses/$id', data: request.toJson());
      return Course.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Course not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid course data');
      }
      throw Exception('Failed to update course: ${e.message}');
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    try {
      await _apiClient.delete('/courses/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Course not found');
      }
      throw Exception('Failed to delete course: ${e.message}');
    }
  }

  @override
  Future<List<Course>> getCoursesByStudent(int studentId) async {
    try {
      final response = await _apiClient.get('/courses/student/$studentId');
      final List<dynamic> data = response.data;
      return data.map((json) => Course.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch courses for student: ${e.message}');
    }
  }
}
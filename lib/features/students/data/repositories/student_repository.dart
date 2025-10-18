import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/student_models.dart';

abstract class StudentRepository {
  Future<List<Student>> getAllStudents();
  Future<Student> getStudentById(int id);
  Future<Student> createStudent(CreateStudentRequest request);
  Future<Student> updateStudent(int id, UpdateStudentRequest request);
  Future<void> deleteStudent(int id);
  Future<Student> enrollInCourses(StudentCourseEnrollmentRequest request);
  Future<Student> addToCourse(int studentId, int courseId);
  Future<Student> removeFromCourse(int studentId, int courseId);
}

class StudentRepositoryImpl implements StudentRepository {
  final ApiClient _apiClient;

  StudentRepositoryImpl(this._apiClient);

  @override
  Future<List<Student>> getAllStudents() async {
    try {
      final response = await _apiClient.get('/students');
      final List<dynamic> data = response.data;
      print(data);
      return data.map((json) => Student.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch students: ${e.message}');
    }
  }

  @override
  Future<Student> getStudentById(int id) async {
    try {
      final response = await _apiClient.get('/students/$id');
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to fetch student: ${e.message}');
    }
  }

  @override
  Future<Student> createStudent(CreateStudentRequest request) async {
    try {
      final response = await _apiClient.post('/students', data: request.toJson());
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid student data');
      }
      throw Exception('Failed to create student: ${e.message}');
    }
  }

  @override
  Future<Student> updateStudent(int id, UpdateStudentRequest request) async {
    try {
      final response = await _apiClient.put('/students/$id', data: request.toJson());
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid student data');
      }
      throw Exception('Failed to update student: ${e.message}');
    }
  }

  @override
  Future<void> deleteStudent(int id) async {
    try {
      await _apiClient.delete('/students/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Failed to delete student: ${e.message}');
    }
  }

  @override
  Future<Student> enrollInCourses(StudentCourseEnrollmentRequest request) async {
    try {
      final response = await _apiClient.post('/students/enroll', data: request.toJson());
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student or course not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid enrollment data');
      }
      throw Exception('Failed to enroll student: ${e.message}');
    }
  }

  @override
  Future<Student> addToCourse(int studentId, int courseId) async {
    try {
      final response = await _apiClient.post('/students/$studentId/courses/$courseId');
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student or course not found');
      }
      throw Exception('Failed to add student to course: ${e.message}');
    }
  }

  @override
  Future<Student> removeFromCourse(int studentId, int courseId) async {
    try {
      final response = await _apiClient.delete('/students/$studentId/courses/$courseId');
      return Student.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student or course not found');
      }
      throw Exception('Failed to remove student from course: ${e.message}');
    }
  }
}
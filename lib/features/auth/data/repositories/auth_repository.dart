import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> logout();
  bool isAuthenticated();
  String? getRefreshToken();
  String? getAccessToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepositoryImpl(this._apiClient, this._storageService);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post('/auth/login', data: request.toJson());
      final authResponse = AuthResponse.fromJson(response.data);
      
      await _storageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid username or password');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _apiClient.post('/auth/refresh', data: request.toJson());
      final authResponse = AuthResponse.fromJson(response.data);
      
      await _storageService.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      
      return authResponse;
    } on DioException catch (e) {
      await _storageService.clearTokens();
      throw Exception('Token refresh failed: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Even if logout fails on server, clear local tokens
      print('Logout request failed: $e');
    } finally {
      await _storageService.clearTokens();
    }
  }

  @override
  bool isAuthenticated() {
    return _storageService.hasTokens();
  }

  @override
  String? getRefreshToken() {
    return _storageService.getRefreshToken();
  }

  @override
  String? getAccessToken() {
    return _storageService.getAccessToken();
  }
}
import 'package:dio/dio.dart';
import '../storage/storage_service.dart';

class ApiClient {
  final Dio _dio;
  final StorageService _storageService;
  bool _isRefreshing = false;

  ApiClient(this._dio, this._storageService) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            
            try {
              await _refreshToken();
              
              // Retry the original request with new token
              final token = _storageService.getAccessToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final clonedRequest = await _dio.fetch(error.requestOptions);
                handler.resolve(clonedRequest);
              } else {
                handler.next(error);
              }
            } catch (e) {
              // Refresh failed, clear tokens and let the error propagate
              await _storageService.clearTokens();
              handler.next(error);
            } finally {
              _isRefreshing = false;
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _refreshToken() async {
    final refreshToken = _storageService.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      // Create a new Dio instance without interceptors to avoid infinite loop
      final refreshDio = Dio();
      refreshDio.options.baseUrl = _dio.options.baseUrl;
      
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      await _storageService.saveTokens(
        data['accessToken'],
        data['refreshToken'],
      );
    } catch (e) {
      await _storageService.clearTokens();
      throw Exception('Token refresh failed');
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
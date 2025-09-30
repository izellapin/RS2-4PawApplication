import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/auth.dart';
import 'auth_service.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:5160/api';
  
  late final Dio _dio;
  final AuthService _authService;

  ApiClient(this._authService) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor - add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        if (kDebugMode) {
          print('🚀 API Request: ${options.method} ${options.uri}');
          if (options.data != null) {
            print('📤 Request Data: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
        }
        handler.next(response);
      },
      
      onError: (error, handler) async {
        if (kDebugMode) {
          print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('Error message: ${error.message}');
        }

        // Handle 401 Unauthorized - token expired
        if (error.response?.statusCode == 401) {
          try {
            // Try to refresh token
            final refreshed = await _authService.refreshToken();
            if (refreshed) {
              // Retry the original request
              final token = await _authService.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              
              final cloneReq = await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              
              return handler.resolve(cloneReq);
            } else {
              // Refresh failed, logout user
              await _authService.logout();
            }
          } catch (e) {
            if (kDebugMode) {
              print('Token refresh failed: $e');
            }
            await _authService.logout();
          }
        }
        
        handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: refreshToken);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/refresh', data: refreshToken);
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // First get basic user info to get the user ID
      final authResponse = await _dio.get('/auth/me');
      final userId = int.parse(authResponse.data['userId']);
      
      // Then get full user profile data
      final response = await _dio.get('/user/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // User endpoints
  Future<List<dynamic>> getUsers({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get('/user', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUser(int id) async {
    try {
      final response = await _dio.get('/user/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/user/$userId', data: userData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateCurrentUser(Map<String, dynamic> userData) async {
    try {
      // First get current user to get their ID
      final currentUser = await getCurrentUser();
      final userId = currentUser['id']; // Backend vraća 'id' kao int
      print('🔄 Update current user ID: $userId sa podacima: $userData');
      return await updateUser(userId, userData);
    } on DioException catch (e) {
      print('❌ API Error u updateCurrentUser: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  // Service endpoints
  Future<List<dynamic>> getServices({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get('/service', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Category endpoints
  Future<List<dynamic>> getCategories({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get('/category', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiError _handleError(DioException error) {
    String message = 'Došlo je do greške';
    int? statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Zahtev je istekao. Proverite internet konekciju.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Nema konekcije sa serverom. Proverite da li je backend pokrenut.';
    } else if (error.response?.data != null) {
      final responseData = error.response!.data;
      if (responseData is Map<String, dynamic>) {
        message = responseData['message'] ?? message;
      } else if (responseData is String) {
        message = responseData;
      }
    }

    return ApiError(
      message: message,
      statusCode: statusCode,
      details: error.message,
    );
  }
}


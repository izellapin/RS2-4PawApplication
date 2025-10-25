import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/auth.dart';
import '../models/pet.dart';
import '../models/appointment.dart';
import 'auth_service.dart';
import 'network_config.dart';

class ApiClient {
  static String get baseUrl => NetworkConfig.apiBaseUrl;
  
  late final Dio _dio;
  final AuthService _authService;

  ApiClient(this._authService) {
    if (kDebugMode) {
      print('🔧 ApiClient constructor called');
      print('🌐 NetworkConfig.apiBaseUrl: ${NetworkConfig.apiBaseUrl}');
    }
    
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
        if (kDebugMode) {
          print('🔑 Token check: ${token != null ? "Token exists (${token.length} chars)" : "No token"}');
        }
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          if (kDebugMode) {
            print('🔑 Authorization header set: Bearer ${token.substring(0, 20)}...');
          }
        } else {
          if (kDebugMode) {
            print('⚠️ No token available - request will be unauthorized');
          }
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
          print('❌ API Greška: ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('Poruka greške: ${error.message}');
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

  Future<void> register(RegisterRequest request) async {
    try {
      await _dio.post('/auth/register', data: request.toJson());
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
      final authResponse = await _dio.get('/auth/me');
      final userId = int.parse(authResponse.data['userId']);
      
      final response = await _dio.get('/user/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Pet endpoints
  Future<List<Pet>> getPets({Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get('/pets', queryParameters: queryParams);
      final List<dynamic> data = response.data;
      return data.map((json) => Pet.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Pet>> getUserPets(int userId) async {
    try {
      final response = await _dio.get('/pets/owner/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => Pet.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Pet> createPet(Map<String, dynamic> petData) async {
    try {
      final response = await _dio.post('/pets', data: petData);
      return Pet.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Pet> updatePet(int petId, Map<String, dynamic> petData) async {
    try {
      final response = await _dio.put('/pets/$petId', data: petData);
      return Pet.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePet(int petId) async {
    try {
      await _dio.delete('/pets/$petId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Appointment endpoints
  Future<List<Appointment>> getAppointments() async {
    try {
      final response = await _dio.get('/appointments');
      final List<dynamic> data = response.data;
      return data.map((json) => Appointment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Appointment>> getUserAppointments(int userId) async {
    try {
      final response = await _dio.get('/appointments/user/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => Appointment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Appointment> bookAppointment(Map<String, dynamic> appointmentData) async {
    try {
      if (kDebugMode) {
        print('🚀 API Request: POST ${_dio.options.baseUrl}/appointments');
        print('📤 Request Data: $appointmentData');
      }
      final response = await _dio.post('/appointments', data: appointmentData);
      return Appointment.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ API Greška: ${e.response?.statusCode} ${_dio.options.baseUrl}/appointments');
        print('Poruka greške: ${e.message}');
        print('🔍 Response data: ${e.response?.data}');
      }
      throw _handleError(e);
    }
  }

  Future<Appointment> updateAppointment(int appointmentId, Map<String, dynamic> appointmentData) async {
    try {
      final response = await _dio.put('/appointments/$appointmentId', data: appointmentData);
      return Appointment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> cancelAppointment(int appointmentId) async {
    try {
      await _dio.patch('/appointments/$appointmentId/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiError _handleError(DioException error) {
    String message = 'Došlo je do greške';
    int? statusCode = error.response?.statusCode;

    if (kDebugMode) {
      print('🔍 DioException details:');
      print('  Type: ${error.type}');
      print('  Status Code: $statusCode');
      print('  Response Data: ${error.response?.data}');
    }

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

    if (kDebugMode) {
      print('📤 Final error message: $message');
    }

    return ApiError(
      message: message,
      statusCode: statusCode,
      details: error.message,
    );
  }
}
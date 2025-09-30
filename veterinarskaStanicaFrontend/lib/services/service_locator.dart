import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'api_client.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final AuthService _authService;
  late final ApiClient _apiClient;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kDebugMode) {
      print('🔧 Initializing services...');
    }

    // Initialize AuthService first
    _authService = AuthService();
    await _authService.initialize();

    // Initialize ApiClient with AuthService dependency
    _apiClient = ApiClient(_authService);

    _isInitialized = true;

    if (kDebugMode) {
      print('✅ Services initialized successfully');
    }
  }

  AuthService get authService {
    if (!_isInitialized) {
      throw Exception('ServiceLocator not initialized. Call initialize() first.');
    }
    return _authService;
  }

  ApiClient get apiClient {
    if (!_isInitialized) {
      throw Exception('ServiceLocator not initialized. Call initialize() first.');
    }
    return _apiClient;
  }

  void dispose() {
    if (_isInitialized) {
      _authService.dispose();
      _isInitialized = false;
      if (kDebugMode) {
        print('🗑️ Services disposed');
      }
    }
  }
}

// Global access
final serviceLocator = ServiceLocator();


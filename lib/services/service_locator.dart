import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'api_client.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final AuthService _authService;
  late final ApiClient _apiClient;

  AuthService get authService => _authService;
  ApiClient get apiClient => _apiClient;

  Future<void> initialize() async {
    if (kDebugMode) {
      print('🔧 Initializing services...');
    }

    // Initialize AuthService first
    _authService = AuthService();
    await _authService.initialize();

    // Initialize ApiClient with AuthService dependency
    _apiClient = ApiClient(_authService);

    if (kDebugMode) {
      print('✅ Services initialized successfully');
    }
  }

  void dispose() {
    _authService.dispose();
  }
}

// Global instance
final serviceLocator = ServiceLocator();

// Setup function to be called in main()
Future<void> setupServiceLocator() async {
  if (kDebugMode) {
    print('🔧 setupServiceLocator called');
  }
  await serviceLocator.initialize();
  if (kDebugMode) {
    print('✅ setupServiceLocator completed');
  }
}







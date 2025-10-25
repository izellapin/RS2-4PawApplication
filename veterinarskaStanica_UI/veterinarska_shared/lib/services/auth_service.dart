import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient;
  bool _isLoggedIn = false;
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  AuthService(this._apiClient) {
    _initializeAuth();
  }

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentUser => _currentUser;

  Future<void> _initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token != null && token.isNotEmpty) {
        print('🔍 Validating existing token...');
        // Try to get current user to validate token
        try {
          _currentUser = await _apiClient.getCurrentUser();
          _isLoggedIn = true;
          print('✅ Token is valid, user authenticated');
        } catch (e) {
          print('❌ Token validation failed: $e');
          // Check if it's a network error (semaphore timeout, connection refused, etc.)
          if (e.toString().contains('semaphore timeout') || 
              e.toString().contains('connection') ||
              e.toString().contains('timeout')) {
            print('🌐 Network error during token validation - keeping user logged in');
            // Keep user logged in for network errors, they can retry later
            _isLoggedIn = true;
            // Don't clear tokens for network issues
          } else {
            // Token is invalid, clear everything
            await logout();
          }
        }
      } else {
        print('ℹ️ No token found, user needs to login');
        _isLoggedIn = false;
        _currentUser = null;
      }
    } catch (e) {
      print('❌ Auth initialization error: $e');
      await logout(); // Clear everything on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final authResponse = await _apiClient.login(email, password);
      
      // Store tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', authResponse.accessToken);
      await prefs.setString('refresh_token', authResponse.refreshToken);
      
      print('🔑 Stored new access token: ${authResponse.accessToken.substring(0, 20)}...');
      
      // Set user data - backend returns user data directly in response, not nested
      _currentUser = authResponse.user ?? {};
      
      // Backend returns 'userId' but we need 'id' for compatibility
      if (_currentUser != null && _currentUser!['userId'] != null) {
        // Ensure userId is converted to int
        final userId = _currentUser!['userId'];
        if (userId is int) {
          _currentUser!['id'] = userId;
        } else if (userId is String) {
          _currentUser!['id'] = int.tryParse(userId) ?? 0;
        } else {
          _currentUser!['id'] = 0;
        }
      }
      
      _isLoggedIn = true;
      
      print('✅ Login successful, user data: $_currentUser');
      notifyListeners();
    } catch (e) {
      print('❌ Login error: $e');
      // Check if it's a network error
      if (e.toString().contains('semaphore timeout') || 
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        print('🌐 Network error during login - please check your connection');
        throw Exception('Greška konekcije sa serverom. Molimo provjerite internet konekciju i pokušajte ponovo.');
      }
      rethrow;
    }
  }

  Future<void> register(String firstName, String lastName, String email, String username, String password, {String? phoneNumber, String? address, int role = 1}) async {
    try {
      final response = await _apiClient.register(firstName, lastName, email, username, password, phoneNumber: phoneNumber, address: address, role: role);
      
      print('✅ Registration successful: $response');
      // Registration doesn't automatically log in the user - they need to verify email first
      // So we don't set _isLoggedIn = true here
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyEmail(String email, String verificationCode) async {
    try {
      final response = await _apiClient.verifyEmail(email, verificationCode);
      
      print('✅ Email verification successful: $response');
      // Email verification doesn't automatically log in the user - they need to login after verification
      // So we don't set _isLoggedIn = true here
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendVerificationCode(String email) async {
    try {
      final response = await _apiClient.resendVerificationCode(email);
      print('✅ Verification code resent successfully: $response');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      await _clearTokens();
      _isLoggedIn = false;
      _currentUser = null;
      print('🔑 Logout completed, tokens cleared');
      notifyListeners();
    }
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    print('🔑 Cleared tokens from SharedPreferences');
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('🔑 Getting access token: ${token?.substring(0, 20)}...');
    return token;
  }

  bool hasRole(UserRole role) {
    if (_currentUser == null) return false;
    final userRole = _currentUser!['role'] as int?;
    if (userRole == null) return false;
    return UserRole.values[userRole - 1] == role; // Adjust for 1-based indexing
  }

  bool hasAnyRole(List<UserRole> roles) {
    return roles.any((role) => hasRole(role));
  }

  // Force refresh token - clear and re-login
  Future<void> forceRefreshToken() async {
    print('🔄 Force refreshing token...');
    await _clearTokens();
    _isLoggedIn = false;
    _currentUser = null;
    print('🔑 Tokens cleared, user logged out');
    notifyListeners();
  }
}

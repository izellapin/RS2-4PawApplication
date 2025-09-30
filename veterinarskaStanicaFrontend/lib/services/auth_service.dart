import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpirationKey = 'token_expiration';

  AuthResponse? _currentAuth;
  bool _isLoading = false;

  AuthResponse? get currentAuth => _currentAuth;
  User? get currentUser => _currentAuth != null 
    ? User(
        id: _currentAuth!.userId,
        firstName: _currentAuth!.firstName,
        lastName: _currentAuth!.lastName,
        email: _currentAuth!.email,
        username: _currentAuth!.username,
        dateCreated: DateTime.now(),
        isActive: _currentAuth!.isActive,
        isEmailVerified: _currentAuth!.isEmailVerified,
        role: _currentAuth!.role,
      )
    : null;
  
  bool get isAuthenticated => _currentAuth != null;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userDataKey);
      final tokenExpiration = prefs.getString(_tokenExpirationKey);
      
      if (userData != null && tokenExpiration != null) {
        final expirationDate = DateTime.parse(tokenExpiration);
        
        // Check if token is still valid
        if (expirationDate.isAfter(DateTime.now())) {
          _currentAuth = AuthResponse.fromJson(jsonDecode(userData));
          if (kDebugMode) {
            print('✅ User restored from storage: ${_currentAuth!.email}');
          }
        } else {
          if (kDebugMode) {
            print('⚠️ Token expired, attempting refresh...');
          }
          // Token expired, try to refresh
          await _attemptTokenRefresh();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing auth: $e');
      }
      await clearAuth();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(AuthResponse authResponse) async {
    try {
      _currentAuth = authResponse;
      await _saveAuthData();
      
      if (kDebugMode) {
        print('✅ User logged in: ${authResponse.email}');
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving auth data: $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    _currentAuth = null;
    await clearAuth();
    
    if (kDebugMode) {
      print('✅ User logged out');
    }
    
    notifyListeners();
  }

  Future<String?> getAccessToken() async {
    if (_currentAuth == null) return null;
    
    // Check if token is expired
    if (_currentAuth!.tokenExpiration.isBefore(DateTime.now())) {
      if (kDebugMode) {
        print('⚠️ Access token expired, attempting refresh...');
      }
      
      final refreshed = await refreshToken();
      if (!refreshed) {
        return null;
      }
    }
    
    return _currentAuth?.accessToken;
  }

  Future<String?> getRefreshToken() async {
    return _currentAuth?.refreshToken;
  }

  Future<bool> refreshToken() async {
    final refreshTokenValue = await getRefreshToken();
    if (refreshTokenValue == null) return false;

    try {
      // We need to import ApiClient here, but we have circular dependency
      // For now, let's just return false and handle this differently
      if (kDebugMode) {
        print('🔄 Token refresh not implemented due to circular dependency');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Token refresh failed: $e');
      }
      await logout();
      return false;
    }
  }

  Future<void> _attemptTokenRefresh() async {
    final success = await refreshToken();
    if (!success) {
      await clearAuth();
    }
  }

  Future<void> _saveAuthData() async {
    if (_currentAuth == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(_currentAuth!.toJson()));
    await prefs.setString(_accessTokenKey, _currentAuth!.accessToken);
    await prefs.setString(_refreshTokenKey, _currentAuth!.refreshToken);
    await prefs.setString(_tokenExpirationKey, _currentAuth!.tokenExpiration.toIso8601String());
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpirationKey);
  }

  bool hasPermission(String permission) {
    return _currentAuth?.permissions.contains(permission) ?? false;
  }

  bool hasAnyPermission(List<String> permissions) {
    if (_currentAuth == null) return false;
    return permissions.any((permission) => _currentAuth!.permissions.contains(permission));
  }

  bool hasRole(UserRole role) {
    return _currentAuth?.role == role;
  }

  bool hasAnyRole(List<UserRole> roles) {
    if (_currentAuth == null) return false;
    return roles.contains(_currentAuth!.role);
  }
}

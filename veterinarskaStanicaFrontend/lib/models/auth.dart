import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  final String? clientType;

  const LoginRequest({
    required this.email,
    required this.password,
    this.clientType = 'Desktop',
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final UserRole role;
  final String accessToken;
  final String refreshToken;
  final DateTime tokenExpiration;
  final bool isActive;
  final bool isEmailVerified;
  final List<String> permissions;

  const AuthResponse({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiration,
    required this.isActive,
    required this.isEmailVerified,
    required this.permissions,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  String get fullName => '$firstName $lastName';
}

@JsonSerializable()
class ApiError {
  final String message;
  final String? details;
  final int? statusCode;

  const ApiError({
    required this.message,
    this.details,
    this.statusCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}


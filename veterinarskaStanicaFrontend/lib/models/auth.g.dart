// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
  clientType: json['clientType'] as String? ?? 'Desktop',
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'clientType': instance.clientType,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  userId: (json['userId'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  tokenExpiration: DateTime.parse(json['tokenExpiration'] as String),
  isActive: json['isActive'] as bool,
  isEmailVerified: json['isEmailVerified'] as bool,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'username': instance.username,
      'role': _$UserRoleEnumMap[instance.role]!,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'tokenExpiration': instance.tokenExpiration.toIso8601String(),
      'isActive': instance.isActive,
      'isEmailVerified': instance.isEmailVerified,
      'permissions': instance.permissions,
    };

const _$UserRoleEnumMap = {
  UserRole.petOwner: 1,
  UserRole.veterinarian: 2,
  UserRole.vetTechnician: 3,
  UserRole.receptionist: 4,
  UserRole.admin: 5,
};

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  message: json['message'] as String,
  details: json['details'] as String?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'message': instance.message,
  'details': instance.details,
  'statusCode': instance.statusCode,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  address: json['address'] as String?,
  dateCreated: DateTime.parse(json['dateCreated'] as String),
  lastLoginDate: json['lastLoginDate'] == null
      ? null
      : DateTime.parse(json['lastLoginDate'] as String),
  isActive: json['isActive'] as bool,
  isEmailVerified: json['isEmailVerified'] as bool,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  licenseNumber: json['licenseNumber'] as String?,
  specialization: json['specialization'] as String?,
  yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt(),
  biography: json['biography'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'username': instance.username,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'dateCreated': instance.dateCreated.toIso8601String(),
  'lastLoginDate': instance.lastLoginDate?.toIso8601String(),
  'isActive': instance.isActive,
  'isEmailVerified': instance.isEmailVerified,
  'role': _$UserRoleEnumMap[instance.role]!,
  'licenseNumber': instance.licenseNumber,
  'specialization': instance.specialization,
  'yearsOfExperience': instance.yearsOfExperience,
  'biography': instance.biography,
};

const _$UserRoleEnumMap = {
  UserRole.petOwner: 1,
  UserRole.veterinarian: 2,
  UserRole.vetTechnician: 3,
  UserRole.receptionist: 4,
  UserRole.admin: 5,
};

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue(1)
  petOwner,
  @JsonValue(2)
  veterinarian,
  @JsonValue(3)
  vetTechnician,
  @JsonValue(4)
  receptionist,
  @JsonValue(5)
  admin,
}

@JsonSerializable()
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? phoneNumber;
  final String? address;
  final DateTime dateCreated;
  final DateTime? lastLoginDate;
  final bool isActive;
  final bool isEmailVerified;
  final UserRole role;
  
  // Veterinarian-specific fields
  final String? licenseNumber;
  final String? specialization;
  final int? yearsOfExperience;
  final String? biography;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.address,
    required this.dateCreated,
    this.lastLoginDate,
    required this.isActive,
    required this.isEmailVerified,
    required this.role,
    this.licenseNumber,
    this.specialization,
    this.yearsOfExperience,
    this.biography,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$firstName $lastName';
  
  bool get isVeterinarian => role == UserRole.veterinarian;
  bool get isAdmin => role == UserRole.admin;
  bool get isStaff => [UserRole.admin, UserRole.receptionist, UserRole.vetTechnician].contains(role);
}


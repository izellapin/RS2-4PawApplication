import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'pet.g.dart';

enum PetGender {
  @JsonValue(1)
  male,
  @JsonValue(2)
  female,
}

enum PetStatus {
  @JsonValue(1)
  active,
  @JsonValue(2)
  inactive,
  @JsonValue(3)
  deceased,
}

@JsonSerializable()
class Pet {
  final int id;
  final String name;
  final String species;
  final String? breed;
  final PetGender gender;
  final DateTime? dateOfBirth;
  final String? color;
  final double? weight;
  final String? microchipNumber;
  final PetStatus status;
  final String? notes;
  final String? photoUrl;
  final DateTime dateCreated;
  final DateTime? dateModified;
  final int petOwnerId;
  final User? petOwner;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    required this.gender,
    this.dateOfBirth,
    this.color,
    this.weight,
    this.microchipNumber,
    required this.status,
    this.notes,
    this.photoUrl,
    required this.dateCreated,
    this.dateModified,
    required this.petOwnerId,
    this.petOwner,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);

  Map<String, dynamic> toJson() => _$PetToJson(this);

  // Helper getters for UI
  String get genderText {
    switch (gender) {
      case PetGender.male:
        return 'Muški';
      case PetGender.female:
        return 'Ženski';
    }
  }

  String get statusText {
    switch (status) {
      case PetStatus.active:
        return 'Aktivan';
      case PetStatus.inactive:
        return 'Neaktivan';
      case PetStatus.deceased:
        return 'Preminuo';
    }
  }

  String get ageText {
    if (dateOfBirth == null) return 'Nepoznato';
    
    final now = DateTime.now();
    final age = now.difference(dateOfBirth!);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return '$years godina${months > 0 ? ' i $months meseci' : ''}';
    } else if (months > 0) {
      return '$months meseci';
    } else {
      return '${age.inDays} dana';
    }
  }

  String get ownerName => petOwner?.firstName != null && petOwner?.lastName != null
      ? '${petOwner!.firstName} ${petOwner!.lastName}'
      : petOwner?.email ?? 'Nepoznato';
}











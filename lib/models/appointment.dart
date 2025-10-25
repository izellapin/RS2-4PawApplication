import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

enum AppointmentStatus {
  @JsonValue(1)
  scheduled,
  @JsonValue(2)
  confirmed,
  @JsonValue(3)
  inProgress,
  @JsonValue(4)
  completed,
  @JsonValue(5)
  cancelled,
  @JsonValue(6)
  noShow,
  @JsonValue(7)
  rescheduled,
}

enum AppointmentType {
  @JsonValue(1)
  checkup,
  @JsonValue(2)
  vaccination,
  @JsonValue(3)
  surgery,
  @JsonValue(4)
  emergency,
  @JsonValue(5)
  grooming,
  @JsonValue(6)
  dental,
  @JsonValue(7)
  consultation,
  @JsonValue(8)
  followUp,
}

@JsonSerializable()
class Appointment {
  final int id;
  final String appointmentNumber;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final double? estimatedCost;
  final double? actualCost;
  final DateTime? dateCreated;
  final DateTime? dateModified;
  final int? petId;
  final int? veterinarianId;
  final int? serviceId;
  final String? petName;
  final String? ownerName;
  final String? veterinarianName;
  final String? serviceName;

  Appointment({
    required this.id,
    required this.appointmentNumber,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.status,
    this.reason,
    this.notes,
    this.estimatedCost,
    this.actualCost,
    this.dateCreated,
    this.dateModified,
    this.petId,
    this.veterinarianId,
    this.serviceId,
    this.petName,
    this.ownerName,
    this.veterinarianName,
    this.serviceName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);

  // Helper getters for UI
  String get statusText {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Zakazan';
      case AppointmentStatus.confirmed:
        return 'Potvrđen';
      case AppointmentStatus.inProgress:
        return 'U toku';
      case AppointmentStatus.completed:
        return 'Završen';
      case AppointmentStatus.cancelled:
        return 'Otkazan';
      case AppointmentStatus.noShow:
        return 'Nije se pojavio';
      case AppointmentStatus.rescheduled:
        return 'Prebačen';
    }
  }

  String get typeText {
    switch (type) {
      case AppointmentType.checkup:
        return 'Pregled';
      case AppointmentType.vaccination:
        return 'Vakcinacija';
      case AppointmentType.surgery:
        return 'Operacija';
      case AppointmentType.emergency:
        return 'Hitni slučaj';
      case AppointmentType.grooming:
        return 'Čišćenje';
      case AppointmentType.dental:
        return 'Stomatologija';
      case AppointmentType.consultation:
        return 'Konsultacija';
      case AppointmentType.followUp:
        return 'Kontrola';
    }
  }

  String get timeRange => '$startTime - $endTime';
  
  String get formattedDate {
    final now = DateTime.now();
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
    );
    
    if (appointmentDateTime.year == now.year &&
        appointmentDateTime.month == now.month &&
        appointmentDateTime.day == now.day) {
      return 'Danas';
    } else if (appointmentDateTime.year == now.year &&
               appointmentDateTime.month == now.month &&
               appointmentDateTime.day == now.day + 1) {
      return 'Sutra';
    } else {
      return '${appointmentDate.day}.${appointmentDate.month}.${appointmentDate.year}';
    }
  }

  String get statusColor {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'blue';
      case AppointmentStatus.confirmed:
        return 'green';
      case AppointmentStatus.inProgress:
        return 'orange';
      case AppointmentStatus.completed:
        return 'red';
      case AppointmentStatus.cancelled:
        return 'red';
      case AppointmentStatus.noShow:
        return 'red';
      case AppointmentStatus.rescheduled:
        return 'purple';
    }
  }
}











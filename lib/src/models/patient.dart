// lib/src/models/patient.dart
class Patient {
  final String id;
  final String doctorId;
  final String name; // Required
  final String email; // Required
  // TODO: Add these fields after running database migration
  // final DateTime? dateOfBirth;
  // final String? gender;
  final String? pronouns;
  final String? background;
  final String? medicalHistory;
  final String? familyHistory;
  final String? socialHistory;
  final String? previousTreatment;

  Patient({
    required this.id,
    required this.doctorId,
    required this.name,
    required this.email,
    // TODO: Add these fields after running database migration
    // this.dateOfBirth,
    // this.gender,
    this.pronouns,
    this.background,
    this.medicalHistory,
    this.familyHistory,
    this.socialHistory,
    this.previousTreatment,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      // TODO: Add these fields after running database migration
      // dateOfBirth: json['date_of_birth'] != null
      //     ? DateTime.parse(json['date_of_birth'] as String)
      //     : null,
      // gender: json['gender'] as String?,
      pronouns: json['pronouns'] as String?,
      background: json['background'] as String?,
      medicalHistory: json['medical_history'] as String?,
      familyHistory: json['family_history'] as String?,
      socialHistory: json['social_history'] as String?,
      previousTreatment: json['previous_treatment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'name': name,
      'email': email,
      // TODO: Add these fields after running database migration
      // 'date_of_birth': dateOfBirth?.toIso8601String(),
      // 'gender': gender,
      'pronouns': pronouns,
      'background': background,
      'medical_history': medicalHistory,
      'family_history': familyHistory,
      'social_history': socialHistory,
      'previous_treatment': previousTreatment,
    };
  }
}

class PatientCreateRequest {
  final String doctorId;
  final String name; // Required
  final String email; // Required
  // TODO: Add these fields after running database migration
  // final DateTime? dateOfBirth;
  // final String? gender;
  final String? pronouns;
  final String? background;
  final String? medicalHistory;
  final String? familyHistory;
  final String? socialHistory;
  final String? previousTreatment;

  PatientCreateRequest({
    required this.doctorId,
    required this.name,
    required this.email,
    // TODO: Add these fields after running database migration
    // this.dateOfBirth,
    // this.gender,
    this.pronouns,
    this.background,
    this.medicalHistory,
    this.familyHistory,
    this.socialHistory,
    this.previousTreatment,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'name': name,
      'email': email,
      // TODO: Add these fields after running database migration
      // 'date_of_birth': dateOfBirth?.toIso8601String(),
      // 'gender': gender,
      'pronouns': pronouns,
      'background': background,
      'medical_history': medicalHistory,
      'family_history': familyHistory,
      'social_history': socialHistory,
      'previous_treatment': previousTreatment,
    };
  }
}

class PatientResponse {
  final Patient patient;

  PatientResponse({required this.patient});

  factory PatientResponse.fromJson(Map<String, dynamic> json) {
    return PatientResponse(
      patient: Patient.fromJson(json['patient'] as Map<String, dynamic>),
    );
  }
}

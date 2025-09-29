// lib/src/services/patient_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:medinote/src/utils/constants.dart';
import '../models/patient.dart';
import 'auth_service.dart';

class PatientService {
  static const String _baseUrl =
      '${Constants.apiURL}/v1'; // Change this to your backend URL
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static Future<Map<String, String>> get _authHeaders async {
    final headers = Map<String, String>.from(_headers);
    final authHeader = await AuthService.getAuthHeader();
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }
    return headers;
  }

  static Future<PatientResponse> addPatient(
    PatientCreateRequest request,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/add-patient-ext');
      final headers = await _authHeaders;

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return PatientResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw PatientServiceException(
          'Bad Request: ${errorData['detail'] ?? 'Invalid patient data'}',
        );
      } else if (response.statusCode == 403) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw PatientServiceException(
          'Unauthorized: ${errorData['detail'] ?? 'Access denied'}',
        );
      } else if (response.statusCode == 401) {
        throw PatientServiceException(
          'Authentication required. Please log in again.',
        );
      } else {
        throw PatientServiceException(
          'Failed to add patient. Server returned status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw PatientServiceException(
        'Network error. Please check your internet connection and try again.',
      );
    } on FormatException {
      throw PatientServiceException('Invalid response format from server.');
    } catch (e) {
      if (e is PatientServiceException) {
        rethrow;
      }
      throw PatientServiceException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  static Future<List<Patient>> getPatients(String doctorId) async {
    try {
      final uri = Uri.parse('$_baseUrl/patients?doctor_id=$doctorId');
      final headers = await _authHeaders;

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> patientsJson = responseData['patients'];
        return patientsJson.map((json) => Patient.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw PatientServiceException(
          'Unauthorized: ${errorData['detail'] ?? 'Access denied'}',
        );
      } else if (response.statusCode == 401) {
        throw PatientServiceException(
          'Authentication required. Please log in again.',
        );
      } else {
        throw PatientServiceException(
          'Failed to fetch patients. Server returned status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw PatientServiceException(
        'Network error. Please check your internet connection and try again.',
      );
    } on FormatException {
      throw PatientServiceException('Invalid response format from server.');
    } catch (e) {
      if (e is PatientServiceException) {
        rethrow;
      }
      throw PatientServiceException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  static Future<Patient> getPatientDetails(String patientId) async {
    try {
      final uri = Uri.parse('$_baseUrl/patient-details/$patientId');
      final headers = await _authHeaders;

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Patient.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw PatientServiceException('Patient not found.');
      } else if (response.statusCode == 403) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw PatientServiceException(
          'Unauthorized: ${errorData['detail'] ?? 'Access denied'}',
        );
      } else if (response.statusCode == 401) {
        throw PatientServiceException(
          'Authentication required. Please log in again.',
        );
      } else {
        throw PatientServiceException(
          'Failed to fetch patient details. Server returned status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw PatientServiceException(
        'Network error. Please check your internet connection and try again.',
      );
    } on FormatException {
      throw PatientServiceException('Invalid response format from server.');
    } catch (e) {
      if (e is PatientServiceException) {
        rethrow;
      }
      throw PatientServiceException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}

class PatientServiceException implements Exception {
  final String message;

  PatientServiceException(this.message);

  @override
  String toString() => message;
}

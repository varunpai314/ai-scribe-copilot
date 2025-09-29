// lib/src/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:medinote/src/utils/constants.dart';
import '../models/doctor.dart';
import 'secure_storage_service.dart';
import 'database_helper.dart';

class AuthService {
  static const String _baseUrl =
      '${Constants.apiURL}/auth'; // Change this to your backend URL
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Signup doctor
  static Future<AuthResult> signup(DoctorSignupRequest request) async {
    try {
      final uri = Uri.parse('$_baseUrl/signup');

      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);

        // Store tokens securely
        await SecureStorageService.storeTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          tokenType: authResponse.tokenType,
          doctorId: authResponse.doctorId,
        );

        // Create doctor object with received data
        final doctor = Doctor(
          id: authResponse.doctorId,
          name: request.name,
          email: request.email,
          specialization: request.specialization,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Store doctor data in local database
        await DatabaseHelper.instance.insertDoctor(doctor);

        return AuthResult.success(doctor);
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResult.error(
          errorData['detail'] ?? 'Email already registered',
        );
      } else {
        return AuthResult.error(
          'Signup failed. Server returned status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      return AuthResult.error(
        'Network error. Please check your internet connection and try again.',
      );
    } on FormatException {
      return AuthResult.error('Invalid response format from server.');
    } catch (e) {
      return AuthResult.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Login doctor
  static Future<AuthResult> login(DoctorLoginRequest request) async {
    try {
      final uri = Uri.parse('$_baseUrl/login');

      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);

        // Store tokens securely
        await SecureStorageService.storeTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          tokenType: authResponse.tokenType,
          doctorId: authResponse.doctorId,
        );

        // Create doctor object with received data
        final doctor = Doctor(
          id: authResponse.doctorId,
          name: '', // Will be updated when we fetch doctor profile
          email: request.email,
          specialization: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Store doctor data in local database
        await DatabaseHelper.instance.insertDoctor(doctor);

        return AuthResult.success(doctor);
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return AuthResult.error(errorData['detail'] ?? 'Invalid credentials');
      } else {
        return AuthResult.error(
          'Login failed. Server returned status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      return AuthResult.error(
        'Network error. Please check your internet connection and try again.',
      );
    } on FormatException {
      return AuthResult.error('Invalid response format from server.');
    } catch (e) {
      return AuthResult.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Logout doctor
  static Future<void> logout() async {
    try {
      // Clear tokens from secure storage
      await SecureStorageService.clearTokens();

      // Clear doctor data from local database
      await DatabaseHelper.instance.clearAllDoctors();
    } catch (e) {
      throw AuthServiceException('Failed to logout: $e');
    }
  }

  // Check if doctor is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final hasTokens = await SecureStorageService.hasTokens();
      final hasDoctor = await DatabaseHelper.instance.isDoctorLoggedIn();
      return hasTokens && hasDoctor;
    } catch (e) {
      return false;
    }
  }

  // Get current authenticated doctor
  static Future<Doctor?> getCurrentDoctor() async {
    try {
      if (await isAuthenticated()) {
        return await DatabaseHelper.instance.getCurrentDoctor();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current access token with Bearer prefix
  static Future<String?> getAuthHeader() async {
    try {
      final accessToken = await SecureStorageService.getAccessToken();
      final tokenType = await SecureStorageService.getTokenType();

      if (accessToken != null && tokenType != null) {
        return '$tokenType $accessToken';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current doctor ID
  static Future<String?> getCurrentDoctorId() async {
    try {
      return await SecureStorageService.getDoctorId();
    } catch (e) {
      return null;
    }
  }

  // Refresh access token (if your backend supports it)
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null) return false;

      // TODO: Implement refresh token endpoint if available in your backend
      // For now, return false to indicate refresh is not available
      return false;
    } catch (e) {
      return false;
    }
  }

  // Auto-login check (for app initialization)
  static Future<AuthResult?> autoLogin() async {
    try {
      if (await isAuthenticated()) {
        final doctor = await getCurrentDoctor();
        if (doctor != null) {
          return AuthResult.success(doctor);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clear all auth data (for complete reset)
  static Future<void> clearAllAuthData() async {
    try {
      await Future.wait([
        SecureStorageService.clearAll(),
        DatabaseHelper.instance.clearAllDoctors(),
      ]);
    } catch (e) {
      throw AuthServiceException('Failed to clear auth data: $e');
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final Doctor? doctor;
  final String? error;

  AuthResult._({required this.isSuccess, this.doctor, this.error});

  factory AuthResult.success(Doctor doctor) {
    return AuthResult._(isSuccess: true, doctor: doctor);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}

class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => 'AuthServiceException: $message';
}

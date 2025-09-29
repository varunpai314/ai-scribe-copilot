import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session.dart';
import '../utils/constants.dart';
import 'secure_storage_service.dart';

class SessionService {
  static const String baseUrl = Constants.apiURL;

  // Create a new session using the existing upload-session endpoint
  static Future<String> createSession(SessionCreateRequest request) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final payload = {
      'patientId': request.patientId,
      'userId': request.doctorId,
      'patientName':
          request.sessionTitle ??
          'Session', // Using sessionTitle as patient display name
      'status': request.status ?? 'recording',
      'startTime': request.startTime ?? DateTime.now().toIso8601String(),
      'templateId':
          request.templateId ??
          '00000000-0000-0000-0000-000000000000', // Default template ID
    };

    final response = await http.post(
      Uri.parse('$baseUrl/session/upload-session'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'] as String; // Returns only the session ID
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create session');
    }
  }

  // Create a session with full template and title information
  static Future<String> createSessionWithTemplate({
    required String doctorId,
    required String patientId,
    required String templateId,
    required String sessionTitle,
  }) async {
    final request = SessionCreateRequest(
      doctorId: doctorId,
      patientId: patientId,
      templateId: templateId,
      sessionTitle: sessionTitle,
      status: 'recording',
      date: DateTime.now().toIso8601String().substring(0, 10),
      startTime: DateTime.now().toIso8601String(),
    );

    return await createSession(request);
  }

  // Get all sessions for a doctor using the existing all-session endpoint
  static Future<List<Session>> getDoctorSessions(String doctorId) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/session/all-session?userId=$doctorId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> sessions = data['sessions'] ?? [];

      return sessions.map((sessionData) {
        return Session(
          id: sessionData['id'] as String,
          doctorId: sessionData['user_id'] as String,
          patientId: sessionData['patient_id'] as String,
          templateId: null, // Not included in the response
          sessionTitle: sessionData['session_title'] as String?,
          sessionSummary: sessionData['session_summary'] as String?,
          transcriptStatus: sessionData['transcript_status'] as String?,
          transcript: sessionData['transcript'] as String?,
          status: sessionData['status'] as String?,
          date: sessionData['date'] as String?,
          startTime: sessionData['start_time'] as String?,
          endTime: sessionData['end_time'] as String?,
          duration: sessionData['duration'] as String?,
        );
      }).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  // Get all sessions for a patient using the existing fetch-session-by-patient endpoint
  static Future<List<Session>> getPatientSessions(String patientId) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/session/fetch-session-by-patient/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> sessions = data['sessions'] ?? [];

      return sessions.map((sessionData) {
        return Session(
          id: sessionData['id'] as String,
          doctorId: '', // Not included in this endpoint response
          patientId: patientId,
          templateId: null,
          sessionTitle: sessionData['session_title'] as String?,
          sessionSummary: sessionData['session_summary'] as String?,
          transcriptStatus: null,
          transcript: null,
          status: null,
          date: sessionData['date'] as String?,
          startTime: null,
          endTime: null,
          duration: sessionData['duration'] as String?,
        );
      }).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else {
      throw Exception('Failed to load patient sessions');
    }
  }

  // Get a specific session by ID
  static Future<Session> getSession(String sessionId) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/sessions/$sessionId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Session.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else if (response.statusCode == 404) {
      throw Exception('Session not found');
    } else {
      throw Exception('Failed to load session');
    }
  }

  // Update a session
  static Future<Session> updateSession(
    String sessionId,
    SessionUpdateRequest request,
  ) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/sessions/$sessionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Session.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else if (response.statusCode == 404) {
      throw Exception('Session not found');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to update session');
    }
  }

  // Delete a session
  static Future<void> deleteSession(String sessionId) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/sessions/$sessionId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else if (response.statusCode == 404) {
      throw Exception('Session not found');
    } else if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete session');
    }
  }

  // Start a session (update status to active and set start time)
  static Future<Session> startSession(String sessionId) async {
    final now = DateTime.now();
    final request = SessionUpdateRequest(
      status: SessionStatus.active,
      startTime: now.toIso8601String(),
    );
    return updateSession(sessionId, request);
  }

  // End a session (update status to completed and set end time)
  static Future<Session> endSession(String sessionId) async {
    final now = DateTime.now();

    // First get the current session to calculate duration
    final currentSession = await getSession(sessionId);

    String? duration;
    if (currentSession.startTime != null) {
      final startTime = DateTime.parse(currentSession.startTime!);
      final endTime = now;
      final diff = endTime.difference(startTime);

      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      final seconds = diff.inSeconds.remainder(60);

      duration =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    final request = SessionUpdateRequest(
      status: SessionStatus.completed,
      endTime: now.toIso8601String(),
      duration: duration,
    );

    return updateSession(sessionId, request);
  }

  // Pause a session
  static Future<Session> pauseSession(String sessionId) async {
    final request = SessionUpdateRequest(status: SessionStatus.paused);
    return updateSession(sessionId, request);
  }

  // Resume a session
  static Future<Session> resumeSession(String sessionId) async {
    final request = SessionUpdateRequest(status: SessionStatus.active);
    return updateSession(sessionId, request);
  }
}

// lib/src/services/template_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/template.dart';
import '../utils/constants.dart';
import 'secure_storage_service.dart';

class TemplateService {
  static const String baseUrl = Constants.apiURL;

  // Get all templates for a doctor
  static Future<List<Template>> getTemplatesForDoctor(String doctorId) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/session/fetch-default-template-ext?userId=$doctorId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final templateResponse = TemplateResponse.fromJson(data);
      return templateResponse.templates;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to fetch templates');
    }
  }
}

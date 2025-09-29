// lib/src/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenTypeKey = 'token_type';
  static const _doctorIdKey = 'doctor_id';

  // Store authentication tokens
  static Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required String doctorId,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
        _storage.write(key: _tokenTypeKey, value: tokenType),
        _storage.write(key: _doctorIdKey, value: doctorId),
      ]);
    } catch (e) {
      throw SecureStorageException('Failed to store tokens: $e');
    }
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw SecureStorageException('Failed to get access token: $e');
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw SecureStorageException('Failed to get refresh token: $e');
    }
  }

  // Get token type
  static Future<String?> getTokenType() async {
    try {
      return await _storage.read(key: _tokenTypeKey);
    } catch (e) {
      throw SecureStorageException('Failed to get token type: $e');
    }
  }

  // Get doctor ID
  static Future<String?> getDoctorId() async {
    try {
      return await _storage.read(key: _doctorIdKey);
    } catch (e) {
      throw SecureStorageException('Failed to get doctor ID: $e');
    }
  }

  // Update access token (for token refresh)
  static Future<void> updateAccessToken(String accessToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    } catch (e) {
      throw SecureStorageException('Failed to update access token: $e');
    }
  }

  // Check if tokens exist
  static Future<bool> hasTokens() async {
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      final doctorId = await _storage.read(key: _doctorIdKey);

      return accessToken != null && refreshToken != null && doctorId != null;
    } catch (e) {
      return false;
    }
  }

  // Get all token data
  static Future<Map<String, String?>> getAllTokens() async {
    try {
      final futures = await Future.wait([
        _storage.read(key: _accessTokenKey),
        _storage.read(key: _refreshTokenKey),
        _storage.read(key: _tokenTypeKey),
        _storage.read(key: _doctorIdKey),
      ]);

      return {
        'accessToken': futures[0],
        'refreshToken': futures[1],
        'tokenType': futures[2],
        'doctorId': futures[3],
      };
    } catch (e) {
      throw SecureStorageException('Failed to get all tokens: $e');
    }
  }

  // Clear all stored tokens (logout)
  static Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _tokenTypeKey),
        _storage.delete(key: _doctorIdKey),
      ]);
    } catch (e) {
      throw SecureStorageException('Failed to clear tokens: $e');
    }
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to clear all data: $e');
    }
  }

  // Check if storage is available
  static Future<bool> isStorageAvailable() async {
    try {
      await _storage.containsKey(key: 'test_key');
      return true;
    } catch (e) {
      return false;
    }
  }
}

class SecureStorageException implements Exception {
  final String message;
  SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}

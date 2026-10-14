import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthService({
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String institutionName,
    String institutionType = 'university',
    required String city,
    required String state,
    String contactNumber = '',
    String department = '',
    String title = 'Researcher',
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'institutionName': institutionName,
        'institutionType': institutionType,
        'city': city,
        'state': state,
        'contactNumber': contactNumber,
        'department': department,
        'title': title,
      },
    );

    final data = response.data['data'];
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    await saveSession(token, user);
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data['data'];
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    await saveSession(token, user);
    return user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (_) {
      // Ignore network errors on logout to allow local cleanup
    }
    await clearSession();
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _apiClient.get('/auth/me');
      final user = UserModel.fromJson(response.data['data']['user']);
      await saveUser(user);
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/auth/reset-password',
      data: {'token': token, 'newPassword': newPassword},
    );
  }

  // Session storage management
  Future<void> saveSession(String token, UserModel user) async {
    await _storage.write(key: AppConstants.tokenStorageKey, value: token);
    await saveUser(user);
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.write(
      key: AppConstants.userStorageKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenStorageKey);
  }

  Future<UserModel?> getCachedUser() async {
    final raw = await _storage.read(key: AppConstants.userStorageKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.tokenStorageKey);
    await _storage.delete(key: AppConstants.userStorageKey);
  }
}

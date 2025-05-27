// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrition_app/services/api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final ApiClient _apiClient = ApiClient();

  // Auth state change notifier
  final ValueNotifier<bool> authStateChanges = ValueNotifier<bool>(false);

  // Store user data
  Map<String, dynamic>? _userData;
  String? _token;

  // Getters
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  // Singleton factory
  factory AuthService() => _instance;

  AuthService._internal();

  // Initialize the service by loading saved data
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      // Parse stored user data if available
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        _userData = jsonDecode(userDataString) as Map<String, dynamic>;
      }

      if (_token != null) {
        _apiClient.setToken(_token!);
      }

      // Notify listeners about auth state
      authStateChanges.value = isAuthenticated;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth service: $e');
      }
      rethrow;
    }
  }

  // User Registration
  Future<Map<String, dynamic>> register(
    String username,
    String phone,
    String password,
  ) async {
    try {
      final response = await _apiClient.request(
        method: 'POST',
        path: '/auth/register',
        data: {
          'username': username,
          'phone': phone,
          'password': password,
        },
      );

      // If registration is successful and data contains auth token, handle as login
      if (response['success'] &&
          response['data'] != null &&
          response['data']['authToken'] != null) {
        await _handleLoginSuccess(response['data']);
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error during registration: $e',
      };
    }
  }

  // User Login
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _apiClient.request(
        method: 'POST',
        path: '/auth/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      if (response['success']) {
        await _handleLoginSuccess(response['data']);
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error during login: $e',
      };
    }
  }

  // Handle successful login
  Future<void> _handleLoginSuccess(Map<String, dynamic> data) async {
    _token = data['authToken'];
    _userData = data['user'] as Map<String, dynamic>;

    // Set token in API client
    _apiClient.setToken(_token!);

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);

    // Save user data
    if (_userData != null) {
      await prefs.setString('userData', jsonEncode(_userData));
    }

    // Notify listeners
    authStateChanges.value = true;
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      // Clear data
      _token = null;
      _userData = null;

      // Clear token in API client
      _apiClient.clearToken();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userData');

      // Notify listeners
      authStateChanges.value = false;

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error during logout: $e',
      };
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (username != null) data['username'] = username;
      if (phone != null) data['phone'] = phone;
      if (currentPassword != null) data['current_password'] = currentPassword;
      if (newPassword != null) data['new_password'] = newPassword;

      final response = await _apiClient.request(
        method: 'PUT',
        path: '/users/profile',
        data: data,
      );

      // Update local user data if successful
      if (response['success'] && response['data'] != null) {
        _userData = response['data'] as Map<String, dynamic>;
        // Save updated user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(_userData));
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating profile: $e',
      };
    }
  }
}

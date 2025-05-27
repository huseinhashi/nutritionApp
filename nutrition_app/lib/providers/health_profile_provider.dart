import 'package:flutter/foundation.dart';
import 'package:nutrition_app/services/health_profile_service.dart';
import 'package:nutrition_app/services/auth_service.dart';

class HealthProfileProvider with ChangeNotifier {
  final HealthProfileService _healthProfileService;
  final AuthService _authService;
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  HealthProfileProvider(this._healthProfileService, this._authService) {
    // Initialize profile when provider is created
    _initializeProfile();

    // Listen to auth state changes
    _authService.authStateChanges.addListener(_handleAuthStateChange);
  }

  @override
  void dispose() {
    _authService.authStateChanges.removeListener(_handleAuthStateChange);
    super.dispose();
  }

  void _handleAuthStateChange() {
    if (_authService.isAuthenticated) {
      _initializeProfile();
    } else {
      clearProfile();
    }
  }

  Future<void> _initializeProfile() async {
    if (_authService.isAuthenticated) {
      await fetchProfile();
    }
  }

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  Future<void> createOrUpdateProfile({
    required int age,
    required String gender,
    required double weight,
    required double height,
    required String goal,
    required String activityLevel,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _healthProfileService.createOrUpdateProfile(
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        goal: goal,
        activityLevel: activityLevel,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    if (!_authService.isAuthenticated) {
      clearProfile();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _healthProfileService.getProfile();
    } catch (e) {
      _error = e.toString();
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkProfile() async {
    try {
      await fetchProfile();
      return hasProfile;
    } catch (e) {
      return false;
    }
  }

  void clearProfile() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}

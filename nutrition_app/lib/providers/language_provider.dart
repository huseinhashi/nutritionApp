import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrition_app/utils/languages.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('language') ?? 'en';
      notifyListeners();
    } catch (e) {
      print('Error loading language: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language', language);
        notifyListeners();
      } catch (e) {
        print('Error saving language: $e');
      }
    }
  }

  String getText(String key) {
    return Languages.getText(key, _currentLanguage);
  }

  void toggleLanguage() {
    final newLanguage = _currentLanguage == 'en' ? 'so' : 'en';
    setLanguage(newLanguage);
  }
}

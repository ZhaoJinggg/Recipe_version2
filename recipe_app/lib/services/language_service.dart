import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('zh', ''), // Mandarin Chinese
    Locale('ms', ''), // Bahasa Malaysia
  ];

  // Language display names
  static const Map<String, String> languageNames = {
    'en': 'English',
    'zh': 'Mandarin',
    'ms': 'Bahasa Malaysia',
  };

  // Get current language
  static Future<Locale> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    return Locale(languageCode, '');
  }

  // Set language
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // Get language display name
  static String getLanguageDisplayName(String languageCode) {
    return languageNames[languageCode] ?? 'English';
  }

  // Check if locale is supported
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }
}

import 'package:flutter/material.dart';
import 'package:recipe_app/services/language_service.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', '');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() async {
    _currentLocale = await LanguageService.getCurrentLanguage();
    notifyListeners();
  }

  void setLanguage(String languageCode) async {
    await LanguageService.setLanguage(languageCode);
    _currentLocale = Locale(languageCode, '');
    notifyListeners();
  }

  String get currentLanguageDisplayName {
    return LanguageService.getLanguageDisplayName(_currentLocale.languageCode);
  }
}

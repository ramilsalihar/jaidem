import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale';

  LocaleCubit() : super(const Locale('ky')) {
    _loadSavedLocale();
  }

  static const List<Locale> supportedLocales = [
    Locale('ky'), // Kyrgyz
    Locale('ru'), // Russian
    Locale('en'), // English
  ];

  static const Map<String, String> localeNames = {
    'ky': 'Кыргызча',
    'ru': 'Русский',
    'en': 'English',
  };

  static const Map<String, String> localeFlags = {
    'ky': '🇰🇬',
    'ru': '🇷🇺',
    'en': '🇺🇸',
  };

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      emit(Locale(savedLocale));
    }
  }

  Future<void> changeLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    emit(locale);
  }

  String get currentLocaleName => localeNames[state.languageCode] ?? 'Кыргызча';
  String get currentLocaleFlag => localeFlags[state.languageCode] ?? '🇰🇬';
}

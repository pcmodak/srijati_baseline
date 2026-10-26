import 'package:flutter/material.dart';

// Port 3003 ebong server IP set korun
const String apiBaseUrl = 'http://187.127.141.232:3003/api';

class TranslationProvider extends InheritedWidget {
  final String currentLocale;
  final Map<String, Map<String, String>> translations;
  final Function(String) onLocaleChange;
  final Function(Map<String, Map<String, String>>) onTranslationsUpdate;

  const TranslationProvider({
    super.key,
    required this.currentLocale,
    required this.translations,
    required this.onLocaleChange,
    required this.onTranslationsUpdate,
    required super.child,
  });

  static TranslationProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TranslationProvider>()!;
  }

  String translate(String key, {String fallback = ''}) {
    if (translations.containsKey(key)) {
      return translations[key]![currentLocale] ?? fallback;
    }
    return fallback.isNotEmpty ? fallback : key;
  }

  @override
  bool updateShouldNotify(TranslationProvider oldWidget) {
    return oldWidget.currentLocale != currentLocale ||
        oldWidget.translations != translations;
  }
}
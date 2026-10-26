import 'package:flutter/material.dart';
import 'database/local_database.dart';
import 'services/translation_service.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.init();
  runApp(const SrijatiApp());
}

class SrijatiApp extends StatefulWidget {
  const SrijatiApp({super.key});

  @override
  State<SrijatiApp> createState() => _SrijatiAppState();
}

class _SrijatiAppState extends State<SrijatiApp> {
  String _currentLocale = 'bn';
  Map<String, Map<String, String>> _translations = {};

  @override
  void initState() {
    super.initState();
    _loadInitialTranslations();
  }

  Future<void> _loadInitialTranslations() async {
    final cached = await LocalDatabase.instance.loadTranslations();
    if (cached.isNotEmpty) {
      setState(() => _translations = cached);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(
      currentLocale: _currentLocale,
      translations: _translations,
      onLocaleChange: (lang) => setState(() => _currentLocale = lang),
      onTranslationsUpdate: (updated) => setState(() => _translations = updated),
      child: MaterialApp(
        title: 'Srijati Baseline Survey',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
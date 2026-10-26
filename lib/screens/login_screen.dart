import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/translation_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      final res = jsonDecode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        final user = res['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user['id']);
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_level', user['user_level']);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EnumeratorHomeScreen(userData: user),
          ),
        );
      } else {
        _showSnack(res['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showSnack('Server offline ba network somossa.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final tProvider = TranslationProvider.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 72, color: Colors.teal),
              const SizedBox(height: 12),
              const Text(
                'Srijati Foundation',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text('Baseline Livelihood Survey MIS'),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: tProvider.translate('lbl_phone', fallback: 'Phone Number / ফোন নম্বর'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: tProvider.translate('lbl_password', fallback: 'Password / পাসওয়ার্ড'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    tProvider.translate('lbl_login', fallback: 'Login / লগইন'),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('user_id', 1);
                    await prefs.setString('user_name', 'Demo Enumerator');
                    await prefs.setString('user_level', 'enumerator');
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnumeratorHomeScreen(userData: {
                          'id': 1,
                          'name': 'Demo Enumerator',
                          'user_level': 'enumerator',
                        }),
                      ),
                    );
                  },
                  icon: const Icon(Icons.offline_pin_outlined, color: Colors.teal),
                  label: const Text(
                    'Offline / Demo Mode (অফলাইন ডেমো)',
                    style: TextStyle(color: Colors.teal, fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Language / ভাষা: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ActionChip(
                    label: const Text('বাংলা', style: TextStyle(fontSize: 12)),
                    backgroundColor: tProvider.currentLocale == 'bn' ? Colors.teal.shade100 : null,
                    onPressed: () => tProvider.onLocaleChange('bn'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('English', style: TextStyle(fontSize: 12)),
                    backgroundColor: tProvider.currentLocale == 'en' ? Colors.teal.shade100 : null,
                    onPressed: () => tProvider.onLocaleChange('en'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
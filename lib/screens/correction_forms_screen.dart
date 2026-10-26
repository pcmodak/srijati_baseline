import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/translation_service.dart';
import 'survey_form_screen.dart';

class CorrectionFormsScreen extends StatefulWidget {
  final int userId;
  const CorrectionFormsScreen({super.key, required this.userId});

  @override
  State<CorrectionFormsScreen> createState() => _CorrectionFormsScreenState();
}

class _CorrectionFormsScreenState extends State<CorrectionFormsScreen> {
  List<dynamic> _corrections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCorrections();
  }

  Future<void> _fetchCorrections() async {
    try {
      final res = await http.get(Uri.parse('$apiBaseUrl/forms/my-corrections?user_id=${widget.userId}'));
      if (res.statusCode == 200) {
        final parsed = jsonDecode(res.body);
        setState(() {
          _corrections = parsed['data'];
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corrections Needed'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _corrections.isEmpty
          ? const Center(child: Text('No correction pending.'))
          : ListView.builder(
        itemCount: _corrections.length,
        itemBuilder: (ctx, i) {
          final item = _corrections[i];
          return Card(
            color: Colors.red.shade50,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: Text('${item['respondent_name']} (${item['hh_code']})'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Field: ${item['field_key']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Team Remark: ${item['reviewer_comment']}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurveyFormScreen(
                        flaggedField: item['field_key'],
                        reviewerRemark: item['reviewer_comment'],
                      ),
                    ),
                  );
                },
                child: const Text('Fix'),
              ),
            ),
          );
        },
      ),
    );
  }
}
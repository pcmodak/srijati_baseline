import 'package:flutter/material.dart';
import '../database/local_database.dart';
import 'survey_form_screen.dart';

class DraftFormsScreen extends StatefulWidget {
  const DraftFormsScreen({super.key});

  @override
  State<DraftFormsScreen> createState() => _DraftFormsScreenState();
}

class _DraftFormsScreenState extends State<DraftFormsScreen> {
  List<Map<String, dynamic>> _drafts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await LocalDatabase.instance.getDrafts();
    setState(() {
      _drafts = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Drafts (Device)'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _drafts.isEmpty
          ? const Center(child: Text('No local drafts found.'))
          : ListView.builder(
        itemCount: _drafts.length,
        itemBuilder: (ctx, i) {
          final d = _drafts[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.description, color: Colors.orange),
              title: Text(d['respondent_name'] ?? 'Unnamed'),
              subtitle: Text('HH Code: ${d['hh_code']} | Village: ${d['village_name']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () async {
                  await LocalDatabase.instance.deleteDraft(d['id']);
                  _load();
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurveyFormScreen(draftData: d),
                  ),
                ).then((_) => _load());
              },
            ),
          );
        },
      ),
    );
  }
}
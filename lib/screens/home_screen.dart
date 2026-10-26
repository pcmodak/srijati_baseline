import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../database/local_database.dart';
import '../services/translation_service.dart';
import 'draft_forms_screen.dart';
import 'submitted_forms_screen.dart';
import 'correction_forms_screen.dart';
import 'survey_form_screen.dart';

class EnumeratorHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EnumeratorHomeScreen({super.key, required this.userData});

  @override
  State<EnumeratorHomeScreen> createState() => _EnumeratorHomeScreenState();
}

class _EnumeratorHomeScreenState extends State<EnumeratorHomeScreen> {
  int _draftCount = 0;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _refreshDraftCount();
  }

  Future<void> _refreshDraftCount() async {
    final drafts = await LocalDatabase.instance.getDrafts();
    if (mounted) setState(() => _draftCount = drafts.length);
  }

  Future<void> _syncAll() async {
    setState(() => _isSyncing = true);
    final tProvider = TranslationProvider.of(context);

    try {
      // 1. Translations sync
      final transRes = await http.get(Uri.parse('$apiBaseUrl/translations'));
      if (transRes.statusCode == 200) {
        final tData = jsonDecode(transRes.body);
        if (tData['success'] == true) {
          await LocalDatabase.instance.saveTranslations(tData['data']);
          final updated = await LocalDatabase.instance.loadTranslations();
          tProvider.onTranslationsUpdate(updated);
        }
      }

      // 2. Draft upload
      final drafts = await LocalDatabase.instance.getDrafts();
      int uploaded = 0;
      for (var d in drafts) {
        final payload = {
          'user_id': widget.userData['id'],
          'local_uuid': d['local_uuid'],
          'hh_code': d['hh_code'],
          'respondent_name': d['respondent_name'],
          'block_name': d['block_name'],
          'panchayat_name': d['panchayat_name'],
          'village_name': d['village_name'],
          'raw_data': jsonDecode(d['form_json']),
        };

        final submitRes = await http.post(
          Uri.parse('$apiBaseUrl/forms/submit'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (submitRes.statusCode == 200) {
          await LocalDatabase.instance.deleteDraft(d['id']);
          uploaded++;
        }
      }

      await _refreshDraftCount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync Complete! $uploaded forms uploaded.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync failed. Please check network.')),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tProvider = TranslationProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userData['name'] ?? 'Enumerator'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          DropdownButton<String>(
            value: tProvider.currentLocale,
            dropdownColor: Colors.teal.shade700,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (val) {
              if (val != null) tProvider.onLocaleChange(val);
            },
          ),
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Icon(Icons.sync),
            tooltip: tProvider.translate('btn_sync', fallback: 'Sync Data'),
            onPressed: _isSyncing ? null : _syncAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActionCard(
            title: tProvider.translate('card_saved', fallback: 'Saved / Draft Forms'),
            subtitle: '$_draftCount pending local forms on this device',
            icon: Icons.drafts,
            color: Colors.orange.shade700,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DraftFormsScreen()),
              );
              _refreshDraftCount();
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            title: tProvider.translate('card_submitted', fallback: 'Submitted Forms'),
            subtitle: 'Sync & view directly from cloud database',
            icon: Icons.cloud_done,
            color: Colors.blue.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubmittedFormsScreen(userId: widget.userData['id']),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            title: tProvider.translate('card_correction', fallback: 'Needs Correction'),
            subtitle: 'Forms flagged by Team review',
            icon: Icons.error_outline,
            color: Colors.red.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CorrectionFormsScreen(userId: widget.userData['id']),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          tProvider.translate('lbl_new_form', fallback: 'New Survey / নতুন ফর্ম'),
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SurveyFormScreen()),
          );
          _refreshDraftCount();
        },
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          radius: 28,
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
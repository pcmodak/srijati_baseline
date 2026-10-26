import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/translation_service.dart';

class SubmittedFormsScreen extends StatefulWidget {
  final int userId;
  const SubmittedFormsScreen({super.key, required this.userId});

  @override
  State<SubmittedFormsScreen> createState() => _SubmittedFormsScreenState();
}

class _SubmittedFormsScreenState extends State<SubmittedFormsScreen> {
  List<dynamic> _list = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSubmitted();
  }

  Future<void> _fetchSubmitted() async {
    try {
      final res = await http.get(Uri.parse('$apiBaseUrl/forms/my-submitted?user_id=${widget.userId}'));
      if (res.statusCode == 200) {
        final parsed = jsonDecode(res.body);
        setState(() {
          _list = parsed['data'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load from server.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Internet connection required to view submitted forms.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submitted Forms (Server)'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _list.isEmpty
          ? const Center(child: Text('No submitted forms yet.'))
          : ListView.builder(
        itemCount: _list.length,
        itemBuilder: (ctx, i) {
          final row = _list[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.blue),
              title: Text(row['respondent_name'] ?? ''),
              subtitle: Text('HH Code: ${row['hh_code']}\nStatus: ${row['frm_status']}'),
              trailing: Text(row['submitted_at'] != null ? row['submitted_at'].toString().substring(0, 10) : ''),
            ),
          );
        },
      ),
    );
  }
}
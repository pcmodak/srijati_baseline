import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/local_database.dart';
import '../services/translation_service.dart';

class SurveyFormScreen extends StatefulWidget {
  final Map<String, dynamic>? draftData;
  final String? flaggedField;
  final String? reviewerRemark;

  const SurveyFormScreen({
    super.key,
    this.draftData,
    this.flaggedField,
    this.reviewerRemark,
  });

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  final _hhCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _blockController = TextEditingController();
  final _panchayatController = TextEditingController();
  final _villageController = TextEditingController();
  final _landOwnedController = TextEditingController();

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (widget.draftData != null) {
      _hhCodeController.text = widget.draftData!['hh_code'] ?? '';
      _nameController.text = widget.draftData!['respondent_name'] ?? '';
      _blockController.text = widget.draftData!['block_name'] ?? '';
      _panchayatController.text = widget.draftData!['panchayat_name'] ?? '';
      _villageController.text = widget.draftData!['village_name'] ?? '';
    }
  }

  Future<void> _saveAsDraft() async {
    final uuid = widget.draftData?['local_uuid'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    await LocalDatabase.instance.insertDraft({
      'local_uuid': uuid,
      'hh_code': _hhCodeController.text.trim(),
      'respondent_name': _nameController.text.trim(),
      'block_name': _blockController.text.trim(),
      'panchayat_name': _panchayatController.text.trim(),
      'village_name': _villageController.text.trim(),
      'form_json': jsonEncode({
        'total_land_owned_acres': _landOwnedController.text.trim(),
      }),
      'created_at': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to device as Draft')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tProvider = TranslationProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tProvider.translate('lbl_survey_form', fallback: 'Baseline Survey Form')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _saveAsDraft();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          Step(
            title: const Text('Identification & Location'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                TextField(
                  controller: _hhCodeController,
                  decoration: const InputDecoration(labelText: 'HH Code / হাউসহোল্ড কোড'),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Respondent Name / উত্তরদাতার নাম'),
                ),
                TextField(
                  controller: _blockController,
                  decoration: const InputDecoration(labelText: 'Block / ব্লক'),
                ),
                TextField(
                  controller: _panchayatController,
                  decoration: const InputDecoration(labelText: 'Panchayat / পঞ্চায়েত'),
                ),
                TextField(
                  controller: _villageController,
                  decoration: const InputDecoration(labelText: 'Village / গ্রাম'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Land & Agriculture'),
            isActive: _currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.flaggedField == 'total_land_owned_acres') ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Reviewer: ${widget.reviewerRemark ?? "Please check this value"}')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: _landOwnedController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total Land Owned (Acres) / মোট জমি (একর)',
                    enabledBorder: widget.flaggedField == 'total_land_owned_acres'
                        ? const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2))
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Finish'),
            isActive: _currentStep >= 2,
            content: const Text('Save as draft on device. Upload when online via Sync button.'),
          ),
        ],
      ),
    );
  }
}
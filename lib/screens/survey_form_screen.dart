import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/local_database.dart';
import '../services/translation_service.dart';

class DropdownOption<T> {
  final T value;
  final String label;

  const DropdownOption({required this.value, required this.label});
}

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

class _SurveyFormScreenState extends State<SurveyFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Section A: Demo Controllers
  final _hhCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _blockController = TextEditingController();
  final _panchayatController = TextEditingController();
  final _villageController = TextEditingController();

  final _ageUnder15Controller = TextEditingController(text: '0');
  final _age15To50Controller = TextEditingController(text: '0');
  final _ageAbove50Controller = TextEditingController(text: '0');
  final _kidsSchoolController = TextEditingController(text: '0');

  // Section A: Dropdown Values
  int? _rationCard;
  int? _differentlyAbled;
  int? _typeOfHouse;
  int? _haveToilet;
  int? _dailyUsingToilet;
  int? _primaryIncome;
  int? _secondaryIncome;

  // Section B: Water
  int? _waterSource;
  int? _waterDistance;
  int? _waterAvailableYearRound;
  int? _waterQuality;

  // Section C: Ecology
  int? _cookingFuel;
  int? _kitchenLocation;
  int? _wasteDisposal;
  int? _solarOrTree;

  // Section D: Agri
  final _landOwnedController = TextEditingController(text: '0');
  final _cultivableLandController = TextEditingController(text: '0');
  int? _primaryCrop;
  int? _irrigationSource;
  int? _livestock;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (widget.draftData != null) {
      _loadDraftData(widget.draftData!);
    }
  }

  void _loadDraftData(Map<String, dynamic> data) {
    _hhCodeController.text = data['hh_code'] ?? '';
    _nameController.text = data['respondent_name'] ?? '';
    _blockController.text = data['block_name'] ?? '';
    _panchayatController.text = data['panchayat_name'] ?? '';
    _villageController.text = data['village_name'] ?? '';

    if (data['form_json'] != null) {
      try {
        final form = jsonDecode(data['form_json']);
        _ageUnder15Controller.text = form['age_under_15']?.toString() ?? '0';
        _age15To50Controller.text = form['age_15_to_50']?.toString() ?? '0';
        _ageAbove50Controller.text = form['age_above_50']?.toString() ?? '0';
        _kidsSchoolController.text = form['kids_school']?.toString() ?? '0';

        _rationCard = form['ration_card'];
        _differentlyAbled = form['differently_abled'];
        _typeOfHouse = form['type_of_house'];
        _haveToilet = form['have_toilet'];
        _dailyUsingToilet = form['daily_using_toilet'];
        _primaryIncome = form['primary_income'];
        _secondaryIncome = form['secondary_income'];

        _waterSource = form['water_source'];
        _waterDistance = form['water_distance'];
        _waterAvailableYearRound = form['water_available_year_round'];
        _waterQuality = form['water_quality'];

        _cookingFuel = form['cooking_fuel'];
        _kitchenLocation = form['kitchen_location'];
        _wasteDisposal = form['waste_disposal'];
        _solarOrTree = form['solar_or_tree'];

        _landOwnedController.text =
            form['total_land_owned_acres']?.toString() ?? '0';
        _cultivableLandController.text =
            form['cultivable_land_acres']?.toString() ?? '0';
        _primaryCrop = form['primary_crop'];
        _irrigationSource = form['irrigation_source'];
        _livestock = form['livestock'];
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hhCodeController.dispose();
    _nameController.dispose();
    _blockController.dispose();
    _panchayatController.dispose();
    _villageController.dispose();
    _ageUnder15Controller.dispose();
    _age15To50Controller.dispose();
    _ageAbove50Controller.dispose();
    _kidsSchoolController.dispose();
    _landOwnedController.dispose();
    _cultivableLandController.dispose();
    super.dispose();
  }

  Future<void> _saveAsDraft() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final uuid = widget.draftData?['local_uuid'] ??
          'draft_${DateTime.now().millisecondsSinceEpoch}';

      final formMap = {
        'age_under_15': _ageUnder15Controller.text.trim(),
        'age_15_to_50': _age15To50Controller.text.trim(),
        'age_above_50': _ageAbove50Controller.text.trim(),
        'kids_school': _kidsSchoolController.text.trim(),
        'ration_card': _rationCard,
        'differently_abled': _differentlyAbled,
        'type_of_house': _typeOfHouse,
        'have_toilet': _haveToilet,
        'daily_using_toilet': _dailyUsingToilet,
        'primary_income': _primaryIncome,
        'secondary_income': _secondaryIncome,
        'water_source': _waterSource,
        'water_distance': _waterDistance,
        'water_available_year_round': _waterAvailableYearRound,
        'water_quality': _waterQuality,
        'cooking_fuel': _cookingFuel,
        'kitchen_location': _kitchenLocation,
        'waste_disposal': _wasteDisposal,
        'solar_or_tree': _solarOrTree,
        'total_land_owned_acres': _landOwnedController.text.trim(),
        'cultivable_land_acres': _cultivableLandController.text.trim(),
        'primary_crop': _primaryCrop,
        'irrigation_source': _irrigationSource,
        'livestock': _livestock,
      };

      await LocalDatabase.instance.insertDraft({
        'local_uuid': uuid,
        'hh_code': _hhCodeController.text.trim().isEmpty
            ? 'HH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
            : _hhCodeController.text.trim(),
        'respondent_name': _nameController.text.trim().isEmpty
            ? 'Household Respondent'
            : _nameController.text.trim(),
        'block_name': _blockController.text.trim(),
        'panchayat_name': _panchayatController.text.trim(),
        'village_name': _villageController.text.trim(),
        'form_json': jsonEncode(formMap),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved successfully / ড্রাফট সংরক্ষিত হয়েছে'),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save draft: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onNextSection() {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    } else {
      _saveAsDraft();
    }
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownOption<T>> options,
    required ValueChanged<T?> onChanged,
    String? flaggedKey,
  }) {
    final isFlagged = widget.flaggedField == flaggedKey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFlagged && widget.reviewerRemark != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reviewer: ${widget.reviewerRemark}',
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          DropdownButtonFormField<T>(
            isExpanded: true,
            isDense: true,
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isFlagged ? Colors.red : Colors.grey.shade400,
                  width: isFlagged ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isFlagged ? Colors.red : Colors.teal,
                  width: 2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            hint: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade800,
              ),
            ),
            items: options.map((opt) {
              return DropdownMenuItem<T>(
                value: opt.value,
                child: Text(
                  opt.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(fontSize: 13.5),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tProvider = TranslationProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tProvider.translate('lbl_survey_form',
              fallback: 'Baseline Survey (Srijati Foundation)'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Draft',
            onPressed: _saveAsDraft,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'A: Demo'),
            Tab(text: 'B: Water'),
            Tab(text: 'C: Ecology'),
            Tab(text: 'D: Agri'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDemoSection(),
                _buildWaterSection(),
                _buildEcologySection(),
                _buildAgriSection(),
              ],
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildDemoSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _hhCodeController,
            decoration: const InputDecoration(
              labelText: 'HH Code / হাউসহোল্ড কোড',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Respondent Name / উত্তরদাতার নাম',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _blockController,
                  decoration: const InputDecoration(
                    labelText: 'Block / ব্লক',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _panchayatController,
                  decoration: const InputDecoration(
                    labelText: 'Panchayat / পঞ্চায়েত',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _villageController,
            decoration: const InputDecoration(
              labelText: 'Village / গ্রাম',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Field 12: Demographics (<15 Yrs | 15-50 Yrs | >50 Yrs)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageUnder15Controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '12. <15 Yrs',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _age15To50Controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '15-50 Yrs',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _ageAbove50Controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '>50 Yrs',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Field 13: Kids going to school/college
          TextField(
            controller: _kidsSchoolController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText:
                  '13. Kids going to school/college / পড়ুয়া শিশু সংখ্যা',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Field 14: Ration card
          _buildDropdownField<int>(
            label: '14. Ration Card / রেশন কার্ডের ধরন',
            value: _rationCard,
            options: const [
              DropdownOption(value: 1, label: 'AAY / অন্ত্যোদয়'),
              DropdownOption(value: 2, label: 'PHH / এস.পি.এইচ.এইচ'),
              DropdownOption(value: 3, label: 'RKSY-I / আর.কে.এস.ওয়াই-১'),
              DropdownOption(value: 4, label: 'RKSY-II / আর.কে.এস.ওয়াই-২'),
              DropdownOption(value: 5, label: 'None / নেই'),
            ],
            onChanged: (val) => setState(() => _rationCard = val),
          ),

          // Field 15: Differently abled member
          _buildDropdownField<int>(
            label: '15. Differently abled member? / প্রতিবন্ধী সদস্য?',
            value: _differentlyAbled,
            options: const [
              DropdownOption(value: 1, label: 'Yes / হ্যাঁ'),
              DropdownOption(value: 2, label: 'No / না'),
            ],
            onChanged: (val) => setState(() => _differentlyAbled = val),
          ),

          // Field 16: Type of House
          _buildDropdownField<int>(
            label: '16. Type of House / বাড়ির ধরন',
            value: _typeOfHouse,
            options: const [
              DropdownOption(value: 1, label: 'Pucca / পাকা'),
              DropdownOption(value: 2, label: 'Semi-Pucca / আধা-পাকা'),
              DropdownOption(value: 3, label: 'Katcha / কাঁচা'),
            ],
            onChanged: (val) => setState(() => _typeOfHouse = val),
          ),

          // Field 17: Have toilet
          _buildDropdownField<int>(
            label: '17. Have Toilet? / বাড়িতে শৌচাগার আছে?',
            value: _haveToilet,
            options: const [
              DropdownOption(value: 1, label: 'Yes / হ্যাঁ'),
              DropdownOption(value: 2, label: 'No / না'),
            ],
            onChanged: (val) => setState(() => _haveToilet = val),
          ),

          // Field 18: Daily using toilet
          _buildDropdownField<int>(
            label: '18. Daily using toilet? / প্রতিদিন ব্যবহার করেন?',
            value: _dailyUsingToilet,
            options: const [
              DropdownOption(value: 1, label: 'Yes, all members / হ্যাঁ'),
              DropdownOption(value: 2, label: 'Partially / আংশিক'),
              DropdownOption(value: 3, label: 'No / না'),
            ],
            onChanged: (val) => setState(() => _dailyUsingToilet = val),
          ),

          // Field 19: Primary Income (FIXED: ZERO OVERFLOW)
          _buildDropdownField<int>(
            label: '19. Primary Income / প্রধান আয়ের উৎস',
            value: _primaryIncome,
            options: const [
              DropdownOption(value: 1, label: 'Agriculture / কৃষি'),
              DropdownOption(
                  value: 2, label: 'Daily Wage Labor / দিনমজুরি'),
              DropdownOption(value: 3, label: 'Small Business / ব্যবসা'),
              DropdownOption(value: 4, label: 'Service / চাকরি'),
              DropdownOption(value: 5, label: 'Livestock / পশুপালন'),
              DropdownOption(value: 6, label: 'Other / অন্যান্য'),
            ],
            onChanged: (val) => setState(() => _primaryIncome = val),
          ),

          // Field 20: Secondary Income (FIXED: ZERO OVERFLOW)
          _buildDropdownField<int>(
            label: '20. Secondary Income / দ্বিতীয় আয়ের উৎস',
            value: _secondaryIncome,
            options: const [
              DropdownOption(value: 0, label: 'None / নেই'),
              DropdownOption(
                  value: 1, label: 'Daily Wage Labor / দিনমজুরি'),
              DropdownOption(value: 2, label: 'Agriculture / কৃষি'),
              DropdownOption(value: 3, label: 'Livestock / পশুপালন'),
              DropdownOption(value: 4, label: 'Handicrafts / হস্তশিল্প'),
              DropdownOption(value: 5, label: 'Other / অন্যান্য'),
            ],
            onChanged: (val) => setState(() => _secondaryIncome = val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWaterSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField<int>(
            label: '21. Water Source / পানীয় জলের প্রধান উৎস',
            value: _waterSource,
            options: const [
              DropdownOption(value: 1, label: 'Tube well / নলকূপ'),
              DropdownOption(value: 2, label: 'Tap water / সরবরাহ জল'),
              DropdownOption(value: 3, label: 'Open Well / কুয়ো'),
              DropdownOption(value: 4, label: 'Pond / পুকুর'),
            ],
            onChanged: (val) => setState(() => _waterSource = val),
          ),
          _buildDropdownField<int>(
            label: '22. Distance to Water / জলের উৎসের দূরত্ব',
            value: _waterDistance,
            options: const [
              DropdownOption(
                  value: 1, label: 'In premises / বাড়ির ভেতরে'),
              DropdownOption(value: 2, label: '< 50 meters / ৫০ মিটারের মধ্যে'),
              DropdownOption(
                  value: 3, label: '50 - 200 meters / ৫০-২০০ মিটার'),
              DropdownOption(value: 4, label: '> 200 meters / ২০০ মিটারের বেশি'),
            ],
            onChanged: (val) => setState(() => _waterDistance = val),
          ),
          _buildDropdownField<int>(
            label: '23. Year-round availability / সারা বছর জল পাওয়া যায়?',
            value: _waterAvailableYearRound,
            options: const [
              DropdownOption(value: 1, label: 'Yes / হ্যাঁ'),
              DropdownOption(value: 2, label: 'No, dry in summer / গরমে শুকিয়ে যায়'),
            ],
            onChanged: (val) => setState(() => _waterAvailableYearRound = val),
          ),
          _buildDropdownField<int>(
            label: '24. Water Quality Issues / জলের গুণগত মান',
            value: _waterQuality,
            options: const [
              DropdownOption(value: 1, label: 'Good / ভালো'),
              DropdownOption(value: 2, label: 'Iron issue / অতিরিক্ত আয়রন'),
              DropdownOption(value: 3, label: 'Salinity / লোনা জল'),
              DropdownOption(value: 4, label: 'Arsenic risk / আর্সেনিক ঝুঁকি'),
            ],
            onChanged: (val) => setState(() => _waterQuality = val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEcologySection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField<int>(
            label: '25. Cooking Fuel / রান্নার প্রধান জ্বালানি',
            value: _cookingFuel,
            options: const [
              DropdownOption(value: 1, label: 'LPG Gas / গ্যাস'),
              DropdownOption(value: 2, label: 'Firewood / কাঠ-পাতা'),
              DropdownOption(value: 3, label: 'Cow Dung Cake / ঘুঁটে'),
              DropdownOption(value: 4, label: 'Biogas / বায়োগ্যাস'),
            ],
            onChanged: (val) => setState(() => _cookingFuel = val),
          ),
          _buildDropdownField<int>(
            label: '26. Kitchen Location / রান্নাঘরের অবস্থান',
            value: _kitchenLocation,
            options: const [
              DropdownOption(
                  value: 1, label: 'Separate inside / ঘরের ভেতরে আলাদা'),
              DropdownOption(
                  value: 2, label: 'Separate outside / ঘরের বাইরে আলাদা'),
              DropdownOption(
                  value: 3, label: 'Cooking in living room / শোবার ঘরে'),
              DropdownOption(value: 4, label: 'Open air / খোলা জায়গায়'),
            ],
            onChanged: (val) => setState(() => _kitchenLocation = val),
          ),
          _buildDropdownField<int>(
            label: '27. Solid Waste Disposal / আবর্জনা ফেলার পদ্ধতি',
            value: _wasteDisposal,
            options: const [
              DropdownOption(value: 1, label: 'Compost Pit / জৈব সার গর্ত'),
              DropdownOption(
                  value: 2, label: 'Open dumping / ফাঁকা জায়গায় ফেলা'),
              DropdownOption(value: 3, label: 'Burning / পুড়িয়ে ফেলা'),
              DropdownOption(
                  value: 4, label: 'Panchayat collection / পঞ্চায়েত সংগ্রহ'),
            ],
            onChanged: (val) => setState(() => _wasteDisposal = val),
          ),
          _buildDropdownField<int>(
            label: '28. Tree Plantation / বৃক্ষরোপণ ও সৌর আলো',
            value: _solarOrTree,
            options: const [
              DropdownOption(value: 1, label: 'Both / উভয়ই আছে'),
              DropdownOption(value: 2, label: 'Trees planted / গাছ লাগানো আছে'),
              DropdownOption(
                  value: 3, label: 'Solar light used / সোলার আলো আছে'),
              DropdownOption(value: 4, label: 'None / কোনটিই নয়'),
            ],
            onChanged: (val) => setState(() => _solarOrTree = val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAgriSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _landOwnedController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '29. Total Land Owned (Acres) / মোট জমি (একর)',
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              enabledBorder: widget.flaggedField == 'total_land_owned_acres'
                  ? const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cultivableLandController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '30. Cultivable Land (Acres) / চাষযোগ্য জমি (একর)',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdownField<int>(
            label: '31. Primary Crops / প্রধান উৎপাদিত ফসল',
            value: _primaryCrop,
            options: const [
              DropdownOption(value: 1, label: 'Paddy / ধান'),
              DropdownOption(value: 2, label: 'Mustard / সরিষা'),
              DropdownOption(value: 3, label: 'Vegetables / শাকসবজি'),
              DropdownOption(value: 4, label: 'Jute / পাট'),
              DropdownOption(value: 5, label: 'Pulses / ডাল'),
            ],
            onChanged: (val) => setState(() => _primaryCrop = val),
          ),
          _buildDropdownField<int>(
            label: '32. Irrigation Source / সেচের জলের উৎস',
            value: _irrigationSource,
            options: const [
              DropdownOption(value: 1, label: 'Pond / পুকুর'),
              DropdownOption(
                  value: 2, label: 'Deep Tube Well / গভীর নলকূপ'),
              DropdownOption(value: 3, label: 'Canal / River / খাল বা নদী'),
              DropdownOption(value: 4, label: 'Rainfed only / বৃষ্টির জল নির্ভর'),
            ],
            onChanged: (val) => setState(() => _irrigationSource = val),
          ),
          _buildDropdownField<int>(
            label: '33. Livestock Owned / পশুপালন বিবরণ',
            value: _livestock,
            options: const [
              DropdownOption(value: 1, label: 'Cattle & Dairy / গরু-মহিষ'),
              DropdownOption(value: 2, label: 'Goats & Sheep / ছাগল-ভেড়া'),
              DropdownOption(value: 3, label: 'Poultry / হাঁস-মুরগি'),
              DropdownOption(value: 4, label: 'Mixed / একাধিক প্রকার'),
              DropdownOption(value: 5, label: 'None / নেই'),
            ],
            onChanged: (val) => setState(() => _livestock = val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final isLastTab = _tabController.index == _tabController.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: OutlinedButton(
                onPressed: _isSaving ? null : _saveAsDraft,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Save Draft (ডিভাইসে রাখুন)',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: ElevatedButton(
                onPressed: _onNextSection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isLastTab ? 'Submit / জমা দিন' : 'Next Section',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
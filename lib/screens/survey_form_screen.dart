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

class _SurveyFormScreenState extends State<SurveyFormScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers: Section A (Identification & Demographics)
  final _q1BlockCtrl = TextEditingController();
  final _q2PanchayatCtrl = TextEditingController();
  final _q3VillageCtrl = TextEditingController();
  final _hamletCtrl = TextEditingController();
  final _q4HhCodeCtrl = TextEditingController();
  final _q5RespondentNameCtrl = TextEditingController();
  final _q6FatherHusbandCtrl = TextEditingController();
  int? _q7SocialGroup; // 1=ST, 2=SC, 3=OBC, 4=General/Other
  int? _q8MobilePhone; // 1=Yes, 2=No
  int? _q9BreadEarner; // 1=Women, 2=Husband, 3=Young Children
  int? _q10MaritalStatus; // 1=Married, 2=Single/Divorced, 3=Widowed, 4=Separated, 5=Other
  final _q11MaleCtrl = TextEditingController(text: '0');
  final _q11FemaleCtrl = TextEditingController(text: '0');
  final _q11TotalCtrl = TextEditingController(text: '0');
  final _q12AgeUnder15Ctrl = TextEditingController(text: '0');
  final _q12Age15To50Ctrl = TextEditingController(text: '0');
  final _q12AgeAbove50Ctrl = TextEditingController(text: '0');
  final _q13KidsSchoolCtrl = TextEditingController(text: '0');
  int? _q14RationCard; // 1=Red Card, 2=Yellow/Antyodaya
  int? _q15DifferentlyAbled; // 1=Yes, 2=No
  int? _q16HouseType; // 1=Hut, 2=Kutcha, 3=Kutcha-pucca, 4=Pucca
  int? _q17Toilet; // 1=Yes, 2=No
  int? _q18ToiletDaily; // 1=Yes, 2=No
  int? _q19PrimaryIncome; // 1=Self-employed/Salaried, 2=Agri, 3=Fishery, 4=Labour, 5=NTFP, 6=Other
  int? _q20SecondaryIncome;

  // Controllers: Section B (Drinking Water Quality & Access)
  int? _q21WaterSource; // 1=Handpump, 2=Well, 3=Tap, 4=River/Pond, 5=Other
  int? _q22SummerAccess; // 1-4 scale
  int? _q23SummerQuality; // 1-4 scale
  int? _q24MonsoonAccess; // 1-4 scale
  int? _q25MonsoonQuality; // 1-4 scale
  int? _q26WinterAccess; // 1-4 scale
  int? _q27WinterQuality; // 1-4 scale

  // Controllers: Section C (Water Resources)
  int? _q28SalineIntrusion; // 1=Yes, 2=No
  int? _q29IrrigationSource; // 1=Freshwater pond, 2=Brackish canal/river, 3=Tube well, 4=Rainwater, 5=Other
  final _q30EmbankmentDistanceCtrl = TextEditingController();
  int? _q31EmbankmentBreach; // 1=Yes, 2=No
  final _q32PondsCountCtrl = TextEditingController(text: '0');
  int? _q33RainwaterHarvest; // 1=Yes, 2=No
  int? _q34SalinityLevel; // 1=Fresh, 2=Slightly Brackish, 3=Highly Brackish
  int? _q35SalinityHealthIssue; // 1=Yes, 2=No

  // Controllers: Section D (Land & Agriculture)
  int? _q36OwnLand; // 1=Yes, 2=No
  final _q37LandOwnedCtrl = TextEditingController(text: '0.00');
  final _q38LandCultivatedCtrl = TextEditingController(text: '0.00');
  final _q39RentedOutAcreCtrl = TextEditingController(text: '0.00');
  final _q39RentReceivedCtrl = TextEditingController(text: '0.00');
  final _q40LeasedInAcreCtrl = TextEditingController(text: '0.00');
  final _q40RentPaidCtrl = TextEditingController(text: '0.00');
  final _q41KharifAcresCtrl = TextEditingController(text: '0.00');
  final _q42RabiAcresCtrl = TextEditingController(text: '0.00');
  final _q43SummerAcresCtrl = TextEditingController(text: '0.00');
  int? _q44FoodMonths; // 1=<6, 2=6-9, 3=9-12, 4=>12
  int? _q45AgriIrrigation; // 1=Tube well, 2=Canal, 3=Well, 4=Pond, 5=Lift, 6=Deep boring, 7=Other

  // Q46 - Q49: Crop Details
  final _q46Crop1NameCtrl = TextEditingController();
  final _q46Crop1AreaCtrl = TextEditingController();
  final _q46Crop1ProdCtrl = TextEditingController();
  int? _q46Crop1SeedQuality; // 1=Own, 2=Improved, 3=Hybrid
  int? _q46Crop1Fertilizer; // 1=Organic, 2=Chemical, 3=Both
  final _q46Crop1CostCtrl = TextEditingController();

  final _q47Crop2NameCtrl = TextEditingController();
  final _q47Crop2AreaCtrl = TextEditingController();
  final _q47Crop2ProdCtrl = TextEditingController();
  int? _q47Crop2SeedQuality;
  int? _q47Crop2Fertilizer;
  final _q47Crop2CostCtrl = TextEditingController();

  int? _q50HomesteadGardenLand; // 1=Yes, 2=No
  int? _q51DoingKitchenGarden; // 1=Yes, 2=No
  int? _q52CompostPit; // 1=Yes, 2=No

  // Controllers: Section E (Freshwater Fishery)
  int? _q53FreshwaterFishery; // 1=Yes, 2=No
  final _q54FwAreaCtrl = TextEditingController();
  final _q55FwDepthSummerCtrl = TextEditingController();
  final _q56FwDepthMonsoonCtrl = TextEditingController();
  int? _q57FwWaterTest; // 1=Yes, 2=No
  final _q58FwSpeciesCtrl = TextEditingController();
  int? _q59FwSeedSource; // 1=Hatchery, 2=Wild catch, 3=Local vendor
  final _q60FwProdCtrl = TextEditingController();
  final _q61FwIncomeCtrl = TextEditingController();
  final _q62FwExpCtrl = TextEditingController();

  // Controllers: Section F (Brackish Water Fishery)
  int? _q63BrackishFishery; // 1=Yes, 2=No
  final _q64BwAreaCtrl = TextEditingController();
  final _q65BwDepthSummerCtrl = TextEditingController();
  final _q66BwDepthMonsoonCtrl = TextEditingController();
  int? _q67BwWaterTest; // 1=Yes, 2=No
  final _q68BwSpeciesCtrl = TextEditingController();
  int? _q69BwSeedSource; // 1=Hatchery, 2=Wild catch, 3=Local vendor
  final _q70BwProdCtrl = TextEditingController();
  final _q71BwIncomeCtrl = TextEditingController();
  final _q72BwExpCtrl = TextEditingController();

  // Controllers: Section G (Crab Cultivation)
  int? _q73CrabFarming; // 1=Yes, 2=No
  int? _q74CrabMethod; // 1=Fattening, 2=Polyculture, 3=Wild catch
  final _q75CrabSpeciesCtrl = TextEditingController();
  final _q76CrabCycleCtrl = TextEditingController();
  int? _q77CrabFeed; // 1=Trash fish, 2=Snails, 3=Formulated feed, 4=None
  final _q78CrabProdCtrl = TextEditingController();
  final _q79CrabIncomeCtrl = TextEditingController();
  final _q80CrabExpCtrl = TextEditingController();

  // Controllers: Section H (Institutions & Credit)
  int? _q81CommunityInst; // 1=SHG, 2=JLG, 3=Kisan Club, 4=None
  int? _q82FpoMember; // 1=Yes, 2=No
  int? _q83SellingChannel; // 1=FPO, 2=Bazar Samiti, 3=Open market, 4=Mix
  int? _q84FpoServices; // 1=Yes, 2=No
  int? _q85HasDebt; // 1=Yes, 2=No
  int? _q86NewDebt; // 1=Yes, 2=No
  int? _q87LoanSource; // 1=Bank, 2=SHG/NGO, 3=Moneylenders, 4=Relatives, 5=Other

  // Controllers: Section I (Government Schemes & Entitlements)
  int? _q88BplCard; // 1=Yes, 2=No
  int? _q89PmKisan; // 1=Yes, 2=No
  int? _q90KrishakBandhu; // 1=Yes, 2=No
  int? _q91PmFasalBima; // 1=Yes, 2=No
  int? _q92Kcc; // 1=Yes, 2=No
  int? _q93MgnregaCard; // 1=Yes, 2=No
  int? _q94MgnregaWorked; // 1=Yes, 2=No
  final _q95MgnregaDaysCtrl = TextEditingController(text: '0');
  int? _q96ForestRights; // 1=Yes, 2=No
  final _q97ForestAreaCtrl = TextEditingController(text: '0.00');
  int? _q98HealthInsurance; // 1=Yes, 2=No
  int? _q99PmayHouse; // 1=Yes, 2=No
  int? _q100Ujjwala; // 1=Yes, 2=No
  int? _q101SocialPension; // 1=Yes, 2=No
  int? _q102DuareSarkar; // 1=Yes, 2=No
  int? _q103LifeInsurance; // 1=Yes, 2=No
  int? _q104SkillTraining; // 1=Yes, 2=No
  int? _q105SchemeConstraint; // 1=Lack of awareness, 2=Documentation, 3=Distance, 4=Corruption, 5=No constraint

  // Controllers: Section J (Agri Knowledge & Practices)
  int? _q106SeedTreatment; // 1=Yes, 2=No
  int? _q107SoilTesting; // 1=Yes, 2=No
  int? _q108BioPesticide; // 1=Yes, 2=No

  final List<String> _sections = [
    'A: Demo',
    'B: Water',
    'C: Ecology',
    'D: Agri',
    'E: Fresh Fish',
    'F: Brack Fish',
    'G: Crab',
    'H: Credit',
    'I: Schemes',
    'J: Practices'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sections.length, vsync: this);
    if (widget.draftData != null) {
      _loadDraftData();
    }
  }

  void _loadDraftData() {
    final d = widget.draftData!;
    _q1BlockCtrl.text = d['block_name'] ?? '';
    _q2PanchayatCtrl.text = d['panchayat_name'] ?? '';
    _q3VillageCtrl.text = d['village_name'] ?? '';
    _hamletCtrl.text = d['hamlet_name'] ?? '';
    _q4HhCodeCtrl.text = d['hh_code'] ?? '';
    _q5RespondentNameCtrl.text = d['respondent_name'] ?? '';

    if (d['form_json'] != null && d['form_json'].toString().isNotEmpty) {
      try {
        final Map<String, dynamic> f = jsonDecode(d['form_json']);
        _q6FatherHusbandCtrl.text = f['q6_father_husband'] ?? '';
        _q7SocialGroup = f['q7_social_group'];
        _q8MobilePhone = f['q8_mobile_phone'];
        _q9BreadEarner = f['q9_bread_earner'];
        _q10MaritalStatus = f['q10_marital_status'];
        _q11MaleCtrl.text = (f['q11_male'] ?? 0).toString();
        _q11FemaleCtrl.text = (f['q11_female'] ?? 0).toString();
        _q11TotalCtrl.text = (f['q11_total'] ?? 0).toString();
        _q12AgeUnder15Ctrl.text = (f['q12_under_15'] ?? 0).toString();
        _q12Age15To50Ctrl.text = (f['q12_15_to_50'] ?? 0).toString();
        _q12AgeAbove50Ctrl.text = (f['q12_above_50'] ?? 0).toString();
        _q13KidsSchoolCtrl.text = (f['q13_kids_school'] ?? 0).toString();
        _q14RationCard = f['q14_ration_card'];
        _q15DifferentlyAbled = f['q15_differently_abled'];
        _q16HouseType = f['q16_house_type'];
        _q17Toilet = f['q17_toilet'];
        _q18ToiletDaily = f['q18_toilet_daily'];
        _q19PrimaryIncome = f['q19_primary_income'];
        _q20SecondaryIncome = f['q20_secondary_income'];

        _q21WaterSource = f['q21_water_source'];
        _q22SummerAccess = f['q22_summer_access'];
        _q23SummerQuality = f['q23_summer_quality'];
        _q24MonsoonAccess = f['q24_monsoon_access'];
        _q25MonsoonQuality = f['q25_monsoon_quality'];
        _q26WinterAccess = f['q26_winter_access'];
        _q27WinterQuality = f['q27_winter_quality'];

        _q28SalineIntrusion = f['q28_saline_intrusion'];
        _q29IrrigationSource = f['q29_irrigation_source'];
        _q30EmbankmentDistanceCtrl.text = (f['q30_embankment_distance'] ?? '').toString();
        _q31EmbankmentBreach = f['q31_embankment_breach'];
        _q32PondsCountCtrl.text = (f['q32_ponds_count'] ?? 0).toString();
        _q33RainwaterHarvest = f['q33_rainwater_harvest'];
        _q34SalinityLevel = f['q34_salinity_level'];
        _q35SalinityHealthIssue = f['q35_salinity_health_issue'];

        _q36OwnLand = f['q36_own_land'];
        _q37LandOwnedCtrl.text = (f['q37_land_owned'] ?? '0.00').toString();
        _q38LandCultivatedCtrl.text = (f['q38_land_cultivated'] ?? '0.00').toString();
        _q39RentedOutAcreCtrl.text = (f['q39_rented_out_acre'] ?? '0.00').toString();
        _q39RentReceivedCtrl.text = (f['q39_rent_received'] ?? '0.00').toString();
        _q40LeasedInAcreCtrl.text = (f['q40_leased_in_acre'] ?? '0.00').toString();
        _q40RentPaidCtrl.text = (f['q40_rent_paid'] ?? '0.00').toString();
        _q41KharifAcresCtrl.text = (f['q41_kharif_acres'] ?? '0.00').toString();
        _q42RabiAcresCtrl.text = (f['q42_rabi_acres'] ?? '0.00').toString();
        _q43SummerAcresCtrl.text = (f['q43_summer_acres'] ?? '0.00').toString();
        _q44FoodMonths = f['q44_food_months'];
        _q45AgriIrrigation = f['q45_agri_irrigation'];

        _q46Crop1NameCtrl.text = f['q46_crop1_name'] ?? '';
        _q46Crop1AreaCtrl.text = (f['q46_crop1_area'] ?? '').toString();
        _q46Crop1ProdCtrl.text = (f['q46_crop1_prod'] ?? '').toString();
        _q46Crop1SeedQuality = f['q46_crop1_seed_quality'];
        _q46Crop1Fertilizer = f['q46_crop1_fertilizer'];
        _q46Crop1CostCtrl.text = (f['q46_crop1_cost'] ?? '').toString();

        _q50HomesteadGardenLand = f['q50_homestead_garden_land'];
        _q51DoingKitchenGarden = f['q51_doing_kitchen_garden'];
        _q52CompostPit = f['q52_compost_pit'];

        _q53FreshwaterFishery = f['q53_freshwater_fishery'];
        _q54FwAreaCtrl.text = (f['q54_fw_area'] ?? '').toString();
        _q58FwSpeciesCtrl.text = f['q58_fw_species'] ?? '';
        _q60FwProdCtrl.text = (f['q60_fw_prod'] ?? '').toString();
        _q61FwIncomeCtrl.text = (f['q61_fw_income'] ?? '').toString();
        _q62FwExpCtrl.text = (f['q62_fw_exp'] ?? '').toString();

        _q63BrackishFishery = f['q63_brackish_fishery'];
        _q64BwAreaCtrl.text = (f['q64_bw_area'] ?? '').toString();
        _q68BwSpeciesCtrl.text = f['q68_bw_species'] ?? '';
        _q70BwProdCtrl.text = (f['q70_bw_prod'] ?? '').toString();
        _q71BwIncomeCtrl.text = (f['q71_bw_income'] ?? '').toString();
        _q72BwExpCtrl.text = (f['q72_bw_exp'] ?? '').toString();

        _q73CrabFarming = f['q73_crab_farming'];
        _q74CrabMethod = f['q74_crab_method'];
        _q75CrabSpeciesCtrl.text = f['q75_crab_species'] ?? '';
        _q78CrabProdCtrl.text = (f['q78_crab_prod'] ?? '').toString();
        _q79CrabIncomeCtrl.text = (f['q79_crab_income'] ?? '').toString();
        _q80CrabExpCtrl.text = (f['q80_crab_exp'] ?? '').toString();

        _q81CommunityInst = f['q81_community_inst'];
        _q82FpoMember = f['q82_fpo_member'];
        _q83SellingChannel = f['q83_selling_channel'];
        _q85HasDebt = f['q85_has_debt'];
        _q87LoanSource = f['q87_loan_source'];

        _q88BplCard = f['q88_bpl_card'];
        _q89PmKisan = f['q89_pm_kisan'];
        _q90KrishakBandhu = f['q90_krishak_bandhu'];
        _q91PmFasalBima = f['q91_pm_fasal_bima'];
        _q92Kcc = f['q92_kcc'];
        _q93MgnregaCard = f['q93_mgnrega_card'];
        _q95MgnregaDaysCtrl.text = (f['q95_mgnrega_days'] ?? 0).toString();
        _q98HealthInsurance = f['q98_health_insurance'];
        _q99PmayHouse = f['q99_pmay_house'];
        _q100Ujjwala = f['q100_ujjwala'];
        _q105SchemeConstraint = f['q105_scheme_constraint'];

        _q106SeedTreatment = f['q106_seed_treatment'];
        _q107SoilTesting = f['q107_soil_testing'];
        _q108BioPesticide = f['q108_bio_pesticide'];
      } catch (e) {
        debugPrint('Draft parse error: $e');
      }
    }
  }

  Map<String, dynamic> _collectFormData() {
    return {
      'q6_father_husband': _q6FatherHusbandCtrl.text.trim(),
      'q7_social_group': _q7SocialGroup,
      'q8_mobile_phone': _q8MobilePhone,
      'q9_bread_earner': _q9BreadEarner,
      'q10_marital_status': _q10MaritalStatus,
      'q11_male': int.tryParse(_q11MaleCtrl.text) ?? 0,
      'q11_female': int.tryParse(_q11FemaleCtrl.text) ?? 0,
      'q11_total': int.tryParse(_q11TotalCtrl.text) ?? 0,
      'q12_under_15': int.tryParse(_q12AgeUnder15Ctrl.text) ?? 0,
      'q12_15_to_50': int.tryParse(_q12Age15To50Ctrl.text) ?? 0,
      'q12_above_50': int.tryParse(_q12AgeAbove50Ctrl.text) ?? 0,
      'q13_kids_school': int.tryParse(_q13KidsSchoolCtrl.text) ?? 0,
      'q14_ration_card': _q14RationCard,
      'q15_differently_abled': _q15DifferentlyAbled,
      'q16_house_type': _q16HouseType,
      'q17_toilet': _q17Toilet,
      'q18_toilet_daily': _q18ToiletDaily,
      'q19_primary_income': _q19PrimaryIncome,
      'q20_secondary_income': _q20SecondaryIncome,

      'q21_water_source': _q21WaterSource,
      'q22_summer_access': _q22SummerAccess,
      'q23_summer_quality': _q23SummerQuality,
      'q24_monsoon_access': _q24MonsoonAccess,
      'q25_monsoon_quality': _q25MonsoonQuality,
      'q26_winter_access': _q26WinterAccess,
      'q27_winter_quality': _q27WinterQuality,

      'q28_saline_intrusion': _q28SalineIntrusion,
      'q29_irrigation_source': _q29IrrigationSource,
      'q30_embankment_distance': double.tryParse(_q30EmbankmentDistanceCtrl.text) ?? 0.0,
      'q31_embankment_breach': _q31EmbankmentBreach,
      'q32_ponds_count': int.tryParse(_q32PondsCountCtrl.text) ?? 0,
      'q33_rainwater_harvest': _q33RainwaterHarvest,
      'q34_salinity_level': _q34SalinityLevel,
      'q35_salinity_health_issue': _q35SalinityHealthIssue,

      'q36_own_land': _q36OwnLand,
      'q37_land_owned': double.tryParse(_q37LandOwnedCtrl.text) ?? 0.0,
      'q38_land_cultivated': double.tryParse(_q38LandCultivatedCtrl.text) ?? 0.0,
      'q39_rented_out_acre': double.tryParse(_q39RentedOutAcreCtrl.text) ?? 0.0,
      'q39_rent_received': double.tryParse(_q39RentReceivedCtrl.text) ?? 0.0,
      'q40_leased_in_acre': double.tryParse(_q40LeasedInAcreCtrl.text) ?? 0.0,
      'q40_rent_paid': double.tryParse(_q40RentPaidCtrl.text) ?? 0.0,
      'q41_kharif_acres': double.tryParse(_q41KharifAcresCtrl.text) ?? 0.0,
      'q42_rabi_acres': double.tryParse(_q42RabiAcresCtrl.text) ?? 0.0,
      'q43_summer_acres': double.tryParse(_q43SummerAcresCtrl.text) ?? 0.0,
      'q44_food_months': _q44FoodMonths,
      'q45_agri_irrigation': _q45AgriIrrigation,

      'q46_crop1_name': _q46Crop1NameCtrl.text.trim(),
      'q46_crop1_area': double.tryParse(_q46Crop1AreaCtrl.text) ?? 0.0,
      'q46_crop1_prod': double.tryParse(_q46Crop1ProdCtrl.text) ?? 0.0,
      'q46_crop1_seed_quality': _q46Crop1SeedQuality,
      'q46_crop1_fertilizer': _q46Crop1Fertilizer,
      'q46_crop1_cost': double.tryParse(_q46Crop1CostCtrl.text) ?? 0.0,

      'q50_homestead_garden_land': _q50HomesteadGardenLand,
      'q51_doing_kitchen_garden': _q51DoingKitchenGarden,
      'q52_compost_pit': _q52CompostPit,

      'q53_freshwater_fishery': _q53FreshwaterFishery,
      'q54_fw_area': double.tryParse(_q54FwAreaCtrl.text) ?? 0.0,
      'q58_fw_species': _q58FwSpeciesCtrl.text.trim(),
      'q60_fw_prod': double.tryParse(_q60FwProdCtrl.text) ?? 0.0,
      'q61_fw_income': double.tryParse(_q61FwIncomeCtrl.text) ?? 0.0,
      'q62_fw_exp': double.tryParse(_q62FwExpCtrl.text) ?? 0.0,

      'q63_brackish_fishery': _q63BrackishFishery,
      'q64_bw_area': double.tryParse(_q64BwAreaCtrl.text) ?? 0.0,
      'q68_bw_species': _q68BwSpeciesCtrl.text.trim(),
      'q70_bw_prod': double.tryParse(_q70BwProdCtrl.text) ?? 0.0,
      'q71_bw_income': double.tryParse(_q71BwIncomeCtrl.text) ?? 0.0,
      'q72_bw_exp': double.tryParse(_q72BwExpCtrl.text) ?? 0.0,

      'q73_crab_farming': _q73CrabFarming,
      'q74_crab_method': _q74CrabMethod,
      'q75_crab_species': _q75CrabSpeciesCtrl.text.trim(),
      'q78_crab_prod': double.tryParse(_q78CrabProdCtrl.text) ?? 0.0,
      'q79_crab_income': double.tryParse(_q79CrabIncomeCtrl.text) ?? 0.0,
      'q80_crab_exp': double.tryParse(_q80CrabExpCtrl.text) ?? 0.0,

      'q81_community_inst': _q81CommunityInst,
      'q82_fpo_member': _q82FpoMember,
      'q83_selling_channel': _q83SellingChannel,
      'q85_has_debt': _q85HasDebt,
      'q87_loan_source': _q87LoanSource,

      'q88_bpl_card': _q88BplCard,
      'q89_pm_kisan': _q89PmKisan,
      'q90_krishak_bandhu': _q90KrishakBandhu,
      'q91_pm_fasal_bima': _q91PmFasalBima,
      'q92_kcc': _q92Kcc,
      'q93_mgnrega_card': _q93MgnregaCard,
      'q95_mgnrega_days': int.tryParse(_q95MgnregaDaysCtrl.text) ?? 0,
      'q98_health_insurance': _q98HealthInsurance,
      'q99_pmay_house': _q99PmayHouse,
      'q100_ujjwala': _q100Ujjwala,
      'q105_scheme_constraint': _q105SchemeConstraint,

      'q106_seed_treatment': _q106SeedTreatment,
      'q107_soil_testing': _q107SoilTesting,
      'q108_bio_pesticide': _q108BioPesticide,
    };
  }

  Future<void> _saveDraft() async {
    final uuid = widget.draftData?['local_uuid'] ??
        '${DateTime.now().millisecondsSinceEpoch}_${_q4HhCodeCtrl.text.trim()}';
    final formData = _collectFormData();

    final block = _q1BlockCtrl.text.trim().isNotEmpty ? _q1BlockCtrl.text.trim() : 'N/A';
    final panchayat = _q2PanchayatCtrl.text.trim().isNotEmpty ? _q2PanchayatCtrl.text.trim() : 'N/A';
    final village = _q3VillageCtrl.text.trim().isNotEmpty ? _q3VillageCtrl.text.trim() : 'N/A';
    final respName = _q5RespondentNameCtrl.text.trim().isNotEmpty ? _q5RespondentNameCtrl.text.trim() : 'Unnamed';
    final hhCode = _q4HhCodeCtrl.text.trim().isNotEmpty ? _q4HhCodeCtrl.text.trim() : 'TEMP_${DateTime.now().millisecondsSinceEpoch}';

    await LocalDatabase.instance.insertDraft({
      'local_uuid': uuid,
      'hh_code': hhCode,
      'respondent_name': respName,
      'block_name': block,
      'panchayat_name': panchayat,
      'village_name': village,
      'form_json': jsonEncode(formData),
      'created_at': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved successfully on this device!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baseline Survey (Srijati Foundation)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _sections.map((s) => Tab(text: s)).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Draft',
            onPressed: _saveDraft,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSectionA(),
          _buildSectionB(),
          _buildSectionC(),
          _buildSectionD(),
          _buildSectionE(),
          _buildSectionF(),
          _buildSectionG(),
          _buildSectionH(),
          _buildSectionI(),
          _buildSectionJ(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saveDraft,
                child: const Text('Save Draft (ডিভাইসে রাখুন)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  if (_tabController.index < _sections.length - 1) {
                    _tabController.animateTo(_tabController.index + 1);
                  } else {
                    _saveDraft();
                  }
                },
                child: Text(
                  _tabController.index == _sections.length - 1 ? 'Finish & Save' : 'Next Section',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION WIDGETS
  // ==========================================================================

  Widget _buildSectionA() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section A: Identification & Demographics', 'পরিচিতি ও জনসংখ্যাতাত্ত্বিক তথ্য'),
        _buildTextField(_q1BlockCtrl, '1. Block / ব্লক', 'block_name'),
        _buildTextField(_q2PanchayatCtrl, '2. Panchayat / পঞ্চায়েত', 'panchayat_name'),
        _buildTextField(_q3VillageCtrl, '3. Village / গ্রাম', 'village_name'),
        _buildTextField(_hamletCtrl, 'Hamlet / পাড়া', 'hamlet_name'),
        _buildTextField(_q4HhCodeCtrl, '4. HH Code / পরিবার কোড', 'hh_code'),
        _buildTextField(_q5RespondentNameCtrl, '5. Name of Respondent / উত্তরদাতার নাম', 'respondent_name'),
        _buildTextField(_q6FatherHusbandCtrl, "6. Respondent's Father/Husband Name / পিতা/স্বামীর নাম", 'q6_father_husband'),
        _buildDropdown<int>(
          label: '7. Social Group / সামাজিক গোষ্ঠী',
          value: _q7SocialGroup,
          fieldKey: 'q7_social_group',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = ST (তফসিলি উপজাতি)')),
            DropdownMenuItem(value: 2, child: Text('2 = SC (তফসিলি জাতি)')),
            DropdownMenuItem(value: 3, child: Text('3 = OBC (অনগ্রসর শ্রেণী)')),
            DropdownMenuItem(value: 4, child: Text('4 = General/Other (সাধারণ/অন্যান্য)')),
          ],
          onChanged: (v) => setState(() => _q7SocialGroup = v),
        ),
        _buildYesNoDropdown('8. Mobile phone? / মোবাইল ফোন আছে কি?', _q8MobilePhone, 'q8_mobile_phone', (v) => setState(() => _q8MobilePhone = v)),
        _buildDropdown<int>(
          label: '9. Bread earner / প্রধান উপার্জনকারী',
          value: _q9BreadEarner,
          fieldKey: 'q9_bread_earner',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = Women (মহিলা)')),
            DropdownMenuItem(value: 2, child: Text('2 = Husband (স্বামী)')),
            DropdownMenuItem(value: 3, child: Text('3 = Young Children (সন্তান)')),
          ],
          onChanged: (v) => setState(() => _q9BreadEarner = v),
        ),
        _buildDropdown<int>(
          label: '10. Head Marital Status / বৈবাহিক অবস্থা',
          value: _q10MaritalStatus,
          fieldKey: 'q10_marital_status',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = Currently Married (বিবাহিত)')),
            DropdownMenuItem(value: 2, child: Text('2 = Single/Divorced (অবিবাহিত/তালাকপ্রাপ্ত)')),
            DropdownMenuItem(value: 3, child: Text('3 = Widowed (বিধবা/বিপত্নীক)')),
            DropdownMenuItem(value: 4, child: Text('4 = Separated (পৃথক)')),
            DropdownMenuItem(value: 5, child: Text('5 = Other (অন্যান্য)')),
          ],
          onChanged: (v) => setState(() => _q10MaritalStatus = v),
        ),
        Row(
          children: [
            Expanded(child: _buildNumberField(_q11MaleCtrl, '11. Male / পুরুষ', 'q11_male')),
            const SizedBox(width: 8),
            Expanded(child: _buildNumberField(_q11FemaleCtrl, 'Female / মহিলা', 'q11_female')),
            const SizedBox(width: 8),
            Expanded(child: _buildNumberField(_q11TotalCtrl, 'Total / মোট', 'q11_total')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildNumberField(_q12AgeUnder15Ctrl, '12. <15 Yrs', 'q12_under_15')),
            const SizedBox(width: 8),
            Expanded(child: _buildNumberField(_q12Age15To50Ctrl, '15-50 Yrs', 'q12_15_to_50')),
            const SizedBox(width: 8),
            Expanded(child: _buildNumberField(_q12AgeAbove50Ctrl, '>50 Yrs', 'q12_above_50')),
          ],
        ),
        _buildNumberField(_q13KidsSchoolCtrl, '13. Kids going to school/college / পড়ুয়া শিশু সংখ্যা', 'q13_kids_school'),
        _buildDropdown<int>(
          label: '14. Ration Card / রেশন কার্ডের ধরন',
          value: _q14RationCard,
          fieldKey: 'q14_ration_card',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = Red Card (লাল কার্ড)')),
            DropdownMenuItem(value: 2, child: Text('2 = Yellow/Antyodaya (অন্ত্যোদয়)')),
            DropdownMenuItem(value: 3, child: Text('3 = Other / সাধারণ')),
          ],
          onChanged: (v) => setState(() => _q14RationCard = v),
        ),
        _buildYesNoDropdown('15. Differently abled member? / প্রতিবন্ধী সদস্য আছে কি?', _q15DifferentlyAbled, 'q15_differently_abled', (v) => setState(() => _q15DifferentlyAbled = v)),
        _buildDropdown<int>(
          label: '16. Type of House / বাড়ির ধরন',
          value: _q16HouseType,
          fieldKey: 'q16_house_type',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = Hut (কুঁড়েঘর)')),
            DropdownMenuItem(value: 2, child: Text('2 = Kutcha (কাঁচা বাড়ি)')),
            DropdownMenuItem(value: 3, child: Text('3 = Kutcha-Pucca (মিশ্র)')),
            DropdownMenuItem(value: 4, child: Text('4 = Pucca (পাকা বাড়ি)')),
          ],
          onChanged: (v) => setState(() => _q16HouseType = v),
        ),
        _buildYesNoDropdown('17. Have Toilet? / বাড়িতে শৌচাগার আছে কি?', _q17Toilet, 'q17_toilet', (v) => setState(() => _q17Toilet = v)),
        _buildYesNoDropdown('18. Daily using toilet? / প্রতিদিন ব্যবহার করেন কি?', _q18ToiletDaily, 'q18_toilet_daily', (v) => setState(() => _q18ToiletDaily = v)),
        _buildDropdown<int>(
          label: '19. Primary Income / প্রধান আয়ের উৎস',
          value: _q19PrimaryIncome,
          fieldKey: 'q19_primary_income',
          items: _incomeSourceItems(),
          onChanged: (v) => setState(() => _q19PrimaryIncome = v),
        ),
        _buildDropdown<int>(
          label: '20. Secondary Income / দ্বিতীয় আয়ের উৎস',
          value: _q20SecondaryIncome,
          fieldKey: 'q20_secondary_income',
          items: _incomeSourceItems(),
          onChanged: (v) => setState(() => _q20SecondaryIncome = v),
        ),
      ],
    );
  }

  Widget _buildSectionB() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section B: Drinking Water Quality & Access', 'পানীয় জলের মান ও প্রাপ্যতা'),
        _buildDropdown<int>(
          label: '21. Drinking Water Source / পানীয় জলের উৎস',
          value: _q21WaterSource,
          fieldKey: 'q21_water_source',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = Handpump (হ্যান্ডপাম্প)')),
            DropdownMenuItem(value: 2, child: Text('2 = Well (কুয়ো)')),
            DropdownMenuItem(value: 3, child: Text('3 = Tap water (কলের জল)')),
            DropdownMenuItem(value: 4, child: Text('4 = River/Pond (নদী/পুকুর)')),
            DropdownMenuItem(value: 5, child: Text('5 = Other (অন্যান্য)')),
          ],
          onChanged: (v) => setState(() => _q21WaterSource = v),
        ),
        const SizedBox(height: 8),
        const Text('Rating Scale: 1=Poor/Inadequate, 2=Fair, 3=Good, 4=Excellent', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 8),
        _buildScaleDropdown('22. Summer Access Rating (গ্রীষ্মে প্রাপ্যতা)', _q22SummerAccess, 'q22_summer_access', (v) => setState(() => _q22SummerAccess = v)),
        _buildScaleDropdown('23. Summer Quality Rating (গ্রীষ্মে গুণমান)', _q23SummerQuality, 'q23_summer_quality', (v) => setState(() => _q23SummerQuality = v)),
        _buildScaleDropdown('24. Monsoon Access Rating (বর্ষায় প্রাপ্যতা)', _q24MonsoonAccess, 'q24_monsoon_access', (v) => setState(() => _q24MonsoonAccess = v)),
        _buildScaleDropdown('25. Monsoon Quality Rating (বর্ষায় গুণমান)', _q25MonsoonQuality, 'q25_monsoon_quality', (v) => setState(() => _q25MonsoonQuality = v)),
        _buildScaleDropdown('26. Winter Access Rating (শীতে প্রাপ্যতা)', _q26WinterAccess, 'q26_winter_access', (v) => setState(() => _q26WinterAccess = v)),
        _buildScaleDropdown('27. Winter Quality Rating (শীতে গুণমান)', _q27WinterQuality, 'q27_winter_quality', (v) => setState(() => _q27WinterQuality = v)),
      ],
    );
  }

  Widget _buildSectionC() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section C: Water Resources & Ecology', 'জল সম্পদ - মিষ্টি ও নোনা জলের প্রাপ্যতা'),
        _buildYesNoDropdown('28. Affected by saline water intrusion? / নোনা জলে ক্ষতি?', _q28SalineIntrusion, 'q28_saline_intrusion', (v) => setState(() => _q28SalineIntrusion = v)),
        _buildDropdown<int>(
          label: '29. Main Irrigation Source / সেচের জলের উৎস',
          value: _q29IrrigationSource,
          fieldKey: 'q29_irrigation_source',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = Freshwater pond (মিষ্টি জলের পুকুর)')),
            DropdownMenuItem(value: 2, child: Text('2 = Brackish canal/river (নোনা খাল/নদী)')),
            DropdownMenuItem(value: 3, child: Text('3 = Tube well (নলকূপ)')),
            DropdownMenuItem(value: 4, child: Text('4 = Rainwater only (শুধু বৃষ্টির জল)')),
            DropdownMenuItem(value: 5, child: Text('5 = Other (অন্যান্য)')),
          ],
          onChanged: (v) => setState(() => _q29IrrigationSource = v),
        ),
        _buildNumberField(_q30EmbankmentDistanceCtrl, '30. Distance to nearest embankment (Km) / বাঁধের দূরত্ব (কিমি)', 'q30_embankment_distance'),
        _buildYesNoDropdown('31. Embankment breach in last 3 yrs? / গত ৩ বছরে বাঁধ ভেঙেছে?', _q31EmbankmentBreach, 'q31_embankment_breach', (v) => setState(() => _q31EmbankmentBreach = v)),
        _buildNumberField(_q32PondsCountCtrl, '32. Freshwater ponds owned/accessible / মিষ্টি জলের পুকুর সংখ্যা', 'q32_ponds_count'),
        _buildYesNoDropdown('33. Harvest rainwater? / বৃষ্টির জল সংরক্ষণ করেন কি?', _q33RainwaterHarvest, 'q33_rainwater_harvest', (v) => setState(() => _q33RainwaterHarvest = v)),
        _buildDropdown<int>(
          label: '34. Salinity level / নিকটস্থ জলাশয়ের লবণাক্ততা',
          value: _q34SalinityLevel,
          fieldKey: 'q34_salinity_level',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = Fresh/Sweet (মিষ্টি জল)')),
            DropdownMenuItem(value: 2, child: Text('2 = Slightly Brackish (সামান্য নোনা)')),
            DropdownMenuItem(value: 3, child: Text('3 = Highly Brackish/Saline (খুব নোনা)')),
          ],
          onChanged: (v) => setState(() => _q34SalinityLevel = v),
        ),
        _buildYesNoDropdown('35. Salinity-related health issue? / লবণাক্ততায় স্বাস্থ্য সমস্যা?', _q35SalinityHealthIssue, 'q35_salinity_health_issue', (v) => setState(() => _q35SalinityHealthIssue = v)),
      ],
    );
  }

  Widget _buildSectionD() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section D: Land & Agriculture', 'জমি ও কৃষি'),
        _buildYesNoDropdown('36. Do you or family own land? / নিজস্ব জমি আছে কি?', _q36OwnLand, 'q36_own_land', (v) => setState(() => _q36OwnLand = v)),
        if (_q36OwnLand == 1) ...[
          _buildNumberField(_q37LandOwnedCtrl, '37. How much land owned? (Acres) / মোট জমি (একর)', 'q37_land_owned'),
          _buildNumberField(_q38LandCultivatedCtrl, '38. Land under cultivation (Acres) / চাষযোগ্য জমি (একর)', 'q38_land_cultivated'),
          Row(
            children: [
              Expanded(child: _buildNumberField(_q39RentedOutAcreCtrl, '39. Rented out (Acre)', 'q39_rented_out_acre')),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberField(_q39RentReceivedCtrl, 'Rent Recv (Rs/Yr)', 'q39_rent_received')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildNumberField(_q40LeasedInAcreCtrl, '40. Leased in (Acre)', 'q40_leased_in_acre')),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberField(_q40RentPaidCtrl, 'Rent Paid (Rs/Yr)', 'q40_rent_paid')),
            ],
          ),
          _buildNumberField(_q41KharifAcresCtrl, '41. Kharif cultivated acres / খরিফ চাষ (একর)', 'q41_kharif_acres'),
          _buildNumberField(_q42RabiAcresCtrl, '42. Rabi cultivated acres / রবি চাষ (একর)', 'q42_rabi_acres'),
          _buildNumberField(_q43SummerAcresCtrl, '43. Summer cultivated acres / গ্রীষ্ম চাষ (একর)', 'q43_summer_acres'),
          _buildDropdown<int>(
            label: '44. Food grain sufficiency / উৎপন্ন খাদ্য কত মাস চলে?',
            value: _q44FoodMonths,
            fieldKey: 'q44_food_months',
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 = < 6 months (৬ মাসের কম)')),
              DropdownMenuItem(value: 2, child: Text('2 = 6-9 months (৬-৯ মাস)')),
              DropdownMenuItem(value: 3, child: Text('3 = 9-12 months (৯-১২ মাস)')),
              DropdownMenuItem(value: 4, child: Text('4 = > 12 months (১২ মাসের বেশি)')),
            ],
            onChanged: (v) => setState(() => _q44FoodMonths = v),
          ),
          _buildDropdown<int>(
            label: '45. Main irrigation source / সেচের উৎস',
            value: _q45AgriIrrigation,
            fieldKey: 'q45_agri_irrigation',
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 = Tube well (নলকূপ)')),
              DropdownMenuItem(value: 2, child: Text('2 = Canal/River (খাল/নদী)')),
              DropdownMenuItem(value: 3, child: Text('3 = Well (কুয়ো)')),
              DropdownMenuItem(value: 4, child: Text('4 = Pond (পুকুর)')),
              DropdownMenuItem(value: 5, child: Text('5 = Lift irrigation (লিফট)')),
              DropdownMenuItem(value: 6, child: Text('6 = Deep boring (গভীর নলকূপ)')),
              DropdownMenuItem(value: 7, child: Text('7 = Other (অন্যান্য)')),
            ],
            onChanged: (v) => setState(() => _q45AgriIrrigation = v),
          ),
          const Divider(),
          const Text('46. Kharif Crop 1 Details (খরিফ ফসল ১)', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildTextField(_q46Crop1NameCtrl, 'Crop Name / ফসলের নাম', 'q46_crop1_name'),
          Row(
            children: [
              Expanded(child: _buildNumberField(_q46Crop1AreaCtrl, 'Area (Acre)', 'q46_crop1_area')),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberField(_q46Crop1ProdCtrl, 'Prod (Quintal)', 'q46_crop1_prod')),
            ],
          ),
          _buildDropdown<int>(
            label: 'Seed Quality / বীজের মান',
            value: _q46Crop1SeedQuality,
            fieldKey: 'q46_crop1_seed_quality',
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 = Own (নিজস্ব)')),
              DropdownMenuItem(value: 2, child: Text('2 = Improved (উন্নত)')),
              DropdownMenuItem(value: 3, child: Text('3 = Hybrid (হাইব্রিড)')),
            ],
            onChanged: (v) => setState(() => _q46Crop1SeedQuality = v),
          ),
          _buildDropdown<int>(
            label: 'Fertilizer Type / সারের প্রকার',
            value: _q46Crop1Fertilizer,
            fieldKey: 'q46_crop1_fertilizer',
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 = Organic (জৈব)')),
              DropdownMenuItem(value: 2, child: Text('2 = Chemical (রাসায়নিক)')),
              DropdownMenuItem(value: 3, child: Text('3 = Both (উভয়)')),
            ],
            onChanged: (v) => setState(() => _q46Crop1Fertilizer = v),
          ),
          _buildNumberField(_q46Crop1CostCtrl, 'Total Cost (Rs) / মোট খরচ (টাকা)', 'q46_crop1_cost'),
        ],
        const Divider(),
        _buildYesNoDropdown('50. Homestead garden land? / বাগানের জমি আছে?', _q50HomesteadGardenLand, 'q50_homestead_garden_land', (v) => setState(() => _q50HomesteadGardenLand = v)),
        _buildYesNoDropdown('51. Doing kitchen garden? / রান্নাঘর বাগান করছেন?', _q51DoingKitchenGarden, 'q51_doing_kitchen_garden', (v) => setState(() => _q51DoingKitchenGarden = v)),
        _buildYesNoDropdown('52. Compost pit available? / কম্পোস্ট গর্ত আছে?', _q52CompostPit, 'q52_compost_pit', (v) => setState(() => _q52CompostPit = v)),
      ],
    );
  }

  Widget _buildSectionE() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section E: Freshwater Fishery', 'মিষ্টি জলের মৎস্যচাষ'),
        _buildYesNoDropdown('53. Freshwater fishery practice? / মিষ্টি জলে মাছ চাষ করেন?', _q53FreshwaterFishery, 'q53_freshwater_fishery', (v) => setState(() => _q53FreshwaterFishery = v)),
        if (_q53FreshwaterFishery == 1) ...[
          _buildNumberField(_q54FwAreaCtrl, '54. Pond area (Acre/Decimal) / পুকুরের আয়তন', 'q54_fw_area'),
          Row(
            children: [
              Expanded(child: _buildNumberField(_q55FwDepthSummerCtrl, '55. Summer depth (ft)', 'q55_fw_depth_summer')),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberField(_q56FwDepthMonsoonCtrl, '56. Monsoon depth (ft)', 'q56_fw_depth_monsoon')),
            ],
          ),
          _buildYesNoDropdown('57. Test water quality? / জল পরীক্ষা করেন?', _q57FwWaterTest, 'q57_fw_water_test', (v) => setState(() => _q57FwWaterTest = v)),
          _buildTextField(_q58FwSpeciesCtrl, '58. Primary Species / চাষ করা প্রধান মাছ (রুই/কাতলা)', 'q58_fw_species'),
          _buildDropdown<int>(
            label: '59. Seed source / পোনার উৎস',
            value: _q59FwSeedSource,
            fieldKey: 'q59_fw_seed_source',
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 = Hatchery (হ্যাচারি)')),
              DropdownMenuItem(value: 2, child: Text('2 = Wild catch (প্রাকৃতিক সংগ্রহ)')),
              DropdownMenuItem(value: 3, child: Text('3 = Local vendor (স্থানীয় বিক্রেতা)')),
            ],
            onChanged: (v) => setState(() => _q59FwSeedSource = v),
          ),
          _buildNumberField(_q60FwProdCtrl, '60. Annual Production (Kg) / বার্ষিক উৎপাদন (কেজি)', 'q60_fw_prod'),
          _buildNumberField(_q61FwIncomeCtrl, '61. Annual Income (Rs) / বার্ষিক আয় (টাকা)', 'q61_fw_income'),
          _buildNumberField(_q62FwExpCtrl, '62. Annual Expenditure (Rs) / বার্ষিক খরচ (টাকা)', 'q62_fw_exp'),
        ],
      ],
    );
  }

  Widget _buildSectionF() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section F: Brackish Water Fishery', 'নোনা জলের মৎস্যচাষ'),
        _buildYesNoDropdown('63. Brackish fishery practice? / নোনা জলে মাছ চাষ করেন?', _q63BrackishFishery, 'q63_brackish_fishery', (v) => setState(() => _q63BrackishFishery = v)),
        if (_q63BrackishFishery == 1) ...[
          _buildNumberField(_q64BwAreaCtrl, '64. Pond area (Acre/Decimal) / পুকুরের আয়তন', 'q64_bw_area'),
          Row(
            children: [
              Expanded(child: _buildNumberField(_q65BwDepthSummerCtrl, '65. Summer depth (ft)', 'q65_bw_depth_summer')),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberField(_q66BwDepthMonsoonCtrl, '66. Monsoon depth (ft)', 'q66_bw_depth_monsoon')),
            ],
          ),
          _buildYesNoDropdown('67. Test water quality? / জল পরীক্ষা করেন?', _q67BwWaterTest, 'q67_bw_water_test', (v) => setState(() => _q67BwWaterTest = v)),
          _buildTextField(_q68BwSpeciesCtrl, '68. Species / চাষ করা মাছ/চিংড়ি (ভেটকি/বাগদা)', 'q68_bw_species'),
          _buildNumberField(_q70BwProdCtrl, '70. Annual Production (Kg) / বার্ষিক উৎপাদন (কেজি)', 'q70_bw_prod'),
          _buildNumberField(_q71BwIncomeCtrl, '71. Annual Income (Rs) / বার্ষিক আয় (টাকা)', 'q71_bw_income'),
          _buildNumberField(_q72BwExpCtrl, '72. Annual Expenditure (Rs) / বার্ষিক খরচ (টাকা)', 'q72_bw_exp'),
        ],
      ],
    );
  }

  Widget _buildSectionG() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section G: Crab Cultivation & Harvesting', 'কাঁকড়া চাষ ও সংগ্রহ'),
        _buildYesNoDropdown('73. Engage in crab farming? / কাঁকড়া চাষ বা সংগ্রহ করেন?', _q73CrabFarming, 'q73_crab_farming', (v) => setState(() => _q73CrabFarming = v)),
        if (_q73CrabFarming == 1) ...[
          _buildDropdown<int>(
            label: '74. Sourcing/Rearing Method / পালনের পদ্ধতি',
            value: _q74CrabMethod,
            fieldKey: 'q74_crab_method',
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 = Fattening (মোটাতাজাকরণ)')),
              DropdownMenuItem(value: 2, child: Text('2 = Polyculture (মিশ্র চাষ)')),
              DropdownMenuItem(value: 3, child: Text('3 = Wild catch (প্রাকৃতিক সংগ্রহ)')),
            ],
            onChanged: (v) => setState(() => _q74CrabMethod = v),
          ),
          _buildTextField(_q75CrabSpeciesCtrl, '75. Crab species / কাঁকড়ার প্রজাতি (Mud crab)', 'q75_crab_species'),
          _buildTextField(_q76CrabCycleCtrl, '76. Fattening cycle duration / চক্রের সময়কাল (দিন/মাস)', 'q76_crab_cycle'),
          _buildDropdown<int>(
            label: '77. Feed used / কাঁকড়ার খাদ্য',
            value: _q77CrabFeed,
            fieldKey: 'q77_crab_feed',
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 = Trash fish (অপ্রয়োজনীয় মাছ)')),
              DropdownMenuItem(value: 2, child: Text('2 = Snails/Molluscs (শামুক/ঝিনুক)')),
              DropdownMenuItem(value: 3, child: Text('3 = Formulated feed (প্রস্তুতকৃত খাবার)')),
              DropdownMenuItem(value: 4, child: Text('4 = None/Natural (কিছুই না)')),
            ],
            onChanged: (v) => setState(() => _q77CrabFeed = v),
          ),
          _buildNumberField(_q78CrabProdCtrl, '78. Total Production (Kg) / বার্ষিক কাঁকড়া উৎপাদন (কেজি)', 'q78_crab_prod'),
          _buildNumberField(_q79CrabIncomeCtrl, '79. Annual Income (Rs) / বার্ষিক আয় (টাকা)', 'q79_crab_income'),
          _buildNumberField(_q80CrabExpCtrl, '80. Annual Expenditure (Rs) / বার্ষিক খরচ (টাকা)', 'q80_crab_exp'),
        ],
      ],
    );
  }

  Widget _buildSectionH() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section H: Institutions & Credit Access', 'প্রতিষ্ঠান ও ঋণ প্রাপ্তি'),
        _buildDropdown<int>(
          label: '81. Member of institution / প্রতিষ্ঠানের সদস্য',
          value: _q81CommunityInst,
          fieldKey: 'q81_community_inst',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = SHG (স্বনির্ভর দল)')),
            DropdownMenuItem(value: 2, child: Text('2 = JLG')),
            DropdownMenuItem(value: 3, child: Text('3 = Kisan Club (কিষান ক্লাব)')),
            DropdownMenuItem(value: 4, child: Text('4 = None (কোনোটিই না)')),
          ],
          onChanged: (v) => setState(() => _q81CommunityInst = v),
        ),
        _buildYesNoDropdown('82. FPO/Cooperative member? / কৃষক সমবায় সদস্য?', _q82FpoMember, 'q82_fpo_member', (v) => setState(() => _q82FpoMember = v)),
        _buildDropdown<int>(
          label: '83. Produce selling channel / ফসল বিক্রির মাধ্যম',
          value: _q83SellingChannel,
          fieldKey: 'q83_selling_channel',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = FPO')),
            DropdownMenuItem(value: 2, child: Text('2 = Bazar Samiti (বাজার সমিতি)')),
            DropdownMenuItem(value: 3, child: Text('3 = Open Market/Middleman (ফড়িয়া)')),
            DropdownMenuItem(value: 4, child: Text('4 = Mix (মিশ্র)')),
          ],
          onChanged: (v) => setState(() => _q83SellingChannel = v),
        ),
        _buildYesNoDropdown('85. Have debts to repay? / কোনো শোধযোগ্য ঋণ আছে?', _q85HasDebt, 'q85_has_debt', (v) => setState(() => _q85HasDebt = v)),
        if (_q85HasDebt == 1) ...[
          _buildDropdown<int>(
            label: '87. Loan Source / ঋণ কোথা থেকে নিয়েছেন?',
            value: _q87LoanSource,
            fieldKey: 'q87_loan_source',
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 = Bank (ব্যাংক)')),
              DropdownMenuItem(value: 2, child: Text('2 = SHG/NGO (স্বনির্ভর দল/এনজিও)')),
              DropdownMenuItem(value: 3, child: Text('3 = Money lenders (মহাজন)')),
              DropdownMenuItem(value: 4, child: Text('4 = Relatives (আত্মীয়স্বজন)')),
              DropdownMenuItem(value: 5, child: Text('5 = Other (অন্যান্য)')),
            ],
            onChanged: (v) => setState(() => _q87LoanSource = v),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionI() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section I: Access to Government Schemes', 'সরকারি প্রকল্প ও সুযোগ-সুবিধা'),
        _buildYesNoDropdown('88. BPL Ration Card? / বিপিএল কার্ড আছে কি?', _q88BplCard, 'q88_bpl_card', (v) => setState(() => _q88BplCard = v)),
        _buildYesNoDropdown('89. PM-KISAN Benefit? / পিএম-কিষান সুবিধা পেয়েছেন?', _q89PmKisan, 'q89_pm_kisan', (v) => setState(() => _q89PmKisan = v)),
        _buildYesNoDropdown('90. Krishak Bandhu? / কৃষক বন্ধু নথিভুক্ত?', _q90KrishakBandhu, 'q90_krishak_bandhu', (v) => setState(() => _q90KrishakBandhu = v)),
        _buildYesNoDropdown('91. Insured PM Fasal Bima? / পিএম ফসল বিমা আছে?', _q91PmFasalBima, 'q91_pm_fasal_bima', (v) => setState(() => _q91PmFasalBima = v)),
        _buildYesNoDropdown('92. Kisan Credit Card (KCC)? / কেসিসি আছে কি?', _q92Kcc, 'q92_kcc', (v) => setState(() => _q92Kcc = v)),
        _buildYesNoDropdown('93. MGNREGA Job Card? / জব কার্ড আছে কি?', _q93MgnregaCard, 'q93_mgnrega_card', (v) => setState(() => _q93MgnregaCard = v)),
        if (_q93MgnregaCard == 1) ...[
          _buildNumberField(_q95MgnregaDaysCtrl, '95. Days worked last year / গত বছর কাজের দিন', 'q95_mgnrega_days'),
        ],
        _buildYesNoDropdown('98. Covered Health Insurance? / স্বাস্থ্যসাথী/আয়ুষ্মান ভারত আছে?', _q98HealthInsurance, 'q98_health_insurance', (v) => setState(() => _q98HealthInsurance = v)),
        _buildYesNoDropdown('99. Received PMAY House? / পিএম আবাস ঘর পেয়েছেন?', _q99PmayHouse, 'q99_pmay_house', (v) => setState(() => _q99PmayHouse = v)),
        _buildYesNoDropdown('100. Ujjwala LPG Connection? / উজ্জ্বলা গ্যাস সংযোগ আছে?', _q100Ujjwala, 'q100_ujjwala', (v) => setState(() => _q100Ujjwala = v)),
        _buildDropdown<int>(
          label: '105. Main constraint in schemes / প্রকল্প পেতে বাধা',
          value: _q105SchemeConstraint,
          fieldKey: 'q105_scheme_constraint',
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 = Lack of awareness (সচেতনতার অভাব)')),
            DropdownMenuItem(value: 2, child: Text('2 = Documentation issues (নথিপত্রের সমস্যা)')),
            DropdownMenuItem(value: 3, child: Text('3 = Distance to office (দূরত্ব)')),
            DropdownMenuItem(value: 4, child: Text('4 = Corruption/middlemen (দালাল চক্র)')),
            DropdownMenuItem(value: 5, child: Text('5 = No constraint (কোনো বাধা নেই)')),
          ],
          onChanged: (v) => setState(() => _q105SchemeConstraint = v),
        ),
      ],
    );
  }

  Widget _buildSectionJ() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Section J: Agricultural Knowledge & Practices', 'কৃষি জ্ঞান ও উন্নত অনুশীলন'),
        _buildYesNoDropdown('106. Seed treatment before sowing? / বীজ শোধন করেন কি?', _q106SeedTreatment, 'q106_seed_treatment', (v) => setState(() => _q106SeedTreatment = v)),
        _buildYesNoDropdown('107. Soil treatment/testing? / মাটি পরীক্ষা করেন কি?', _q107SoilTesting, 'q107_soil_testing', (v) => setState(() => _q107SoilTesting = v)),
        _buildYesNoDropdown('108. Use of organic/bio-pesticide? / জৈব কীটনাশক ব্যবহার করেন?', _q108BioPesticide, 'q108_bio_pesticide', (v) => setState(() => _q108BioPesticide = v)),
      ],
    );
  }

  // ==========================================================================
  // HELPER BUILDERS & STYLING
  // ==========================================================================

  Widget _buildSectionHeader(String titleEn, String titleBn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
          const SizedBox(height: 2),
          Text(titleBn, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String fieldKey) {
    final isFlagged = widget.flaggedField == fieldKey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFlagged) _buildErrorBanner(),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              enabledBorder: isFlagged ? const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(TextEditingController ctrl, String label, String fieldKey) {
    final isFlagged = widget.flaggedField == fieldKey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFlagged) _buildErrorBanner(),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              enabledBorder: isFlagged ? const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required String fieldKey,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final isFlagged = widget.flaggedField == fieldKey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFlagged) _buildErrorBanner(),
          DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              enabledBorder: isFlagged ? const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoDropdown(String label, int? value, String fieldKey, ValueChanged<int?> onChanged) {
    return _buildDropdown<int>(
      label: label,
      value: value,
      fieldKey: fieldKey,
      items: const [
        DropdownMenuItem(value: 1, child: Text('1 = Yes (হ্যাঁ)')),
        DropdownMenuItem(value: 2, child: Text('2 = No (না)')),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildScaleDropdown(String label, int? value, String fieldKey, ValueChanged<int?> onChanged) {
    return _buildDropdown<int>(
      label: label,
      value: value,
      fieldKey: fieldKey,
      items: const [
        DropdownMenuItem(value: 1, child: Text('1 = Poor / খারাপ')),
        DropdownMenuItem(value: 2, child: Text('2 = Fair / মোটামুটি')),
        DropdownMenuItem(value: 3, child: Text('3 = Good / ভালো')),
        DropdownMenuItem(value: 4, child: Text('4 = Excellent / চমৎকার')),
      ],
      onChanged: onChanged,
    );
  }

  List<DropdownMenuItem<int>> _incomeSourceItems() {
    return const [
      DropdownMenuItem(value: 1, child: Text('1 = Salaried/Self-employed (বেতনভুক্ত/চাকরি)')),
      DropdownMenuItem(value: 2, child: Text('2 = Agriculture (কৃষি)')),
      DropdownMenuItem(value: 3, child: Text('3 = Fishery (মৎস্যচাষ)')),
      DropdownMenuItem(value: 4, child: Text('4 = Agri/Non-Agri Labour (শ্রমিক)')),
      DropdownMenuItem(value: 5, child: Text('5 = NTFP (বনজ সম্পদ)')),
      DropdownMenuItem(value: 6, child: Text('6 = Other (অন্যান্য)')),
    ];
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Team Flag: ${widget.reviewerRemark ?? "Please verify this field"}',
              style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
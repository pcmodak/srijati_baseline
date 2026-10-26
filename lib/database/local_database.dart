import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;
  static bool _initAttempted = false;

  LocalDatabase._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database;
    if (!_initAttempted) {
      _database = await init();
    }
    return _database;
  }

  Future<Database?> init() async {
    _initAttempted = true;
    if (kIsWeb) {
      return null;
    }
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'srijati_local.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE local_survey_drafts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              local_uuid TEXT UNIQUE,
              hh_code TEXT,
              respondent_name TEXT,
              block_name TEXT,
              panchayat_name TEXT,
              village_name TEXT,
              form_json TEXT,
              created_at TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE local_translations (
              label_key TEXT PRIMARY KEY,
              bn_text TEXT,
              en_text TEXT
            )
          ''');
        },
      );
    } catch (_) {
      // Fallback gracefully to SharedPreferences when sqflite is unavailable
      return null;
    }
  }

  Future<int> insertDraft(Map<String, dynamic> row) async {
    final db = await database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getString('local_survey_drafts') ?? '[]';
      List<dynamic> list = jsonDecode(draftsJson);

      final mutableRow = Map<String, dynamic>.from(row);
      int id = mutableRow['id'] ?? DateTime.now().millisecondsSinceEpoch;
      mutableRow['id'] = id;

      // Replace if existing by local_uuid or id
      list.removeWhere((item) =>
          (item['local_uuid'] != null &&
              item['local_uuid'] == mutableRow['local_uuid']) ||
          (item['id'] != null && item['id'] == id));
      list.add(mutableRow);
      await prefs.setString('local_survey_drafts', jsonEncode(list));
      return id;
    }

    return await db.insert('local_survey_drafts', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getDrafts() async {
    final db = await database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getString('local_survey_drafts') ?? '[]';
      List<dynamic> list = jsonDecode(draftsJson);
      List<Map<String, dynamic>> result =
          list.map((e) => Map<String, dynamic>.from(e)).toList();
      result.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
      return result;
    }

    return await db.query('local_survey_drafts', orderBy: 'id DESC');
  }

  Future<int> deleteDraft(int id) async {
    final db = await database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getString('local_survey_drafts') ?? '[]';
      List<dynamic> list = jsonDecode(draftsJson);
      list.removeWhere((item) => item['id'] == id);
      await prefs.setString('local_survey_drafts', jsonEncode(list));
      return 1;
    }

    return await db
        .delete('local_survey_drafts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveTranslations(List<dynamic> items) async {
    final db = await database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final transJson = prefs.getString('local_translations') ?? '{}';
      Map<String, dynamic> current = jsonDecode(transJson);
      for (var item in items) {
        current[item['label_key']] = {
          'bn': item['bn_text'] ?? '',
          'en': item['en_text'] ?? '',
        };
      }
      await prefs.setString('local_translations', jsonEncode(current));
      return;
    }

    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'local_translations',
        {
          'label_key': item['label_key'],
          'bn_text': item['bn_text'],
          'en_text': item['en_text'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Map<String, String>>> loadTranslations() async {
    final db = await database;
    if (db == null) {
      final prefs = await SharedPreferences.getInstance();
      final transJson = prefs.getString('local_translations') ?? '{}';
      Map<String, dynamic> current = jsonDecode(transJson);
      Map<String, Map<String, String>> dict = {};
      current.forEach((k, v) {
        dict[k] = {
          'bn': v['bn']?.toString() ?? '',
          'en': v['en']?.toString() ?? '',
        };
      });
      return dict;
    }

    final List<Map<String, dynamic>> maps =
        await db.query('local_translations');
    Map<String, Map<String, String>> dict = {};
    for (var r in maps) {
      dict[r['label_key']] = {
        'bn': r['bn_text'] ?? '',
        'en': r['en_text'] ?? '',
      };
    }
    return dict;
  }
}
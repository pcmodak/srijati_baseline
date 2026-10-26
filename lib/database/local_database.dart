import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await init();
    return _database!;
  }

  Future<Database> init() async {
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
  }

  Future<int> insertDraft(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('local_survey_drafts', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getDrafts() async {
    final db = await instance.database;
    return await db.query('local_survey_drafts', orderBy: 'id DESC');
  }

  Future<int> deleteDraft(int id) async {
    final db = await instance.database;
    return await db.delete('local_survey_drafts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveTranslations(List<dynamic> items) async {
    final db = await instance.database;
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
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('local_translations');
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
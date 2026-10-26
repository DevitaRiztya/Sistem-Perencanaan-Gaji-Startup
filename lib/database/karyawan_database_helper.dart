import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

import '../models/karyawan_record.dart';
import '../models/calon_karyawan_record.dart';
import '../models/perencanaan_gaji_record.dart';

class KaryawanDatabaseHelper {
  static const String _dbName = 'karyawan_payroll.db';
  static const int _dbVersion = 3;
  static const String _tableName = 'tabel_karyawan';
  static const String _tableCalonKaryawan = 'tabel_calon_karyawan';
  static const String _tablePerencanaanGaji = 'tabel_perencanaan_gaji';

  static final KaryawanDatabaseHelper instance =
      KaryawanDatabaseHelper._internal();
  KaryawanDatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static void _ensureFfiInitialized() {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> _initDatabase() async {
    _ensureFfiInitialized();

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    if (!kIsWeb) {
      final dbFile = File(path);
      if (!await dbFile.exists()) {
        try {
          await Directory(dirname(path)).create(recursive: true);
        } catch (_) {}

        try {
          ByteData data;
          try {
            data = await rootBundle.load('database/$_dbName');
          } catch (_) {
            data = await rootBundle.load('assets/database/$_dbName');
          }
          final bytes = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          await dbFile.writeAsBytes(bytes, flush: true);
        } catch (e) {
          developer.log(
            'Asset DB tidak ditemukan, dibuat baru: $e',
            name: 'DB',
          );
        }
      }
    }

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await _ensureSchemaValid(db);

    return db;
  }

  Future<void> _ensureSchemaValid(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id          TEXT PRIMARY KEY,
        nama        TEXT NOT NULL,
        jabatan     TEXT NOT NULL,
        tanggalLahir TEXT NOT NULL,
        alamat      TEXT NOT NULL DEFAULT 'Jl. Malioboro No. 12, Yogyakarta',
        noTelepon   TEXT NOT NULL DEFAULT '081234567890',
        gajiPokok   REAL NOT NULL DEFAULT 0,
        tunjangan   REAL NOT NULL DEFAULT 0,
        potongan    REAL NOT NULL DEFAULT 0,
        hariLembur  INTEGER NOT NULL DEFAULT 0,
        createdAt   TEXT NOT NULL
      )
    ''');

    final columns = await db.rawQuery('PRAGMA table_info($_tableName)');
    final columnNames = columns.map((c) => c['name'] as String).toSet();

    if (!columnNames.contains('alamat')) {
      developer.log('Menambah kolom alamat ke $_tableName', name: 'DB');
      await db.execute(
        "ALTER TABLE $_tableName ADD COLUMN alamat TEXT NOT NULL DEFAULT 'Jl. Malioboro No. 12, Yogyakarta'",
      );
    }
    if (!columnNames.contains('noTelepon')) {
      developer.log('Menambah kolom noTelepon ke $_tableName', name: 'DB');
      await db.execute(
        "ALTER TABLE $_tableName ADD COLUMN noTelepon TEXT NOT NULL DEFAULT '081234567890'",
      );
    }

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableCalonKaryawan (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nama        TEXT NOT NULL,
        posisi      TEXT NOT NULL,
        gajiPokok   TEXT NOT NULL,
        tunjangan   TEXT NOT NULL,
        jamLembur   TEXT NOT NULL,
        tarifLembur TEXT NOT NULL,
        hariKerja   INTEGER NOT NULL DEFAULT 1,
        potongan    TEXT NOT NULL,
        createdAt   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tablePerencanaanGaji (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        namaKandidat    TEXT NOT NULL,
        posisi          TEXT NOT NULL,
        gajiPokok       TEXT NOT NULL,
        tunjangan       TEXT NOT NULL,
        jamLembur       TEXT NOT NULL,
        tarifLembur     TEXT NOT NULL,
        hariKerja       INTEGER NOT NULL DEFAULT 1,
        potongan        TEXT NOT NULL,
        hasilUangLembur TEXT NOT NULL,
        hasilGajiKotor  TEXT NOT NULL,
        hasilGajiBersih TEXT NOT NULL,
        hasilGajiPerHari TEXT NOT NULL,
        tanggalSimulasi TEXT NOT NULL
      )
    ''');

    developer.log('Schema validation selesai.', name: 'DB');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id          TEXT PRIMARY KEY,
        nama        TEXT NOT NULL,
        jabatan     TEXT NOT NULL,
        tanggalLahir TEXT NOT NULL,
        alamat      TEXT NOT NULL,
        noTelepon   TEXT NOT NULL,
        gajiPokok   REAL NOT NULL DEFAULT 0,
        tunjangan   REAL NOT NULL DEFAULT 0,
        potongan    REAL NOT NULL DEFAULT 0,
        hariLembur  INTEGER NOT NULL DEFAULT 0,
        createdAt   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableCalonKaryawan (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nama        TEXT NOT NULL,
        posisi      TEXT NOT NULL,
        gajiPokok   TEXT NOT NULL,
        tunjangan   TEXT NOT NULL,
        jamLembur   TEXT NOT NULL,
        tarifLembur TEXT NOT NULL,
        hariKerja   INTEGER NOT NULL DEFAULT 1,
        potongan    TEXT NOT NULL,
        createdAt   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tablePerencanaanGaji (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        namaKandidat    TEXT NOT NULL,
        posisi          TEXT NOT NULL,
        gajiPokok       TEXT NOT NULL,
        tunjangan       TEXT NOT NULL,
        jamLembur       TEXT NOT NULL,
        tarifLembur     TEXT NOT NULL,
        hariKerja       INTEGER NOT NULL DEFAULT 1,
        potongan        TEXT NOT NULL,
        hasilUangLembur TEXT NOT NULL,
        hasilGajiKotor  TEXT NOT NULL,
        hasilGajiBersih TEXT NOT NULL,
        hasilGajiPerHari TEXT NOT NULL,
        tanggalSimulasi TEXT NOT NULL
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableCalonKaryawan (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          nama        TEXT NOT NULL,
          posisi      TEXT NOT NULL,
          gajiPokok   TEXT NOT NULL,
          tunjangan   TEXT NOT NULL,
          jamLembur   TEXT NOT NULL,
          tarifLembur TEXT NOT NULL,
          hariKerja   INTEGER NOT NULL DEFAULT 1,
          potongan    TEXT NOT NULL,
          createdAt   TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tablePerencanaanGaji (
          id              INTEGER PRIMARY KEY AUTOINCREMENT,
          namaKandidat    TEXT NOT NULL,
          posisi          TEXT NOT NULL,
          gajiPokok       TEXT NOT NULL,
          tunjangan       TEXT NOT NULL,
          jamLembur       TEXT NOT NULL,
          tarifLembur     TEXT NOT NULL,
          hariKerja       INTEGER NOT NULL DEFAULT 1,
          potongan        TEXT NOT NULL,
          hasilUangLembur TEXT NOT NULL,
          hasilGajiKotor  TEXT NOT NULL,
          hasilGajiBersih TEXT NOT NULL,
          hasilGajiPerHari TEXT NOT NULL,
          tanggalSimulasi TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      try {
        await db.execute(
          "ALTER TABLE $_tableName ADD COLUMN alamat TEXT NOT NULL DEFAULT 'Jl. Malioboro No. 12, Yogyakarta'",
        );
      } catch (_) {}
      try {
        await db.execute(
          "ALTER TABLE $_tableName ADD COLUMN noTelepon TEXT NOT NULL DEFAULT '081234567890'",
        );
      } catch (_) {}
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableCalonKaryawan (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          nama        TEXT NOT NULL,
          posisi      TEXT NOT NULL,
          gajiPokok   TEXT NOT NULL,
          tunjangan   TEXT NOT NULL,
          jamLembur   TEXT NOT NULL,
          tarifLembur TEXT NOT NULL,
          hariKerja   INTEGER NOT NULL DEFAULT 1,
          potongan    TEXT NOT NULL,
          createdAt   TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tablePerencanaanGaji (
          id              INTEGER PRIMARY KEY AUTOINCREMENT,
          namaKandidat    TEXT NOT NULL,
          posisi          TEXT NOT NULL,
          gajiPokok       TEXT NOT NULL,
          tunjangan       TEXT NOT NULL,
          jamLembur       TEXT NOT NULL,
          tarifLembur     TEXT NOT NULL,
          hariKerja       INTEGER NOT NULL DEFAULT 1,
          potongan        TEXT NOT NULL,
          hasilUangLembur TEXT NOT NULL,
          hasilGajiKotor  TEXT NOT NULL,
          hasilGajiBersih TEXT NOT NULL,
          hasilGajiPerHari TEXT NOT NULL,
          tanggalSimulasi TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _seedInitialData(Database db) async {
    final seedData = [
      KaryawanRecord(
        id: 'EMP-001',
        nama: 'Budi',
        jabatan: 'Software Engineer',
        tanggalLahir: DateTime(2005, 11, 11),
        alamat: 'Jl. Malioboro No. 10, Yogyakarta',
        noTelepon: '081234567890',
        gajiPokok: 8500000.0,
        tunjangan: 1500000.0,
        potongan: 250000.0,
        hariLembur: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      KaryawanRecord(
        id: 'EMP-002',
        nama: 'Ahmad Fauzi',
        jabatan: 'Senior Backend Engineer',
        tanggalLahir: DateTime(2002, 5, 15),
        alamat: 'Jl. Kaliurang KM 5, Sleman',
        noTelepon: '081234567891',
        gajiPokok: 12500000.0,
        tunjangan: 2500000.0,
        potongan: 350000.0,
        hariLembur: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      KaryawanRecord(
        id: 'EMP-003',
        nama: 'Siti Rahmawati',
        jabatan: 'UI/UX Product Designer',
        tanggalLahir: DateTime(2003, 5, 20),
        alamat: 'Jl. Gejayan No. 22, Yogyakarta',
        noTelepon: '081234567892',
        gajiPokok: 9500000.0,
        tunjangan: 1800000.0,
        potongan: 250000.0,
        hariLembur: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      KaryawanRecord(
        id: 'EMP-004',
        nama: 'Dewi Lestari',
        jabatan: 'Quality Assurance Analyst',
        tanggalLahir: DateTime(2004, 8, 15),
        alamat: 'Jl. Solo KM 8, Sleman',
        noTelepon: '081234567893',
        gajiPokok: 8000000.0,
        tunjangan: 1500000.0,
        potongan: 200000.0,
        hariLembur: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    final batch = db.batch();
    for (final record in seedData) {
      batch.insert(_tableName, _toMap(record));
    }
    await batch.commit(noResult: true);
  }

  Future<List<KaryawanRecord>> getAllKaryawan() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'createdAt DESC',
      );
      return maps.map((map) => _fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> insertKaryawan(KaryawanRecord karyawan) async {
    final db = await database;
    final existing = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [karyawan.id],
      limit: 1,
    );
    if (existing.isNotEmpty) return false; // ID duplikat

    await db.insert(
      _tableName,
      _toMap(karyawan),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return true;
  }

  Future<bool> updateKaryawan(KaryawanRecord karyawan) async {
    try {
      final db = await database;
      final rowsAffected = await db.update(
        _tableName,
        _toMap(karyawan),
        where: 'id = ?',
        whereArgs: [karyawan.id],
      );
      return rowsAffected > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteKaryawan(String id) async {
    try {
      final db = await database;
      final rowsAffected = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return rowsAffected > 0;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _toMap(KaryawanRecord record) {
    return {
      'id': record.id,
      'nama': record.nama,
      'jabatan': record.jabatan,
      'tanggalLahir': record.tanggalLahir.toIso8601String(),
      'alamat': record.alamat,
      'noTelepon': record.noTelepon,
      'gajiPokok': record.gajiPokok,
      'tunjangan': record.tunjangan,
      'potongan': record.potongan,
      'hariLembur': record.hariLembur,
      'createdAt': record.createdAt.toIso8601String(),
    };
  }

  KaryawanRecord _fromMap(Map<String, dynamic> map) {
    return KaryawanRecord(
      id: map['id'] as String,
      nama: map['nama'] as String,
      jabatan: map['jabatan'] as String,
      tanggalLahir:
          DateTime.tryParse(map['tanggalLahir'] as String) ??
          DateTime(2005, 11, 11),
      alamat: (map['alamat'] as String?) ?? 'Yogyakarta',
      noTelepon: (map['noTelepon'] as String?) ?? '081234567890',
      gajiPokok: (map['gajiPokok'] as num).toDouble(),
      tunjangan: (map['tunjangan'] as num).toDouble(),
      potongan: (map['potongan'] as num).toDouble(),
      hariLembur: (map['hariLembur'] as int?) ?? 0,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now(),
    );
  }

  Future<List<CalonKaryawanRecord>> getAllCalonKaryawan() async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableCalonKaryawan,
        orderBy: 'createdAt DESC',
      );
      return maps.map((m) => CalonKaryawanRecord.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> insertCalonKaryawan(CalonKaryawanRecord record) async {
    try {
      final db = await database;
      final map = record.toMap()..remove('id');
      return await db.insert(
        _tableCalonKaryawan,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('ERROR INSERT CALON KARYAWAN: $e');
      return -1;
    }
  }

  Future<bool> updateCalonKaryawan(CalonKaryawanRecord record) async {
    try {
      final db = await database;
      final rows = await db.update(
        _tableCalonKaryawan,
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      return rows > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCalonKaryawan(int id) async {
    try {
      final db = await database;
      final rows = await db.delete(
        _tableCalonKaryawan,
        where: 'id = ?',
        whereArgs: [id],
      );
      return rows > 0;
    } catch (_) {
      return false;
    }
  }

  Future<List<PerencanaanGajiRecord>> getAllPerencanaanGaji() async {
    try {
      final db = await database;
      final maps = await db.query(
        _tablePerencanaanGaji,
        orderBy: 'tanggalSimulasi DESC',
      );
      return maps.map((m) => PerencanaanGajiRecord.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> insertPerencanaanGaji(PerencanaanGajiRecord record) async {
    final db = await database;
    final map = record.toMap()..remove('id');
    return await db.insert(
      _tablePerencanaanGaji,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> deletePerencanaanGaji(int id) async {
    try {
      final db = await database;
      final rows = await db.delete(
        _tablePerencanaanGaji,
        where: 'id = ?',
        whereArgs: [id],
      );
      return rows > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAllPerencanaanGaji() async {
    try {
      final db = await database;
      await db.delete(_tablePerencanaanGaji);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Menutup koneksi database (opsional, dipanggil saat app ditutup)
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

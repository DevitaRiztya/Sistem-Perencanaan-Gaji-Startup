import 'dart:io';

/// Script Dart untuk mengecek dan memastikan file database fisik SQLite tersedia.
///
/// Cara menjalankan:
/// dart run database/generate_db.dart
void main() async {
  print('====================================================');
  print(' Pemeriksaan Database Fisik: karyawan_payroll.db');
  print('====================================================');

  final currentDir = Directory.current.path;
  final dbFile = File('$currentDir/database/karyawan_payroll.db');
  final sqlFile = File('$currentDir/database/init_db.sql');

  print('Lokasi project : $currentDir');
  print('File database  : ${dbFile.path}');
  print('File skema SQL : ${sqlFile.path}');

  if (!await dbFile.exists()) {
    print('\n[STATUS] File database belum ditemukan.');
    if (await sqlFile.exists()) {
      print('[INFO] Mencari tool SQLite untuk membuat database dari init_db.sql...');
      final candidates = [
        'sqlite3',
        r'C:\Program Files\QGIS 3.40.15\bin\sqlite3.exe',
        r'C:\xampp\MercuryMail\sqlite3.exe',
      ];

      bool generated = false;
      for (final candidate in candidates) {
        try {
          final process = await Process.start(candidate, [dbFile.path]);
          await sqlFile.openRead().pipe(process.stdin);
          final exitCode = await process.exitCode;
          if (exitCode == 0) {
            print('[SUKSES] Database berhasil dibuat menggunakan: $candidate');
            generated = true;
            break;
          }
        } catch (_) {}
      }

      if (!generated) {
        print('[PERINGATAN] Silakan jalankan database/create_db.bat atau install sqlite3 CLI.');
      }
    }
  } else {
    final size = await dbFile.length();
    print('\n[SUKSES] File database fisik SUDAH TERSEDIA!');
    print('Ukuran file    : $size bytes');
    print('Status         : Siap dibuka dengan ekstensi SQLite Viewer di VS Code.');
  }

  print('====================================================');
}

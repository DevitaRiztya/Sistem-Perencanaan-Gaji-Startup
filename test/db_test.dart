import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_payroll/database/karyawan_database_helper.dart';
import 'package:flutter_payroll/models/karyawan_record.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Test Karyawan Insert', () async {
    final dbHelper = KaryawanDatabaseHelper.instance;
    final record = KaryawanRecord(
      id: 'EMP-TEST',
      nama: 'Test',
      jabatan: 'Test',
      gajiPokok: 1000,
      tunjangan: 0,
      potongan: 0,
    );
    try {
      final res = await dbHelper.insertKaryawan(record);
      print('Result: \$res');
    } catch (e) {
      print('Error: \$e');
    }
  });
}

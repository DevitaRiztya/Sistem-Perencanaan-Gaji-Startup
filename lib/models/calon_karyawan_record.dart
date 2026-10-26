import 'desimal_besar.dart';

/// Model Record untuk Data Calon Karyawan di SQLite Database
class CalonKaryawanRecord {
  final int? id;
  final String nama;
  final String posisi;
  final String gajiPokokStr;
  final String tunjanganStr;
  final String jamLemburStr;
  final String tarifLemburStr;
  final int hariKerja;
  final String potonganStr;
  final DateTime createdAt;

  CalonKaryawanRecord({
    this.id,
    required this.nama,
    required this.posisi,
    required this.gajiPokokStr,
    required this.tunjanganStr,
    required this.jamLemburStr,
    required this.tarifLemburStr,
    required this.hariKerja,
    required this.potonganStr,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Getter DesimalBesar
  DesimalBesar get gajiPokok => DesimalBesar.dariString(gajiPokokStr);
  DesimalBesar get tunjangan => DesimalBesar.dariString(tunjanganStr);
  DesimalBesar get jamLembur => DesimalBesar.dariString(jamLemburStr);
  DesimalBesar get tarifLembur => DesimalBesar.dariString(tarifLemburStr);
  DesimalBesar get potongan => DesimalBesar.dariString(potonganStr);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'posisi': posisi,
      'gajiPokok': gajiPokokStr,
      'tunjangan': tunjanganStr,
      'jamLembur': jamLemburStr,
      'tarifLembur': tarifLemburStr,
      'hariKerja': hariKerja,
      'potongan': potonganStr,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CalonKaryawanRecord.fromMap(Map<String, dynamic> map) {
    return CalonKaryawanRecord(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      posisi: map['posisi'] as String,
      gajiPokokStr: map['gajiPokok'] as String,
      tunjanganStr: map['tunjangan'] as String,
      jamLemburStr: map['jamLembur'] as String,
      tarifLemburStr: map['tarifLembur'] as String,
      hariKerja: map['hariKerja'] as int,
      potonganStr: map['potongan'] as String,
      createdAt: DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now(),
    );
  }
}

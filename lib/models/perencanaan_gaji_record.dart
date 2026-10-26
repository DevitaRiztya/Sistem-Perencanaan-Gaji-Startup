import 'desimal_besar.dart';

/// Model Record untuk menyimpan Riwayat Simulasi Perencanaan Gaji di SQLite
class PerencanaanGajiRecord {
  final int? id;
  final String namaKandidat;
  final String posisi;
  // Input komponen (disimpan sebagai String untuk presisi DesimalBesar)
  final String gajiPokokStr;
  final String tunjanganStr;
  final String jamLemburStr;
  final String tarifLemburStr;
  final int hariKerja;
  final String potonganStr;
  // Hasil kalkulasi (disimpan sebagai String untuk presisi DesimalBesar)
  final String hasilUangLemburStr;
  final String hasilGajiKotorStr;
  final String hasilGajiBersihStr;
  final String hasilGajiPerHariStr;
  final DateTime tanggalSimulasi;

  PerencanaanGajiRecord({
    this.id,
    required this.namaKandidat,
    required this.posisi,
    required this.gajiPokokStr,
    required this.tunjanganStr,
    required this.jamLemburStr,
    required this.tarifLemburStr,
    required this.hariKerja,
    required this.potonganStr,
    required this.hasilUangLemburStr,
    required this.hasilGajiKotorStr,
    required this.hasilGajiBersihStr,
    required this.hasilGajiPerHariStr,
    DateTime? tanggalSimulasi,
  }) : tanggalSimulasi = tanggalSimulasi ?? DateTime.now();

  // Getter DesimalBesar untuk input
  DesimalBesar get gajiPokok => DesimalBesar.dariString(gajiPokokStr);
  DesimalBesar get tunjangan => DesimalBesar.dariString(tunjanganStr);
  DesimalBesar get jamLembur => DesimalBesar.dariString(jamLemburStr);
  DesimalBesar get tarifLembur => DesimalBesar.dariString(tarifLemburStr);
  DesimalBesar get potongan => DesimalBesar.dariString(potonganStr);

  // Getter DesimalBesar untuk hasil
  DesimalBesar get hasilUangLembur => DesimalBesar.dariString(hasilUangLemburStr);
  DesimalBesar get hasilGajiKotor => DesimalBesar.dariString(hasilGajiKotorStr);
  DesimalBesar get hasilGajiBersih => DesimalBesar.dariString(hasilGajiBersihStr);
  DesimalBesar get hasilGajiPerHari => DesimalBesar.dariString(hasilGajiPerHariStr);

  /// Format tanggal simulasi Indonesia
  String get tanggalFormatted {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final tgl = tanggalSimulasi;
    return '${tgl.day} ${bulan[tgl.month - 1]} ${tgl.year}, '
        '${tgl.hour.toString().padLeft(2, '0')}:${tgl.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaKandidat': namaKandidat,
      'posisi': posisi,
      'gajiPokok': gajiPokokStr,
      'tunjangan': tunjanganStr,
      'jamLembur': jamLemburStr,
      'tarifLembur': tarifLemburStr,
      'hariKerja': hariKerja,
      'potongan': potonganStr,
      'hasilUangLembur': hasilUangLemburStr,
      'hasilGajiKotor': hasilGajiKotorStr,
      'hasilGajiBersih': hasilGajiBersihStr,
      'hasilGajiPerHari': hasilGajiPerHariStr,
      'tanggalSimulasi': tanggalSimulasi.toIso8601String(),
    };
  }

  factory PerencanaanGajiRecord.fromMap(Map<String, dynamic> map) {
    return PerencanaanGajiRecord(
      id: map['id'] as int?,
      namaKandidat: map['namaKandidat'] as String,
      posisi: map['posisi'] as String,
      gajiPokokStr: map['gajiPokok'] as String,
      tunjanganStr: map['tunjangan'] as String,
      jamLemburStr: map['jamLembur'] as String,
      tarifLemburStr: map['tarifLembur'] as String,
      hariKerja: map['hariKerja'] as int,
      potonganStr: map['potongan'] as String,
      hasilUangLemburStr: map['hasilUangLembur'] as String,
      hasilGajiKotorStr: map['hasilGajiKotor'] as String,
      hasilGajiBersihStr: map['hasilGajiBersih'] as String,
      hasilGajiPerHariStr: map['hasilGajiPerHari'] as String,
      tanggalSimulasi: DateTime.tryParse(map['tanggalSimulasi'] as String) ?? DateTime.now(),
    );
  }
}

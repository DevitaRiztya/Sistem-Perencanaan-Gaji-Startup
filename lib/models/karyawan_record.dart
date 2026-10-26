import 'desimal_besar.dart';

/// Model Record Karyawan untuk Payroll, Data Karyawan & Konversi Kalender
class KaryawanRecord {
  final String id; // ID atau NIK Karyawan
  final String nama;
  final String jabatan;
  final DateTime tanggalLahir;
  final String alamat;
  final String noTelepon;
  final double gajiPokok;
  final double tunjangan;
  final double potongan;
  final int hariLembur;
  final DateTime createdAt;

  KaryawanRecord({
    required this.id,
    required this.nama,
    required this.jabatan,
    DateTime? tanggalLahir,
    this.alamat = 'Jl. Malioboro No. 12, Yogyakarta',
    this.noTelepon = '081234567890',
    required this.gajiPokok,
    required this.tunjangan,
    required this.potongan,
    this.hariLembur = 0,
    DateTime? createdAt,
  })  : tanggalLahir = tanggalLahir ?? DateTime(2005, 11, 11),
        createdAt = createdAt ?? DateTime.now();

  // Konversi Presisi Tinggi Menggunakan DesimalBesar
  DesimalBesar get gajiPokokDesimal => DesimalBesar.dariString(gajiPokok.toString());
  DesimalBesar get tunjanganDesimal => DesimalBesar.dariString(tunjangan.toString());
  DesimalBesar get potonganDesimal => DesimalBesar.dariString(potongan.toString());

  /// Perhitungan Uang Lembur Presisi Tinggi
  DesimalBesar get uangLemburDesimal {
    if (hariLembur <= 0) return DesimalBesar.nol();
    final rateHarian = gajiPokokDesimal / DesimalBesar.dariInt(22);
    final faktor = (DesimalBesar.dariInt(3) / DesimalBesar.dariInt(2)) * DesimalBesar.dariInt(hariLembur);
    return rateHarian * faktor;
  }

  /// Rumus Konsisten: Gaji Kotor = Gaji Pokok + Tunjangan + Uang Lembur
  DesimalBesar get gajiKotorDesimal => gajiPokokDesimal + tunjanganDesimal + uangLemburDesimal;

  /// Rumus Konsisten: Gaji Bersih = Gaji Kotor - Potongan
  DesimalBesar get gajiBersihDesimal => gajiKotorDesimal - potonganDesimal;

  /// Rumus Total Gaji: Gaji Pokok + Tunjangan - Potongan
  double get totalGaji {
    final total = gajiPokok + tunjangan - potongan;
    return total > 0 ? total : 0.0;
  }

  /// Kompatibilitas untuk perhitungan lembur
  double get estimasiLembur {
    if (hariLembur <= 0) return 0.0;
    final rateHarian = gajiPokok / 22.0;
    return rateHarian * 1.5 * hariLembur;
  }

  /// Total Gaji Bersih: Gaji Kotor - Potongan (Gaji Pokok + Tunjangan + Lembur - Potongan)
  double get totalGajiBersih => (gajiPokok + tunjangan + estimasiLembur) - potongan;

  /// Format tanggal lahir Indonesia (contoh: 11 November 2005)
  String get tanggalLahirFormatted {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${tanggalLahir.day} ${bulan[tanggalLahir.month - 1]} ${tanggalLahir.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'jabatan': jabatan,
      'tanggalLahir': tanggalLahir.toIso8601String(),
      'alamat': alamat,
      'noTelepon': noTelepon,
      'gajiPokok': gajiPokok,
      'tunjangan': tunjangan,
      'potongan': potongan,
      'hariLembur': hariLembur,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory KaryawanRecord.fromJson(Map<String, dynamic> json) {
    return KaryawanRecord(
      id: json['id'] as String,
      nama: json['nama'] as String,
      jabatan: json['jabatan'] as String,
      tanggalLahir: json['tanggalLahir'] != null
          ? DateTime.tryParse(json['tanggalLahir'] as String) ?? DateTime(2005, 11, 11)
          : DateTime(2005, 11, 11),
      alamat: (json['alamat'] as String?) ?? 'Yogyakarta',
      noTelepon: (json['noTelepon'] as String?) ?? '081234567890',
      gajiPokok: (json['gajiPokok'] as num).toDouble(),
      tunjangan: (json['tunjangan'] as num).toDouble(),
      potongan: (json['potongan'] as num).toDouble(),
      hariLembur: (json['hariLembur'] as int?) ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  KaryawanRecord copyWith({
    String? id,
    String? nama,
    String? jabatan,
    DateTime? tanggalLahir,
    String? alamat,
    String? noTelepon,
    double? gajiPokok,
    double? tunjangan,
    double? potongan,
    int? hariLembur,
    DateTime? createdAt,
  }) {
    return KaryawanRecord(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jabatan: jabatan ?? this.jabatan,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      alamat: alamat ?? this.alamat,
      noTelepon: noTelepon ?? this.noTelepon,
      gajiPokok: gajiPokok ?? this.gajiPokok,
      tunjangan: tunjangan ?? this.tunjangan,
      potongan: potongan ?? this.potongan,
      hariLembur: hariLembur ?? this.hariLembur,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

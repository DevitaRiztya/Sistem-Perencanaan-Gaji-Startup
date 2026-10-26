import 'personil.dart';
import 'desimal_besar.dart';

/// Inheritance: CalonKaryawan mewarisi sifat dasar dari Personil
class CalonKaryawan extends Personil {
  // Encapsulation: Komponen finansial dikapsulasi secara privat
  DesimalBesar _gajiPokok;
  DesimalBesar _tunjangan;
  DesimalBesar _jamLembur;
  DesimalBesar _tarifLembur;
  int _hariKerja;
  DesimalBesar _potongan;

  // Parameterized Constructor memanggil super() untuk inisialisasi class induk
  CalonKaryawan({
    required super.nama,
    required super.posisi,
    required DesimalBesar gajiPokok,
    required DesimalBesar tunjangan,
    required DesimalBesar jamLembur,
    required DesimalBesar tarifLembur,
    required int hariKerja,
    required DesimalBesar potongan,
  })  : _gajiPokok = gajiPokok,
        _tunjangan = tunjangan,
        _jamLembur = jamLembur,
        _tarifLembur = tarifLembur,
        _hariKerja = hariKerja,
        _potongan = potongan;

  // Getter & Setter dengan validasi aturan bisnis
  DesimalBesar get gajiPokok => _gajiPokok;
  set gajiPokok(DesimalBesar nilai) {
    if (nilai.isNegatif) {
      throw ArgumentError("Gaji pokok tidak boleh bernilai negatif.");
    }
    _gajiPokok = nilai;
  }

  DesimalBesar get tunjangan => _tunjangan;
  set tunjangan(DesimalBesar nilai) => _tunjangan = nilai;

  DesimalBesar get jamLembur => _jamLembur;
  set jamLembur(DesimalBesar nilai) => _jamLembur = nilai;

  DesimalBesar get tarifLembur => _tarifLembur;
  set tarifLembur(DesimalBesar nilai) => _tarifLembur = nilai;

  int get hariKerja => _hariKerja;
  set hariKerja(int nilai) {
    if (nilai <= 0) throw ArgumentError("Hari kerja harus lebih dari 0.");
    _hariKerja = nilai;
  }

  DesimalBesar get potongan => _potongan;
  set potongan(DesimalBesar nilai) => _potongan = nilai;

  // --------------------------------------------------------------------------
  // PERHITUNGAN MATEMATIKA MODULAR BERORIENTASI OBJEK
  // --------------------------------------------------------------------------

  /// Operasi Perkalian: Menghitung total uang lembur
  DesimalBesar hitungUangLembur() {
    return _jamLembur * _tarifLembur;
  }

  /// Operasi Penjumlahan: Menghitung total gaji kotor
  DesimalBesar hitungGajiKotor() {
    return _gajiPokok + _tunjangan + hitungUangLembur();
  }

  /// Operasi Pengurangan: Menghitung estimasi gaji bersih
  DesimalBesar hitungGajiBersih() {
    return hitungGajiKotor() - _potongan;
  }

  /// Operasi Pembagian: Menghitung rata-rata estimasi gaji per hari kerja
  DesimalBesar hitungGajiPerHari() {
    if (_hariKerja <= 0) {
      throw ArgumentError("Jumlah hari kerja harus lebih besar dari 0!");
    }
    return hitungGajiBersih() / DesimalBesar.dariInt(_hariKerja);
  }

  // Polymorphism: Implementasi nyata method tampilkanProfil()
  @override
  void tampilkanProfil() {
    print(" Nama Calon Karyawan : $nama");
    print(" Posisi / Jabatan    : $posisi");
  }
}

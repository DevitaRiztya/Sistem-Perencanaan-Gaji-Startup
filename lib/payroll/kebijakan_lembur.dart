import 'kebijakan_lembur_nol.dart';
import 'kebijakan_lembur_genap.dart';
import 'kebijakan_lembur_ganjil.dart';

abstract class KebijakanLembur {
  final BigInt _hariLembur;

  KebijakanLembur(this._hariLembur);

  BigInt get hariLembur => _hariLembur;
  String get statusKategori;

  void tampilkanKeputusan();

  String get deskripsiKeputusan;

  factory KebijakanLembur.evaluasi(BigInt hari) {
    if (hari == BigInt.zero) {
      return KebijakanLemburNol(hari);
    } else if (hari % BigInt.two == BigInt.zero) {
      return KebijakanLemburGenap(hari);
    } else {
      return KebijakanLemburGanjil(hari);
    }
  }
}

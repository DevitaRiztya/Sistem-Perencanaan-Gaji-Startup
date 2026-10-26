import 'kebijakan_lembur.dart';

class KebijakanLemburNol extends KebijakanLembur {
  KebijakanLemburNol(super.hariLembur);

  @override
  String get statusKategori => "GENAP (Nol)";

  @override
  void tampilkanKeputusan() {
    print(
      " [i] Tidak ada rencana lembur. Calon karyawan bekerja pada jam normal.",
    );
  }

  @override
  String get deskripsiKeputusan =>
      "Tidak ada rencana lembur. Calon karyawan bekerja pada jam normal.";
}

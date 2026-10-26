import 'kebijakan_lembur.dart';

/// Turunan 2: Lembur Genap
class KebijakanLemburGenap extends KebijakanLembur {
  KebijakanLemburGenap(super.hariLembur);

  @override
  String get statusKategori => "GENAP";

  @override
  void tampilkanKeputusan() {
    print(" [✓] Pola Lembur GENAP (Siklus Seimbang).");
    print("     Rekomendasi Kebijakan:");
    print("     1. Bayarkan upah lembur reguler sesuai total jam lembur.");
    print(
        "     2. Berikan 1 Hari Libur Pengganti (Off-Day) pada pekan berikutnya");
    print("        guna menjaga work-life balance calon karyawan.");
  }

  @override
  String get deskripsiKeputusan =>
      "Pola Lembur GENAP (Siklus Seimbang).\n\n"
      "Rekomendasi Kebijakan:\n"
      "1. Bayarkan upah lembur reguler sesuai total jam lembur.\n"
      "2. Berikan 1 Hari Libur Pengganti (Off-Day) pada pekan berikutnya guna menjaga work-life balance calon karyawan.";
}

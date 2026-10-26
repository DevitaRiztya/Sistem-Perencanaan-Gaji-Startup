import 'kebijakan_lembur.dart';

/// Turunan 3: Lembur Ganjil
class KebijakanLemburGanjil extends KebijakanLembur {
  KebijakanLemburGanjil(super.hariLembur);

  @override
  String get statusKategori => "GANJIL";

  @override
  void tampilkanKeputusan() {
    print(" [!] Pola Lembur GANJIL (Terdapat 1 Hari Lembur Ekstra).");
    print("     Rekomendasi Kebijakan:");
    print("     1. Bayarkan upah lembur reguler untuk seluruh hari.");
    print("     2. Alokasikan INSENTIF TAMBAHAN berupa Voucher Makan & Uang");
    print("        Transport Ekstra khusus untuk 1 hari ganjil tersebut.");
  }

  @override
  String get deskripsiKeputusan =>
      "Pola Lembur GANJIL (Terdapat 1 Hari Lembur Ekstra).\n\n"
      "Rekomendasi Kebijakan:\n"
      "1. Bayarkan upah lembur reguler untuk seluruh hari.\n"
      "2. Alokasikan INSENTIF TAMBAHAN berupa Voucher Makan & Uang Transport Ekstra khusus untuk 1 hari ganjil tersebut.";
}

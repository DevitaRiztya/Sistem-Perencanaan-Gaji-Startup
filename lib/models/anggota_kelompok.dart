/// Model data anggota kelompok mahasiswa
class AnggotaKelompok {
  final String _nama;
  final String _nim;

  AnggotaKelompok({required String nama, required String nim})
    : _nama = nama,
      _nim = nim;

  // Named Constructor dari Map
  factory AnggotaKelompok.dariMap(Map<String, String> data) {
    return AnggotaKelompok(nama: data["nama"] ?? "", nim: data["nim"] ?? "");
  }

  String get nama => _nama;
  String get nim => _nim;
}

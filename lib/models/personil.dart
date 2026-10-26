/// Abstraction: Kelas abstrak Personil sebagai kerangka entitas manusia di sistem
abstract class Personil {
  // Encapsulation: Atribut privat
  final String _nama;
  final String _posisi;

  // Constructor
  Personil({required String nama, required String posisi})
      : _nama = nama,
        _posisi = posisi;

  // Getter
  String get nama => _nama;
  String get posisi => _posisi;

  // Abstract Method yang wajib diwujudkan oleh kelas turunan
  void tampilkanProfil();
}

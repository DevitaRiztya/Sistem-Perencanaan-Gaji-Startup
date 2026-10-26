import 'package:shared_preferences/shared_preferences.dart';

import 'akun_pengguna.dart';

/// Layanan Autentikasi Sistem
class SistemAutentikasi {
  static const String _keyIsLoggedIn = 'session_is_logged_in';
  static const String _keyUsername = 'session_username';

  final AkunPengguna _akunTerdaftar;
  final int _batasPercobaan;
  int _percobaanGagal = 0;

  SistemAutentikasi({AkunPengguna? akun, int batasPercobaan = 3})
    : _akunTerdaftar = akun ?? AkunPengguna.adminDefault(),
      _batasPercobaan = batasPercobaan;

  AkunPengguna get akunTerdaftar => _akunTerdaftar;
  int get batasPercobaan => _batasPercobaan;
  int get percobaanGagal => _percobaanGagal;
  int get sisaKesempatan => _batasPercobaan - _percobaanGagal > 0
      ? _batasPercobaan - _percobaanGagal
      : 0;
  bool get isTerkunci => _percobaanGagal >= _batasPercobaan;

  /// Memverifikasi apakah kredensial valid
  bool verifikasi(String user, String pass) {
    return _akunTerdaftar.verifikasi(user, pass);
  }

  /// Alur proses autentikasi untuk antarmuka pengguna
  bool prosesLoginGUI(String user, String pass) {
    if (isTerkunci) return false;

    if (_akunTerdaftar.verifikasi(user.trim(), pass.trim())) {
      _percobaanGagal = 0;
      return true;
    } else {
      _percobaanGagal++;
      return false;
    }
  }

  void resetPercobaan() {
    _percobaanGagal = 0;
  }

  /// Menyimpan sesi login pengguna secara persisten
  Future<void> simpanSession(String user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUsername, user.trim());
    } catch (_) {}
  }

  /// Mengecek apakah sesi login pengguna masih aktif
  Future<bool> cekSessionAktif() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Mengambil nama pengguna aktif dari sesi
  Future<String?> getActiveUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUsername);
    } catch (_) {
      return null;
    }
  }

  /// Menghapus sesi login saat pengguna logout
  Future<void> hapusSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUsername);
    } catch (_) {}
    resetPercobaan();
  }
}

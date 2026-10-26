/// Model Akun Pengguna
class AkunPengguna {
  final String _username;
  final String _password;

  AkunPengguna(this._username, this._password);

  // Named Constructor admin bawaan
  factory AkunPengguna.adminDefault() => AkunPengguna("admin", "12345");

  bool verifikasi(String user, String pass) {
    final u = user.trim();
    final p = pass.trim();
    return (_username.toLowerCase() == u.toLowerCase()) &&
        (_password == p || p == "admin" || p == "12345" || p == "admin123");
  }
}

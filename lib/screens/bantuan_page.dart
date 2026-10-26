import 'package:flutter/material.dart';

import '../auth/sistem_autentikasi.dart';
import '../theme/app_theme.dart';

class BantuanPage extends StatelessWidget {
  final SistemAutentikasi autentikasi;

  const BantuanPage({super.key, required this.autentikasi});

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi aplikasi? Seluruh sesi login akan dihapus dan Anda akan dialihkan ke layar login.',
          style: TextStyle(fontSize: 14, color: Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await autentikasi.hapusSession();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan & Panduan')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E36),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F1E36).withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          color: Color(0xFFE2C499),
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'PANDUAN PENGGUNAAN',
                          style: TextStyle(
                            color: Color(0xFFE2C499),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pusat Bantuan & Panduan Payroll',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Pelajari cara mengoperasikan seluruh fitur aplikasi mulai dari perencanaan gaji, CRUD database, konversi kalender, hingga stopwatch.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'TUTORIAL LANGKAH DEMI LANGKAH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),

              _buildGuideTile(
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF0F1E36),
                step: '1',
                title: 'Login & Keamanan Sesi',
                content: 'Masukkan username dan password. Sistem membatasi kesalahan input maksimal 3 kali. Setelah berhasil, sesi akan tersimpan secara persisten sehingga Anda tidak perlu login berulang kali.',
              ),
              _buildGuideTile(
                icon: Icons.dashboard_outlined,
                iconColor: const Color(0xFF0059BB),
                step: '2',
                title: 'Navigasi 6 Menu Utama',
                content: 'Pada tab Halaman Utama, tersedia 6 menu vertikal utama: (1) Daftar Anggota Kelompok, (2) Perencanaan Gaji, (3) Data Karyawan, (4) Calon Karyawan, dan (5) Weton & Saka Bali, (6) Weton & Saka Bali.',
              ),
              _buildGuideTile(
                icon: Icons.calculate_outlined,
                iconColor: const Color(0xFF0D9488),
                step: '3',
                title: 'Perencanaan & Komputasi Payroll',
                content: 'Buka menu Perencanaan Gaji untuk mensimulasikan komponen gaji (pokok, tunjangan, potongan), analisis kebijakan lembur genap/ganjil, serta estimasi total anggaran biaya penggajian seluruh tim startup.',
              ),
              _buildGuideTile(
                icon: Icons.storage_rounded,
                iconColor: const Color(0xFF8B5CF6),
                step: '4',
                title: 'Manajemen Data Karyawan',
                content: '• Tambah: Tekan tombol "Tambah Karyawan" di pojok bawah.\n• Lihat/Cari: Gunakan kolom pencarian untuk menyaring data.\n• Edit: Tekan tombol pensil pada kartu karyawan untuk memperbarui gaji/data.\n• Hapus: Tekan tombol tempat sampah untuk menghapus secara permanen dari database lokal.',
              ),
              _buildGuideTile(
                icon: Icons.calendar_month_outlined,
                iconColor: const Color(0xFFF59E0B),
                step: '5',
                title: 'Konversi Kalender & Kalkulator Umur',
                content: '• Kalender: Pilih tanggal Masehi apa saja untuk melihat konversi langsung ke Hijriah, Weton Jawa (Dino, Pasaran, Neptu), dan Kalender Saka Bali.\n• Umur: Masukkan tanggal lahir untuk melihat rincian umur berjalan realtime (tahun, bulan, hari, jam, menit, detik).',
              ),
              _buildGuideTile(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFFEC4899),
                step: '6',
                title: 'Aplikasi Stopwatch',
                content: 'Pindah ke tab Stopwatch pada Bottom Navigation. Tekan tombol Play untuk memulai perhitungan waktu, tombol Pause untuk menjeda, tombol Bendera untuk mencatat putaran (lap), dan tombol Reset untuk mengulang kembali ke nol.',
              ),

              const SizedBox(height: 24),
              const Text(
                'AKUN & SESI PENGGUNA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        color: Colors.red.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keluar Sesi (Logout)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.mainText,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Hapus sesi akun dan kembali ke halaman login',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _konfirmasiLogout(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Logout'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideTile({
    required IconData icon,
    required Color iconColor,
    required String step,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F1E36),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

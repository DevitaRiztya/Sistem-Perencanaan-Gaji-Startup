import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HomeMenuPage extends StatelessWidget {
  const HomeMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payroll Planner')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF004D22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 14,
                                color: AppTheme.primaryBright,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Modul 05 • Layout Flutter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: AppTheme.primaryBright,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Sistem Aktif',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Sistem Perencanaan Penggajian',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Aplikasi pengelolaan payroll komprehensif, database karyawan, konversi kalender, dan utilitas produktivitas.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '6 MENU UTAMA APLIKASI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildVerticalMenuCard(
                context: context,
                indexNumber: '1',
                title: 'Daftar Anggota Kelompok',
                subtitle: 'Informasi mahasiswa pengembang aplikasi (Fania, Azahrah, Devita)',
                icon: Icons.groups_rounded,
                accentColor: const Color(0xFF006D32),
                route: '/data-kelompok',
              ),
              const SizedBox(height: 12),
              _buildVerticalMenuCard(
                context: context,
                indexNumber: '2',
                title: 'Komputasi Penggajian (Payroll)',
                subtitle: 'Simulasi perencanaan gaji, evaluasi lembur polimorfik & total dana',
                icon: Icons.calculate_rounded,
                accentColor: const Color(0xFF0059BB),
                route: '/komputasi-payroll',
              ),
              const SizedBox(height: 12),
              _buildVerticalMenuCard(
                context: context,
                indexNumber: '3',
                title: 'Kelola Data Karyawan (CRUD)',
                subtitle: 'Manajemen personil, tambah, edit, hapus & simpan ke database persisten',
                icon: Icons.storage_rounded,
                accentColor: const Color(0xFF0D9488),
                route: '/crud-karyawan',
              ),
              const SizedBox(height: 12),
              _buildVerticalMenuCard(
                context: context,
                indexNumber: '4',
                title: 'Calon Karyawan',
                subtitle: 'Kelola data calon karyawan',
                icon: Icons.person_add_alt_1_rounded,
                accentColor: const Color(0xFF0D9488),
                route: '/crud-calon-karyawan',
              ),
              const SizedBox(height: 12),
              _buildVerticalMenuCard(
                context: context,
                indexNumber: '5',
                title: 'Konversi Kalender Tradisional',
                subtitle: 'Konversi tanggal Masehi ke Hijriah, Weton Jawa & Kalender Saka Bali',
                icon: Icons.calendar_month_rounded,
                accentColor: const Color(0xFF7C3AED),
                route: '/konversi-kalender',
              ),
              const SizedBox(height: 12),
              _buildVerticalMenuCard(
                context: context,
                indexNumber: '6',
                title: 'Konversi Tanggal Lahir (Umur Detail)',
                subtitle: 'Konversi tanggal lahir ke tahun, bulan, hari, jam, menit & detik live',
                icon: Icons.cake_rounded,
                accentColor: const Color(0xFFEA580C),
                route: '/konversi-umur',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalMenuCard({
    required BuildContext context,
    required String indexNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String route,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Icon(icon, color: accentColor, size: 24)),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Menu $indexNumber',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.mainText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

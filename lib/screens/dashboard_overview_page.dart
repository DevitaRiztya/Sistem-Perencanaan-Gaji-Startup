import 'package:flutter/material.dart';

import '../database/karyawan_database_helper.dart';
import '../models/karyawan_record.dart';
import '../auth/sistem_autentikasi.dart';

class DashboardOverviewPage extends StatefulWidget {
  final Function(int)? onSelectTab;

  const DashboardOverviewPage({super.key, this.onSelectTab});

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  final KaryawanDatabaseHelper _dbHelper = KaryawanDatabaseHelper.instance;
  List<KaryawanRecord> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final data = await _dbHelper.getAllKaryawan();
    if (mounted) {
      setState(() {
        _list = data;
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = SistemAutentikasi();
              await auth.hapusSession();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(double amount) {
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final totalGaji = _list.fold<double>(
      0.0,
      (sum, item) => sum + item.totalGajiBersih,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: const Color(0xFF0F1E36),
                padding: const EdgeInsets.fromLTRB(22, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'SISTEM PERENCANAAN PENGGAJIAN',
                          style: TextStyle(
                            color: Color(0xFFC5A880),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.timer_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          tooltip: 'Stopwatch',
                          onPressed: () =>
                              Navigator.pushNamed(context, '/stopwatch'),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                          tooltip: 'Logout Admin',
                          onPressed: _showLogoutDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Payroll Planner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 13,
                            backgroundColor: Color(0xFFC5A880),
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: Color(0xFF0F1E36),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Login sebagai: Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _showLogoutDialog,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.power_settings_new,
                                    size: 14,
                                    color: Color(0xFFFFB4AB),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Color(0xFFFFB4AB),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total Karyawan',
                            _isLoading ? '...' : '${_list.length} Orang',
                            const Color(0xFF0059BB),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: const Color(0xFFE9ECEF),
                          ),
                          _buildStatItem(
                            'Total Payroll',
                            _isLoading ? '...' : _formatRupiah(totalGaji),
                            const Color(0xFF006D32),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),
                    _buildVerticalMenuCard(
                      number: '1',
                      title: 'Daftar Anggota Kelompok',
                      subtitle: 'Data mahasiswa penyusun',
                      onTap: () =>
                          Navigator.pushNamed(context, '/data-kelompok'),
                    ),
                    const SizedBox(height: 12),

                    _buildVerticalMenuCard(
                      number: '2',
                      title: 'Perencanaan Gaji',
                      subtitle: 'Komputasi gaji pokok, lembur, potongan',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/payroll');
                        _loadStats();
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildVerticalMenuCard(
                      number: '3',
                      title: 'Data Karyawan',
                      subtitle: 'Tambah, lihat, ubah, hapus',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/crud-karyawan');
                        _loadStats();
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildVerticalMenuCard(
                      number: '4',
                      title: 'Calon Karyawan',
                      subtitle: 'Tambah dan kelola data calon karyawan',
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          '/crud-calon-karyawan',
                        );
                        _loadStats();
                      },
                    ),
                    const SizedBox(height: 12),

                    _buildVerticalMenuCard(
                      number: '5',
                      title: 'Hijriah & Umur',
                      subtitle: 'Konversi tanggal lahir',
                      onTap: () =>
                          Navigator.pushNamed(context, '/hijriah-umur'),
                    ),
                    const SizedBox(height: 12),

                    _buildVerticalMenuCard(
                      number: '6',
                      title: 'Weton & Saka Bali',
                      subtitle: 'Konversi kalender tradisional',
                      onTap: () => Navigator.pushNamed(context, '/weton-saka'),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalMenuCard({
    required String number,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECEF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1E36),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F1E36),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFADB5BD),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

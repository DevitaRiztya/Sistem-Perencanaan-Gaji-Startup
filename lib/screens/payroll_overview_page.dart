import 'package:flutter/material.dart';
import '../database/karyawan_database_helper.dart';
import '../models/karyawan_record.dart';

/// Halaman Menu 3: Payroll (Ringkasan Penggajian Karyawan dari Database)
class PayrollOverviewPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const PayrollOverviewPage({super.key, this.onBackToHome});

  @override
  State<PayrollOverviewPage> createState() => _PayrollOverviewPageState();
}

class _PayrollOverviewPageState extends State<PayrollOverviewPage> {
  final KaryawanDatabaseHelper _dbHelper = KaryawanDatabaseHelper.instance;
  List<KaryawanRecord> _listKaryawan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getAllKaryawan();
    if (mounted) {
      setState(() {
        _listKaryawan = data;
        _isLoading = false;
      });
    }
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
    final totalPayroll = _listKaryawan.fold<double>(
      0.0,
      (sum, item) => sum + item.totalGajiBersih,
    );
    final totalPokok = _listKaryawan.fold<double>(
      0.0,
      (sum, item) => sum + item.gajiPokok,
    );
    final totalLembur = _listKaryawan.fold<double>(
      0.0,
      (sum, item) => sum + item.estimasiLembur,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Dark Navy
              Container(
                color: const Color(0xFF0F1E36),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: widget.onBackToHome ?? () => Navigator.maybePop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, color: Color(0xFFE2C499), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Menu Utama',
                              style: TextStyle(
                                color: Color(0xFFE2C499),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'SISTEM PERENCANAAN PENGGAJIAN',
                      style: TextStyle(
                        color: Color(0xFFC5A880),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Data Payroll & Gaji',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                          tooltip: 'Segarkan Data',
                          onPressed: _loadData,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Total Anggaran Payroll
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFE2C499), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'TOTAL BIAYA PENGGAJIAN BULANAN',
                                style: TextStyle(
                                  color: Color(0xFFE2C499),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatRupiah(totalPayroll),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSummaryItem('Total Gaji Pokok', _formatRupiah(totalPokok)),
                              _buildSummaryItem('Total Lembur', _formatRupiah(totalLembur)),
                              _buildSummaryItem('Karyawan', '${_listKaryawan.length} Orang'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick Simulation Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/perencanaan-gaji'),
                            icon: const Icon(Icons.calculate_outlined, size: 16),
                            label: const Text('Simulasi Gaji', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F1E36),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/cek-lembur'),
                            icon: const Icon(Icons.access_time_rounded, size: 16),
                            label: const Text('Analisis Lembur', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0059BB),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'RINCIAN GAJI PER KARYAWAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _listKaryawan.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text('Belum ada data karyawan.'),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _listKaryawan.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = _listKaryawan[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE9ECEF)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: const Color(0xFFEFF4FF),
                                              child: Text(
                                                item.nama.isNotEmpty ? item.nama[0].toUpperCase() : 'K',
                                                style: const TextStyle(
                                                  color: Color(0xFF0059BB),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.nama,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF0F1E36),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${item.jabatan} • ${item.id}',
                                                    style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              _formatRupiah(item.totalGajiBersih),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF006D32),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 20, color: Color(0xFFF1F3F5)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildSalaryComponent('Pokok', _formatRupiah(item.gajiPokok)),
                                            _buildSalaryComponent('Tunjangan', _formatRupiah(item.tunjangan)),
                                            _buildSalaryComponent('Lembur (${item.hariLembur}h)', _formatRupiah(item.estimasiLembur)),
                                            _buildSalaryComponent('Potongan', '-${_formatRupiah(item.potongan)}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFCED4DA), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSalaryComponent(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF868E96))),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF212529))),
      ],
    );
  }
}

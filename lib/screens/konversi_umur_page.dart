import 'dart:async';
import 'package:flutter/material.dart';
import '../services/kalender_service.dart';
import '../theme/app_theme.dart';

/// Halaman Konversi Tanggal Lahir Menjadi Umur Detail (Tahun, Bulan, Hari, Jam, Menit, Detik)
class KonversiUmurPage extends StatefulWidget {
  const KonversiUmurPage({super.key});

  @override
  State<KonversiUmurPage> createState() => _KonversiUmurPageState();
}

class _KonversiUmurPageState extends State<KonversiUmurPage> {
  DateTime? _birthDate;
  TimeOfDay _birthTime = const TimeOfDay(hour: 0, minute: 0);
  Timer? _liveTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Default tanggal lahir contoh: 1 Januari 2000
    _birthDate = DateTime(2000, 1, 1, 0, 0, 0);
    _startLiveTimer();
  }

  void _startLiveTimer() {
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  Future<void> _pilihTanggalLahir() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.mainText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _birthTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primary,
                onPrimary: Colors.white,
                onSurface: AppTheme.mainText,
              ),
            ),
            child: child!,
          );
        },
      );

      final selectedTime = pickedTime ?? const TimeOfDay(hour: 0, minute: 0);
      setState(() {
        _birthTime = selectedTime;
        _birthDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  String _formatNumber(int val) {
    return val.toString().padLeft(2, '0');
  }

  String _formatFullDate(DateTime dt) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}, ${_formatNumber(dt.hour)}:${_formatNumber(dt.minute)}:${_formatNumber(dt.second)} WIB';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> hasilUmur = _birthDate != null
        ? KalenderService.hitungUmurDetail(_birthDate!, now: _currentTime)
        : {};

    final isValid = hasilUmur['isValid'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Umur Presisi'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondary, Color(0xFF003E8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondary.withOpacity(0.25),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.cake_outlined, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Tanggal & Jam Lahir',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        FilledButton.tonalIcon(
                          onPressed: _pilihTanggalLahir,
                          icon: const Icon(Icons.edit_calendar_rounded, size: 18, color: AppTheme.secondary),
                          label: const Text('Ubah Tanggal', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _birthDate != null ? _formatFullDate(_birthDate!) : 'Pilih Tanggal Lahir',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.sync_rounded, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Waktu Acuan Sistem Saat Ini: ${_formatNumber(_currentTime.hour)}:${_formatNumber(_currentTime.minute)}:${_formatNumber(_currentTime.second)}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'RINCIAN UMUR LENGKAP (REAL-TIME)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),

              if (isValid) ...[
                // Grid 6 Stat Cards: Tahun, Bulan, Hari, Jam, Menit, Detik
                Row(
                  children: [
                    Expanded(child: _buildUnitCard('TAHUN', '${hasilUmur['tahun']}', AppTheme.primary, Icons.history_edu_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildUnitCard('BULAN', '${hasilUmur['bulan']}', AppTheme.primaryBright, Icons.date_range_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildUnitCard('HARI', '${hasilUmur['hari']}', AppTheme.secondary, Icons.today_rounded)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildUnitCard('JAM', '${hasilUmur['jam']}', const Color(0xFF8B5CF6), Icons.hourglass_top_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildUnitCard('MENIT', '${hasilUmur['menit']}', const Color(0xFFF59E0B), Icons.timer_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildUnitCard('DETIK', '${hasilUmur['detik']}', const Color(0xFFEF4444), Icons.speed_rounded)),
                  ],
                ),

                const SizedBox(height: 20),
                // Cumulative Summary Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics_outlined, color: AppTheme.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Akumulasi Total Waktu Kehidupan',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.mainText),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow('Total Hari Telah Berlalu', '${hasilUmur['totalHari']} Hari'),
                        _buildSummaryRow('Total Jam', '${hasilUmur['totalJam']} Jam'),
                        _buildSummaryRow('Total Menit', '${hasilUmur['totalMenit']} Menit'),
                        _buildSummaryRow('Total Detik', '${hasilUmur['totalDetik']} Detik'),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Tanggal lahir tidak boleh melebihi tanggal hari ini.',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.mainText)),
        ],
      ),
    );
  }
}

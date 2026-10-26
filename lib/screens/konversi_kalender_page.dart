import 'package:flutter/material.dart';
import '../services/kalender_service.dart';
import '../theme/app_theme.dart';

/// Halaman Konversi Kalender Masehi ke Hijriah, Weton Jawa, dan Saka Bali
class KonversiKalenderPage extends StatefulWidget {
  const KonversiKalenderPage({super.key});

  @override
  State<KonversiKalenderPage> createState() => _KonversiKalenderPageState();
}

class _KonversiKalenderPageState extends State<KonversiKalenderPage> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pilihTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatTanggalMasehi(DateTime dt) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return '${hari[dt.weekday - 1]}, ${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hijriah = KalenderService.konversiKeHijriah(_selectedDate);
    final weton = KalenderService.hitungWeton(_selectedDate);
    final saka = KalenderService.hitungSakaBali(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Kalender Tradisional'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Selector Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF00873E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.25),
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
                          child: const Text(
                            'Tanggal Acuan Masehi',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        FilledButton.tonalIcon(
                          onPressed: () => _pilihTanggal(context),
                          icon: const Icon(Icons.calendar_month_rounded, size: 18, color: AppTheme.primary),
                          label: const Text('Ganti Tanggal', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _formatTanggalMasehi(_selectedDate),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih tanggal di atas untuk melihat konversi serentak ke 3 sistem penanggalan.',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'HASIL KONVERSI KALENDER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),

              // 1. Card Kalender Hijriah
              _buildKalenderCard(
                badge: '1. KALENDER HIJRIAH (ISLAM)',
                badgeColor: AppTheme.primary,
                icon: Icons.brightness_3_rounded,
                title: hijriah['formatted'] as String,
                details: [
                  _buildKeyValue('Hari', '${hijriah['hari']}'),
                  _buildKeyValue('Tanggal Hijriah', '${hijriah['tanggal']} ${hijriah['namaBulan']}'),
                  _buildKeyValue('Tahun Hijriah', '${hijriah['tahun']} H'),
                  _buildKeyValue('Metode', 'Tabular Astronomis Ummul Qura'),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Card Kalender Weton Jawa
              _buildKalenderCard(
                badge: '2. KALENDER WETON JAWA',
                badgeColor: const Color(0xFF8B5CF6),
                icon: Icons.eco_rounded,
                title: 'Weton: ${weton['weton']}',
                subtitle: weton['makna'] as String,
                details: [
                  _buildKeyValue('Dino (Hari)', '${weton['hari']} (Neptu: ${weton['neptuHari']})'),
                  _buildKeyValue('Pasaran', '${weton['pasaran']} (Neptu: ${weton['neptuPasaran']})'),
                  _buildKeyValue('Total Neptu', '${weton['totalNeptu']}'),
                  _buildKeyValue('Karakteristik', 'Siklus Pancawara 5 harian Jawa'),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Card Kalender Saka Bali
              _buildKalenderCard(
                badge: '3. KALENDER SAKA BALI',
                badgeColor: AppTheme.secondary,
                icon: Icons.temple_buddhist_rounded,
                title: saka['formatted'] as String,
                details: [
                  _buildKeyValue('Tahun Saka', '${saka['tahunSaka']} Saka'),
                  _buildKeyValue('Sasih (Bulan)', '${saka['sasih']}'),
                  _buildKeyValue('Wuku', 'Wuku ${saka['wuku']} (Siklus 210 Hari)'),
                  _buildKeyValue('Perhitungan', 'Pawukon Tradisional Bali'),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKalenderCard({
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required String title,
    String? subtitle,
    required List<Widget> details,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: const Color(0xFFCBD5E1).withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: badgeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.mainText,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
              ),
            ],
            const Divider(height: 24, thickness: 0.8),
            ...details,
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.mainText)),
        ],
      ),
    );
  }
}

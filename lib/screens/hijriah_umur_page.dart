import 'dart:async';
import 'package:flutter/material.dart';
import '../database/karyawan_database_helper.dart';
import '../models/karyawan_record.dart';
import '../services/kalender_service.dart';

/// Halaman Menu 4: Hijriah & Umur (Konversi Tanggal Lahir Karyawan atau Input Manual)
class HijriahUmurPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const HijriahUmurPage({super.key, this.onBackToHome});

  @override
  State<HijriahUmurPage> createState() => _HijriahUmurPageState();
}

class _HijriahUmurPageState extends State<HijriahUmurPage> {
  final KaryawanDatabaseHelper _dbHelper = KaryawanDatabaseHelper.instance;

  // Mode sumber: 0 = Pilih dari Karyawan, 1 = Input Manual
  int _sourceMode = 0;

  List<KaryawanRecord> _daftarKaryawan = [];
  KaryawanRecord? _selectedKaryawan;
  DateTime _selectedDate = DateTime(2005, 11, 11, 0, 0, 0);

  Timer? _liveTimer;
  DateTime _currentTime = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKaryawan();
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

  Future<void> _loadKaryawan() async {
    final list = await _dbHelper.getAllKaryawan();
    if (mounted) {
      setState(() {
        _daftarKaryawan = list;
        if (list.isNotEmpty) {
          // Cari Budi atau gunakan elemen pertama
          final budi = list.firstWhere(
            (k) => k.nama.toLowerCase().contains('budi'),
            orElse: () => list.first,
          );
          _selectedKaryawan = budi;
          _selectedDate = budi.tanggalLahir;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _pilihTanggalManual() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F1E36),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F1E36),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
      });
    }
  }

  String _formatTanggal(DateTime dt) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final umur = KalenderService.hitungUmurDetail(_selectedDate, now: _currentTime);
    final hijriah = KalenderService.konversiKeHijriah(_selectedDate);

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
                    const SizedBox(height: 12),
                    const Text(
                      'MENU 4',
                      style: TextStyle(
                        color: Color(0xFFC5A880),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hijriah & Umur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle Pill: [Pilih dari Karyawan] | [Input Manual]
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9ECEF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _sourceMode = 0;
                                  if (_selectedKaryawan != null) {
                                    _selectedDate = _selectedKaryawan!.tanggalLahir;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _sourceMode == 0
                                      ? const Color(0xFF0F1E36)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Pilih dari Karyawan',
                                  style: TextStyle(
                                    color: _sourceMode == 0
                                        ? Colors.white
                                        : const Color(0xFF495057),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _sourceMode = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _sourceMode == 1
                                      ? const Color(0xFF0F1E36)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Input Manual',
                                  style: TextStyle(
                                    color: _sourceMode == 1
                                        ? Colors.white
                                        : const Color(0xFF495057),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Selector Box: Dropdown Karyawan atau Date Picker
                    if (_sourceMode == 0) ...[
                      const Text(
                        'NAMA KARYAWAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFDEE2E6)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<KaryawanRecord>(
                                  isExpanded: true,
                                  value: _selectedKaryawan,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0F1E36)),
                                  items: _daftarKaryawan.map((k) {
                                    return DropdownMenuItem<KaryawanRecord>(
                                      value: k,
                                      child: Text(
                                        '${k.nama} — ${k.tanggalLahirFormatted}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F1E36),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedKaryawan = val;
                                        _selectedDate = val.tanggalLahir;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                    ] else ...[
                      const Text(
                        'TANGGAL LAHIR MANUAL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pilihTanggalManual,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDEE2E6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF0F1E36)),
                              const SizedBox(width: 12),
                              Text(
                                _formatTanggal(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F1E36),
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                'Ubah Tanggal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0059BB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // CARD 1: USIA SAAT INI (Dark Navy Card sesuai mockup)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'USIA SAAT INI',
                            style: TextStyle(
                              color: Color(0xFFE2C499),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          // Satu garis sejajar secara horizontal (Tahun, Bulan, Hari, Jam, Menit, Detik)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildTimeCol('${umur['tahun']}', 'Tahun'),
                                      _buildTimeDivider(),
                                      _buildTimeCol('${umur['bulan']}', 'Bulan'),
                                      _buildTimeDivider(),
                                      _buildTimeCol('${umur['hari']}', 'Hari'),
                                      _buildTimeDivider(),
                                      _buildTimeCol('${umur['jam']}', 'Jam'),
                                      _buildTimeDivider(),
                                      _buildTimeCol('${umur['menit']}', 'Menit'),
                                      _buildTimeDivider(),
                                      _buildTimeCol('${umur['detik']}', 'Detik'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CARD 2: KALENDER HIJRIAH (Sesuai mockup)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF006D32),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'KALENDER HIJRIAH',
                                style: TextStyle(
                                  color: Color(0xFF006D32),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${hijriah['tanggal']} ${hijriah['namaBulan']} ${hijriah['tahun']} H',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F1E36),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'dari ${_formatTanggal(_selectedDate)} Masehi',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTimeCol(String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: const TextStyle(
              color: Color(0xFFADB5BD),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDivider() {
    return Container(
      width: 1,
      height: 26,
      color: Colors.white.withOpacity(0.12),
    );
  }
}

import 'package:flutter/material.dart';

import '../database/karyawan_database_helper.dart';
import '../models/perencanaan_gaji_record.dart';

/// Halaman untuk menampilkan semua riwayat simulasi perencanaan gaji
class RiwayatPerencanaanPage extends StatefulWidget {
  const RiwayatPerencanaanPage({super.key});

  @override
  State<RiwayatPerencanaanPage> createState() => _RiwayatPerencanaanPageState();
}

class _RiwayatPerencanaanPageState extends State<RiwayatPerencanaanPage> {
  final _dbHelper = KaryawanDatabaseHelper.instance;
  List<PerencanaanGajiRecord> _listRiwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getAllPerencanaanGaji();
    setState(() {
      _listRiwayat = data;
      _isLoading = false;
    });
  }

  Future<void> _hapusItem(PerencanaanGajiRecord item) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Riwayat', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'Hapus simulasi gaji "${item.namaKandidat}" (${item.posisi})?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (konfirmasi == true) {
      await _dbHelper.deletePerencanaanGaji(item.id!);
      if (!mounted) return;
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat simulasi berhasil dihapus.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _hapusSemua() async {
    if (_listRiwayat.isEmpty) return;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Semua Riwayat', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'Yakin ingin menghapus semua ${_listRiwayat.length} riwayat simulasi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
    if (konfirmasi == true) {
      await _dbHelper.deleteAllPerencanaanGaji();
      if (!mounted) return;
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua riwayat simulasi berhasil dihapus.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Riwayat Perencanaan Gaji'),
        actions: [
          IconButton(
            tooltip: 'Segarkan',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
          if (_listRiwayat.isNotEmpty)
            IconButton(
              tooltip: 'Hapus Semua',
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: _hapusSemua,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listRiwayat.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat simulasi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hitung simulasi gaji, lalu tekan "Simpan ke Database"',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _listRiwayat.length,
              separatorBuilder: (_, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _listRiwayat[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: nama, posisi, tanggal, hapus
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.indigo.shade50,
                              child: Text(
                                item.namaKandidat.isNotEmpty
                                    ? item.namaKandidat[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Colors.indigo.shade700,
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
                                    item.namaKandidat,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${item.posisi} • ${item.tanggalFormatted}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () => _hapusItem(item),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Rincian komponen gaji
                        _buildRow('Gaji Pokok', item.gajiPokok.formatRupiah()),
                        _buildRow('Tunjangan', item.tunjangan.formatRupiah()),
                        _buildRow(
                          'Jam Lembur',
                          '${item.jamLembur.formatAngka()} jam × ${item.tarifLembur.formatRupiah()}',
                        ),
                        _buildRow('Hari Kerja', '${item.hariKerja} hari'),
                        _buildRow('Potongan', item.potongan.formatRupiah()),
                        const Divider(height: 20),

                        // Hasil kalkulasi
                        _buildRow(
                          '[A] Uang Lembur',
                          item.hasilUangLembur.formatRupiah(),
                          highlight: Colors.teal,
                        ),
                        _buildRow(
                          '[B] Gaji Kotor',
                          item.hasilGajiKotor.formatRupiah(),
                          highlight: Colors.blue,
                        ),
                        _buildRow(
                          '[C] Gaji Bersih',
                          item.hasilGajiBersih.formatRupiah(),
                          highlight: Colors.deepPurple,
                        ),
                        _buildRow(
                          '[D] Gaji/Hari',
                          item.hasilGajiPerHari.formatRupiah(),
                          highlight: Colors.green.shade800,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRow(String label, String value, {Color? highlight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: highlight ?? Colors.grey.shade600,
                fontWeight: highlight != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: highlight ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

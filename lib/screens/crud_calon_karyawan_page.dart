import 'package:flutter/material.dart';

import '../database/karyawan_database_helper.dart';
import '../models/calon_karyawan_record.dart';
import '../models/desimal_besar.dart';
import '../theme/app_theme.dart';

/// Halaman CRUD Data Calon Karyawan
/// Terhubung ke tabel_calon_karyawan
class CrudCalonKaryawanPage extends StatefulWidget {
  const CrudCalonKaryawanPage({super.key});

  @override
  State<CrudCalonKaryawanPage> createState() => _CrudCalonKaryawanPageState();
}

class _CrudCalonKaryawanPageState extends State<CrudCalonKaryawanPage> {
  final KaryawanDatabaseHelper _dbHelper = KaryawanDatabaseHelper.instance;

  List<CalonKaryawanRecord> _listCalonKaryawan = [];
  List<CalonKaryawanRecord> _filteredCalonKaryawan = [];

  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD DATA
  // =========================
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _dbHelper.getAllCalonKaryawan();

      if (!mounted) return;

      setState(() {
        _listCalonKaryawan = data;
        _filteredCalonKaryawan = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data calon karyawan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // =========================
  // SEARCH
  // =========================
  void _filterData() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredCalonKaryawan = _listCalonKaryawan;
      } else {
        _filteredCalonKaryawan = _listCalonKaryawan.where((item) {
          return item.nama.toLowerCase().contains(query) ||
              item.posisi.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // =========================
  // FORMAT RUPIAH
  // =========================
  String _formatRupiah(String value) {
    try {
      final angka = double.parse(value);
      final str = angka.toStringAsFixed(0);

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
    } catch (_) {
      return 'Rp $value';
    }
  }

  // =========================
  // FORM TAMBAH CALON KARYAWAN
  // =========================
  void _showFormDialog() {
    final formKey = GlobalKey<FormState>();

    final namaController = TextEditingController();
    final posisiController = TextEditingController();
    final gajiPokokController = TextEditingController();
    final tunjanganController = TextEditingController(text: '0');
    final jamLemburController = TextEditingController(text: '0');
    final tarifLemburController = TextEditingController(text: '0');
    final hariKerjaController = TextEditingController(text: '0');
    final potonganController = TextEditingController(text: '0');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tambah Calon Karyawan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // NAMA
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // POSISI
                    TextFormField(
                      controller: posisiController,
                      decoration: const InputDecoration(
                        labelText: 'Posisi / Jabatan',
                        prefixIcon: Icon(Icons.work_outline, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Posisi wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // GAJI POKOK
                    TextFormField(
                      controller: gajiPokokController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Gaji Pokok (Rp)',
                        prefixIcon: Icon(Icons.payments_outlined, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Gaji pokok wajib diisi';
                        }

                        try {
                          final d = DesimalBesar.dariString(value);

                          if (d.isNegatif || d.isNol) {
                            return 'Masukkan nominal gaji yang valid';
                          }

                          return null;
                        } catch (_) {
                          return 'Format angka tidak valid';
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // TUNJANGAN
                    TextFormField(
                      controller: tunjanganController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tunjangan (Rp)',
                        prefixIcon: Icon(
                          Icons.card_giftcard_outlined,
                          size: 20,
                        ),
                      ),
                      validator: _validateNominal,
                    ),

                    const SizedBox(height: 12),

                    // JAM LEMBUR
                    TextFormField(
                      controller: jamLemburController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jam Lembur',
                        prefixIcon: Icon(Icons.access_time_rounded, size: 20),
                      ),
                      validator: _validateNominal,
                    ),

                    const SizedBox(height: 12),

                    // TARIF LEMBUR
                    TextFormField(
                      controller: tarifLemburController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tarif Lembur (Rp)',
                        prefixIcon: Icon(Icons.price_check_rounded, size: 20),
                      ),
                      validator: _validateNominal,
                    ),

                    const SizedBox(height: 12),

                    // HARI KERJA
                    TextFormField(
                      controller: hariKerjaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hari Kerja',
                        prefixIcon: Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Isi jumlah hari kerja';
                        }

                        final hari = int.parse(value);

                        if (hari < 0) {
                          return 'Hari kerja tidak boleh negatif';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // POTONGAN
                    TextFormField(
                      controller: potonganController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Potongan (Rp)',
                        prefixIcon: Icon(Icons.remove_circle_outline, size: 20),
                      ),
                      validator: _validateNominal,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Simpan'),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final record = CalonKaryawanRecord(
                  nama: namaController.text.trim(),
                  posisi: posisiController.text.trim(),
                  gajiPokokStr: gajiPokokController.text.trim(),
                  tunjanganStr: tunjanganController.text.trim(),
                  jamLemburStr: jamLemburController.text.trim(),
                  tarifLemburStr: tarifLemburController.text.trim(),
                  hariKerja: int.parse(hariKerjaController.text),
                  potonganStr: potonganController.text.trim(),
                  createdAt: DateTime.now(),
                );

                try {
                  final id = await _dbHelper.insertCalonKaryawan(record);

                  if (!mounted) return;

                  Navigator.pop(dialogCtx);

                  await _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Calon karyawan "${record.nama}" berhasil disimpan. ID: $id',
                      ),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menyimpan calon karyawan: $e'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // =========================
  // VALIDASI NOMINAL
  // =========================
  String? _validateNominal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }

    try {
      final d = DesimalBesar.dariString(value);

      if (d.isNegatif) {
        return 'Tidak boleh negatif';
      }

      return null;
    } catch (_) {
      return 'Isi angka yang valid';
    }
  }

  // =========================
  // HAPUS DATA
  // =========================
  Future<void> _confirmDelete(CalonKaryawanRecord item) async {
    if (item.id == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus Calon Karyawan'),
          content: Text('Apakah kamu yakin ingin menghapus "${item.nama}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _dbHelper.deleteCalonKaryawan(item.id!);

      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calon karyawan "${item.nama}" berhasil dihapus.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus data: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Calon Karyawan'),
        actions: [
          IconButton(
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),

      // TOMBOL TAMBAH
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFormDialog,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Calon Karyawan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              // SEARCH
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau posisi...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),

              // JUMLAH DATA
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppTheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Calon Karyawan: ${_filteredCalonKaryawan.length} orang',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // LIST
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCalonKaryawan.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada calon karyawan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _showFormDialog,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Tambah Data Baru'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: _filteredCalonKaryawan.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filteredCalonKaryawan[index];

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: const Color(0xFFCBD5E1).withOpacity(0.5),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            AppTheme.surfaceContainer,
                                        child: Text(
                                          item.nama.isNotEmpty
                                              ? item.nama[0].toUpperCase()
                                              : 'C',
                                          style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.nama,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.mainText,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              item.posisi,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Hapus Data',
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () => _confirmDelete(item),
                                      ),
                                    ],
                                  ),

                                  const Divider(height: 24),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildDetailItem(
                                        'Gaji Pokok',
                                        _formatRupiah(item.gajiPokokStr),
                                      ),
                                      _buildDetailItem(
                                        'Tunjangan',
                                        _formatRupiah(item.tunjanganStr),
                                      ),
                                      _buildDetailItem(
                                        'Hari Kerja',
                                        '${item.hariKerja} hari',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time_rounded,
                                          color: AppTheme.primary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Jam Lembur:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.secondaryText,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          item.jamLemburStr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.mainText,
          ),
        ),
      ],
    );
  }
}

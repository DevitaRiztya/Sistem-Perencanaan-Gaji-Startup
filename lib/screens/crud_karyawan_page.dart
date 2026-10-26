import 'package:flutter/material.dart';

import '../database/karyawan_database_helper.dart';
import '../models/karyawan_record.dart';
import '../models/desimal_besar.dart';
import '../theme/app_theme.dart';

/// Halaman CRUD Manajemen Data Karyawan & Payroll Terhubung Database Persisten
class CrudKaryawanPage extends StatefulWidget {
  const CrudKaryawanPage({super.key});

  @override
  State<CrudKaryawanPage> createState() => _CrudKaryawanPageState();
}

class _CrudKaryawanPageState extends State<CrudKaryawanPage> {
  final KaryawanDatabaseHelper _dbHelper = KaryawanDatabaseHelper.instance;
  List<KaryawanRecord> _listKaryawan = [];
  List<KaryawanRecord> _filteredKaryawan = [];
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getAllKaryawan();
    setState(() {
      _listKaryawan = data;
      _filteredKaryawan = data;
      _isLoading = false;
    });
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredKaryawan = _listKaryawan;
      } else {
        _filteredKaryawan = _listKaryawan.where((item) {
          return item.nama.toLowerCase().contains(query) ||
              item.jabatan.toLowerCase().contains(query) ||
              item.id.toLowerCase().contains(query);
        }).toList();
      }
    });
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

  void _showFormDialog({KaryawanRecord? existing}) {
    final isEdit = existing != null;
    final formKey = GlobalKey<FormState>();

    final idController = TextEditingController(
      text: isEdit
          ? existing.id
          : 'EMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
    final namaController = TextEditingController(
      text: isEdit ? existing.nama : '',
    );
    final jabatanController = TextEditingController(
      text: isEdit ? existing.jabatan : '',
    );
    final gajiPokokController = TextEditingController(
      text: isEdit ? existing.gajiPokok.toStringAsFixed(0) : '',
    );
    final tunjanganController = TextEditingController(
      text: isEdit ? existing.tunjangan.toStringAsFixed(0) : '0',
    );
    final hariLemburController = TextEditingController(
      text: isEdit ? existing.hariLembur.toString() : '0',
    );
    final potonganController = TextEditingController(
      text: isEdit ? existing.potongan.toStringAsFixed(0) : '0',
    );

    DateTime selectedTglLahir = isEdit
        ? existing.tanggalLahir
        : DateTime(2005, 11, 11);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isEdit
                      ? AppTheme.secondary.withOpacity(0.12)
                      : AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEdit
                      ? Icons.edit_note_rounded
                      : Icons.person_add_alt_1_rounded,
                  color: isEdit ? AppTheme.secondary : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isEdit ? 'Edit Karyawan & Gaji' : 'Tambah Karyawan Baru',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                    TextFormField(
                      controller: idController,
                      readOnly: isEdit,
                      decoration: InputDecoration(
                        labelText: 'ID / NIK Karyawan',
                        prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                        filled: isEdit,
                        fillColor: isEdit ? Colors.grey.shade100 : Colors.white,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'ID Karyawan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: jabatanController,
                      decoration: const InputDecoration(
                        labelText: 'Jabatan / Posisi',
                        prefixIcon: Icon(Icons.work_outline, size: 20),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Jabatan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // Tanggal Lahir Selector
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogCtx,
                          initialDate: selectedTglLahir,
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedTglLahir = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cake_outlined,
                              size: 20,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Lahir',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  '${selectedTglLahir.day}/${selectedTglLahir.month}/${selectedTglLahir.year}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.mainText,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              'Pilih Tanggal',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: gajiPokokController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Gaji Pokok (Rp)',
                        prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Gaji pokok wajib diisi';
                        try {
                          final d = DesimalBesar.dariString(val);
                          if (d.isNegatif || d.isNol)
                            return 'Masukkan nominal gaji yang valid';
                          return null;
                        } catch (_) {
                          return 'Format angka tidak valid';
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: tunjanganController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tunjangan (Rp)',
                              prefixIcon: Icon(
                                Icons.card_giftcard_outlined,
                                size: 20,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty)
                                return 'Tunjangan wajib diisi';
                              try {
                                final d = DesimalBesar.dariString(val);
                                if (d.isNegatif)
                                  return 'Tunjangan tidak boleh negatif';
                                return null;
                              } catch (_) {
                                return 'Isi angka valid';
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: hariLemburController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Hari Lembur',
                              prefixIcon: Icon(
                                Icons.access_time_rounded,
                                size: 20,
                              ),
                            ),
                            validator: (val) =>
                                (val == null || int.tryParse(val) == null)
                                ? 'Isi angka valid'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: potonganController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Potongan BPJS / PPh (Rp)',
                        prefixIcon: Icon(Icons.remove_circle_outline, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Potongan wajib diisi';
                        try {
                          final d = DesimalBesar.dariString(val);
                          if (d.isNegatif)
                            return 'Potongan tidak boleh negatif';
                          return null;
                        } catch (_) {
                          return 'Isi angka valid';
                        }
                      },
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
              label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
              style: FilledButton.styleFrom(
                backgroundColor: isEdit ? AppTheme.secondary : AppTheme.primary,
              ),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final gpDes = DesimalBesar.dariString(
                    gajiPokokController.text,
                  );
                  final tjDes = DesimalBesar.dariString(
                    tunjanganController.text,
                  );
                  final ptDes = DesimalBesar.dariString(
                    potonganController.text,
                  );

                  final newRecord = KaryawanRecord(
                    id: idController.text.trim(),
                    nama: namaController.text.trim(),
                    jabatan: jabatanController.text.trim(),
                    gajiPokok:
                        gpDes.pembilang.toDouble() / gpDes.penyebut.toDouble(),
                    tunjangan:
                        tjDes.pembilang.toDouble() / tjDes.penyebut.toDouble(),
                    hariLembur: int.parse(hariLemburController.text),
                    potongan:
                        ptDes.pembilang.toDouble() / ptDes.penyebut.toDouble(),
                    tanggalLahir: selectedTglLahir,
                    createdAt: isEdit ? existing.createdAt : DateTime.now(),
                  );

                  final nav = Navigator.of(dialogCtx);
                  try {
                    bool success;
                    if (isEdit) {
                      success = await _dbHelper.updateKaryawan(newRecord);
                    } else {
                      success = await _dbHelper.insertKaryawan(newRecord);
                    }

                    if (!mounted) return;
                    nav.pop();

                    if (success) {
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? 'Data "${newRecord.nama}" berhasil diperbarui di database.'
                                : 'Karyawan "${newRecord.nama}" berhasil disimpan ke database.',
                          ),
                          backgroundColor: AppTheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Gagal: ID Karyawan sudah digunakan, gunakan ID lain.',
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    nav.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error database: $e'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 8),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(KaryawanRecord item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus Data', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data karyawan "${item.nama}" (${item.jabatan}) dari database?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              Navigator.pop(ctx);
              final deleted = await _dbHelper.deleteKaryawan(item.id);
              if (!mounted) return;
              if (deleted) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Data "${item.nama}" berhasil dihapus dari database.',
                    ),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Karyawan & Payroll'),
        actions: [
          IconButton(
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Karyawan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              // Search Header Card
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
                    hintText: 'Cari berdasarkan nama, jabatan, atau ID...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _filterData();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              // Summary counter strip
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storage_rounded,
                      size: 16,
                      color: AppTheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tersimpan di Database: ${_filteredKaryawan.length} personil',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.outlineVariant.withOpacity(0.4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: AppTheme.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Auto-Persisted',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredKaryawan.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_off_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada data karyawan ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => _showFormDialog(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Tambah Data Baru'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: _filteredKaryawan.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filteredKaryawan[index];
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: const Color(0xFFCBD5E1).withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: ID, Name, Action buttons
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            AppTheme.surfaceContainer,
                                        child: Text(
                                          item.nama.isNotEmpty
                                              ? item.nama[0].toUpperCase()
                                              : 'K',
                                          style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
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
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item.jabatan} • ${item.id}\nLahir: ${item.tanggalLahirFormatted}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.secondaryText,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Edit and Delete Icons
                                      IconButton(
                                        tooltip: 'Edit Data',
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: AppTheme.secondary,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _showFormDialog(existing: item),
                                      ),
                                      IconButton(
                                        tooltip: 'Hapus Data',
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                        onPressed: () => _confirmDelete(item),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, thickness: 0.8),

                                  // Financial Data Grid
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildDetailItem(
                                        'Gaji Pokok',
                                        _formatRupiah(item.gajiPokok),
                                      ),
                                      _buildDetailItem(
                                        'Tunjangan',
                                        _formatRupiah(item.tunjangan),
                                      ),
                                      _buildDetailItem(
                                        'Hari Lembur',
                                        '${item.hariLembur} Hari',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Total Gaji Banner
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
                                          Icons.payments_outlined,
                                          color: AppTheme.primary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Total Gaji Bersih:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.secondaryText,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatRupiah(item.totalGajiBersih),
                                          style: const TextStyle(
                                            fontSize: 15,
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

import 'package:flutter/material.dart';
import '../models/desimal_besar.dart';
import '../models/calon_karyawan.dart';
import '../models/perencanaan_gaji_record.dart';
import '../database/karyawan_database_helper.dart';
import '../widgets/hasil_rincian_card.dart';

class PerencanaanGajiPage extends StatefulWidget {
  const PerencanaanGajiPage({super.key});

  @override
  State<PerencanaanGajiPage> createState() => _PerencanaanGajiPageState();
}

class _PerencanaanGajiPageState extends State<PerencanaanGajiPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _posisiController = TextEditingController();
  final _gajiPokokController = TextEditingController();
  final _tunjanganController = TextEditingController();
  final _jamLemburController = TextEditingController();
  final _tarifLemburController = TextEditingController();
  final _hariKerjaController = TextEditingController();
  final _potonganController = TextEditingController();

  CalonKaryawan? _hasilKandidat;
  DesimalBesar? _uangLembur;
  DesimalBesar? _gajiKotor;
  DesimalBesar? _gajiBersih;
  DesimalBesar? _gajiPerHari;
  bool _isSaving = false;
  bool _sudahDisimpan = false;

  @override
  void initState() {
    super.initState();
  }



  @override
  void dispose() {
    _namaController.dispose();
    _posisiController.dispose();
    _gajiPokokController.dispose();
    _tunjanganController.dispose();
    _jamLemburController.dispose();
    _tarifLemburController.dispose();
    _hariKerjaController.dispose();
    _potonganController.dispose();
    super.dispose();
  }

  void _hitungGaji() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final nama = _namaController.text.trim();
      final posisi = _posisiController.text.trim();
      final gajiPokok = DesimalBesar.dariString(_gajiPokokController.text);
      final tunjangan = DesimalBesar.dariString(_tunjanganController.text);
      final jamLembur = DesimalBesar.dariString(_jamLemburController.text);
      final tarifLembur = DesimalBesar.dariString(_tarifLemburController.text);
      final hariKerja = int.parse(_hariKerjaController.text.trim());
      final potongan = DesimalBesar.dariString(_potonganController.text);

      final kandidat = CalonKaryawan(
        nama: nama,
        posisi: posisi,
        gajiPokok: gajiPokok,
        tunjangan: tunjangan,
        jamLembur: jamLembur,
        tarifLembur: tarifLembur,
        hariKerja: hariKerja,
        potongan: potongan,
      );

      setState(() {
        _hasilKandidat = kandidat;
        _uangLembur = kandidat.hitungUangLembur();
        _gajiKotor = kandidat.hitungGajiKotor();
        _gajiBersih = kandidat.hitungGajiBersih();
        _gajiPerHari = kandidat.hitungGajiPerHari();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan perhitungan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _posisiController.clear();
    _gajiPokokController.clear();
    _tunjanganController.clear();
    _jamLemburController.clear();
    _tarifLemburController.clear();
    _hariKerjaController.clear();
    _potonganController.clear();
    setState(() {
      _hasilKandidat = null;
      _uangLembur = null;
      _gajiKotor = null;
      _gajiBersih = null;
      _gajiPerHari = null;
      _sudahDisimpan = false;
    });
  }

  Future<void> _simpanKeDatabase() async {
    if (_hasilKandidat == null || _uangLembur == null) return;
    setState(() => _isSaving = true);
    try {
      final record = PerencanaanGajiRecord(
        namaKandidat: _hasilKandidat!.nama,
        posisi: _hasilKandidat!.posisi,
        gajiPokokStr: _hasilKandidat!.gajiPokok.toDesimalString(),
        tunjanganStr: _hasilKandidat!.tunjangan.toDesimalString(),
        jamLemburStr: _hasilKandidat!.jamLembur.toDesimalString(),
        tarifLemburStr: _hasilKandidat!.tarifLembur.toDesimalString(),
        hariKerja: _hasilKandidat!.hariKerja,
        potonganStr: _hasilKandidat!.potongan.toDesimalString(),
        hasilUangLemburStr: _uangLembur!.toDesimalString(),
        hasilGajiKotorStr: _gajiKotor!.toDesimalString(),
        hasilGajiBersihStr: _gajiBersih!.toDesimalString(),
        hasilGajiPerHariStr: _gajiPerHari!.toDesimalString(),
      );
      // insertPerencanaanGaji sekarang throw jika ada error SQLite
      final id = await KaryawanDatabaseHelper.instance.insertPerencanaanGaji(record);
      if (!mounted) return;
      if (id > 0) {
        setState(() => _sudahDisimpan = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simulasi berhasil disimpan ke database!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan simulasi (row id = 0).'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Tampilkan error SQLite yang sesungguhnya di snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error database: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 10),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _validasiDesimalPositif(String? value, String namaField) {
    if (value == null || value.trim().isEmpty) {
      return "$namaField tidak boleh kosong";
    }
    try {
      final d = DesimalBesar.dariString(value);
      if (d.isNegatif) {
        return "$namaField tidak boleh bernilai negatif";
      }
    } catch (_) {
      return "Format $namaField salah! Harus berupa angka numerik valid";
    }
    return null;
  }

  String? _validasiHariKerja(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Jumlah hari kerja tidak boleh kosong";
    }
    final n = int.tryParse(value.trim());
    if (n == null) {
      return "Hari kerja harus berupa bilangan bulat";
    }
    if (n <= 0) {
      return "Jumlah hari kerja harus lebih dari 0 (mencegah pembagian nol)";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Perencanaan Gaji"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: "Kembali ke Halaman Utama",
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              tooltip: 'Riwayat Simulasi',
              onPressed: () => Navigator.pushNamed(context, '/riwayat-perencanaan'),
            ),
          ],
        ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Info
                  Card(
                    elevation: 0,
                    color: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.indigo.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.indigo.shade700),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Simulasi Biaya & Komponen Gaji Calon Karyawan",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Mendukung operasi perkalian, penjumlahan, pengurangan, pembagian presisi tinggi.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Data Identitas
                  Text(
                    "DATA IDENTITAS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      labelText: "Nama Calon Karyawan",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Nama calon karyawan tidak boleh kosong"
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _posisiController,
                    decoration: InputDecoration(
                      labelText: "Posisi / Jabatan",
                      prefixIcon: const Icon(Icons.work_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Posisi / jabatan tidak boleh kosong"
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Komponen Finansial
                  Text(
                    "KOMPONEN FINANSIAL",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _gajiPokokController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Gaji Pokok (Rp)",
                            prefixIcon: const Icon(Icons.payments_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              _validasiDesimalPositif(v, "Gaji pokok"),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _tunjanganController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Tunjangan (Rp)",
                            prefixIcon: const Icon(Icons.card_giftcard_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              _validasiDesimalPositif(v, "Tunjangan"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _jamLemburController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Jumlah Jam Lembur",
                            prefixIcon: const Icon(Icons.timer_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              _validasiDesimalPositif(v, "Jam lembur"),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _tarifLemburController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Tarif Lembur/Jam (Rp)",
                            prefixIcon: const Icon(Icons.price_change_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              _validasiDesimalPositif(v, "Tarif lembur"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hariKerjaController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Jumlah Hari Kerja (min. 1)",
                            prefixIcon: const Icon(Icons.calendar_month_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: _validasiHariKerja,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _potonganController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Jumlah Potongan (Rp)",
                            prefixIcon: const Icon(Icons.money_off_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                              _validasiDesimalPositif(v, "Potongan"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _hitungGaji,
                          icon: const Icon(Icons.calculate),
                          label: const Text(
                            "Hitung Estimasi Gaji",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _resetForm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Reset"),
                      ),
                    ],
                  ),

                  // Hasil Kalkulasi
                  if (_hasilKandidat != null) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      "HASIL ESTIMASI PENGGAJIAN",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Profil Singkat
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.indigo.shade100,
                                  child: Icon(Icons.person,
                                      color: Colors.indigo.shade800),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _hasilKandidat!.nama,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _hasilKandidat!.posisi,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                Text(
                                  "Hari Kerja: ${_hasilKandidat!.hariKerja} hari",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  "Jam Lembur: ${_hasilKandidat!.jamLembur.formatAngka()} jam",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // [A] Perkalian - Uang Lembur
                    HasilRincianCard(
                      label: "[A] Perkalian (Uang Lembur)",
                      nilai: _uangLembur!.formatRupiah(),
                      rumus:
                          "${_hasilKandidat!.jamLembur.formatAngka()} jam × ${_hasilKandidat!.tarifLembur.formatRupiah()}",
                      icon: Icons.close_rounded,
                      color: Colors.teal,
                    ),

                    // [B] Penjumlahan - Gaji Kotor
                    HasilRincianCard(
                      label: "[B] Penjumlahan (Gaji Kotor)",
                      nilai: _gajiKotor!.formatRupiah(),
                      rumus:
                          "Pokok (${_hasilKandidat!.gajiPokok.formatRupiah()}) + Tunjangan (${_hasilKandidat!.tunjangan.formatRupiah()}) + Lembur (${_uangLembur!.formatRupiah()})",
                      icon: Icons.add_rounded,
                      color: Colors.blue,
                    ),

                    // [C] Pengurangan - Estimasi Gaji Bersih
                    HasilRincianCard(
                      label: "[C] Pengurangan (Estimasi Gaji Bersih)",
                      nilai: _gajiBersih!.formatRupiah(),
                      rumus:
                          "Gaji Kotor (${_gajiKotor!.formatRupiah()}) − Potongan (${_hasilKandidat!.potongan.formatRupiah()})",
                      icon: Icons.remove_rounded,
                      color: Colors.deepPurple,
                    ),

                    // [D] Pembagian - Estimasi Gaji per Hari
                    HasilRincianCard(
                      label: "[D] Pembagian (Estimasi Gaji/Hari)",
                      nilai: _gajiPerHari!.formatRupiah(),
                      rumus:
                          "Gaji Bersih (${_gajiBersih!.formatRupiah()}) ÷ ${_hasilKandidat!.hariKerja} hari kerja",
                      icon: Icons.percent_rounded,
                      color: Colors.green.shade800,
                    ),

                    // Tombol Simpan ke Database
                    const SizedBox(height: 20),
                    _sudahDisimpan
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Tersimpan di Database',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: _isSaving ? null : _simpanKeDatabase,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              _isSaving ? 'Menyimpan...' : 'Simpan ke Database',
                              style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.indigo.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                 ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}

import 'package:flutter/material.dart';
import '../models/desimal_besar.dart';

class TotalPenggajianPage extends StatefulWidget {
  const TotalPenggajianPage({super.key});

  @override
  State<TotalPenggajianPage> createState() => _TotalPenggajianPageState();
}

class _TotalPenggajianPageState extends State<TotalPenggajianPage> {
  final _formKey = GlobalKey<FormState>();
  static const int _jumlahCalon = 4;

  late final List<TextEditingController> _controllers;
  List<DesimalBesar>? _daftarGaji;
  DesimalBesar? _totalEstimasi;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _jumlahCalon,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _hitungTotal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      List<DesimalBesar> gajiList = [];
      for (int i = 0; i < _jumlahCalon; i++) {
        gajiList.add(DesimalBesar.dariString(_controllers[i].text));
      }

      // Menghitung total dengan menjumlahkan DesimalBesar (persis dari source code asli)
      DesimalBesar total = DesimalBesar.nol();
      for (DesimalBesar g in gajiList) {
        total = total + g;
      }

      setState(() {
        _daftarGaji = gajiList;
        _totalEstimasi = total;
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

  void _reset() {
    _formKey.currentState?.reset();
    for (var c in _controllers) {
      c.clear();
    }
    setState(() {
      _daftarGaji = null;
      _totalEstimasi = null;
    });
  }

  String? _validasiGaji(String? val, int index) {
    if (val == null || val.trim().isEmpty) {
      return "Gaji calon karyawan ${index + 1} tidak boleh kosong";
    }
    try {
      final d = DesimalBesar.dariString(val);
      if (d.isNegatif) {
        return "Gaji tidak boleh bernilai negatif";
      }
    } catch (_) {
      return "Format harus berupa angka numerik valid";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Total Biaya Penggajian"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  Card(
                    elevation: 0,
                    color: Colors.deepOrange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.deepOrange.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            color: Colors.deepOrange.shade800,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TOTAL BIAYA PENGGAJIAN TIM",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.deepOrange.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Estimasi kebutuhan dana penggajian startup awal untuk $_jumlahCalon orang calon karyawan.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepOrange.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "MASUKKAN ESTIMASI GAJI BERSIH ($_jumlahCalon CALON KARYAWAN)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4 Input fields
                  ...List.generate(_jumlahCalon, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        controller: _controllers[index],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              "Estimasi Gaji Calon Karyawan ${index + 1} (Rp)",
                          hintText: "Contoh: 8000000 atau 8.000.000",
                          prefixIcon: const Icon(Icons.person_pin_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => _validasiGaji(v, index),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _hitungTotal,
                          icon: const Icon(Icons.calculate_outlined),
                          label: const Text(
                            "Hitung Total Estimasi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.deepOrange.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _reset,
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

                  // Hasil Rincian
                  if (_totalEstimasi != null && _daftarGaji != null) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      "RINCIAN TOTAL ESTIMASI PENGGAJIAN",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.deepOrange.shade900,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            ...List.generate(_daftarGaji!.length, (i) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Calon Karyawan ${i + 1}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SelectableText(
                                      _daftarGaji![i].formatRupiah(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Biaya Penggajian",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SelectableText(
                                  _totalEstimasi!.formatRupiah(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Catatan Card
                    Card(
                      elevation: 0,
                      color: Colors.amber.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.amber.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes_rounded,
                                color: Colors.amber.shade900),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Catatan:\nDana sebesar ${_totalEstimasi!.formatRupiah()} perlu dipersiapkan oleh startup untuk menggaji $_jumlahCalon orang calon karyawan tersebut.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.brown.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

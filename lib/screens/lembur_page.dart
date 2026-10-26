import 'package:flutter/material.dart';
import '../payroll/kebijakan_lembur.dart';

class LemburPage extends StatefulWidget {
  const LemburPage({super.key});

  @override
  State<LemburPage> createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {
  final _formKey = GlobalKey<FormState>();
  final _hariController = TextEditingController();

  KebijakanLembur? _kebijakanTerpilih;
  BigInt? _hariLembur;
  BigInt? _sisaModulo;

  @override
  void dispose() {
    _hariController.dispose();
    super.dispose();
  }

  void _analisisLembur() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final inputStr = _hariController.text.trim();
      final hari = BigInt.parse(inputStr);

      final hasil = KebijakanLembur.evaluasi(hari);
      final modulo = hari % BigInt.two;

      // Jalankan method polimorfik bawaan asli
      hasil.tampilkanKeputusan();

      setState(() {
        _hariLembur = hari;
        _kebijakanTerpilih = hasil;
        _sisaModulo = modulo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error parsing angka lembur: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _hariController.clear();
    setState(() {
      _kebijakanTerpilih = null;
      _hariLembur = null;
      _sisaModulo = null;
    });
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.teal.shade900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String kat) {
    if (kat.contains("GANJIL")) return Colors.orange.shade800;
    if (kat.contains("Nol")) return Colors.blueGrey;
    return Colors.teal.shade800;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cek Hari Lembur"),
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
                    color: Colors.teal.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.teal.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: Colors.teal.shade800),
                              const SizedBox(width: 10),
                              Text(
                                "TUJUAN FITUR DALAM STARTUP",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.teal.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Fitur ini digunakan untuk mengecek apakah jumlah hari lembur calon karyawan termasuk GANJIL atau GENAP guna menentukan kebijakan pembagian hak istirahat dan insentif kerja:",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.teal.shade900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildBulletPoint(
                            "GENAP : Jadwal lembur terencana & seimbang (misal: Sabtu & Minggu). Hak: Kompensasi normal + 1 Hari Libur Pengganti (Off-Day).",
                          ),
                          const SizedBox(height: 4),
                          _buildBulletPoint(
                            "GANJIL : Terdapat 1 hari lembur ekstra/insidental. Hak: Insentif Tambahan (Voucher Makan & Uang Transport Ekstra) khusus hari ganjil tersebut.",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Form
                  TextFormField(
                    controller: _hariController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Masukkan Rencana Jumlah Hari Lembur",
                      hintText: "Contoh: 0, 2, 3, 5, dst.",
                      prefixIcon: const Icon(Icons.event_note_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Jumlah hari lembur tidak boleh kosong";
                      }
                      try {
                        final val = BigInt.parse(v.trim());
                        if (val < BigInt.zero) {
                          return "Hari lembur tidak boleh bernilai negatif";
                        }
                      } catch (_) {
                        return "Harus berupa bilangan bulat non-negatif";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _analisisLembur(),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _analisisLembur,
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text(
                            "Analisis Kebijakan Lembur",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
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

                  // Hasil Evaluasi
                  if (_kebijakanTerpilih != null) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      "HASIL ANALISIS KEBIJAKAN LEMBUR",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.teal.shade900,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Ringkasan Modulo
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
                            _buildInfoRow(
                              "Rencana Hari Lembur",
                              "$_hariLembur hari",
                              Icons.calendar_today,
                            ),
                            const Divider(height: 16),
                            _buildInfoRow(
                              "Operasi Modulo",
                              "$_hariLembur % 2 = $_sisaModulo",
                              Icons.calculate_outlined,
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Kategori Bilangan",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(
                                      _kebijakanTerpilih!.statusKategori,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getCategoryColor(
                                        _kebijakanTerpilih!.statusKategori,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _kebijakanTerpilih!.statusKategori,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getCategoryColor(
                                        _kebijakanTerpilih!.statusKategori,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Keputusan Kebijakan Box
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.teal.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.policy_outlined,
                                  color: Colors.teal.shade800,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "KEPUTUSAN KEBIJAKAN STARTUP",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _kebijakanTerpilih!.deskripsiKeputusan,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.grey.shade800,
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

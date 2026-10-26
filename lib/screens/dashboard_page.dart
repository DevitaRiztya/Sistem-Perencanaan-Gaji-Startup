import 'package:flutter/material.dart';
import '../widgets/menu_card.dart';
import '../theme/app_theme.dart';

/// Halaman Pusat Komputasi Penggajian (Sesuai Tema Payroll)
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Komputasi Payroll"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Mesin Finansial OOP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.calculate_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Simulasi & Komputasi Payroll",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Perhitungan presisi komponen gaji, kebijakan lembur dinamis, dan agregat anggaran startup.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                "FITUR KOMPUTASI PENGGAJIAN",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),

              // Menu 1: Perencanaan Gaji
              MenuCard(
                title: "1. Perencanaan Gaji Karyawan",
                description:
                    "Simulasi komponen gaji (Pokok, Tunjangan, Lembur, Potongan, & Gaji/Hari)",
                icon: Icons.calculate_outlined,
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/perencanaan-gaji'),
              ),
              const SizedBox(height: 12),

              // Menu 2: Cek Hari Lembur
              MenuCard(
                title: "2. Cek Kebijakan Lembur Polimorfik",
                description:
                    "Analisis kebijakan lembur polimorfik (Genap 1.5x, Ganjil 1.25x, & Nol 0x)",
                icon: Icons.access_time_filled_outlined,
                color: AppTheme.secondary,
                onTap: () => Navigator.pushNamed(context, '/cek-lembur'),
              ),
              const SizedBox(height: 12),

              // Menu 3: Total Biaya Penggajian
              MenuCard(
                title: "3. Total Biaya Penggajian Tim Startup",
                description:
                    "Estimasi total kebutuhan dana penggajian untuk seluruh personil startup",
                icon: Icons.groups_outlined,
                color: const Color(0xFF0D9488),
                onTap: () => Navigator.pushNamed(context, '/total-penggajian'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'auth/sistem_autentikasi.dart';
import 'theme/app_theme.dart';
import 'screens/login_page.dart';
import 'screens/main_shell_page.dart';
import 'screens/dashboard_overview_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/perencanaan_gaji_page.dart';
import 'screens/lembur_page.dart';
import 'screens/total_penggajian_page.dart';
import 'screens/data_kelompok_page.dart';
import 'screens/crud_karyawan_page.dart';
import 'screens/crud_calon_karyawan_page.dart';
import 'screens/payroll_overview_page.dart';
import 'screens/hijriah_umur_page.dart';
import 'screens/weton_saka_page.dart';
import 'screens/konversi_kalender_page.dart';
import 'screens/konversi_umur_page.dart';
import 'screens/stopwatch_page.dart';
import 'screens/bantuan_page.dart';
import 'screens/riwayat_perencanaan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Gunakan sqflite_common_ffi_web untuk SQLite di browser
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Gunakan sqflite_common_ffi untuk desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const PayrollPlannerApp());
}

class PayrollPlannerApp extends StatefulWidget {
  final String? initialRoute;
  const PayrollPlannerApp({super.key, this.initialRoute});

  @override
  State<PayrollPlannerApp> createState() => _PayrollPlannerAppState();
}

class _PayrollPlannerAppState extends State<PayrollPlannerApp> {
  // Layanan autentikasi tunggal dengan session persisten
  final SistemAutentikasi _sistemAutentikasi = SistemAutentikasi();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payroll Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: widget.initialRoute ?? '/login',
      routes: {
        '/login': (context) => LoginPage(autentikasi: _sistemAutentikasi),
        '/main': (context) => MainShellPage(autentikasi: _sistemAutentikasi),
        '/dashboard': (context) =>
            MainShellPage(autentikasi: _sistemAutentikasi),
        '/dashboard-overview': (context) => const DashboardOverviewPage(),
        '/crud-karyawan': (context) => const CrudKaryawanPage(),
        '/crud-calon-karyawan': (context) => const CrudCalonKaryawanPage(),
        '/payroll': (context) => const PayrollOverviewPage(),
        '/hijriah-umur': (context) => const HijriahUmurPage(),
        '/weton-saka': (context) => const WetonSakaPage(),
        '/komputasi-payroll': (context) => const DashboardPage(),
        '/perencanaan-gaji': (context) => const PerencanaanGajiPage(),
        '/cek-lembur': (context) => const LemburPage(),
        '/total-penggajian': (context) => const TotalPenggajianPage(),
        '/data-kelompok': (context) => const DataKelompokPage(),
        '/konversi-kalender': (context) => const KonversiKalenderPage(),
        '/konversi-umur': (context) => const KonversiUmurPage(),
        '/stopwatch': (context) => const StopwatchPage(),
        '/bantuan': (context) => BantuanPage(autentikasi: _sistemAutentikasi),
        '/riwayat-perencanaan': (context) => const RiwayatPerencanaanPage(),
      },
    );
  }
}

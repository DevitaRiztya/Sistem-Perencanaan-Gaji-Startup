import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_payroll/main.dart';
import 'package:flutter_payroll/screens/main_shell_page.dart';
import 'package:flutter_payroll/screens/dashboard_overview_page.dart';
import 'package:flutter_payroll/screens/data_kelompok_page.dart';
import 'package:flutter_payroll/screens/payroll_overview_page.dart';
import 'package:flutter_payroll/screens/crud_karyawan_page.dart';
import 'package:flutter_payroll/screens/hijriah_umur_page.dart';
import 'package:flutter_payroll/screens/weton_saka_page.dart';
import 'package:flutter_payroll/screens/stopwatch_page.dart';
import 'package:flutter_payroll/screens/bantuan_page.dart';

void main() {
  testWidgets('End-to-End GUI Flow: Login -> Bottom Navigation 3 Menu (Halaman Utama, Stopwatch, Bantuan & Logout) + 5 Menu Vertikal', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const PayrollPlannerApp());
    await tester.pumpAndSettle();

    // 1. Verifikasi Halaman Login Admin
    expect(find.text('Payroll Management System'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Masukkan kredensial admin / admin123
    await tester.enterText(find.byType(TextFormField).first, 'admin');
    await tester.enterText(find.byType(TextFormField).last, 'admin123');
    await tester.pumpAndSettle();

    // Klik tombol Login
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // 2. Verifikasi MainShellPage & Tab 1: Halaman Utama (dengan 5 Menu Vertikal)
    expect(find.byType(MainShellPage), findsOneWidget);
    expect(find.byType(DashboardOverviewPage), findsOneWidget);
    expect(find.text('Payroll Planner'), findsOneWidget);
    expect(find.text('Total Karyawan'), findsOneWidget);
    expect(find.text('Total Payroll'), findsOneWidget);

    // Verifikasi 3 Menu pada Bottom Navigation Bar
    expect(find.text('Halaman Utama'), findsOneWidget);
    expect(find.text('Stopwatch'), findsOneWidget);
    expect(find.text('Bantuan'), findsOneWidget);

    // Verifikasi 5 Kartu Menu Vertikal di Halaman Utama
    expect(find.text('Daftar Anggota Kelompok'), findsOneWidget);
    expect(find.text('Perencanaan Gaji'), findsOneWidget);
    expect(find.text('Data Karyawan'), findsOneWidget);
    expect(find.text('Hijriah & Umur'), findsOneWidget);
    expect(find.text('Weton & Saka Bali'), findsOneWidget);

    // 3. Masuk ke Menu 1: Daftar Anggota Kelompok
    await tester.tap(find.text('Daftar Anggota Kelompok'));
    await tester.pumpAndSettle();
    expect(find.byType(DataKelompokPage), findsOneWidget);
    expect(find.text('Fania Azelia'), findsOneWidget);
    expect(find.text('Azahrah Zakiyah N.F'), findsOneWidget);
    expect(find.text('Devita Riztya N.P'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 4. Masuk ke Menu 2: Perencanaan Gaji
    await tester.tap(find.text('Perencanaan Gaji'));
    await tester.pumpAndSettle();
    expect(find.byType(PayrollOverviewPage), findsOneWidget);
    expect(find.text('Data Payroll & Gaji'), findsOneWidget);
    expect(find.text('TOTAL BIAYA PENGGAJIAN BULANAN'), findsOneWidget);
    expect(find.text('Budi'), findsWidgets);
    await tester.tap(find.text('Menu Utama'));
    await tester.pumpAndSettle();

    // 5. Masuk ke Menu 3: Data Karyawan
    await tester.tap(find.text('Data Karyawan'));
    await tester.pumpAndSettle();
    expect(find.byType(CrudKaryawanPage), findsOneWidget);
    expect(find.text('Kelola Data Karyawan & Payroll'), findsOneWidget);
    expect(find.text('Budi'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 6. Masuk ke Menu 4: Hijriah & Umur
    await tester.tap(find.text('Hijriah & Umur'));
    await tester.pumpAndSettle();
    expect(find.byType(HijriahUmurPage), findsOneWidget);
    expect(find.text('USIA SAAT INI'), findsOneWidget);
    expect(find.text('KALENDER HIJRIAH'), findsOneWidget);
    expect(find.text('10 Syawal 1426 H'), findsOneWidget);
    await tester.tap(find.text('Menu Utama'));
    await tester.pumpAndSettle();

    // 7. Masuk ke Menu 5: Weton & Saka Bali
    await tester.tap(find.text('Weton & Saka Bali'));
    await tester.pumpAndSettle();
    expect(find.byType(WetonSakaPage), findsOneWidget);
    expect(find.text('KALENDER JAWA (WETON)'), findsOneWidget);
    expect(find.text('Jumat Pahing'), findsOneWidget);
    expect(find.text('KALENDER SAKA BALI'), findsOneWidget);
    expect(find.text('Tahun Saka 1927'), findsOneWidget);
    expect(find.textContaining('Sukra Paing Pahang'), findsOneWidget);
    await tester.tap(find.text('Menu Utama'));
    await tester.pumpAndSettle();

    // 8. Pindah Tab BottomNavigationBar ke Tab 2: Stopwatch
    await tester.tap(find.text('Stopwatch'));
    await tester.pumpAndSettle();
    expect(find.byType(StopwatchPage), findsOneWidget);
    expect(find.text('Aplikasi Stopwatch'), findsOneWidget);

    // 9. Pindah Tab BottomNavigationBar ke Tab 3: Bantuan & Logout
    await tester.tap(find.text('Bantuan'));
    await tester.pumpAndSettle();
    expect(find.byType(BantuanPage), findsOneWidget);
    expect(find.text('Pusat Bantuan & Panduan'), findsOneWidget);
    expect(find.text('Keluar Sesi (Logout)'), findsOneWidget);

    // 10. Lakukan Logout dari menu Bantuan
    final logoutBtn = find.widgetWithText(FilledButton, 'Logout');
    expect(logoutBtn, findsOneWidget);
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    // Dialog konfirmasi logout
    expect(find.text('Konfirmasi Logout'), findsOneWidget);
    await tester.tap(find.text('Ya, Logout'));
    await tester.pumpAndSettle();

    // Verifikasi berhasil kembali ke Login Page
    expect(find.text('Payroll Management System'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}


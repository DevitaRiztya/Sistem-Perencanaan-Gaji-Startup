import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_payroll/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Aplikasi merender halaman login dengan benar', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PayrollPlannerApp());
    await tester.pumpAndSettle();

    // Verifikasi judul dan form login ada di layar
    expect(find.text('Payroll Management System'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Perencanaan Gaji merender preset tarif lembur dan tombol back', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'admin_logged_in': true});
    await tester.pumpWidget(const PayrollPlannerApp(initialRoute: '/perencanaan-gaji'));
    await tester.pumpAndSettle();

    // Verifikasi judul dan preset ada di layar
    expect(find.text('Perencanaan Gaji'), findsOneWidget);
    expect(find.text('Preset Skala Tarif Lembur (Mendukung Triliun & Kuadriliun):'), findsOneWidget);
    expect(find.text('50 Rb'), findsOneWidget);
    expect(find.text('100 Rb'), findsOneWidget);
    expect(find.text('1 Juta'), findsOneWidget);
    expect(find.text('1 Miliar'), findsOneWidget);
    expect(find.text('1 Triliun'), findsOneWidget);
    expect(find.text('1 Kuadriliun'), findsOneWidget);

    // Tap preset 1 Kuadriliun
    await tester.tap(find.text('1 Kuadriliun'));
    await tester.pumpAndSettle();

    // Pastikan terdeteksi terbaca
    expect(find.textContaining('1 Kuadriliun Rupiah'), findsOneWidget);

    // Verifikasi tombol back di AppBar
    final backBtn = find.byIcon(Icons.arrow_back);
    expect(backBtn, findsOneWidget);
  });
}

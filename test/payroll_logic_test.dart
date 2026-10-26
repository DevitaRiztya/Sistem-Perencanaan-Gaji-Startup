import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_payroll/models/desimal_besar.dart';
import 'package:flutter_payroll/models/calon_karyawan.dart';
import 'package:flutter_payroll/models/anggota_kelompok.dart';
import 'package:flutter_payroll/auth/sistem_autentikasi.dart';
import 'package:flutter_payroll/payroll/kebijakan_lembur.dart';
import 'package:flutter_payroll/payroll/kebijakan_lembur_nol.dart';
import 'package:flutter_payroll/payroll/kebijakan_lembur_genap.dart';
import 'package:flutter_payroll/payroll/kebijakan_lembur_ganjil.dart';

void main() {
  group('Verifikasi Presisi & Aritmatika DesimalBesar', () {
    test('Format Rupiah dan operasi +, -, *, /', () {
      final a = DesimalBesar.dariString("15.000.000");
      final b = DesimalBesar.dariString("2.500.000");
      
      expect((a + b).formatRupiah(), equals("Rp 17.500.000"));
      expect((a - b).formatRupiah(), equals("Rp 12.500.000"));
      expect((b * DesimalBesar.dariInt(2)).formatRupiah(), equals("Rp 5.000.000"));
      expect((a / DesimalBesar.dariInt(3)).formatRupiah(), equals("Rp 5.000.000"));
    });

    test('Angka Raksasa Triliun dan Kuadriliun', () {
      final raksasa = DesimalBesar.dariString("1000000000000000"); // 1 Kuadriliun
      expect(raksasa.formatRupiah(), equals("Rp 1.000.000.000.000.000"));
    });

    test('Mandatory Math Tests: Uji Wajib Presisi DesimalBesar', () {
      // Uji wajib 1: 268157163,76913838161763 + 912816816753,013817381781
      final d1 = DesimalBesar.dariString("268157163,76913838161763");
      final d2 = DesimalBesar.dariString("912816816753,013817381781");
      final sum1 = d1 + d2;
      expect(sum1.toDesimalString(), equals("913084973916,78295576339863"));

      // Uji wajib 2: 9217187 − 93183873
      final d3 = DesimalBesar.dariString("9217187");
      final d4 = DesimalBesar.dariString("93183873");
      final sub2 = d3 - d4;
      expect(sub2.toDesimalString(), equals("-83966686"));
      expect(sub2.isNegatif, isTrue);

      // Uji wajib 3: 1.000.000.000.000.000 + 2.000.000.000.000.000
      final d5 = DesimalBesar.dariString("1.000.000.000.000.000");
      final d6 = DesimalBesar.dariString("2.000.000.000.000.000");
      final sum3 = d5 + d6;
      expect(sum3.toDesimalString(), equals("3000000000000000"));
      expect(sum3.formatRupiah(), equals("Rp 3.000.000.000.000.000"));
    });

    test('Parser Titik dan Koma Sesuai Spesifikasi Persis', () {
      // 1. 268157163,76913838161763
      expect(DesimalBesar.dariString("268157163,76913838161763").toDesimalString(), equals("268157163,76913838161763"));
      // 2. 152651.7281376
      expect(DesimalBesar.dariString("152651.7281376").toDesimalString(), equals("152651,7281376"));
      // 3. 1.234.567,89 (koma terakhir -> desimal)
      expect(DesimalBesar.dariString("1.234.567,89").toDesimalString(), equals("1234567,89"));
      // 4. 1,234,567.89 (titik terakhir -> desimal)
      expect(DesimalBesar.dariString("1,234,567.89").toDesimalString(), equals("1234567,89"));
      // 5. 1.000.000.000.000.000 (banyak titik -> ribuan)
      expect(DesimalBesar.dariString("1.000.000.000.000.000").toDesimalString(), equals("1000000000000000"));
      // Penolakan karakter tidak valid
      expect(() => DesimalBesar.dariString("123abc"), throwsFormatException);
      expect(() => DesimalBesar.dariString("12@34"), throwsFormatException);
    });

    test('FIX BUG: Ribuan Tunggal (154.000 = 154000, bukan 154)', () {
      // Bug lama: satu titik selalu dianggap desimal, 154.000 = 154
      // Fix: satu titik/koma diikuti tepat 3 digit = pemisah ribuan
      expect(DesimalBesar.dariString("154.000").formatRupiah(), equals("Rp 154.000"));
      expect(DesimalBesar.dariString("50.000").formatRupiah(), equals("Rp 50.000"));
      expect(DesimalBesar.dariString("100.000").formatRupiah(), equals("Rp 100.000"));
      expect(DesimalBesar.dariString("1.000").formatRupiah(), equals("Rp 1.000"));
      // Koma ribuan
      expect(DesimalBesar.dariString("154,000").formatRupiah(), equals("Rp 154.000"));
      expect(DesimalBesar.dariString("1,000").formatRupiah(), equals("Rp 1.000"));
    });

    test('FIX BUG: Desimal valid (bukan 3 digit setelah pemisah) tetap benar', () {
      // 3.5 = 3,50 (bukan 3500)
      expect(DesimalBesar.dariString("3.5").formatRupiah(), equals("Rp 3,50"));
      // 1.25 = 1,25
      expect(DesimalBesar.dariString("1.25").formatRupiah(), equals("Rp 1,25"));
      // 3,5 = 3,50 (koma desimal)
      expect(DesimalBesar.dariString("3,5").formatRupiah(), equals("Rp 3,50"));
      // 1,25 = 1,25
      expect(DesimalBesar.dariString("1,25").formatRupiah(), equals("Rp 1,25"));
    });

    test('FIX BUG: 3 jam × Rp154.000 = Rp462.000', () {
      final jam = DesimalBesar.dariString("3");
      final tarif = DesimalBesar.dariString("154.000");
      final hasil = jam * tarif;
      expect(hasil.formatRupiah(), equals("Rp 462.000"));
    });
  });

  group('Verifikasi Model CalonKaryawan', () {
    test('Perhitungan Payroll CalonKaryawan sesuai console', () {
      final calon = CalonKaryawan(
        nama: "Budi Santoso",
        posisi: "Software Engineer",
        gajiPokok: DesimalBesar.dariString("8000000"),
        tunjangan: DesimalBesar.dariString("2000000"),
        jamLembur: DesimalBesar.dariString("10"),
        tarifLembur: DesimalBesar.dariString("50000"),
        hariKerja: 20,
        potongan: DesimalBesar.dariString("500000"),
      );

      // Uang lembur = 10 * 50.000 = 500.000
      expect(calon.hitungUangLembur().formatRupiah(), equals("Rp 500.000"));
      // Gaji kotor = 8.000.000 + 2.000.000 + 500.000 = 10.500.000
      expect(calon.hitungGajiKotor().formatRupiah(), equals("Rp 10.500.000"));
      // Gaji bersih = 10.500.000 - 500.000 = 10.000.000
      expect(calon.hitungGajiBersih().formatRupiah(), equals("Rp 10.000.000"));
      // Gaji per hari = 10.000.000 / 20 = 500.000
      expect(calon.hitungGajiPerHari().formatRupiah(), equals("Rp 500.000"));
    });
  });

  group('Verifikasi Kebijakan Lembur', () {
    test('Evaluasi 0, Genap, dan Ganjil', () {
      final nol = KebijakanLembur.evaluasi(BigInt.zero);
      expect(nol, isA<KebijakanLemburNol>());
      expect(nol.statusKategori, equals("GENAP (Nol)"));

      final genap = KebijakanLembur.evaluasi(BigInt.from(4));
      expect(genap, isA<KebijakanLemburGenap>());
      expect(genap.statusKategori, equals("GENAP"));

      final ganjil = KebijakanLembur.evaluasi(BigInt.from(3));
      expect(ganjil, isA<KebijakanLemburGanjil>());
      expect(ganjil.statusKategori, equals("GANJIL"));
    });
  });

  group('Verifikasi Autentikasi', () {
    test('Kredensial dan batas 3x percobaan', () {
      final auth = SistemAutentikasi();
      expect(auth.prosesLoginGUI("admin", "wrong"), isFalse);
      expect(auth.percobaanGagal, equals(1));
      expect(auth.sisaKesempatan, equals(2));

      expect(auth.prosesLoginGUI("admin", "wrong2"), isFalse);
      expect(auth.percobaanGagal, equals(2));
      expect(auth.sisaKesempatan, equals(1));

      expect(auth.prosesLoginGUI("admin", "wrong3"), isFalse);
      expect(auth.isTerkunci, isTrue);
      expect(auth.sisaKesempatan, equals(0));

      // Saat terkunci, meskipun password benar, tetap ditolak sampai di-reset
      expect(auth.prosesLoginGUI("admin", "12345"), isFalse);

      auth.resetPercobaan();
      expect(auth.prosesLoginGUI("admin", "12345"), isTrue);
    });
  });

  group('Verifikasi Data Anggota Kelompok', () {
    test('Data Anggota dari Map', () {
      final mhs = AnggotaKelompok.dariMap({"nama": "Fania Azelia", "nim": "124240161"});
      expect(mhs.nama, equals("Fania Azelia"));
      expect(mhs.nim, equals("124240161"));
    });
  });
}

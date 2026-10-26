/// Class untuk menangani angka finansial berskala raksasa (Triliun, Kuadriliun, dst.)
/// menggunakan representasi pecahan rasional BigInt agar tidak terjadi precision-loss
/// atau integer overflow 64-bit.
class DesimalBesar {
  // Encapsulation: Atribut privat dengan awalan underscore (_)
  final BigInt _pembilang;
  final BigInt _penyebut;

  // Parameterized Constructor dengan Initializer List
  DesimalBesar(BigInt pembilang, [BigInt? penyebut])
      : _pembilang = (penyebut == null || penyebut >= BigInt.zero)
            ? pembilang
            : -pembilang,
        _penyebut = penyebut == null
            ? BigInt.one
            : (penyebut < BigInt.zero ? -penyebut : penyebut) {
    if (_penyebut == BigInt.zero) {
      throw ArgumentError(
          "Penyebut tidak boleh bernilai nol (Division by Zero).");
    }
  }

  // Named Constructor: Menginisialisasi nilai 0
  factory DesimalBesar.nol() => DesimalBesar(BigInt.zero, BigInt.one);

  // Named Constructor: Menginisialisasi dari integer standar
  factory DesimalBesar.dariInt(int nilai) => DesimalBesar(BigInt.from(nilai));

  // Named Constructor (Factory): Melakukan parsing teks angka secara fleksibel
  // Named Constructor (Factory): Melakukan parsing teks angka secara fleksibel
  // Aturan Spesifikasi:
  // 1. Jika titik dan koma sama-sama ada, pemisah terakhir dianggap desimal.
  // 2. Jika hanya satu titik/koma, anggap desimal.
  // 3. Banyak titik/koma dianggap pemisah ribuan.
  // 4. Tolak karakter tidak valid.
  factory DesimalBesar.dariString(String teks) {
    String bersih = teks.trim();
    if (bersih.isEmpty) return DesimalBesar.nol();

    // Hapus awalan mata uang seperti Rp, rp, RP jika ada
    if (bersih.startsWith('Rp') || bersih.startsWith('rp') || bersih.startsWith('RP')) {
      bersih = bersih.substring(2).trim();
    }
    bersih = bersih.replaceAll(' ', '');

    if (bersih.isEmpty) return DesimalBesar.nol();

    bool negatif = false;
    if (bersih.startsWith('-')) {
      negatif = true;
      bersih = bersih.substring(1);
    } else if (bersih.startsWith('+')) {
      bersih = bersih.substring(1);
    }

    if (bersih.isEmpty) {
      throw FormatException("Input tidak boleh hanya berupa tanda tanda: $teks");
    }

    // Tolak karakter tidak valid: hanya boleh angka 0-9, titik (.), dan koma (,)
    final validRegex = RegExp(r'^[0-9.,]+$');
    if (!validRegex.hasMatch(bersih)) {
      throw FormatException("Karakter tidak valid pada angka: $teks");
    }

    // Penerapan Aturan Spesifikasi (format Indonesia & internasional):
    // - Jika ada titik DAN koma: pemisah terakhir = desimal, lainnya = ribuan
    // - Jika hanya titik/koma, cek apakah diikuti tepat 3 digit:
    //   → Tepat 3 digit setelah pemisah tunggal = pemisah ribuan (mis. 154.000 = 154000)
    //   → Bukan 3 digit = desimal (mis. 3.5 = 3,5)
    // - Banyak titik/koma = semua pemisah ribuan
    if (bersih.contains('.') && bersih.contains(',')) {
      int lastDot = bersih.lastIndexOf('.');
      int lastComma = bersih.lastIndexOf(',');
      if (lastDot > lastComma) {
        // Titik terakhir adalah desimal, koma pemisah ribuan
        bersih = bersih.replaceAll(',', '');
      } else {
        // Koma terakhir adalah desimal, titik pemisah ribuan
        bersih = bersih.replaceAll('.', '').replaceAll(',', '.');
      }
    } else if (bersih.contains('.')) {
      int dotCount = '.'.allMatches(bersih).length;
      if (dotCount > 1) {
        // Banyak titik -> semua pemisah ribuan (1.000.000 -> 1000000)
        bersih = bersih.replaceAll('.', '');
      } else {
        // Satu titik: cek digit setelah titik
        int dotIndex = bersih.indexOf('.');
        String afterDot = bersih.substring(dotIndex + 1);
        if (afterDot.length == 3) {
          // Tepat 3 digit -> pemisah ribuan (154.000 -> 154000, 1.000 -> 1000)
          bersih = bersih.replaceAll('.', '');
        }
        // Bukan 3 digit -> desimal (3.5, 1.25, 3.14159 tetap sebagai desimal)
      }
    } else if (bersih.contains(',')) {
      int commaCount = ','.allMatches(bersih).length;
      if (commaCount > 1) {
        // Banyak koma -> semua pemisah ribuan (1,000,000 -> 1000000)
        bersih = bersih.replaceAll(',', '');
      } else {
        // Satu koma: cek digit setelah koma
        int commaIndex = bersih.indexOf(',');
        String afterComma = bersih.substring(commaIndex + 1);
        if (afterComma.length == 3) {
          // Tepat 3 digit -> pemisah ribuan (154,000 -> 154000, 1,500 -> 1500)
          bersih = bersih.replaceAll(',', '');
        } else {
          // Bukan 3 digit -> desimal (3,5 -> 3.5, 1,25 -> 1.25)
          bersih = bersih.replaceAll(',', '.');
        }
      }
    }

    // Parsing ke BigInt
    if (!bersih.contains('.')) {
      BigInt nilai = BigInt.parse(bersih);
      return DesimalBesar(negatif ? -nilai : nilai, BigInt.one);
    }

    List<String> bagian = bersih.split('.');
    if (bagian.length != 2) {
      throw FormatException("Format desimal tidak valid: $teks");
    }
    String bulatStr = bagian[0].isEmpty ? '0' : bagian[0];
    String pecahanStr = bagian[1];

    if (pecahanStr.isEmpty) {
      BigInt bulat = BigInt.parse(bulatStr);
      return DesimalBesar(negatif ? -bulat : bulat, BigInt.one);
    }

    BigInt pengali = BigInt.from(10).pow(pecahanStr.length);
    BigInt bulat = BigInt.parse(bulatStr);
    BigInt pecahan = BigInt.parse(pecahanStr);

    BigInt total = (bulat * pengali) + pecahan;
    BigInt fpb = total.gcd(pengali);

    BigInt num = total ~/ fpb;
    BigInt den = pengali ~/ fpb;

    return DesimalBesar(negatif ? -num : num, den);
  }

  // Getter (Encapsulation)
  BigInt get pembilang => _pembilang;
  BigInt get penyebut => _penyebut;
  bool get isNegatif => _pembilang < BigInt.zero;
  bool get isNol => _pembilang == BigInt.zero;
  bool get isPositif => _pembilang > BigInt.zero;

  // Operator Overloading untuk mendukung kalkulasi aritmatika natural
  DesimalBesar operator +(DesimalBesar lain) {
    BigInt num = (_pembilang * lain._penyebut) + (lain._pembilang * _penyebut);
    BigInt den = _penyebut * lain._penyebut;
    BigInt fpb = num.gcd(den);
    return DesimalBesar(num ~/ fpb, den ~/ fpb);
  }

  DesimalBesar operator -(DesimalBesar lain) {
    BigInt num = (_pembilang * lain._penyebut) - (lain._pembilang * _penyebut);
    BigInt den = _penyebut * lain._penyebut;
    BigInt fpb = num.gcd(den);
    return DesimalBesar(num ~/ fpb, den ~/ fpb);
  }

  DesimalBesar operator *(DesimalBesar lain) {
    BigInt num = _pembilang * lain._pembilang;
    BigInt den = _penyebut * lain._penyebut;
    BigInt fpb = num.gcd(den);
    return DesimalBesar(num ~/ fpb, den ~/ fpb);
  }

  DesimalBesar operator /(DesimalBesar lain) {
    if (lain.isNol) {
      throw ArgumentError("Pembagian dengan angka 0 tidak diperbolehkan!");
    }
    BigInt num = _pembilang * lain._penyebut;
    BigInt den = _penyebut * lain._pembilang;
    BigInt fpb = num.gcd(den);
    return DesimalBesar(num ~/ fpb, den ~/ fpb);
  }

  /// Memformat angka ke format mata uang Rupiah tanpa batas digit
  String formatRupiah() {
    bool neg = isNegatif;
    BigInt num = _pembilang.abs();
    BigInt den = _penyebut.abs();

    BigInt bulat = num ~/ den;
    BigInt sisa = num % den;

    // Pembulatan ke 2 tempat desimal
    BigInt duaDesimal = (sisa * BigInt.from(100) + (den ~/ BigInt.two)) ~/ den;
    if (duaDesimal >= BigInt.from(100)) {
      bulat += BigInt.one;
      duaDesimal = BigInt.zero;
    }

    String strBulat = bulat.toString();
    String hasilRibuan = "";
    int count = 0;
    for (int i = strBulat.length - 1; i >= 0; i--) {
      hasilRibuan = strBulat[i] + hasilRibuan;
      count++;
      if (count % 3 == 0 && i != 0) {
        hasilRibuan = "." + hasilRibuan;
      }
    }

    String strDesimal = "";
    if (duaDesimal > BigInt.zero) {
      strDesimal = ",${duaDesimal.toString().padLeft(2, '0')}";
    }

    return "${neg ? '-' : ''}Rp $hasilRibuan$strDesimal";
  }

  /// Memformat angka numerik umum
  String formatAngka() {
    bool neg = isNegatif;
    BigInt num = _pembilang.abs();
    BigInt den = _penyebut.abs();

    BigInt bulat = num ~/ den;
    BigInt sisa = num % den;

    BigInt duaDesimal = (sisa * BigInt.from(100) + (den ~/ BigInt.two)) ~/ den;
    if (duaDesimal >= BigInt.from(100)) {
      bulat += BigInt.one;
      duaDesimal = BigInt.zero;
    }

    String strBulat = bulat.toString();
    String hasilRibuan = "";
    int count = 0;
    for (int i = strBulat.length - 1; i >= 0; i--) {
      hasilRibuan = strBulat[i] + hasilRibuan;
      count++;
      if (count % 3 == 0 && i != 0) {
        hasilRibuan = "." + hasilRibuan;
      }
    }

    String strDesimal = "";
    if (duaDesimal > BigInt.zero) {
      strDesimal = ",${duaDesimal.toString().padLeft(2, '0')}";
    }

    return "${neg ? '-' : ''}$hasilRibuan$strDesimal";
  }

  /// Menghasilkan representasi string desimal presisi penuh tanpa batas digit
  String toDesimalString({int? maxDesimal}) {
    bool neg = isNegatif;
    BigInt num = _pembilang.abs();
    BigInt den = _penyebut.abs();

    BigInt bulat = num ~/ den;
    BigInt sisa = num % den;

    if (sisa == BigInt.zero) {
      return "${neg ? '-' : ''}$bulat";
    }

    StringBuffer pecahanBuffer = StringBuffer();
    int limit = maxDesimal ?? 50;
    while (sisa > BigInt.zero && pecahanBuffer.length < limit) {
      sisa *= BigInt.from(10);
      pecahanBuffer.write((sisa ~/ den).toString());
      sisa = sisa % den;
    }

    String frac = pecahanBuffer.toString();
    while (frac.endsWith('0')) {
      frac = frac.substring(0, frac.length - 1);
    }

    if (frac.isEmpty) {
      return "${neg ? '-' : ''}$bulat";
    }
    return "${neg ? '-' : ''}$bulat,$frac";
  }

  @override
  String toString() => formatRupiah();
}

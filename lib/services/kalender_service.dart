class KalenderService {
  // ==========================================
  // 1. KONVERSI KALENDER HIJRIAH
  // ==========================================
  static const List<String> namaBulanHijriah = [
    'Muharram',
    'Safar',
    'Rabi\'ul Awwal',
    'Rabi\'ul Akhir',
    'Jumadil Awwal',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadhan',
    'Syawal',
    'Dzulqa\'dah',
    'Dzulhijjah',
  ];

  static const List<String> namaHariIndonesia = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static Map<String, dynamic> konversiKeHijriah(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    final int a = (year / 100).floor();
    final int b = 2 - a + (a / 4).floor();
    final int jd =
        (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;

    // Menghitung Epoch Hijriah dari Julian Day (Kalibrasi kalender Islam Indonesia / Umm al-Qura)
    final double l = jd - 1948439 + 10632;
    final int n = ((l - 1) / 10631).floor();
    final double l2 = l - 10631 * n + 354;
    final int j =
        ((10985 - l2) / 5316).floor() * ((50 * l2) / 17719).floor() +
        (l2 / 5670).floor() * ((43 * l2) / 15238).floor();
    final double l3 =
        l2 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final int hMonth = ((24 * l3) / 709).floor();
    final int hDay = (l3 - ((709 * hMonth) / 24).floor()).floor();
    final int hYear = (30 * n + j - 30).floor();

    final bulanHijriahText = (hMonth >= 1 && hMonth <= 12)
        ? namaBulanHijriah[hMonth - 1]
        : 'Bulan $hMonth';

    final hariText = namaHariIndonesia[date.weekday - 1];

    return {
      'hari': hariText,
      'tanggal': hDay,
      'bulan': hMonth,
      'namaBulan': bulanHijriahText,
      'tahun': hYear,
      'formatted': '$hariText, $hDay $bulanHijriahText $hYear H',
    };
  }

  // ==========================================
  // 2. KALENDER WETON JAWA
  // ==========================================
  static const List<String> daftarPasaran = [
    'Legi',
    'Pahing',
    'Pon',
    'Wage',
    'Kliwon',
  ];

  // Neptu Hari Masehi (Minggu=5, Senin=4, Selasa=3, Rabu=7, Kamis=8, Jumat=6, Sabtu=9)
  static const Map<int, int> neptuHari = {
    DateTime.monday: 4,
    DateTime.tuesday: 3,
    DateTime.wednesday: 7,
    DateTime.thursday: 8,
    DateTime.friday: 6,
    DateTime.saturday: 9,
    DateTime.sunday: 5,
  };

  // Neptu Pasaran Jawa (Legi=5, Pahing=9, Pon=7, Wage=4, Kliwon=8)
  static const Map<String, int> neptuPasaran = {
    'Legi': 5,
    'Pahing': 9,
    'Pon': 7,
    'Wage': 4,
    'Kliwon': 8,
  };

  /// Menghitung Weton Jawa (Dino, Pasaran, dan Neptu)
  static Map<String, dynamic> hitungWeton(DateTime date) {
    // Referensi acuan terverifikasi: 11 November 2005 adalah Jumat Pahing
    // Hari: Jumat (weekday 5), Pasaran: Pahing (index 1 dalam [Legi, Pahing, Pon, Wage, Kliwon])
    final refDate = DateTime.utc(2005, 11, 11);
    final targetDate = DateTime.utc(date.year, date.month, date.day);
    final diffDays = targetDate.difference(refDate).inDays;

    final pasaranIndex = ((diffDays + 1) % 5 + 5) % 5;
    final pasaran = daftarPasaran[pasaranIndex];

    final namaHari = namaHariIndonesia[date.weekday - 1];
    final nHari = neptuHari[date.weekday] ?? 0;
    final nPasaran = neptuPasaran[pasaran] ?? 0;
    final totalNeptu = nHari + nPasaran;

    String makna;
    if (totalNeptu <= 10) {
      makna = 'Watak tenang, teliti, hemat, dan berjiwa perintis.';
    } else if (totalNeptu <= 14) {
      makna = 'Watak ramah, pekerja keras, adaptif, dan disukai banyak orang.';
    } else {
      makna = 'Watak berwibawa, berjiwa pemimpin, teguh pendirian, dan berani.';
    }

    return {
      'hari': namaHari,
      'pasaran': pasaran,
      'weton': '$namaHari $pasaran',
      'neptuHari': nHari,
      'neptuPasaran': nPasaran,
      'totalNeptu': totalNeptu,
      'makna': makna,
    };
  }

  // ==========================================
  // 3. KALENDER SAKA BALI
  // ==========================================
  static const List<String> daftarWukuBali = [
    'Sinta',
    'Landep',
    'Ukir',
    'Kulantir',
    'Tolu',
    'Gumbreg',
    'Wariga',
    'Warigadean',
    'Julungwangi',
    'Sungsang',
    'Dungulan',
    'Kuningan',
    'Langkir',
    'Medangsia',
    'Pujut',
    'Pahang',
    'Krulut',
    'Merakih',
    'Tambir',
    'Medangkungan',
    'Matal',
    'Uye',
    'Menail',
    'Prangbakat',
    'Bala',
    'Ugu',
    'Wayang',
    'Kelawu',
    'Dukut',
    'Watugunung',
  ];

  static const List<String> daftarHariBali = [
    'Redite',
    'Soma',
    'Anggara',
    'Buda',
    'Wraspati',
    'Sukra',
    'Saniscara',
  ];

  static const List<String> daftarPasaranBali = [
    'Umanis',
    'Paing',
    'Pon',
    'Wage',
    'Kliwon',
  ];

  static const List<String> daftarSasihBali = [
    'Kasa',
    'Karo',
    'Katiga',
    'Kapat',
    'Kelima',
    'Kanem',
    'Kapitu',
    'Kawolu',
    'Kasanga',
    'Kedasa',
    'Jyestha',
    'Sadha',
  ];

  /// Menghitung Kalender Saka Bali (Tahun Saka, Sasih, Wuku)
  static Map<String, dynamic> hitungSakaBali(DateTime date) {
    // Tahun Saka = Tahun Masehi - 78 (setelah Nyepi bulan Maret)
    int tahunSaka = date.year - 78;
    if (date.month < 3 || (date.month == 3 && date.day < 22)) {
      tahunSaka -= 1;
    }

    // Perhitungan Wuku (Siklus 210 hari)
    // Referensi acuan: 11 November 2005 adalah Sukra Paing Pahang (Wuku ke-15 'Pahang', hari ke-5 Sukra)
    final ref = DateTime.utc(2005, 11, 11);
    final target = DateTime.utc(date.year, date.month, date.day);
    final diff = target.difference(ref).inDays;
    final wukuDayIndex = ((diff + (15 * 7 + 5)) % 210 + 210) % 210;
    final wukuIndex = (wukuDayIndex / 7).floor() % 30;
    final wukuName = daftarWukuBali[wukuIndex];

    // Saptawara (Hari Bali) & Pancawara (Pasaran Bali)
    final hariBali = daftarHariBali[date.weekday % 7];
    final pasaranBaliIndex = ((diff + 1) % 5 + 5) % 5;
    final pasaranBali = daftarPasaranBali[pasaranBaliIndex];

    // Sasih Bali (Bulan Saka: November jatuh pada Sasih Kelima)
    final sasihIndex = (date.month + 5) % 12;
    final sasihName = daftarSasihBali[sasihIndex];

    return {
      'tahunSaka': tahunSaka,
      'wuku': wukuName,
      'sasih': sasihName,
      'hariBali': hariBali,
      'pasaranBali': pasaranBali,
      'pawukon': '$hariBali $pasaranBali $wukuName',
      'formatted': 'Tahun Saka $tahunSaka\n$hariBali $pasaranBali $wukuName',
    };
  }

  // ==========================================
  // 4. KONVERSI TANGGAL LAHIR (UMUR DETAIL)
  // ==========================================
  /// Menghitung rincian umur: Tahun, Bulan, Hari, Jam, Menit, Detik
  static Map<String, dynamic> hitungUmurDetail(
    DateTime birthDate, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    if (current.isBefore(birthDate)) {
      return {
        'tahun': 0,
        'bulan': 0,
        'hari': 0,
        'jam': 0,
        'menit': 0,
        'detik': 0,
        'isValid': false,
      };
    }

    int years = current.year - birthDate.year;
    int months = current.month - birthDate.month;
    int days = current.day - birthDate.day;
    int hours = current.hour - birthDate.hour;
    int minutes = current.minute - birthDate.minute;
    int seconds = current.second - birthDate.second;

    if (seconds < 0) {
      seconds += 60;
      minutes -= 1;
    }
    if (minutes < 0) {
      minutes += 60;
      hours -= 1;
    }
    if (hours < 0) {
      hours += 24;
      days -= 1;
    }
    if (days < 0) {
      // Ambil jumlah hari pada bulan sebelumnya
      final prevMonth = DateTime(current.year, current.month, 0);
      days += prevMonth.day;
      months -= 1;
    }
    if (months < 0) {
      months += 12;
      years -= 1;
    }

    final totalDays = current.difference(birthDate).inDays;
    final totalHours = current.difference(birthDate).inHours;
    final totalMinutes = current.difference(birthDate).inMinutes;
    final totalSeconds = current.difference(birthDate).inSeconds;

    return {
      'tahun': years,
      'bulan': months,
      'hari': days,
      'jam': hours,
      'menit': minutes,
      'detik': seconds,
      'totalHari': totalDays,
      'totalJam': totalHours,
      'totalMenit': totalMinutes,
      'totalDetik': totalSeconds,
      'isValid': true,
    };
  }
}

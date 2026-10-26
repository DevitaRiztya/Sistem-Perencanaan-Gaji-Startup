-- Skrip Inisialisasi Database SQLite: karyawan_payroll.db
-- Topik: Aplikasi Perencanaan Gaji Karyawan pada Startup
-- PRAGMA user_version = 2 disesuaikan dengan _dbVersion pada KaryawanDatabaseHelper

PRAGMA foreign_keys = ON;
PRAGMA user_version = 2;

-- ============================================================
-- 1. TABEL KARYAWAN (Data Karyawan Tetap)
-- ============================================================
DROP TABLE IF EXISTS tabel_karyawan;
CREATE TABLE tabel_karyawan (
  id          TEXT PRIMARY KEY,
  nama        TEXT NOT NULL,
  jabatan     TEXT NOT NULL,
  tanggalLahir TEXT NOT NULL,
  alamat      TEXT NOT NULL,
  noTelepon   TEXT NOT NULL,
  gajiPokok   REAL NOT NULL DEFAULT 0,
  tunjangan   REAL NOT NULL DEFAULT 0,
  potongan    REAL NOT NULL DEFAULT 0,
  hariLembur  INTEGER NOT NULL DEFAULT 0,
  createdAt   TEXT NOT NULL
);

-- ============================================================
-- 2. TABEL CALON KARYAWAN (Kandidat Rekrutmen)
-- ============================================================
DROP TABLE IF EXISTS tabel_calon_karyawan;
CREATE TABLE tabel_calon_karyawan (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  nama        TEXT NOT NULL,
  posisi      TEXT NOT NULL,
  gajiPokok   TEXT NOT NULL,
  tunjangan   TEXT NOT NULL,
  jamLembur   TEXT NOT NULL,
  tarifLembur TEXT NOT NULL,
  hariKerja   INTEGER NOT NULL DEFAULT 1,
  potongan    TEXT NOT NULL,
  createdAt   TEXT NOT NULL
);

-- ============================================================
-- 3. TABEL PERENCANAAN GAJI (Riwayat Simulasi Kalkulasi)
-- ============================================================
DROP TABLE IF EXISTS tabel_perencanaan_gaji;
CREATE TABLE tabel_perencanaan_gaji (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  namaKandidat    TEXT NOT NULL,
  posisi          TEXT NOT NULL,
  gajiPokok       TEXT NOT NULL,
  tunjangan       TEXT NOT NULL,
  jamLembur       TEXT NOT NULL,
  tarifLembur     TEXT NOT NULL,
  hariKerja       INTEGER NOT NULL DEFAULT 1,
  potongan        TEXT NOT NULL,
  hasilUangLembur TEXT NOT NULL,
  hasilGajiKotor  TEXT NOT NULL,
  hasilGajiBersih TEXT NOT NULL,
  hasilGajiPerHari TEXT NOT NULL,
  tanggalSimulasi TEXT NOT NULL
);

-- ============================================================
-- SEED DATA: TABEL KARYAWAN (Sesuai _seedInitialData)
-- ============================================================
INSERT INTO tabel_karyawan (id, nama, jabatan, tanggalLahir, alamat, noTelepon, gajiPokok, tunjangan, potongan, hariLembur, createdAt)
VALUES 
  ('EMP-001', 'Budi', 'Software Engineer', '2005-11-11T00:00:00.000', 'Jl. Malioboro No. 10, Yogyakarta', '081234567890', 8500000.0, 1500000.0, 250000.0, 3, '2026-09-07T10:00:00.000'),
  ('EMP-002', 'Ahmad Fauzi', 'Senior Backend Engineer', '2002-05-15T00:00:00.000', 'Jl. Kaliurang KM 5, Sleman', '081234567891', 12500000.0, 2500000.0, 350000.0, 4, '2026-09-09T10:00:00.000'),
  ('EMP-003', 'Siti Rahmawati', 'UI/UX Product Designer', '2003-05-20T00:00:00.000', 'Jl. Gejayan No. 22, Yogyakarta', '081234567892', 9500000.0, 1800000.0, 250000.0, 2, '2026-09-12T10:00:00.000'),
  ('EMP-004', 'Dewi Lestari', 'Quality Assurance Analyst', '2004-08-15T00:00:00.000', 'Jl. Solo KM 8, Sleman', '081234567893', 8000000.0, 1500000.0, 200000.0, 1, '2026-09-15T10:00:00.000');

-- ============================================================
-- SEED DATA: TABEL CALON KARYAWAN
-- ============================================================
INSERT INTO tabel_calon_karyawan (nama, posisi, gajiPokok, tunjangan, jamLembur, tarifLembur, hariKerja, potongan, createdAt)
VALUES 
  ('Rian Pratama', 'Frontend Developer', '7500000', '1000000', '10', '50000', 22, '150000', '2026-09-16T09:00:00.000'),
  ('Nadia Putri', 'Product Manager', '11000000', '2000000', '5', '75000', 22, '250000', '2026-09-16T14:30:00.000');

-- ============================================================
-- SEED DATA: TABEL PERENCANAAN GAJI
-- ============================================================
INSERT INTO tabel_perencanaan_gaji (namaKandidat, posisi, gajiPokok, tunjangan, jamLembur, tarifLembur, hariKerja, potongan, hasilUangLembur, hasilGajiKotor, hasilGajiBersih, hasilGajiPerHari, tanggalSimulasi)
VALUES 
  ('Rian Pratama', 'Frontend Developer', '7500000', '1000000', '10', '50000', 22, '150000', '500000', '9000000', '8850000', '402272.73', '2026-09-16T09:15:00.000'),
  ('Nadia Putri', 'Product Manager', '11000000', '2000000', '5', '75000', 22, '250000', '375000', '13375000', '13125000', '596590.91', '2026-09-16T14:45:00.000');

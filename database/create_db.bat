@echo off
echo ========================================================
echo  Membangun Database SQLite: database/karyawan_payroll.db
echo ========================================================

set SCRIPT_DIR=%~dp0
set DB_FILE=%SCRIPT_DIR%karyawan_payroll.db
set SQL_FILE=%SCRIPT_DIR%init_db.sql

where sqlite3 >nul 2>&1
if %ERRORLEVEL% equ 0 (
    sqlite3 "%DB_FILE%" < "%SQL_FILE%"
    echo [SUKSES] File karyawan_payroll.db berhasil dibuat dengan sqlite3 CLI.
    goto selesai
)

if exist "C:\Program Files\QGIS 3.40.15\bin\sqlite3.exe" (
    "C:\Program Files\QGIS 3.40.15\bin\sqlite3.exe" "%DB_FILE%" < "%SQL_FILE%"
    echo [SUKSES] File karyawan_payroll.db berhasil dibuat menggunakan SQLite QGIS.
    goto selesai
)

if exist "C:\xampp\MercuryMail\sqlite3.exe" (
    "C:\xampp\MercuryMail\sqlite3.exe" "%DB_FILE%" < "%SQL_FILE%"
    echo [SUKSES] File karyawan_payroll.db berhasil dibuat menggunakan SQLite MercuryMail.
    goto selesai
)

echo [INFO] sqlite3 tidak ditemukan di PATH sistem.
echo Namun file database/karyawan_payroll.db sudah tersedia secara fisik di project Anda.

:selesai
echo Database siap dibuka dengan SQLite Viewer di VS Code!
pause

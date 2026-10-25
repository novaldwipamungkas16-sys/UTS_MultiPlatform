# FinTrack — Aplikasi Catatan Keuangan Multiplatform

FinTrack adalah aplikasi pencatatan keuangan pribadi berbasis **Flutter dan Dart**. Aplikasi ini membantu pengguna mencatat pemasukan, pengeluaran, saldo, kategori transaksi, dan target anggaran bulanan.

Project ini dibuat untuk memenuhi tugas UTS Mata Kuliah Pemrograman Multiplatform.

## 👤 Pembuat

- **Nama:** Noval Dwi Pamungkas
- **NIM:** 240605110040
- **Program Studi:** Teknik Informatika
- **Fakultas:** Sains dan Teknologi
- **Universitas:** Universitas Islam Negeri Maulana Malik Ibrahim Malang

## 🎯 Tujuan Aplikasi

FinTrack dirancang sebagai aplikasi keuangan pribadi yang dapat digunakan secara offline. Pengguna dapat menyimpan dan mengelola data transaksi secara lokal tanpa bergantung pada koneksi internet.

## ✨ Fitur Utama

- Dashboard saldo bersih, pemasukan, dan pengeluaran.
- Tambah, baca, ubah, dan hapus transaksi.
- Kategori pemasukan dan pengeluaran.
- Pencarian transaksi.
- Filter transaksi berdasarkan tipe.
- Statistik pengeluaran berdasarkan kategori.
- Target anggaran bulanan.
- Mode terang dan mode gelap.
- Penyimpanan transaksi menggunakan SQLite.
- Penyimpanan preferensi menggunakan SharedPreferences.
- Pemuatan data menggunakan asynchronous programming.
- Swipe-to-dismiss untuk menghapus transaksi.
- Tips finansial dengan simulasi proses asinkron.

## 🧠 Konsep Pemrograman yang Diterapkan

### Asynchronous Programming

Project menggunakan:

- `Future`
- `async`
- `await`
- `Future.wait`
- `Future.delayed`

Konsep tersebut digunakan saat membaca dan menyimpan data SQLite, membaca preferensi pengguna, serta memuat tips finansial.

### Data Persistence

Project menerapkan dua teknik penyimpanan data:

1. **SQLite** — menyimpan data transaksi keuangan terstruktur.
2. **SharedPreferences** — menyimpan mode tema, nama pengguna, dan target anggaran bulanan.

## 🛠️ Teknologi dan Package

- Flutter 3.47.2
- Dart 3.13.2
- `sqflite`
- `sqflite_common_ffi`
- `shared_preferences`
- `path_provider`
- `path`
- `intl`

## 📁 Struktur Project

```text
UTS/
├── README.md
├── Laporan_UTS_FinTrack_Noval_240605110040_Revisi_Format.docx
├── create_report.py
├── revise_report.py
└── fintrack_app/
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   └── widgets/
    ├── test/
    ├── screenshots/
    ├── android/
    ├── ios/
    ├── windows/
    ├── web/
    ├── pubspec.yaml
    └── README.md
```

## 🚀 Cara Menjalankan

### Prasyarat

- Flutter SDK terpasang.
- Android Studio atau VS Code.
- Android Emulator atau perangkat Android.
- Developer Mode Windows aktif jika menjalankan project melalui Windows.

### Menjalankan Project

Masuk ke folder aplikasi:

```bash
cd fintrack_app
```

Ambil dependency:

```bash
flutter pub get
```

Jalankan pengujian:

```bash
flutter test
```

Jalankan aplikasi pada emulator Android:

```bash
flutter run
```

Jalankan aplikasi pada Windows:

```bash
flutter run -d windows
```

Jalankan aplikasi pada Chrome:

```bash
flutter run -d chrome
```

## 🧪 Pengujian

Pengujian otomatis mencakup:

- Model transaksi.
- Serialisasi dan deserialisasi data.
- Operasi SQLite.
- Operasi CRUD transaksi.
- Perhitungan saldo dan kategori.
- Penyimpanan SharedPreferences.
- Proses asynchronous programming.

Hasil pengujian terakhir: **semua test berhasil lulus**.

## 📄 Dokumentasi

Laporan lengkap tersedia pada file:

```text
Laporan_UTS_FinTrack_Noval_240605110040_Revisi_Format.docx
```

Dokumentasi teknis khusus source code tersedia pada:

```text
fintrack_app/README.md
```

---

Dibuat untuk UTS Pemrograman Multiplatform — 2026.

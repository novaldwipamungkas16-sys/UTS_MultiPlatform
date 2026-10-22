// File: lib/main.dart
// Entry point utama aplikasi FinTrack - Catatan Keuangan Multiplatform
// Mengatur inisialisasi awal, tema persisten (SharedPreferences), dan konfigurasi aplikasi.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/home_screen.dart';
import 'services/preference_service.dart';

void main() async {
  // Memastikan binding Flutter engine telah terinisialisasi sebelum operasi asinkron
  WidgetsFlutterBinding.ensureInitialized();

  // Menyiapkan data locale Indonesia sebelum DateFormat dipakai di UI transaksi.
  await initializeDateFormatting('id_ID');

  // Inisialisasi basis data SQLite FFI jika berjalan di platform Desktop (Windows / Linux)
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Membaca preferensi mode tema pengguna dari SharedPreferences secara asinkron
  final bool initialDarkMode = await PreferenceService.isDarkMode();

  // Jalankan aplikasi dengan state tema awal
  runApp(FinTrackApp(initialDarkMode: initialDarkMode));
}

class FinTrackApp extends StatefulWidget {
  final bool initialDarkMode;

  const FinTrackApp({super.key, required this.initialDarkMode});

  @override
  State<FinTrackApp> createState() => _FinTrackAppState();
}

class _FinTrackAppState extends State<FinTrackApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  // Callback untuk mengubah tema aplikasi secara dinamis
  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack - Catatan Keuangan',
      debugShowCheckedModeBanner: false,

      // Konfigurasi Tema Terang (Light Mode)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
      ),

      // Konfigurasi Tema Gelap (Dark Mode)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B132B),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1C2541),
          elevation: 0,
        ),
      ),

      // Mengikuti state _isDarkMode yang disimpan di SharedPreferences
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Halaman beranda utama
      home: HomeScreen(onThemeChanged: _toggleTheme),
    );
  }
}

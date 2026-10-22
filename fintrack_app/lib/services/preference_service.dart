// File: lib/services/preference_service.dart
// Pengelolaan Penyimpanan Pengaturan Lokal Menggunakan SharedPreferences (Teknik Data Persistence 2)
// Menyimpan data sederhana berupa pasangan key-value (Tema, Nama Pengguna, Target Anggaran)
// Menerapkan konsep Asynchronous Programming (Future, async, await) untuk operasi I/O disk.

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  // Kunci-kunci (keys) penyimpanan SharedPreferences
  static const String _keyDarkMode = 'is_dark_mode';            // Key preferensi tema gelap
  static const String _keyUserName = 'user_name';                // Key nama profil pengguna
  static const String _keyMonthlyBudget = 'monthly_budget';      // Key batas budget bulanan

  // BACA: Membaca status tema gelap/terang secara asinkron
  // Mengembalikan nilai boolean (true = Gelap, false = Terang)
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();        // Dapatkan instance SharedPreferences secara async
    return prefs.getBool(_keyDarkMode) ?? false;                // Default: false (Tema Terang) jika belum diatur
  }

  // SIMPAN: Menyimpan preferensi tema ke memori lokal SharedPreferences
  static Future<bool> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyDarkMode, value);            // Simpan status boolean (true/false)
  }

  // BACA: Membaca nama pengguna yang tersimpan secara asinkron
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'Noval Dwi Pamungkas'; // Default: nama mahasiswa
  }

  // SIMPAN: Menyimpan nama profil pengguna ke SharedPreferences
  static Future<bool> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyUserName, name.trim());     // Simpan string nama
  }

  // BACA: Membaca batas anggaran belanja bulanan secara asinkron
  static Future<double> getMonthlyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonthlyBudget) ?? 2500000.0;      // Default anggaran Rp 2.500.000
  }

  // SIMPAN: Menyimpan target batas anggaran belanja bulanan
  static Future<bool> setMonthlyBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble(_keyMonthlyBudget, budget);     // Simpan nilai double budget
  }

  // HAPUS: Membersihkan seluruh preferensi pengguna jika diperlukan
  static Future<bool> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}

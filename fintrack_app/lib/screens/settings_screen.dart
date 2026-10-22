// File: lib/screens/settings_screen.dart
// Halaman Pengaturan Aplikasi (Settings & Preferences)
// Mengimplementasikan manipulasi data persistence SharedPreferences dan pembersihan basis data SQLite.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/preference_service.dart';
import '../services/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;   // Callback untuk mengubah tema di root widget
  final VoidCallback onDataReset;        // Callback saat data SQLite di-reset

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onDataReset,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDark = false;                  // Status tema saat ini
  String _userName = '';                 // Nama pengguna
  double _monthlyBudget = 0.0;           // Target anggaran bulanan
  bool _isLoading = true;                // Indikator loading saat membaca SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadPreferences();                  // Baca preferensi awal dari SharedPreferences
  }

  // Fungsi asinkron untuk memuat semua pengaturan dari SharedPreferences
  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    final dark = await PreferenceService.isDarkMode();
    final name = await PreferenceService.getUserName();
    final budget = await PreferenceService.getMonthlyBudget();

    if (mounted) {
      setState(() {
        _isDark = dark;
        _userName = name;
        _monthlyBudget = budget;
        _isLoading = false;
      });
    }
  }

  // Dialog asinkron untuk mengubah nama pengguna
  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: _userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama Pengguna'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            hintText: 'Masukkan nama Anda...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      // Simpan perubahan ke SharedPreferences secara asinkron
      await PreferenceService.setUserName(result.trim());
      setState(() {
        _userName = result.trim();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama berhasil diperbarui di SharedPreferences!')),
        );
      }
    }
  }

  // Dialog asinkron untuk mengubah anggaran bulanan
  Future<void> _showEditBudgetDialog() async {
    final controller = TextEditingController(text: _monthlyBudget.toStringAsFixed(0));
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atur Target Anggaran'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target Anggaran Bulanan (Rp)',
            prefixText: 'Rp ',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final newBudget = double.tryParse(result.replaceAll(',', ''));
      if (newBudget != null && newBudget > 0) {
        await PreferenceService.setMonthlyBudget(newBudget);
        setState(() {
          _monthlyBudget = newBudget;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Batas anggaran berhasil disimpan di SharedPreferences!')),
          );
        }
      }
    }
  }

  // Dialog konfirmasi untuk menghapus seluruh data transaksi SQLite
  Future<void> _confirmClearDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Basis Data SQLite?'),
        content: const Text(
          'Semua catatan transaksi keuangan akan dihapus permanen dari basis data SQLite. Aksi ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Semua Data'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Eksekusi asinkron penghapusan tabel transaksi di SQLite
      await DatabaseHelper.instance.clearAllTransactions();
      widget.onDataReset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seluruh data transaksi SQLite telah dibersihkan!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Preferensi'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Bagian 1: Preferensi Tampilan & Akun (SharedPreferences)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'Preferensi Pengguna (SharedPreferences)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      // Switch Tema Gelap
                      SwitchListTile(
                        secondary: Icon(
                          _isDark ? Icons.dark_mode : Icons.light_mode,
                          color: _isDark ? Colors.amber : Colors.blueGrey,
                        ),
                        title: const Text('Mode Gelap (Dark Mode)'),
                        subtitle: Text(
                          _isDark ? 'Tema gelap aktif' : 'Tema terang aktif',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: _isDark,
                        onChanged: (val) async {
                          setState(() => _isDark = val);
                          // Simpan perubahan ke SharedPreferences secara asinkron
                          await PreferenceService.setDarkMode(val);
                          widget.onThemeChanged(val);
                        },
                      ),
                      const Divider(height: 1),

                      // Nama Pengguna
                      ListTile(
                        leading: const Icon(Icons.person_outline, color: Colors.blueAccent),
                        title: const Text('Nama Pengguna'),
                        subtitle: Text(_userName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showEditNameDialog,
                      ),
                      const Divider(height: 1),

                      // Batas Anggaran Bulanan
                      ListTile(
                        leading: const Icon(Icons.savings_outlined, color: Colors.green),
                        title: const Text('Batas Anggaran Bulanan'),
                        subtitle: Text(formatCurrency.format(_monthlyBudget)),
                        trailing: const Icon(Icons.edit_outlined),
                        onTap: _showEditBudgetDialog,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bagian 2: Manajemen Basis Data (SQLite)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'Manajemen Data Lokal (SQLite)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    title: const Text(
                      'Hapus Seluruh Data Transaksi',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Mengosongkan tabel transaksi di fintrack.db'),
                    onTap: _confirmClearDatabase,
                  ),
                ),
                const SizedBox(height: 20),

                // Bagian 3: Identitas Mahasiswa & Pengembang
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'Informasi Tugas & Pengembang',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.school, color: Colors.blueAccent),
                            SizedBox(width: 10),
                            Text(
                              'UTS Pemrograman Multiplatform',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text('• Mahasiswa : Noval Dwi Pamungkas'),
                        SizedBox(height: 4),
                        Text('• NIM : 240605110040'),
                        SizedBox(height: 4),
                        Text('• Kelas : A (Semester 5)'),
                        SizedBox(height: 4),
                        Text('• Program Studi : Teknik Informatika'),
                        SizedBox(height: 4),
                        Text('• Fakultas : Sains dan Teknologi'),
                        SizedBox(height: 4),
                        Text('• Kampus : UIN Maulana Malik Ibrahim Malang'),
                        SizedBox(height: 4),
                        Text('• Dosen Pengampu : A\'la Syauqi, M.Kom'),
                        SizedBox(height: 12),
                        Divider(),
                        SizedBox(height: 4),
                        Text(
                          'Teknologi: Flutter 3.47.2, Dart 3.13.2, SQLite (sqflite), SharedPreferences, Async/Await.',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }
}

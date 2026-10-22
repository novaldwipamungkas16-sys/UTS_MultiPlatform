// File: lib/screens/home_screen.dart
// Halaman Utama Aplikasi FinTrack (Dashboard Finansial)
// Mengintegrasikan Asynchronous Programming, SQLite Database, dan SharedPreferences.

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';
import '../services/preference_service.dart';
import '../services/quote_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';
import 'add_edit_transaction_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;   // Callback untuk mengubah tema aplikasi di root widget

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State data transaksi dari SQLite
  List<TransactionModel> _transactions = [];
  double _balance = 0.0;
  double _income = 0.0;
  double _expense = 0.0;

  // State preferensi dari SharedPreferences
  String _userName = 'Noval Dwi Pamungkas';
  double _monthlyBudget = 2500000.0;

  // State filter & pencarian
  String _filterType = 'all';            // 'all', 'income', atau 'expense'
  String _searchQuery = '';              // Kata kunci pencarian
  final TextEditingController _searchController = TextEditingController();

  // State async quote harian & status loading
  String _dailyQuote = '';
  bool _isLoadingQuote = true;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadAllInitialData();               // Muat seluruh data awal secara asinkron
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi komprehensif untuk memuat seluruh data secara asinkron
  Future<void> _loadAllInitialData() async {
    setState(() => _isLoadingData = true);
    await Future.wait([
      _loadPreferences(),                // Baca SharedPreferences secara async
      _loadTransactions(),               // Query SQLite secara async
      _loadDailyQuote(),                 // Simulasi async fetch quote eksternal
    ]);
    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  // Membaca preferensi dari SharedPreferences secara asinkron
  Future<void> _loadPreferences() async {
    final name = await PreferenceService.getUserName();
    final budget = await PreferenceService.getMonthlyBudget();
    if (mounted) {
      setState(() {
        _userName = name;
        _monthlyBudget = budget;
      });
    }
  }

  // Membaca transaksi dan agregat dari SQLite secara asinkron
  Future<void> _loadTransactions() async {
    final txList = await DatabaseHelper.instance.getAllTransactions(
      filterType: _filterType,
      searchKeyword: _searchQuery,
    );
    final totals = await DatabaseHelper.instance.getSummaryTotals();

    if (mounted) {
      setState(() {
        _transactions = txList;
        _income = totals['income'] ?? 0.0;
        _expense = totals['expense'] ?? 0.0;
        _balance = totals['balance'] ?? 0.0;
      });
    }
  }

  // Mengambil kutipan edukasi finansial secara asinkron dengan simulasi delay
  Future<void> _loadDailyQuote() async {
    setState(() => _isLoadingQuote = true);
    final quote = await QuoteService.fetchDailyFinancialTip();
    if (mounted) {
      setState(() {
        _dailyQuote = quote;
        _isLoadingQuote = false;
      });
    }
  }

  // Fungsi asinkron untuk menghapus satu transaksi
  Future<void> _deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await _loadTransactions(); // Refresh data setelah penghapusan
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan transaksi berhasil dihapus dari SQLite!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Navigasi ke halaman Tambah / Edit Transaksi
  Future<void> _openAddEditScreen([TransactionModel? transaction]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(transaction: transaction),
      ),
    );
    // Jika ada aksi penyimpanan data (result == true), refresh data dari database
    if (result == true) {
      await _loadTransactions();
    }
  }

  // Navigasi ke halaman Pengaturan (Settings)
  Future<void> _openSettingsScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
          onDataReset: () async {
            await _loadTransactions();
          },
        ),
      ),
    );
    // Muat ulang preferensi dan transaksi setelah kembali dari pengaturan
    await _loadPreferences();
    await _loadTransactions();
  }

  // Navigasi ke halaman Statistik Visual
  void _openStatisticsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? Colors.blueGrey.shade800 : Colors.blue.shade100,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.blueAccent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Halo, Selamat Datang!',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    _userName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Halaman Statistik Kategori
          IconButton(
            icon: const Icon(Icons.insert_chart_outlined),
            tooltip: 'Statistik Kategori',
            onPressed: _openStatisticsScreen,
          ),
          // Tombol Pengaturan
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan & Preferensi',
            onPressed: _openSettingsScreen,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllInitialData, // Tarik ke bawah untuk refresh asinkron
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Widget 1: Card Ringkasan Finansial (SummaryCard)
                  SummaryCard(
                    balance: _balance,
                    income: _income,
                    expense: _expense,
                    monthlyBudget: _monthlyBudget,
                  ),
                  const SizedBox(height: 16),

                  // Widget 2: Banner Edukasi & Motivasi Finansial (Asynchronous Simulation)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.blueGrey.shade700 : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isLoadingQuote
                              ? const Text(
                                  'Memuat tips keuangan hari ini...',
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                )
                              : Text(
                                  _dailyQuote,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: isDark ? Colors.grey.shade300 : const Color(0xFF1E3A8A),
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          tooltip: 'Ambil Tips Baru (Async)',
                          onPressed: _loadDailyQuote,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Widget 3: Kotak Input Pencarian Transaksi
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari transaksi atau kategori...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadTransactions();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      _loadTransactions(); // Filter realtime secara asinkron
                    },
                  ),
                  const SizedBox(height: 14),

                  // Widget 4: Filter Chips (Semua, Pemasukan, Pengeluaran)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Semua Transaksi'),
                          selected: _filterType == 'all',
                          onSelected: (selected) {
                            setState(() => _filterType = 'all');
                            _loadTransactions();
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          avatar: const Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                          label: const Text('Pemasukan'),
                          selected: _filterType == 'income',
                          onSelected: (selected) {
                            setState(() => _filterType = 'income');
                            _loadTransactions();
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          avatar: const Icon(Icons.arrow_upward, color: Colors.redAccent, size: 16),
                          label: const Text('Pengeluaran'),
                          selected: _filterType == 'expense',
                          onSelected: (selected) {
                            setState(() => _filterType = 'expense');
                            _loadTransactions();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Riwayat Transaksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat Transaksi (${_transactions.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_transactions.isNotEmpty)
                        const Text(
                          'Geser kartu untuk hapus',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Widget 5: Daftar Transaksi (ListView SQLite)
                  if (_transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada catatan transaksi.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Ketuk tombol (+) di bawah untuk mencatat transaksi pertamamu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._transactions.map((tx) {
                      return TransactionCard(
                        transaction: tx,
                        onTap: () => _openAddEditScreen(tx),
                        onDelete: () => _deleteTransaction(tx.id!),
                      );
                    }),
                  const SizedBox(height: 80), // Ruang ekstra agar tidak tertutup FAB
                ],
              ),
      ),
      // Floating Action Button: Tambah Transaksi
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditScreen(),
        icon: const Icon(Icons.add),
        label: const Text('Catat Transaksi'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

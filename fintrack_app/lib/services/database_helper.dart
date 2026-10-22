// File: lib/services/database_helper.dart
// Pengelolaan Basis Data Lokal Menggunakan SQLite (Teknik Data Persistence 1)
// Menerapkan konsep Asynchronous Programming (Future, async, await) untuk semua operasi I/O database.

import 'dart:io';                                      // Untuk mengecek platform OS aplikasi
import 'package:sqflite_common_ffi/sqflite_ffi.dart';  // Dukungan SQLite untuk Desktop (Windows/Linux) dan mobile
import 'package:path/path.dart';                      // Utilitas manipulasi path direktori berkas
import '../models/transaction_model.dart';           // Model data transaksi keuangan

class DatabaseHelper {
  // Singleton pattern: memastikan hanya ada satu instance DatabaseHelper yang aktif
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Private constructor
  DatabaseHelper._init();

  // Getter asinkron untuk mengambil instance database SQLite
  // Mengembalikan objek Database di dalam Future untuk mencegah UI thread terblokir
  Future<Database> get database async {
    if (_database != null) return _database!;          // Jika sudah terbuka, kembalikan instance yang ada
    _database = await _initDB('fintrack.db');          // Jika belum, inisialisasi file database fintrack.db
    return _database!;
  }

  // Fungsi inisialisasi basis data secara asinkron
  Future<Database> _initDB(String filePath) async {
    // Apabila berjalan di Windows atau Linux Desktop, aktifkan backend FFI
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();                               // Inisialisasi library C sqlite ffi
      databaseFactory = databaseFactoryFfi;            // Atur databaseFactory global ke engine FFI
    }

    // Mendapatkan direktori penyimpanan basis data lokal perangkat secara asinkron
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);               // Menggabungkan path direktori dengan nama berkas

    // Membuka database dengan konfigurasi versi dan skema tabel awal
    return await openDatabase(
      path,
      version: 1,                                      // Versi skema basis data
      onCreate: _createDB,                             // Callback pembuat tabel saat DB pertama kali dibuat
    );
  }

  // Fungsi pembuatan tabel transaksi saat basis data pertama kali dibuat
  Future<void> _createDB(Database db, int version) async {
    // Definisi tipe data SQL: INTEGER, TEXT, REAL
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const textNullable = 'TEXT';

    // Eksekusi DDL query SQL untuk membuat tabel 'transactions'
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        title $textType,
        amount $realType,
        type $textType,
        category $textType,
        date $textType,
        note $textNullable
      )
    ''');
  }

  // CREATE: Menyimpan transaksi baru ke basis data SQLite
  // Mengembalikan ID transaksi yang baru di-generate
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;                         // Tunggu koneksi database terbuka (asinkron)
    final id = await db.insert(
      'transactions',                                  // Nama tabel target
      transaction.toMap(),                             // Data dalam format Map
      conflictAlgorithm: ConflictAlgorithm.replace,    // Ganti jika terjadi konflik kunci
    );
    return id;                                         // Kembalikan primary key baru
  }

  // READ: Mengambil seluruh data transaksi dengan fleksibilitas filter dan pencarian
  Future<List<TransactionModel>> getAllTransactions({
    String? filterType,                                // Filter 'income', 'expense', atau null untuk semua
    String? searchKeyword,                             // Kata kunci pencarian judul atau kategori
  }) async {
    final db = await database;                         // Tunggu akses database selesai
    String? whereClause;                               // Klausul WHERE SQL
    List<dynamic> whereArgs = [];                      // Parameter proteksi dari SQL Injection

    List<String> conditions = [];

    // Filter berdasarkan tipe transaksi jika ditentukan
    if (filterType != null && filterType != 'all') {
      conditions.add('type = ?');
      whereArgs.add(filterType);
    }

    // Filter berdasarkan kata kunci pencarian jika pengguna mengetik di search bar
    if (searchKeyword != null && searchKeyword.trim().isNotEmpty) {
      conditions.add('(title LIKE ? OR category LIKE ? OR note LIKE ?)');
      final term = '%${searchKeyword.trim()}%';
      whereArgs.addAll([term, term, term]);
    }

    if (conditions.isNotEmpty) {
      whereClause = conditions.join(' AND ');
    }

    // Eksekusi query SELECT dengan pengurutan tanggal terbaru di urutan teratas
    final result = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC, id DESC',                  // Urutkan dari data paling baru
    );

    // Konversi hasil List<Map> menjadi List<TransactionModel>
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // READ: Menghitung total saldo, total pemasukan, dan total pengeluaran secara agregat SQL
  Future<Map<String, double>> getSummaryTotals() async {
    final db = await database;

    // Hitung total pemasukan menggunakan fungsi agregat SUM()
    final incomeResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'",
    );
    // Hitung total pengeluaran menggunakan fungsi agregat SUM()
    final expenseResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'",
    );

    final double totalIncome = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final double totalExpense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final double netBalance = totalIncome - totalExpense; // Saldo bersih = pemasukan - pengeluaran

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': netBalance,
    };
  }

  // READ: Menghitung pengeluaran per kategori untuk visualisasi statistik
  Future<Map<String, double>> getCategoryBreakdown({String type = 'expense'}) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total 
      FROM transactions 
      WHERE type = ? 
      GROUP BY category 
      ORDER BY total DESC
    ''', [type]);

    Map<String, double> breakdown = {};
    for (var row in result) {
      final category = row['category'] as String;
      final total = (row['total'] as num).toDouble();
      breakdown[category] = total;
    }
    return breakdown;
  }

  // UPDATE: Memperbarui data transaksi yang sudah tersimpan
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),                             // Data baru hasil modifikasi
      where: 'id = ?',                                 // Kondisi berdasarkan ID transaksi
      whereArgs: [transaction.id],                     // Argumen ID aman dari SQL injection
    );
  }

  // DELETE: Menghapus satu transaksi dari database berdasarkan primary key ID
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: Menghapus seluruh data transaksi (Fitur Reset Database)
  Future<int> clearAllTransactions() async {
    final db = await database;
    return await db.delete('transactions');
  }

  // Menutup koneksi database secara asinkron saat aplikasi dihentikan
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

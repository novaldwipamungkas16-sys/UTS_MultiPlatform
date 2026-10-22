import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack_app/models/transaction_model.dart';
import 'package:fintrack_app/services/database_helper.dart';
import 'package:fintrack_app/services/preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Pengujian Komprehensif Persistensi SQLite (Teknik Data Persistence 1)', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      // Bersihkan data sebelum pengujian
      await dbHelper.clearAllTransactions();
    });

    test('1. Pengujian Create & Read Transaksi (Insert & Query)', () async {
      final tx = TransactionModel(
        title: 'Makan Siang Bebek Sinjay',
        amount: 35000,
        type: 'expense',
        category: 'Makanan',
        date: DateTime.now(),
        note: 'Cabang Malang',
      );

      final id = await dbHelper.insertTransaction(tx);
      expect(id, isPositive);

      final list = await dbHelper.getAllTransactions();
      expect(list.length, 1);
      expect(list.first.title, 'Makan Siang Bebek Sinjay');
      expect(list.first.amount, 35000);
      expect(list.first.type, 'expense');
      expect(list.first.category, 'Makanan');
    });

    test('2. Pengujian Asynchronous Update Transaksi', () async {
      final tx = TransactionModel(
        title: 'Beli Buku Pemrograman',
        amount: 120000,
        type: 'expense',
        category: 'Pendidikan',
        date: DateTime.now(),
      );

      await dbHelper.insertTransaction(tx);
      final inserted = (await dbHelper.getAllTransactions()).first;

      final updatedModel = inserted.copyWith(title: 'Beli Buku Flutter & Dart', amount: 150000);
      final affectedRows = await dbHelper.updateTransaction(updatedModel);
      expect(affectedRows, 1);

      final afterUpdate = (await dbHelper.getAllTransactions()).first;
      expect(afterUpdate.title, 'Beli Buku Flutter & Dart');
      expect(afterUpdate.amount, 150000);
    });

    test('3. Pengujian Asynchronous Delete Transaksi', () async {
      final tx = TransactionModel(
        title: 'Uang Jajan',
        amount: 20000,
        type: 'expense',
        category: 'Lain-lain',
        date: DateTime.now(),
      );

      final id = await dbHelper.insertTransaction(tx);
      expect((await dbHelper.getAllTransactions()).length, 1);

      final deletedRows = await dbHelper.deleteTransaction(id);
      expect(deletedRows, 1);
      expect((await dbHelper.getAllTransactions()).isEmpty, isTrue);
    });

    test('4. Pengujian Agregasi Saldo & Kategori (getSummaryTotals & getCategoryBreakdown)', () async {
      await dbHelper.insertTransaction(TransactionModel(
        title: 'Gaji Freelance',
        amount: 1500000,
        type: 'income',
        category: 'Gaji',
        date: DateTime.now(),
      ));

      await dbHelper.insertTransaction(TransactionModel(
        title: 'Bayar Wifi Kost',
        amount: 200000,
        type: 'expense',
        category: 'Tagihan',
        date: DateTime.now(),
      ));

      await dbHelper.insertTransaction(TransactionModel(
        title: 'Belanja Bulanan',
        amount: 300000,
        type: 'expense',
        category: 'Belanja',
        date: DateTime.now(),
      ));

      final summary = await dbHelper.getSummaryTotals();
      expect(summary['income'], 1500000);
      expect(summary['expense'], 500000);
      expect(summary['balance'], 1000000);

      final breakdown = await dbHelper.getCategoryBreakdown(type: 'expense');
      expect(breakdown['Tagihan'], 200000);
      expect(breakdown['Belanja'], 300000);
    });
  });

  group('Pengujian Komprehensif Persistensi SharedPreferences (Teknik Data Persistence 2)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('1. Pengujian Nilai Default SharedPreferences', () async {
      final isDark = await PreferenceService.isDarkMode();
      expect(isDark, false);

      final name = await PreferenceService.getUserName();
      expect(name, 'Noval Dwi Pamungkas');

      final budget = await PreferenceService.getMonthlyBudget();
      expect(budget, 2500000.0);
    });

    test('2. Pengujian Simpan dan Baca (Key-Value Persistence)', () async {
      await PreferenceService.setDarkMode(true);
      expect(await PreferenceService.isDarkMode(), true);

      await PreferenceService.setUserName('Noval Dwi P.');
      expect(await PreferenceService.getUserName(), 'Noval Dwi P.');

      await PreferenceService.setMonthlyBudget(3000000.0);
      expect(await PreferenceService.getMonthlyBudget(), 3000000.0);
    });
  });
}

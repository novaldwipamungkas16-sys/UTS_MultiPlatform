// Pengujian Unit & Model untuk Aplikasi FinTrack
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack_app/models/transaction_model.dart';
import 'package:fintrack_app/services/quote_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Pengujian Model Transaksi (TransactionModel)', () {
    test('Serialisasi toMap dan Deserialisasi fromMap harus konsisten', () {
      final now = DateTime.now();
      final model = TransactionModel(
        id: 1,
        title: 'Makan Bakso',
        amount: 25000.0,
        type: 'expense',
        category: 'Makanan',
        date: now,
        note: 'Bakso urat dekat kampus',
      );

      final map = model.toMap();
      expect(map['title'], 'Makan Bakso');
      expect(map['amount'], 25000.0);
      expect(map['type'], 'expense');
      expect(map['category'], 'Makanan');

      final fromMapModel = TransactionModel.fromMap(map);
      expect(fromMapModel.id, 1);
      expect(fromMapModel.title, 'Makan Bakso');
      expect(fromMapModel.amount, 25000.0);
      expect(fromMapModel.type, 'expense');
      expect(fromMapModel.category, 'Makanan');
      expect(fromMapModel.note, 'Bakso urat dekat kampus');
    });

    test('Method copyWith harus memodifikasi field yang ditentukan', () {
      final model = TransactionModel(
        id: 1,
        title: 'Gaji Bulanan',
        amount: 5000000.0,
        type: 'income',
        category: 'Gaji',
        date: DateTime.now(),
      );

      final updated = model.copyWith(title: 'Gaji + Bonus', amount: 6500000.0);
      expect(updated.title, 'Gaji + Bonus');
      expect(updated.amount, 6500000.0);
      expect(updated.category, 'Gaji');
      expect(updated.id, 1);
    });
  });

  group('Pengujian Asynchronous QuoteService', () {
    test('fetchDailyFinancialTip mengembalikan quote string valid secara async', () async {
      final quote = await QuoteService.fetchDailyFinancialTip();
      expect(quote.isNotEmpty, isTrue);
    });
  });
}

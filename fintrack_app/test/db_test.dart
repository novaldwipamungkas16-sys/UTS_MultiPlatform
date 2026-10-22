import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('sqflite ffi probe', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    var db = await openDatabase(inMemoryDatabasePath, version: 1, onCreate: (db, version) async {
      await db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)');
    });
    await db.insert('Test', {'name': 'Noval'});
    final list = await db.query('Test');
    expect(list.first['name'], 'Noval');
    await db.close();
  });
}

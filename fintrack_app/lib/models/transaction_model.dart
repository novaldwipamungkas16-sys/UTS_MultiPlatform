// File: lib/models/transaction_model.dart
// Model data untuk merepresentasikan entitas transaksi keuangan (Pemasukan & Pengeluaran)

class TransactionModel {
  final int? id;             // ID unik transaksi (Primary Key auto-increment di SQLite)
  final String title;        // Judul atau nama transaksi (misal: "Beli Makan Siang", "Gaji")
  final double amount;       // Nominal uang dalam satuan Rupiah
  final String type;         // Tipe transaksi: 'income' (pemasukan) atau 'expense' (pengeluaran)
  final String category;     // Kategori transaksi (Makanan, Transport, Tagihan, Gaji, dll)
  final DateTime date;       // Tanggal dan waktu transaksi dicatat
  final String note;         // Catatan tambahan opsional mengenai transaksi

  // Constructor utama untuk inisialisasi objek transaksi
  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  });

  // Konversi objek TransactionModel menjadi Map<String, dynamic>
  // Fungsi ini wajib digunakan sebelum menyimpan objek ke dalam tabel SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,                                    // ID (bisa null jika auto-increment baru)
      'title': title,                              // Menyimpan string judul
      'amount': amount,                            // Menyimpan nilai numerik nominal
      'type': type,                                // Menyimpan string tipe ('income' / 'expense')
      'category': category,                        // Menyimpan kategori transaksi
      'date': date.toIso8601String(),              // Tanggal disimpan dalam format ISO-8601 string
      'note': note,                                // Menyimpan deskripsi catatan tambahan
    };
  }

  // Factory constructor untuk membuat objek TransactionModel dari Map SQLite
  // Digunakan saat membaca (SELECT query) baris data dari database SQLite
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,                       // Parsing ID dari kolom integer SQLite
      title: map['title'] as String,               // Parsing judul transaksi
      amount: (map['amount'] as num).toDouble(),   // Konversi num ke double untuk fleksibilitas
      type: map['type'] as String,                 // Parsing tipe transaksi
      category: map['category'] as String,         // Parsing kategori
      date: DateTime.parse(map['date'] as String), // Parse string ISO-8601 kembali menjadi objek DateTime
      note: (map['note'] ?? '') as String,         // Antisipasi null jika catatan tidak diisi
    );
  }

  // Method copyWith untuk membuat salinan objek dengan modifikasi sebagian nilai
  // Sangat berguna untuk state management dan proses edit transaksi
  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

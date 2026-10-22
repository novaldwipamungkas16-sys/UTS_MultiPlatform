// File: lib/widgets/transaction_card.dart
// Widget kartu untuk menampilkan satu item transaksi keuangan dalam ListView
// Mendukung gesture tap untuk edit dan swipe/dismiss untuk hapus transaksi secara asinkron.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;   // Objek transaksi yang akan ditampilkan
  final VoidCallback onTap;             // Aksi ketika kartu ditekan (buka form edit)
  final VoidCallback onDelete;          // Aksi konfirmasi hapus transaksi

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  // Helper untuk menentukan icon berdasarkan kategori transaksi
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
      case 'makanan & minuman':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'belanja':
        return Icons.shopping_bag;
      case 'tagihan':
      case 'listrik/air/wifi':
        return Icons.receipt_long;
      case 'hiburan':
        return Icons.sports_esports;
      case 'gaji':
        return Icons.account_balance_wallet;
      case 'investasi':
        return Icons.trending_up;
      case 'pendidikan':
        return Icons.school;
      case 'kesehatan':
        return Icons.medical_services;
      default:
        return Icons.category;
    }
  }

  // Helper format mata uang Rupiah
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Helper format tanggal Indonesia (contoh: 22 Okt 2026)
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Warna aksen: hijau untuk pemasukan, merah untuk pengeluaran
    final Color badgeColor = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Dismissible(
      key: Key('transaction_${transaction.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Tampilkan dialog konfirmasi sebelum benar-benar menghapus data
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Transaksi?'),
            content: Text('Apakah Anda yakin ingin menghapus catatan "${transaction.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDelete(); // Panggil fungsi hapus di database
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon Kategori dengan background bulat
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getCategoryIcon(transaction.category),
                    color: badgeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Informasi Judul, Kategori, dan Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              transaction.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDate(transaction.date),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (transaction.note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          transaction.note,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Nominal Transaksi (+ / -)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'} ${_formatCurrency(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isIncome ? 'Pemasukan' : 'Pengeluaran',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

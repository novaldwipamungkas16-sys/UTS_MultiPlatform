// File: lib/widgets/summary_card.dart
// Widget kartu ringkasan keuangan (Saldo Bersih, Pemasukan, Pengeluaran, dan Progress Anggaran)
// Dirancang dengan visualisasi modern Material 3, gradien elegan, dan responsif terhadap tema.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  final double balance;        // Total saldo bersih (Pemasukan - Pengeluaran)
  final double income;         // Total pemasukan
  final double expense;        // Total pengeluaran
  final double monthlyBudget;  // Target anggaran bulanan dari SharedPreferences

  const SummaryCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.monthlyBudget,
  });

  // Helper untuk format angka ke format Rupiah Indonesia (contoh: Rp 1.500.000)
  String _formatCurrency(double amount) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Hitung persentase pemakaian anggaran
    final double budgetUsagePercent = monthlyBudget > 0
        ? (expense / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final int budgetUsageInteger = (budgetUsagePercent * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Gradien modern sesuai status tema
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF2563EB)).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Label Saldo Bersih
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Bersih Saat Ini',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      balance >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: balance >= 0 ? Colors.greenAccent : Colors.orangeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      balance >= 0 ? 'Surplus' : 'Defisit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Baris 2: Nilai Nominal Saldo
          Text(
            _formatCurrency(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Baris 3: Kolom Pemasukan dan Pengeluaran
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Kolom Pemasukan
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_downward,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(income),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Pembatas vertikal
                Container(
                  height: 32,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 12),

                // Kolom Pengeluaran
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengeluaran',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(expense),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Baris 4: Progress Bar Pemakaian Anggaran Bulanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pemakaian Anggaran Bulanan',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                '$budgetUsageInteger% dari ${_formatCurrency(monthlyBudget)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: budgetUsagePercent,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                budgetUsagePercent > 0.85
                    ? Colors.redAccent
                    : (budgetUsagePercent > 0.65 ? Colors.orangeAccent : Colors.greenAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

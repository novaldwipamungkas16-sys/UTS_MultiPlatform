// File: lib/screens/statistics_screen.dart
// Visualisasi Sederhana Statistik Keuangan Per Kategori
// Menerapkan Asynchronous Programming untuk agregasi data dari SQLite.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedType = 'expense';                      // 'expense' atau 'income'
  Map<String, double> _breakdown = {};                    // Data agregasi per kategori
  double _totalAmount = 0.0;                             // Total nominal
  bool _isLoading = true;                                // Status loading

  @override
  void initState() {
    super.initState();
    _loadStatistics();                                   // Muat data statistik secara asinkron
  }

  // Fungsi asinkron untuk mengambil data agregasi dari SQLite
  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getCategoryBreakdown(type: _selectedType);
    double sum = 0.0;
    data.forEach((_, val) => sum += val);

    if (mounted) {
      setState(() {
        _breakdown = data;
        _totalAmount = sum;
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Daftar warna elegan untuk variasi kategori
  Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFF3B82F6), // Biru
      Color(0xFF10B981), // Hijau
      Color(0xFFF59E0B), // Amber
      Color(0xFFEF4444), // Merah
      Color(0xFF8B5CF6), // Ungu
      Color(0xFFEC4899), // Pink
      Color(0xFF14B8A6), // Teal
      Color(0xFF6B7280), // Abu-abu
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _selectedType == 'expense';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Kategori'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Segmented Button untuk beralih tipe statistik
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'expense',
                label: Text('Pengeluaran'),
                icon: Icon(Icons.pie_chart, color: Colors.redAccent),
              ),
              ButtonSegment(
                value: 'income',
                label: Text('Pemasukan'),
                icon: Icon(Icons.bar_chart, color: Colors.green),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedType = newSelection.first;
              });
              _loadStatistics(); // Muat ulang data kategori baru secara async
            },
          ),
          const SizedBox(height: 16),

          // Card Total Akumulasi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isExpense ? 'Total Seluruh Pengeluaran' : 'Total Seluruh Pemasukan',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(_totalAmount),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isExpense ? Colors.redAccent : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      isExpense ? Icons.trending_down : Icons.trending_up,
                      size: 36,
                      color: isExpense ? Colors.redAccent : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Visualisasi Bar Tiap Kategori
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _breakdown.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada data ${isExpense ? 'pengeluaran' : 'pemasukan'}.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _breakdown.length,
                        itemBuilder: (context, index) {
                          final category = _breakdown.keys.elementAt(index);
                          final amount = _breakdown[category]!;
                          final double percentage = _totalAmount > 0
                              ? (amount / _totalAmount).clamp(0.0, 1.0)
                              : 0.0;
                          final int percentInt = (percentage * 100).toInt();
                          final color = _getCategoryColor(index);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '$percentInt%  (${_formatCurrency(amount)})',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: percentage,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.withValues(alpha: 0.15),
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

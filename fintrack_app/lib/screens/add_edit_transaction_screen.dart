// File: lib/screens/add_edit_transaction_screen.dart
// Form Input Transaksi (Tambah & Edit)
// Menerapkan Asynchronous Programming untuk operasi penyimpanan ke database SQLite.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction; // Jika null = Tambah Baru, jika ada = Edit

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();            // Key validasi form
  late TextEditingController _titleController;        // Controller input judul
  late TextEditingController _amountController;       // Controller input nominal
  late TextEditingController _noteController;         // Controller input catatan

  late String _type;                                  // 'income' atau 'expense'
  late String _category;                              // Kategori transaksi terpilih
  late DateTime _selectedDate;                        // Tanggal transaksi terpilih
  bool _isLoading = false;                            // Status loading saat operasi simpan async

  // Kategori transaksi pengeluaran
  final List<String> _expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Pendidikan',
    'Kesehatan',
    'Lain-lain',
  ];

  // Kategori transaksi pemasukan
  final List<String> _incomeCategories = [
    'Gaji',
    'Bonus & Tunjangan',
    'Investasi',
    'Penjualan',
    'Hadiah',
    'Lain-lain',
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi nilai awal berdasarkan apakah mode Tambah atau Edit
    final tx = widget.transaction;
    _type = tx?.type ?? 'expense';
    _titleController = TextEditingController(text: tx?.title ?? '');
    _amountController = TextEditingController(
      text: tx != null ? tx.amount.toStringAsFixed(0) : '',
    );
    _noteController = TextEditingController(text: tx?.note ?? '');
    _selectedDate = tx?.date ?? DateTime.now();

    // Pastikan kategori awal valid
    if (tx != null) {
      _category = tx.category;
    } else {
      _category = _type == 'expense' ? _expenseCategories.first : _incomeCategories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Fungsi asinkron untuk menampilkan kalender DatePicker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi asinkron untuk memvalidasi dan menyimpan transaksi ke SQLite
  Future<void> _saveTransaction() async {
    // Validasi form input
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Tampilkan status loading indikator
    });

    final double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

    final item = TransactionModel(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _category,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );

    try {
      // Pemanggilan operasi asinkron ke SQLite DatabaseHelper
      if (widget.transaction == null) {
        // Mode INSERT data baru
        await DatabaseHelper.instance.insertTransaction(item);
      } else {
        // Mode UPDATE data yang sudah ada
        await DatabaseHelper.instance.updateTransaction(item);
      }

      if (!mounted) return;

      // Beri feedback notifikasi SnackBar ke pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction == null
                ? 'Transaksi berhasil dicatat ke SQLite!'
                : 'Perubahan transaksi berhasil diperbarui!',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Tutup halaman form dan kembalikan sinyal true untuk me-refresh data
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan transaksi: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final categories = _type == 'expense' ? _expenseCategories : _incomeCategories;

    // Pastikan kategori saat berganti tipe tetap cocok dengan list
    if (!categories.contains(_category)) {
      _category = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaksi' : 'Tambah Transaksi'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SegmentedButton: Pilihan Tipe Transaksi
                    Center(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'expense',
                            label: Text('Pengeluaran'),
                            icon: Icon(Icons.arrow_upward, color: Colors.redAccent),
                          ),
                          ButtonSegment(
                            value: 'income',
                            label: Text('Pemasukan'),
                            icon: Icon(Icons.arrow_downward, color: Colors.green),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _type = newSelection.first;
                            _category = _type == 'expense'
                                ? _expenseCategories.first
                                : _incomeCategories.first;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Judul Transaksi
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Transaksi',
                        hintText: 'Misal: Beli Nasi Goreng, Gaji Bulanan',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul transaksi wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Nominal Transaksi
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nominal (Rupiah)',
                        hintText: 'Contoh: 50000',
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nominal wajib diisi';
                        }
                        final numValue = double.tryParse(value.replaceAll(',', ''));
                        if (numValue == null || numValue <= 0) {
                          return 'Masukkan angka nominal yang valid dan lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Kategori
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _category = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pemilihan Tanggal Transaksi
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.blueAccent),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Transaksi',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Catatan Tambahan (Opsional)
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Catatan Tambahan (Opsional)',
                        hintText: 'Tambahkan keterangan detail atau lokasi pengeluaran...',
                        prefixIcon: const Icon(Icons.notes),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Simpan Transaksi (Async Action)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _saveTransaction,
                        icon: const Icon(Icons.save),
                        label: Text(
                          isEditing ? 'Perbarui Transaksi' : 'Simpan Transaksi ke Database',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

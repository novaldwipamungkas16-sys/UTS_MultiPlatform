// File: lib/services/quote_service.dart
// Penerapan Asynchronous Programming untuk simulasi pengambilan data eksternal / API
// Menggunakan konsep Future, async, await dan penanganan latensi jaringan (network delay).

import 'dart:math';

class QuoteService {
  // Kumpulan kutipan dan edukasi bijak finansial
  static final List<String> _tips = [
    '“Jangan menabung apa yang tersisa setelah dibelanjakan, tetapi habiskan apa yang tersisa setelah ditabung.” – Warren Buffett',
    '“Atur uangmu, atau kekurangan uang akan selalu mengatur hidupmu.” – Dave Ramsey',
    '“Bukan berapa banyak uang yang kamu hasilkan, tapi berapa banyak yang kamu simpan.” – Robert Kiyosaki',
    '“Pengeluaran kecil yang sering diabaikan bagaikan kebocoran kecil yang menenggelamkan kapal besar.” – Benjamin Franklin',
    '“Investasi terbaik yang bisa kamu lakukan adalah investasi pada pengetahuan dan disiplin diri.”',
    '“Catat setiap pengeluaran sekecil apa pun; transparansi finansial adalah kunci ketenangan hidup.”',
  ];

  // Fungsi asinkron untuk mensimulasikan pemanggilan REST API ke server eksternal
  // Menggunakan await Future.delayed untuk memberikan delay waktu seolah-olah mengambil data dari cloud
  static Future<String> fetchDailyFinancialTip() async {
    // Simulasi waktu tunggu jaringan selama 800 milidetik
    await Future.delayed(const Duration(milliseconds: 800));

    // Mengambil kutipan secara acak
    final random = Random();
    final index = random.nextInt(_tips.length);
    return _tips[index];
  }
}

import 'package:flutter/material.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  bool _terbaru = true;

  List<_RiwayatItem> items = [
    _RiwayatItem(
      kategori: 'Karbohidrat',
      deskripsi: 'Beras, roti, jagung, dll.',
      tanggal: DateTime(2025, 4, 5),
    ),
    _RiwayatItem(
      kategori: 'Kalsium',
      deskripsi: 'Susu sapi, susu kambing, susu unta, dll.',
      tanggal: DateTime(2025, 3, 2),
    ),
    _RiwayatItem(
      kategori: 'Protein',
      deskripsi: 'Dada ayam, telor, dll',
      tanggal: DateTime(2024, 8, 17),
    ),
    _RiwayatItem(
      kategori: 'Vitamin',
      deskripsi: 'Vitamin D, Vitamin C, Vitamin A, dll.',
      tanggal: DateTime(2024, 6, 23),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sortedItems = [...items];
    sortedItems.sort(
      (a, b) =>
          _terbaru
              ? b.tanggal.compareTo(a.tanggal)
              : a.tanggal.compareTo(b.tanggal),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Riwayat Bantuan'),
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Makan Siang Gratis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Urutkan'),
                const SizedBox(width: 12),
                _buildSortButton('Terbaru', true),
                const SizedBox(width: 8),
                _buildSortButton('Terlama', false),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: sortedItems.length,
                itemBuilder: (context, index) {
                  final item = sortedItems[index];
                  return _buildRiwayatCard(item);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEAF6FD),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black45,
        currentIndex: 4,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: ''),
        ],
        onTap: (index) {
          // Tambahkan navigasi jika diperlukan
        },
      ),
    );
  }

  Widget _buildSortButton(String label, bool value) {
    final isSelected = _terbaru == value;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _terbaru = value;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF218BCF) : Colors.white,
        side: BorderSide(color: const Color(0xFF218BCF)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF218BCF),
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(_RiwayatItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF218BCF), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Color(0xFF218BCF), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.kategori,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF218BCF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.deskripsi),
                const SizedBox(height: 4),
                Text(
                  'Terdistribusi ${_formatTanggal(item.tanggal)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTanggal(DateTime date) {
    final bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }
}

class _RiwayatItem {
  final String kategori;
  final String deskripsi;
  final DateTime tanggal;

  _RiwayatItem({
    required this.kategori,
    required this.deskripsi,
    required this.tanggal,
  });
}

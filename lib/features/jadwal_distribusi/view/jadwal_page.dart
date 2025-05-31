// lib/features/jadwal_distribusi/view/jadwal_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giziku/models/jadwal_item.dart'; // ✅ Import model JadwalItem

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  DateTime _currentMonth = DateTime.now(); // Bulan yang ditampilkan di kalender
  DateTime? _selectedCalendarDate; // Tanggal yang dipilih di kalender
  JadwalItem?
  _selectedJadwalItemDetail; // Detail jadwal untuk tanggal yang dipilih

  final List<String> _bulanSingkat = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  // List untuk menyimpan semua JadwalItem yang diambil dari Firestore
  List<JadwalItem> _allJadwalDistribusi = [];
  JadwalItem? _nextDistribusiItem; // Untuk "Jadwal distribusi selanjutnya"

  @override
  void initState() {
    super.initState();
    _fetchJadwalDistribusi();
  }

  Future<void> _fetchJadwalDistribusi() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('jadwal_distribusi')
              .orderBy(
                'tanggal',
              ) // Urutkan berdasarkan tanggal untuk memudahkan pencarian terdekat
              .get();

      final List<JadwalItem> fetchedJadwal = [];
      for (var doc in querySnapshot.docs) {
        fetchedJadwal.add(JadwalItem.fromFirestore(doc));
      }

      if (mounted) {
        setState(() {
          _allJadwalDistribusi = fetchedJadwal;
          _findNextDistribusi(); // Panggil setelah data dimuat
          // Secara default, pilih tanggal distribusi terdekat jika ada
          if (_nextDistribusiItem != null) {
            _selectedCalendarDate = _nextDistribusiItem!.tanggal;
            _selectedJadwalItemDetail = _nextDistribusiItem;
          } else if (_allJadwalDistribusi.isNotEmpty) {
            // Jika tidak ada jadwal terdekat di masa depan, pilih yang pertama dari semua
            _selectedCalendarDate = _allJadwalDistribusi.first.tanggal;
            _selectedJadwalItemDetail = _allJadwalDistribusi.first;
          }
        });
      }
    } catch (e) {
      print('Error fetching jadwal distribusi: $e');
      // Tampilkan pesan error ke user jika perlu
    }
  }

  void _findNextDistribusi() {
    final now = DateTime.now();
    _nextDistribusiItem = _allJadwalDistribusi
        .where(
          (item) => item.tanggal.isAfter(now.subtract(const Duration(days: 1))),
        ) // Filter tanggal setelah hari ini
        .fold<JadwalItem?>(
          null,
          (min, item) =>
              min == null || item.tanggal.isBefore(min.tanggal) ? item : min,
        );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedCalendarDate = date;
      // Cari detail jadwal untuk tanggal yang dipilih
      _selectedJadwalItemDetail = _allJadwalDistribusi.firstWhereOrNull(
        (item) => DateUtils.isSameDay(item.tanggal, date),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday =
        firstDayOfMonth
            .weekday; // 1 = Monday, 7 = Sunday (Dart's DateTime.weekday)
    // Sesuaikan weekday agar Minggu menjadi terakhir (1 = Senin, ..., 7 = Minggu)
    final adjustedFirstWeekday =
        (firstWeekday == 7)
            ? 0
            : firstWeekday; // If Sunday (7), make it 0 for padding

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
        title: const Text('Jadwal Distribusi Bantuan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align to start for labels
          children: [
            // "Jadwal distribusi selanjutnya" bubble
            if (_nextDistribusiItem != null)
              Align(
                // Use Align to position the bubble
                alignment: Alignment.centerLeft, // Align left within its parent
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    // Hapus border karena tidak ada di desain terbaru
                  ),
                  child: Text(
                    'Jadwal distribusi selanjutnya: ${DateFormat('dd MMM yyyy').format(_nextDistribusiItem!.tanggal)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Pilih Bulan
            Row(
              children: [
                const Text(
                  'Pilih Bulan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _currentMonth.month,
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(_bulanSingkat[index]),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, value, 1);
                      });
                    }
                  },
                ),
                // Tambahkan kontrol tahun jika diperlukan
              ],
            ),
            const SizedBox(height: 16),

            // Hari-hari
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Sesuaikan mainAxisAlignment
              children: const [
                _HariLabel('SEN'),
                _HariLabel('SEL'),
                _HariLabel('RAB'),
                _HariLabel('KAM'),
                _HariLabel('JUM'),
                _HariLabel('SAB'),
                _HariLabel('MIN'),
              ],
            ),
            const SizedBox(height: 8),

            // Kalender Tanggal
            GridView.builder(
              shrinkWrap:
                  true, // Penting agar GridView tidak mengambil tinggi tak terbatas
              physics:
                  const NeverScrollableScrollPhysics(), // Nonaktifkan scrolling GridView
              itemCount:
                  daysInMonth +
                  adjustedFirstWeekday, // Jumlah kotak di kalender
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                // Hitung hari yang sebenarnya
                final day = index + 1 - adjustedFirstWeekday;

                if (day <= 0) {
                  return Container(); // Kosongkan kotak sebelum hari pertama bulan
                }

                final currentDate = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  day,
                );

                // Periksa apakah tanggal ini ada di jadwal distribusi
                final isDistribusi = _allJadwalDistribusi.any(
                  (item) => DateUtils.isSameDay(item.tanggal, currentDate),
                );

                // Periksa apakah tanggal ini adalah hari ini
                final isToday = DateUtils.isSameDay(currentDate, now);

                // Periksa apakah tanggal ini adalah tanggal yang dipilih
                final isSelected =
                    _selectedCalendarDate != null &&
                    DateUtils.isSameDay(currentDate, _selectedCalendarDate!);

                return GestureDetector(
                  onTap: () => _onDateSelected(currentDate),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors
                                  .blueAccent // Warna untuk tanggal yang dipilih
                              : isDistribusi
                              ? const Color(
                                0xFFB3DAF4,
                              ) // Warna untuk tanggal distribusi
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color:
                            isSelected || isToday
                                ? Colors.white
                                : Colors
                                    .black, // Teks putih jika dipilih atau hari ini
                        fontWeight:
                            isDistribusi || isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Detail Jadwal untuk tanggal yang dipilih
            if (_selectedJadwalItemDetail != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFEAF6FD,
                  ), // Warna latar belakang sesuai desain
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat(
                        'dd MMMM yyyy',
                      ).format(_selectedJadwalItemDetail!.tanggal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jenis bantuan: ${_selectedJadwalItemDetail!.jenisBantuan}',
                    ),
                    Text('Lokasi: ${_selectedJadwalItemDetail!.lokasi}'),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEAF6FD),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black45,
        currentIndex: 0, // Sesuaikan dengan index Jadwal Distribusi
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: ''),
        ],
        onTap: (index) {
          // (Opsional) Tambahkan navigasi berdasarkan index
          // if (index == 0) context.go('/jadwal'); // Ini sudah halaman jadwal
          // if (index == 1) context.go('/konsultasi');
          // if (index == 2) context.go('/home');
          // if (index == 3) context.go('/komunitas');
          // if (index == 4) context.go('/riwayat');
        },
      ),
    );
  }
}

class _HariLabel extends StatelessWidget {
  final String label;
  const _HariLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF218BCF),
      ),
    );
  }
}

// Extension untuk memudahkan pencarian di List (opsional)
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

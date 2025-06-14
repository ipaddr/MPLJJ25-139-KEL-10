// lib/features/jadwal_distribusi/view/jadwal_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giziku/models/jadwal_detail_item.dart'; // Pastikan model ini diimpor
import 'package:collection/collection.dart'; // Diperlukan untuk .firstWhereOrNull

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  // Bulan yang sedang ditampilkan di kalender
  DateTime _currentMonth = DateTime.now();
  // Tanggal yang dipilih di kalender oleh pengguna
  DateTime? _selectedCalendarDate;
  // Detail jadwal untuk tanggal yang dipilih
  JadwalDetailItem? _selectedJadwalItemDetail;

  // Singkatan nama bulan untuk DropdownButton
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

  // List untuk menyimpan semua JadwalDetailItem yang diambil dari Firestore
  List<JadwalDetailItem> _allJadwalDistribusi = [];
  // Untuk "Jadwal distribusi selanjutnya"
  JadwalDetailItem? _nextDistribusiItem;

  @override
  void initState() {
    super.initState();
    // Menggunakan Stream untuk mendengarkan perubahan real-time dari Firestore
    // Ini memastikan kalender dan jadwal terdekat update otomatis
    FirebaseFirestore.instance
        .collection('jadwal_distribusi')
        .where(
          'status',
          isEqualTo: 'Dijadwalkan',
        ) // Hanya tampilkan jadwal yang belum disalurkan
        .orderBy('tanggal') // Urutkan berdasarkan tanggal
        .snapshots() // Mendengarkan perubahan data secara real-time
        .listen(
          (querySnapshot) {
            final List<JadwalDetailItem> fetchedJadwal = [];
            for (var doc in querySnapshot.docs) {
              try {
                fetchedJadwal.add(JadwalDetailItem.fromFirestore(doc));
              } catch (e) {
                print(
                  'Error parsing JadwalDetailItem from Firestore: $e, Doc ID: ${doc.id}',
                );
                // Anda bisa menambahkan SnackBar di sini jika error signifikan
              }
            }

            // Pastikan widget masih mounted sebelum memanggil setState
            if (mounted) {
              setState(() {
                _allJadwalDistribusi = fetchedJadwal;
                _findNextDistribusi(); // Cari jadwal terdekat setelah data diperbarui

                // Update detail jadwal yang dipilih jika tanggal yang sama masih ada dalam data yang diperbarui
                if (_selectedCalendarDate != null) {
                  _selectedJadwalItemDetail = _allJadwalDistribusi
                      .firstWhereOrNull(
                        (item) =>
                            DateUtils.isSameDay(
                              item.tanggal,
                              _selectedCalendarDate!,
                            ) &&
                            item.status == 'Dijadwalkan',
                      );
                } else if (_nextDistribusiItem != null) {
                  // Jika belum ada yang dipilih, dan ada jadwal terdekat, tampilkan itu
                  _selectedCalendarDate = _nextDistribusiItem!.tanggal;
                  _selectedJadwalItemDetail = _nextDistribusiItem;
                } else if (_allJadwalDistribusi.isNotEmpty) {
                  // Jika tidak ada jadwal terdekat (misal, semua sudah lewat), tampilkan jadwal pertama
                  _selectedCalendarDate = _allJadwalDistribusi.first.tanggal;
                  _selectedJadwalItemDetail = _allJadwalDistribusi.first;
                } else {
                  // Jika tidak ada jadwal sama sekali, reset tampilan
                  _selectedCalendarDate = null;
                  _selectedJadwalItemDetail = null;
                }
              });
            }
          },
          onError: (error) {
            print('Error listening to jadwal_distribusi stream: $error');
            // Tampilkan pesan error ke user jika stream gagal
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memuat jadwal: ${error.toString()}'),
                ),
              );
            }
          },
        );
  }

  // Fungsi untuk mencari jadwal distribusi terdekat di masa depan
  void _findNextDistribusi() {
    final now = DateTime.now();
    _nextDistribusiItem = _allJadwalDistribusi
        .where(
          (item) => item.tanggal.isAfter(now.subtract(const Duration(days: 1))),
        ) // Filter tanggal setelah hari ini
        .fold<JadwalDetailItem?>(
          // Temukan item dengan tanggal terlama di masa depan
          null,
          (min, item) =>
              min == null || item.tanggal.isBefore(min.tanggal) ? item : min,
        );
  }

  // Fungsi yang dipanggil saat pengguna memilih tanggal di kalender
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedCalendarDate = date; // Set tanggal yang dipilih
      // Cari detail jadwal yang cocok dengan tanggal yang dipilih dan status 'Dijadwalkan'
      _selectedJadwalItemDetail = _allJadwalDistribusi.firstWhereOrNull(
        (item) =>
            DateUtils.isSameDay(item.tanggal, date) &&
            item.status == 'Dijadwalkan',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Logika untuk menampilkan kalender
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ); // Hari terakhir bulan
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Senin, ..., 7 = Minggu
    // Sesuaikan weekday agar Minggu menjadi kolom terakhir (0-6, di mana 0 adalah Minggu)
    final adjustedFirstWeekday = (firstWeekday == 7) ? 0 : firstWeekday;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilan "Jadwal distribusi selanjutnya"
            if (_nextDistribusiItem != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Jadwal distribusi selanjutnya: ${DateFormat('dd MMMMyyyy').format(_nextDistribusiItem!.tanggal)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Dropdown untuk memilih bulan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Bulan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                        _selectedCalendarDate =
                            null; // Reset tanggal pilihan saat bulan berubah
                        _selectedJadwalItemDetail =
                            null; // Reset detail saat bulan berubah
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Label hari-hari (SEN, SEL, dst.)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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

            // Grid kalender untuk tanggal
            GridView.builder(
              shrinkWrap:
                  true, // Penting agar GridView tidak mengambil tinggi tak terbatas
              physics:
                  const NeverScrollableScrollPhysics(), // Nonaktifkan scrolling GridView
              itemCount:
                  daysInMonth +
                  adjustedFirstWeekday, // Jumlah kotak di kalender
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 hari dalam seminggu
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                // Hitung hari yang sebenarnya berdasarkan offset weekday pertama
                final day = index + 1 - adjustedFirstWeekday;
                if (day <= 0) {
                  return Container(); // Kosongkan kotak sebelum hari pertama bulan
                }

                final currentDate = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  day,
                );
                // Periksa apakah tanggal ini memiliki jadwal distribusi yang statusnya 'Dijadwalkan'
                final isDistribusi = _allJadwalDistribusi.any(
                  (item) =>
                      DateUtils.isSameDay(item.tanggal, currentDate) &&
                      item.status == 'Dijadwalkan',
                );
                // Periksa apakah tanggal ini adalah hari ini
                final isToday = DateUtils.isSameDay(currentDate, now);
                // Periksa apakah tanggal ini adalah tanggal yang sedang dipilih
                final isSelected =
                    _selectedCalendarDate != null &&
                    DateUtils.isSameDay(currentDate, _selectedCalendarDate!);

                return GestureDetector(
                  onTap:
                      () => _onDateSelected(currentDate), // Saat tanggal diklik
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isSelected // Warna jika dipilih
                              ? Colors.blueAccent
                              : isDistribusi // Warna jika ada jadwal distribusi
                              ? const Color(0xFFB3DAF4)
                              : Colors.transparent, // Warna default
                      shape: BoxShape.circle, // Bentuk lingkaran
                    ),
                    child: Text(
                      '$day', // Tampilkan nomor hari
                      style: TextStyle(
                        color:
                            isSelected || isToday
                                ? const Color(0xFFB3DAF4)
                                : Colors
                                    .black, // Warna teks putih jika dipilih atau hari ini
                        fontWeight:
                            isDistribusi || isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight
                                    .normal, // Tebal jika ada jadwal, dipilih, atau hari ini
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Tampilan detail jadwal untuk tanggal yang dipilih
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
                        'dd MMMMyyyy',
                      ).format(_selectedJadwalItemDetail!.tanggal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subject bantuan: ${_selectedJadwalItemDetail!.jenisBantuan}',
                    ), // Menampilkan subject bantuan
                    Text(
                      'Deskripsi bantuan: ${_selectedJadwalItemDetail!.deskripsiBantuan}',
                    ), // Menampilkan deskripsi bantuan
                    Text('Lokasi: ${_selectedJadwalItemDetail!.lokasi}'),
                  ],
                ),
              ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEAF6FD),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black45,
        currentIndex:
            0, // Sesuaikan dengan index Jadwal Distribusi di bottom nav
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
          // (Opsional) Tambahkan navigasi berdasarkan index jika ini adalah bottom nav utama
          // if (index == 0) context.go('/jadwal'); // Sudah di halaman ini
          // if (index == 1) context.go('/konsultasi');
          // if (index == 2) context.go('/home');
          // if (index == 3) context.go('/komunitas');
          // if (index == 4) context.go('/riwayat');
        },
      ),
    );
  }
}

// Widget bantu untuk label hari-hari (SEN, SEL, dst.)
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

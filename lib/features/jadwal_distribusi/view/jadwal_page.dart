// lib/features/jadwal_distribusi/view/jadwal_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giziku/models/jadwal_detail_item.dart';
import 'package:collection/collection.dart'; // Pastikan import ini ada

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedCalendarDate;
  JadwalDetailItem? _selectedJadwalItemDetail;

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

  List<JadwalDetailItem> _allJadwalDistribusi = [];
  JadwalDetailItem? _nextDistribusiItem;

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
              .where('status', isEqualTo: 'Dijadwalkan')
              .orderBy('tanggal')
              .get();

      final List<JadwalDetailItem> fetchedJadwal = [];
      for (var doc in querySnapshot.docs) {
        fetchedJadwal.add(JadwalDetailItem.fromFirestore(doc));
      }

      if (mounted) {
        setState(() {
          _allJadwalDistribusi = fetchedJadwal;
          _findNextDistribusi();
          if (_nextDistribusiItem != null) {
            _selectedCalendarDate = _nextDistribusiItem!.tanggal;
            _selectedJadwalItemDetail = _nextDistribusiItem;
          } else if (_allJadwalDistribusi.isNotEmpty) {
            _selectedCalendarDate = _allJadwalDistribusi.first.tanggal;
            _selectedJadwalItemDetail = _allJadwalDistribusi.first;
          } else {
            _selectedCalendarDate = null;
            _selectedJadwalItemDetail = null;
          }
        });
      }
    } catch (e) {
      print('Error fetching jadwal distribusi: $e');
    }
  }

  void _findNextDistribusi() {
    final now = DateTime.now();
    _nextDistribusiItem = _allJadwalDistribusi
        .where(
          (item) => item.tanggal.isAfter(now.subtract(const Duration(days: 1))),
        )
        .fold<JadwalDetailItem?>(
          null,
          (min, item) =>
              min == null || item.tanggal.isBefore(min.tanggal) ? item : min,
        );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedCalendarDate = date;
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
    final firstWeekday = firstDayOfMonth.weekday;
    final adjustedFirstWeekday = (firstWeekday == 7) ? 0 : firstWeekday;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
        title: const Text('Jadwal Distribusi Bantuan'),
      ),
      body: Padding(
        // ✅ Pastikan hanya ada satu argumen posisi di sini (padding)
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_nextDistribusiItem !=
                null) // ✅ 'if' statement harus langsung diikuti oleh widget
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
                        _selectedCalendarDate = null;
                        _selectedJadwalItemDetail = null;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

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

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daysInMonth + adjustedFirstWeekday,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final day = index + 1 - adjustedFirstWeekday;
                if (day <= 0) return Container();

                final currentDate = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  day,
                );
                final isDistribusi = _allJadwalDistribusi.any(
                  (item) =>
                      DateUtils.isSameDay(item.tanggal, currentDate) &&
                      item.status == 'Dijadwalkan',
                );
                final isToday = DateUtils.isSameDay(currentDate, now);
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
                              ? Colors.blueAccent
                              : isDistribusi
                              ? const Color(0xFFB3DAF4)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color:
                            isSelected || isToday ? Colors.white : Colors.black,
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

            if (_selectedJadwalItemDetail !=
                null) // ✅ 'if' statement harus langsung diikuti oleh widget
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6FD),
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
        currentIndex: 0,
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

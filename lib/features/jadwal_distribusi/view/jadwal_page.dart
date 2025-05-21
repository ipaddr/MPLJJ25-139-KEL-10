import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final DateTime _selectedDate = DateTime.now();
  final List<String> _bulan = [
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
  late int _selectedMonth;

  final List<DateTime> _jadwalDistribusi = [
    DateTime(2024, 4, 9),
    DateTime(2024, 4, 11),
    DateTime(2024, 4, 23),
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = _selectedDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, _selectedMonth, 1);
    final lastDay = DateTime(now.year, _selectedMonth + 1, 0);
    final daysInMonth = lastDay.day;

    final nextDistribusi = _jadwalDistribusi
        .where((d) => d.isAfter(now))
        .toList()
        .fold<DateTime?>(
          null,
          (min, d) => min == null || d.isBefore(min) ? d : min,
        );

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
          children: [
            if (nextDistribusi != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                ),
                child: Text(
                  'Jadwal distribusi selanjutnya: ${DateFormat('dd MMM yyyy').format(nextDistribusi)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
                  value: _selectedMonth,
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(_bulan[index]),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hari-hari
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Expanded(
              child: GridView.builder(
                itemCount: daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final current = DateTime(now.year, _selectedMonth, day);
                  final isDistribusi = _jadwalDistribusi.any(
                    (d) =>
                        d.year == current.year &&
                        d.month == current.month &&
                        d.day == current.day,
                  );
                  final isToday =
                      current.day == now.day &&
                      current.month == now.month &&
                      current.year == now.year;

                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isToday
                              ? Colors.blueAccent
                              : isDistribusi
                              ? const Color(0xFFB3DAF4)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.black,
                        fontWeight:
                            isDistribusi ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFEAF6FD),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.blue),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
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

// lib/features/riwayat/view/riwayat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:giziku/models/riwayat_detail_item.dart'; // ✅ Import RiwayatDetailItem

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  bool _terbaru = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Bantuan'),
          backgroundColor: const Color(0xFF218BCF),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Anda harus login untuk melihat riwayat bantuan.'),
        ),
      );
    }

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
                  onPressed: () {
                    // Aksi untuk filter tanggal, jika diperlukan
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('riwayat_bantuan')
                        .where('userId', isEqualTo: _currentUser!.uid)
                        .orderBy(
                          'tanggalDisalurkan',
                          descending: _terbaru,
                        ) // Menggunakan tanggalDisalurkan
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada riwayat bantuan.'),
                    );
                  }

                  final items =
                      snapshot.data!.docs.map((doc) {
                        return RiwayatDetailItem.fromFirestore(
                          doc,
                        ); // Menggunakan RiwayatDetailItem
                      }).toList();

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildRiwayatCard(item);
                    },
                  );
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
        side: const BorderSide(color: Color(0xFF218BCF)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF218BCF),
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(RiwayatDetailItem item) {
    // Menggunakan RiwayatDetailItem
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
                  item.jenisBantuan, // Menggunakan jenisBantuan
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
                  'Terdistribusi ${DateFormat('dd MMMM yyyy').format(item.tanggalDisalurkan)} oleh ${item.disalurkanOlehUserName}', // Menambahkan info petugas
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Lokasi: ${item.lokasiDisalurkan}', // Menambahkan lokasi
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

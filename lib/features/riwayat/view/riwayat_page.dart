// lib/features/riwayat/view/riwayat_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:giziku/models/riwayat_detail_item.dart'; // Pastikan model ini diimpor

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  bool _terbaru = true; // Untuk opsi pengurutan "Terbaru" atau "Terlama"
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser; // Pengguna yang sedang login

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Dapatkan pengguna saat ini
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan pesan jika pengguna belum login
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
      backgroundColor: Colors.white, // Warna background
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
              'Makan Siang Gratis', // Ini bisa dinamis jika ada jenis bantuan lain
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Urutkan'),
                const SizedBox(height: 12),
                _buildSortButton('Terbaru', true), // Tombol urutkan Terbaru
                const SizedBox(width: 8),
                _buildSortButton('Terlama', false), // Tombol urutkan Terlama
                const Spacer(), // Memberikan ruang kosong
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today_outlined, // Ikon kalender
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    // Aksi untuk filter tanggal, jika diperlukan (misal: membuka date picker)
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              // StreamBuilder untuk mendengarkan perubahan data riwayat secara real-time
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('riwayat_bantuan')
                        .where(
                          'userId',
                          isEqualTo: _currentUser!.uid,
                        ) // Filter berdasarkan user ID yang login
                        .orderBy(
                          'tanggalDisalurkan',
                          descending: _terbaru,
                        ) // Urutkan berdasarkan pilihan pengguna
                        .snapshots(), // Mendengarkan perubahan data secara real-time
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // Tampilkan loading
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    ); // Tampilkan error
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada riwayat bantuan.'),
                    ); // Pesan jika tidak ada data
                  }

                  // Konversi DocumentSnapshot menjadi list RiwayatDetailItem
                  final items =
                      snapshot.data!.docs.map((doc) {
                        return RiwayatDetailItem.fromFirestore(doc);
                      }).toList();

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildRiwayatCard(
                        item,
                      ); // Membangun setiap card riwayat
                    },
                  );
                },
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
        currentIndex: 4, // Sesuaikan dengan index Riwayat Bantuan di bottom nav
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: ''),
        ],
        onTap: (index) {
          // (Opsional) Tambahkan navigasi berdasarkan index jika ini adalah bottom nav utama
          // if (index == 0) context.go('/jadwal');
          // if (index == 1) context.go('/konsultasi');
          // if (index == 2) context.go('/home');
          // if (index == 3) context.go('/komunitas');
          // if (index == 4) context.go('/riwayat'); // Sudah di halaman ini
        },
      ),
    );
  }

  // Widget untuk tombol pengurutan "Terbaru" / "Terlama"
  Widget _buildSortButton(String label, bool value) {
    final isSelected = _terbaru == value;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _terbaru = value; // Mengubah state pengurutan
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

  // Widget untuk menampilkan setiap item riwayat bantuan
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
          const Icon(
            Icons.receipt_long,
            color: Color(0xFF218BCF),
            size: 28,
          ), // Ikon penerimaan
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.jenisBantuan, // Subject bantuan dari jadwal
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF218BCF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.deskripsiTambahan), // Deskripsi bantuan
                const SizedBox(height: 4),
                Text(
                  'Terdistribusi ${DateFormat('dd MMMMyyyy').format(item.tanggalDisalurkan)} oleh ${item.disalurkanOlehUserName}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Lokasi: ${item.lokasiDisalurkan}',
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

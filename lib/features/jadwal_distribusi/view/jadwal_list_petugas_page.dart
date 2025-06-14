// lib/features/jadwal_distribusi/view/jadwal_list_petugas_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:giziku/models/jadwal_detail_item.dart';
import 'package:giziku/models/riwayat_detail_item.dart';
import 'package:giziku/models/chat_user.dart'; // Untuk mendapatkan nama penerima

class JadwalListPetugasPage extends StatefulWidget {
  const JadwalListPetugasPage({super.key});

  @override
  State<JadwalListPetugasPage> createState() => _JadwalListPetugasPageState();
}

class _JadwalListPetugasPageState extends State<JadwalListPetugasPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String? _currentUserName; // Nama petugas yang login

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadCurrentUserName();
  }

  Future<void> _loadCurrentUserName() async {
    if (_currentUser != null) {
      final userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _currentUserName = userDoc.data()?['name'] as String?;
        });
      }
    }
  }

  Future<void> _markAsDistributed(JadwalDetailItem jadwal) async {
    if (_currentUser == null || _currentUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Anda harus login sebagai petugas untuk menyalurkan bantuan.',
          ),
        ),
      );
      return;
    }

    // Konfirmasi penyaluran
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Konfirmasi Penyaluran'),
            content: Text(
              'Apakah Anda yakin ingin menandai jadwal ini sebagai disalurkan?\n\nSubject: ${jadwal.jenisBantuan}\nDeskripsi: ${jadwal.deskripsiBantuan}\nLokasi: ${jadwal.lokasi}\nTanggal: ${DateFormat('dd MMMMyyyy').format(jadwal.tanggal)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ya, Salurkan'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      // 1. Perbarui status jadwal di jadwal_distribusi menjadi 'Disalurkan'
      await _firestore.collection('jadwal_distribusi').doc(jadwal.id).update({
        'status': 'Disalurkan',
      });

      // 2. Tambahkan entri ke riwayat_bantuan untuk setiap penerima
      for (String recipientUid in jadwal.recipientUserIds) {
        // Ambil nama penerima dari Firestore
        final recipientDoc =
            await _firestore.collection('users').doc(recipientUid).get();
        String recipientName =
            recipientDoc.exists
                ? (recipientDoc.data()?['name'] as String? ?? 'Pengguna')
                : 'Pengguna Tidak Ditemukan';

        final riwayatItem = RiwayatDetailItem(
          id: '', // ID akan diisi Firestore
          userId: recipientUid,
          userName: recipientName,
          jenisBantuan: jadwal.jenisBantuan, // Subject bantuan dari jadwal
          deskripsiTambahan:
              jadwal.deskripsiBantuan, // Deskripsi bantuan dari jadwal
          tanggalDisalurkan: DateTime.now(), // Tanggal disalurkan saat ini
          lokasiDisalurkan: jadwal.lokasi,
          disalurkanOlehUserId: _currentUser!.uid,
          disalurkanOlehUserName: _currentUserName ?? 'Petugas',
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('riwayat_bantuan')
            .add(riwayatItem.toFirestore());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jadwal berhasil disalurkan dan ditambahkan ke riwayat!',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyalurkan jadwal: ${e.toString()}')),
      );
      print('Error marking as distributed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Jadwal Bantuan')),
        body: const Center(
          child: Text('Anda harus login untuk melihat jadwal.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Jadwal Bantuan'),
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Menggunakan StreamBuilder untuk live update
        stream:
            _firestore
                .collection('jadwal_distribusi')
                .where(
                  'status',
                  isEqualTo: 'Dijadwalkan',
                ) // Hanya tampilkan jadwal yang belum disalurkan
                // Opsional: filter berdasarkan petugas yang menambahkan jadwal (jika ingin petugas hanya melihat jadwalnya sendiri)
                // .where('addedByUserId', isEqualTo: _currentUser!.uid)
                .orderBy('tanggal', descending: false)
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
              child: Text('Tidak ada jadwal bantuan yang dijadwalkan.'),
            );
          }

          final jadwalList =
              snapshot.data!.docs.map((doc) {
                return JadwalDetailItem.fromFirestore(doc);
              }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jadwalList.length,
            itemBuilder: (context, index) {
              final jadwal = jadwalList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMMMyyyy').format(jadwal.tanggal),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF218BCF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Subject Bantuan: ${jadwal.jenisBantuan}'),
                      Text('Deskripsi Bantuan: ${jadwal.deskripsiBantuan}'),
                      Text('Lokasi: ${jadwal.lokasi}'),
                      Text('Status: ${jadwal.status}'),
                      const SizedBox(height: 8),
                      // Tampilkan daftar penerima
                      if (jadwal.recipientUserIds.isNotEmpty)
                        FutureBuilder<List<String>>(
                          future: Future.wait(
                            jadwal.recipientUserIds.map((uid) async {
                              final userDoc =
                                  await _firestore
                                      .collection('users')
                                      .doc(uid)
                                      .get();
                              return userDoc.exists
                                  ? (userDoc.data()?['name'] as String? ??
                                      'Pengguna')
                                  : 'Tidak Ditemukan';
                            }),
                          ),
                          builder: (
                            context,
                            AsyncSnapshot<List<String>> namesSnapshot,
                          ) {
                            if (namesSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Penerima: Memuat...');
                            }
                            if (namesSnapshot.hasError) {
                              return const Text('Penerima: Error memuat nama.');
                            }
                            return Text(
                              'Penerima: ${namesSnapshot.data!.join(', ')}',
                            );
                          },
                        ),

                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _markAsDistributed(jadwal),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Tandai Disalurkan',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tambah-jadwal-bantuan'),
        backgroundColor: const Color(0xFF218BCF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

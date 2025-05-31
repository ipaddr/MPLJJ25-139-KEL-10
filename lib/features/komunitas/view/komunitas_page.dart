// lib/features/komunitas/view/komunitas_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase
import 'package:go_router/go_router.dart';
import 'package:giziku/models/postingan.dart'; // Pastikan import model Postingan
import 'package:intl/intl.dart'; // Untuk format tanggal

class KomunitasPage extends StatelessWidget {
  const KomunitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GiziKu Komunitas'),
        backgroundColor: const Color(0xFFEAF6FD), // Warna AppBar sesuai desain
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // Aksi notifikasi
            },
          ),
          // Anda bisa menambahkan tombol lain di sini jika diperlukan
        ],
      ),
      backgroundColor: const Color(
        0xFFEAF6FD,
      ), // Warna background sesuai desain
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('postingan')
                .orderBy(
                  'createdAt',
                  descending: true,
                ) // Urutkan berdasarkan tanggal terbaru
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada postingan.'));
          }

          final postinganList =
              snapshot.data!.docs.map((doc) {
                return Postingan.fromFirestore(doc);
              }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: postinganList.length,
            itemBuilder: (context, index) {
              final postingan = postinganList[index];
              return _PostinganCard(postingan: postingan);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/buat-postingan'); // Navigasi ke halaman buat postingan
        },
        backgroundColor: const Color(0xFF218BCF),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      // BottomNavigationBar tetap seperti sebelumnya atau sesuai desain
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEAF6FD),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black45,
        currentIndex: 3, // Sesuaikan dengan index Komunitas & Edukasi
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
          // Contoh:
          // if (index == 0) context.go('/jadwal');
          // if (index == 1) context.go('/konsultasi');
          // if (index == 2) context.go('/home');
          // if (index == 3) context.go('/komunitas'); // Ini sudah halaman komunitas
          // if (index == 4) context.go('/riwayat');
        },
      ),
    );
  }
}

// ───────────────────────── _PostinganCard Widget ─────────────────────────
class _PostinganCard extends StatelessWidget {
  final Postingan postingan;

  const _PostinganCard({required this.postingan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/detail-postingan', extra: postingan);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    // Implementasikan avatar berdasarkan user, contoh:
                    // backgroundImage: NetworkImage(postingan.userProfilePicUrl ?? 'default_avatar.png'),
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      postingan.userName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              postingan.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (postingan
                                .isVerified) // Tampilkan centang biru jika terverifikasi
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy, HH:mm',
                          ).format(postingan.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                postingan.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                postingan.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3, // Tampilkan beberapa baris isi postingan
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

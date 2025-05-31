// lib/features/konsultasi/view/konsultasi_petugas_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:giziku/models/chat_user.dart'; // Import model ChatUser

class KonsultasiPetugasPage extends StatelessWidget {
  const KonsultasiPetugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF7FF),
        elevation: 0,
        title: const Text(
          'Konsultasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.filter_list, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4),
            child: Row(
              children: [
                Text('Urutkan', style: TextStyle(fontSize: 14)),
                SizedBox(width: 8),
                Chip(
                  label: Text('A - Z'),
                  backgroundColor: Color(0xFFEAF7FF),
                  labelStyle: TextStyle(color: Color(0xFF218BCF)),
                ),
                // Tambahkan filter lain di sini jika diperlukan
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .where(
                        'role',
                        isEqualTo: 'Pengguna Umum',
                      ) // Filter hanya Pengguna Umum
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
                    child: Text('Tidak ada pengguna umum untuk konsultasi.'),
                  );
                }

                final penggunaList =
                    snapshot.data!.docs.map((doc) {
                      return ChatUser.fromFirestore(doc);
                    }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: penggunaList.length,
                  itemBuilder: (context, index) {
                    final user = penggunaList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FB),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(
                              user.profileImageUrl,
                            ), // Menggunakan NetworkImage
                            onBackgroundImageError: (exception, stackTrace) {
                              // Fallback jika gambar gagal dimuat
                              Image.asset(
                                'assets/images/default_profile.png',
                              ).image;
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF218BCF),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildButton('Info', Icons.info, () {
                                      // Aksi Info pengguna
                                    }),
                                    const SizedBox(width: 8),
                                    _buildButton('Chat', Icons.chat, () {
                                      // Navigasi ke ChatPage, kirim objek ChatUser
                                      context.push('/chat', extra: user);
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            1, // Sesuaikan dengan index Konsultasi di bottom nav petugas
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: '',
          ),
        ],
        onTap: (index) {
          // (Opsional) Tambahkan navigasi berdasarkan index
          // if (index == 0) context.go('/konsultasi-petugas'); // Ini sudah halaman konsultasi
          // if (index == 1) context.go('/home-petugas');
          // if (index == 2) context.go('/komunitas');
        },
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
    );
  }
}

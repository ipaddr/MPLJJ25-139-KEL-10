// lib/features/konsultasi/view/konsultasi_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:giziku/models/chat_user.dart'; // Import model ChatUser

class KonsultasiPage extends StatelessWidget {
  const KonsultasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ahli Gizi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 12),
          Icon(Icons.filter_list),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4),
            child: Row(
              children: [
                const Text('Urutkan', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'A - Z',
                    style: TextStyle(color: Color(0xFF218BCF)),
                  ),
                ),
                // Tambahkan filter lain di sini jika diperlukan (misalnya status online)
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
                        isEqualTo: 'Petugas',
                      ) // Filter hanya Petugas
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
                    child: Text('Tidak ada ahli gizi tersedia.'),
                  );
                }

                final ahliGiziList =
                    snapshot.data!.docs.map((doc) {
                      return ChatUser.fromFirestore(doc);
                    }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ahliGiziList.length,
                  itemBuilder: (context, index) {
                    final dokter = ahliGiziList[index];
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
                              dokter.profileImageUrl,
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        dokter.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons
                                          .verified, // Centang biru untuk ahli gizi
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dokter.specialization ??
                                      'Spesialis Gizi', // Tampilkan spesialisasi
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildSmallButton('Info', Icons.info, () {
                                      // Aksi tombol Info (misalnya, tampilkan detail profil dokter)
                                    }),
                                    const SizedBox(width: 8),
                                    _buildSmallButton(
                                      'Simpan',
                                      Icons.favorite_border,
                                      () {
                                        // Aksi tombol Simpan
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSmallButton(
                                      'Chat',
                                      Icons.chat_bubble_outline,
                                      () {
                                        // Navigasi ke ChatPage, kirim objek ChatUser
                                        context.push('/chat', extra: dokter);
                                      },
                                    ),
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
        currentIndex: 1, // Sesuaikan dengan index Konsultasi di bottom nav
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black45,
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
          // if (index == 0) context.go('/jadwal');
          // if (index == 1) context.go('/konsultasi'); // Ini sudah halaman konsultasi
          // if (index == 2) context.go('/home');
          // if (index == 3) context.go('/komunitas');
          // if (index == 4) context.go('/riwayat');
        },
      ),
    );
  }

  Widget _buildSmallButton(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          backgroundColor: const Color(0xFFE0F2FF),
          foregroundColor: const Color(0xFF218BCF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

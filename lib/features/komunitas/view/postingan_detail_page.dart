// lib/features/komunitas/view/postingan_detail_page.dart
import 'package:flutter/material.dart';
import 'package:giziku/models/postingan.dart'; // Pastikan import model Postingan
import 'package:intl/intl.dart'; // Untuk format tanggal

class PostinganDetailPage extends StatelessWidget {
  final Postingan postingan;

  const PostinganDetailPage({required this.postingan, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konten'), // Judul AppBar sesuai desain
        backgroundColor: const Color(0xFF218BCF), // Warna AppBar
        foregroundColor: Colors.white, // Warna ikon dan teks pada AppBar
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama pengirim dan waktu
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    postingan.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 18,
                    ),
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
                              fontSize: 18,
                            ),
                          ),
                          if (postingan
                              .isVerified) // Tampilkan centang biru jika terverifikasi
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        postingan
                            .userRole, // Menampilkan role (misal: "Pengguna Umum" atau "Petugas")
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              postingan.subject, // Menggunakan properti subject langsung
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              // Menggunakan properti createdAt dan DateFormat dari intl
              'Upload: ${DateFormat('dd MMMM yyyy, HH:mm').format(postingan.createdAt)} WIB',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const Divider(height: 32, thickness: 1),
            Text(
              postingan.content, // Menggunakan properti content langsung
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Tampilan "Postingan Ini Terverifikasi" sesuai desain
            if (postingan.isVerified)
              Row(
                children: const [
                  Text(
                    'Postingan Ini Terverifikasi',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.verified, color: Colors.blue, size: 18),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

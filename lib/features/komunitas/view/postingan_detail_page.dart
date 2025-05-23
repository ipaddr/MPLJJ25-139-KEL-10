import 'package:flutter/material.dart';
import '../../../models/postingan.dart';

class PostinganDetailPage extends StatelessWidget {
  final Postingan postingan;
  const PostinganDetailPage({super.key, required this.postingan});

  @override
  Widget build(BuildContext context) {
    final parts = postingan.konten.split('\n\n');
    final subject = parts.first;
    final isi = parts.sublist(1).join('\n\n');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konten'),
        backgroundColor: const Color(0xFF218BCF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              'Upload: ${postingan.waktu.day} ${_bulan(postingan.waktu.month)} ${postingan.waktu.year}, ${postingan.waktu.hour}:${postingan.waktu.minute.toString().padLeft(2, '0')} WIB',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              subject,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(isi, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            if (postingan.terverifikasi)
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

  String _bulan(int bulan) {
    const namaBulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return namaBulan[bulan];
  }
}

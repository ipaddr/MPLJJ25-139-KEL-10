import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/postingan.dart';

class KomunitasPage extends StatelessWidget {
  const KomunitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final List<Postingan> postinganList = [
      Postingan(
        id: '1',
        nama: 'Dr. Annisa Irena, Sp.GK.',
        konten: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        waktu: DateTime.now().subtract(const Duration(minutes: 2)),
        terverifikasi: true,
      ),
      Postingan(
        id: '2',
        nama: 'Wahyu Isnan',
        konten: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        waktu: DateTime.now(),
        terverifikasi: false,
      ),
      Postingan(
        id: '3',
        nama: 'Fahrezy D.',
        konten: 'Lorem ipsum dolor sit amet, sed do eiusmod tempor.',
        waktu: DateTime.now().subtract(const Duration(hours: 3)),
        terverifikasi: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        title: const Text('GiziKu Komunitas'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: postinganList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = postinganList[index];
          return ListTile(
            onTap: () => context.push('/detail-postingan', extra: post),
            leading: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/default_profile.png'),
            ),
            title: Row(
              children: [
                Text(
                  post.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (post.terverifikasi) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 16, color: Colors.blue),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(post.konten, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/buat-postingan'),
        backgroundColor: const Color(0xFF218BCF),
        child: const Icon(Icons.edit),
      ),
    );
  }
}

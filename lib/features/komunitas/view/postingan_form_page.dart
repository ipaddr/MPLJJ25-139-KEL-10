import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/postingan.dart';

class PostinganFormPage extends StatefulWidget {
  const PostinganFormPage({super.key});

  @override
  State<PostinganFormPage> createState() => _PostinganFormPageState();
}

class _PostinganFormPageState extends State<PostinganFormPage> {
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();

  void _submit() async {
    final subject = _subjectController.text.trim();
    final content = _contentController.text.trim();

    if (subject.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subjek dan isi postingan wajib diisi')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'pengguna';

    final newPost = Postingan(
      id: DateTime.now().toIso8601String(),
      nama: 'Nama Anda',
      konten: '$subject\n\n$content',
      waktu: DateTime.now(),
      terverifikasi: role == 'petugas',
    );

    // Simulasikan pengiriman data
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Postingan berhasil dikirim')));

    Navigator.pop(context, newPost); // Kembali
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Postingan'),
        backgroundColor: const Color(0xFF218BCF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Isi Subjek...',
                filled: true,
                fillColor: Color(0xFFEAF6FD),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                expands: true,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Isi Postingan...',
                  filled: true,
                  fillColor: Color(0xFFEAF6FD),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF218BCF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const SizedBox(
                width: double.infinity,
                height: 48,
                child: Center(child: Text('Posting')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

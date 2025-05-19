import 'package:flutter/material.dart';

class PostinganFormPage extends StatefulWidget {
  const PostinganFormPage({super.key});

  @override
  State<PostinganFormPage> createState() => _PostinganFormPageState();
}

class _PostinganFormPageState extends State<PostinganFormPage> {
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  void _submitPostingan() {
    final judul = _judulController.text.trim();
    final isi = _isiController.text.trim();

    if (judul.isEmpty || isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan isi postingan tidak boleh kosong'),
        ),
      );
      return;
    }

    // Simulasi kirim data ke backend
    print('Judul: $judul');
    print('Isi: $isi');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Postingan berhasil dikirim')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        title: const Text(
          'Buat Postingan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Subjek', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _judulController,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Isi Subjek...',
                filled: true,
                fillColor: const Color(0xFFEAF7FF),
                counterText: '',
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _isiController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Isi Postingan...',
                filled: true,
                fillColor: const Color(0xFFEAF7FF),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitPostingan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF218BCF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Posting',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: '',
          ),
        ],
      ),
    );
  }
}

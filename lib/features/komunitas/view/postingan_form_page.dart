// lib/features/komunitas/view/postingan_form_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Untuk mendapatkan UID user
import 'package:go_router/go_router.dart';
import 'package:giziku/models/postingan.dart'; // Pastikan import model Postingan
import 'package:shared_preferences/shared_preferences.dart'; // Untuk mendapatkan role user

class PostinganFormPage extends StatefulWidget {
  const PostinganFormPage({super.key});

  @override
  State<PostinganFormPage> createState() => _PostinganFormPageState();
}

class _PostinganFormPageState extends State<PostinganFormPage> {
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? _errorMessage;
  String? _currentUserRole; // Untuk menyimpan role pengguna yang login
  String? _currentUserName; // Untuk menyimpan nama pengguna yang login
  String? _currentUserId; // Untuk menyimpan UID pengguna yang login

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }

  Future<void> _loadCurrentUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    setState(() {
      _currentUserRole = role;
    });

    final user = _auth.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          _currentUserName = userData.data()?['name'] as String?;
        });
      }
    } else {
      // Jika user belum login atau sesi habis, tampilkan error
      setState(() {
        _errorMessage = 'Anda harus login untuk membuat postingan.';
      });
    }
  }

  Future<void> _submitPostingan() async {
    setState(() {
      _errorMessage = null;
    });

    if (_currentUserId == null ||
        _currentUserName == null ||
        _currentUserRole == null) {
      setState(() {
        _errorMessage = 'Gagal mendapatkan data pengguna. Coba login ulang.';
      });
      return;
    }

    if (_subjectController.text.isEmpty || _contentController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Judul dan isi postingan tidak boleh kosong.';
      });
      return;
    }

    // Tentukan isVerified berdasarkan role pengguna
    final bool isVerified = (_currentUserRole == 'Petugas');

    try {
      final newPostingan = Postingan(
        id: '', // ID akan diisi oleh Firestore
        userId: _currentUserId!,
        userName: _currentUserName!,
        userRole: _currentUserRole!,
        subject: _subjectController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: DateTime.now(),
        isVerified: isVerified,
      );

      await _firestore.collection('postingan').add(newPostingan.toFirestore());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan berhasil dikirim!')),
        );
        context.pop(); // Kembali ke halaman sebelumnya setelah berhasil
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuat postingan: ${e.toString()}';
      });
      print('Error creating posting: $e'); // Debugging
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Postingan'),
        backgroundColor: const Color(0xFF218BCF), // Warna AppBar
        foregroundColor: Colors.white, // Warna ikon dan teks pada AppBar
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding disesuaikan
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              maxLength: 100, // Batasan karakter untuk subjek
              decoration: InputDecoration(
                hintText: 'Isi Subjek...',
                filled: true,
                fillColor: const Color(0xFFEAF6FD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Border radius
                  borderSide: BorderSide.none,
                ),
                counterText: '', // Sembunyikan counter karakter
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                expands: true,
                maxLines: null, // Memungkinkan banyak baris
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Isi Postingan...',
                  filled: true,
                  fillColor: const Color(0xFFEAF6FD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // Border radius
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitPostingan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF218BCF), // Warna tombol
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded button
                  ),
                ),
                child: const Text('Posting', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

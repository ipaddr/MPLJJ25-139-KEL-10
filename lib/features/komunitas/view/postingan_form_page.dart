// lib/features/komunitas/view/postingan_form_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:giziku/models/postingan.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _currentUserRole;
  String? _currentUserName;
  String? _currentUserId;
  bool _isCurrentUserVerified =
      false; // ✅ Tambahkan ini untuk menyimpan status verifikasi pengguna

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
      try {
        final userDataDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDataDoc.exists) {
          final userData = userDataDoc.data();
          setState(() {
            _currentUserName = userData?['name'] as String?;
            _isCurrentUserVerified =
                userData?['isVerified'] as bool? ??
                false; // ✅ Ambil status isVerified
          });
        }
      } catch (e) {
        print('Error loading user profile for posting form: $e');
        setState(() {
          _errorMessage = 'Gagal memuat info pengguna.';
        });
      }
    } else {
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

    // ✅ Tentukan isVerified postingan berdasarkan status isVerified petugas (JIKA dia petugas)
    // Pengguna Umum (role='Pengguna Umum') akan selalu membuat isVerified: false
    // Petugas (role='Petugas') akan membuat isVerified: true HANYA JIKA isCurrentUserVerified
    final bool isPostVerified =
        (_currentUserRole == 'Petugas' && _isCurrentUserVerified);

    try {
      final newPostingan = Postingan(
        id: '',
        userId: _currentUserId!,
        userName: _currentUserName!,
        userRole: _currentUserRole!,
        subject: _subjectController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: DateTime.now(),
        isVerified: isPostVerified, // ✅ Gunakan logika baru ini
      );

      await _firestore.collection('postingan').add(newPostingan.toFirestore());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan berhasil dikirim!')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuat postingan: ${e.toString()}';
      });
      print('Error creating posting: $e');
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
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Isi Subjek...',
                filled: true,
                fillColor: const Color(0xFFEAF6FD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Isi Postingan...',
                  filled: true,
                  fillColor: const Color(0xFFEAF6FD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
                  backgroundColor: const Color(0xFF218BCF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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

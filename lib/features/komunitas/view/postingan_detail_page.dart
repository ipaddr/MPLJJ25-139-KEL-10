// lib/features/komunitas/view/postingan_detail_page.dart
import 'package:flutter/material.dart';
import 'package:giziku/models/postingan.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostinganDetailPage extends StatefulWidget {
  final Postingan postingan;

  const PostinganDetailPage({required this.postingan, super.key});

  @override
  State<PostinganDetailPage> createState() => _PostinganDetailPageState();
}

class _PostinganDetailPageState extends State<PostinganDetailPage> {
  String _userProfileImageUrl = 'assets/images/default_profile.png';

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  // Menggunakan didUpdateWidget untuk memperbarui gambar jika postingan berubah
  @override
  void didUpdateWidget(covariant PostinganDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.postingan.userId != oldWidget.postingan.userId) {
      _loadUserProfileImage();
    }
  }

  Future<void> _loadUserProfileImage() async {
    print(
      '[PostinganDetailPage:_PostinganDetailPageState] Loading image for user ID: ${widget.postingan.userId}',
    );
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.postingan.userId)
              .get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final imageUrl =
            userData?['profileImageUrl'] as String? ??
            'assets/images/default_profile.png';
        if (mounted) {
          setState(() {
            _userProfileImageUrl = imageUrl;
            print(
              '[PostinganDetailPage:_PostinganDetailPageState] Loaded image URL: $_userProfileImageUrl for user: ${widget.postingan.userName}',
            );
          });
        }
      } else {
        print(
          '[PostinganDetailPage:_PostinganDetailPageState] User document not found for ${widget.postingan.userName}. Using default image.',
        );
        if (mounted) {
          setState(() {
            _userProfileImageUrl = 'assets/images/default_profile.png';
          });
        }
      }
    } catch (e) {
      print(
        '[PostinganDetailPage:_PostinganDetailPageState] Error loading user profile image for ${widget.postingan.userName}: $e',
      );
      if (mounted) {
        setState(() {
          _userProfileImageUrl = 'assets/images/default_profile.png';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konten'),
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  // Pastikan _userProfileImageUrl adalah URL yang valid sebelum menggunakan NetworkImage
                  backgroundImage:
                      (_userProfileImageUrl.startsWith('http') &&
                              Uri.tryParse(
                                    _userProfileImageUrl,
                                  )?.hasAbsolutePath ==
                                  true)
                          ? NetworkImage(_userProfileImageUrl) as ImageProvider
                          : AssetImage(_userProfileImageUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    print(
                      '[PostinganDetailPage:_PostinganDetailPageState] Error loading network image for avatar: $exception',
                    );
                    if (mounted) {
                      setState(() {
                        _userProfileImageUrl =
                            'assets/images/default_profile.png';
                      });
                    }
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.postingan.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (widget.postingan.isVerified)
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
                        widget.postingan.userRole,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.postingan.subject,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload: ${DateFormat('dd MMMM yyyy, HH:mm').format(widget.postingan.createdAt)} WIB',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const Divider(height: 32, thickness: 1),
            Text(
              widget.postingan.content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            if (widget.postingan.isVerified)
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

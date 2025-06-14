// lib/features/komunitas/view/komunitas_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:giziku/models/postingan.dart';
import 'package:intl/intl.dart';

class KomunitasPage extends StatelessWidget {
  const KomunitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GiziKu Komunitas'),
        backgroundColor: const Color(0xFFEAF6FD),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // Aksi notifikasi
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFEAF6FD),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('postingan')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada postingan.'));
          }

          final postinganList =
              snapshot.data!.docs.map((doc) {
                return Postingan.fromFirestore(doc);
              }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: postinganList.length,
            itemBuilder: (context, index) {
              final postingan = postinganList[index];
              return _PostinganCard(postingan: postingan);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/buat-postingan');
        },
        backgroundColor: const Color(0xFF218BCF),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEAF6FD),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black45,
        currentIndex: 3,
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
        },
      ),
    );
  }
}

class _PostinganCard extends StatefulWidget {
  final Postingan postingan;

  const _PostinganCard({required this.postingan});

  @override
  State<_PostinganCard> createState() => _PostinganCardState();
}

class _PostinganCardState extends State<_PostinganCard> {
  String _userProfileImageUrl = 'assets/images/default_profile.png';

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  // Menggunakan didUpdateWidget untuk memperbarui gambar jika postingan berubah
  @override
  void didUpdateWidget(covariant _PostinganCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.postingan.userId != oldWidget.postingan.userId) {
      _loadUserProfileImage();
    }
  }

  Future<void> _loadUserProfileImage() async {
    print(
      '[KomunitasPage:_PostinganCardState] Loading image for user ID: ${widget.postingan.userId}',
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
              '[KomunitasPage:_PostinganCardState] Loaded image URL: $_userProfileImageUrl for user: ${widget.postingan.userName}',
            );
          });
        }
      } else {
        print(
          '[KomunitasPage:_PostinganCardState] User document not found for ${widget.postingan.userName}. Using default image.',
        );
        if (mounted) {
          setState(() {
            _userProfileImageUrl = 'assets/images/default_profile.png';
          });
        }
      }
    } catch (e) {
      print(
        '[KomunitasPage:_PostinganCardState] Error loading user profile image for ${widget.postingan.userName}: $e',
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
    return GestureDetector(
      onTap: () {
        context.push('/detail-postingan', extra: widget.postingan);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    // Pastikan _userProfileImageUrl adalah URL yang valid sebelum menggunakan NetworkImage
                    backgroundImage:
                        (_userProfileImageUrl.startsWith('http') &&
                                Uri.tryParse(
                                      _userProfileImageUrl,
                                    )?.hasAbsolutePath ==
                                    true)
                            ? NetworkImage(_userProfileImageUrl)
                                as ImageProvider
                            : AssetImage(_userProfileImageUrl),
                    onBackgroundImageError: (exception, stackTrace) {
                      print(
                        '[KomunitasPage:_PostinganCardState] Error loading network image for avatar: $exception',
                      );
                      if (mounted) {
                        setState(() {
                          _userProfileImageUrl =
                              'assets/images/default_profile.png'; // Fallback to default asset
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
                                fontSize: 16,
                              ),
                            ),
                            if (widget.postingan.isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy, HH:mm',
                          ).format(widget.postingan.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.postingan.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                widget.postingan.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

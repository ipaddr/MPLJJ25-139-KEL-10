// lib/features/home/view/home_petugas_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePetugasPage extends StatefulWidget {
  const HomePetugasPage({super.key});

  @override
  State<HomePetugasPage> createState() => _HomePetugasPageState();
}

class _HomePetugasPageState extends State<HomePetugasPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'Petugas';
  String _profileImageUrl = 'assets/images/default_profile.png';
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    print(
      '[HomePetugasPage] _loadUserProfile called. Current user: ${user?.uid}',
    );
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen(
            (userDoc) {
              if (userDoc.exists) {
                final userData = userDoc.data();
                if (mounted) {
                  setState(() {
                    _userName = userData?['name'] as String? ?? 'Petugas';
                    _profileImageUrl =
                        userData?['profileImageUrl'] as String? ??
                        'assets/images/default_profile.png';
                    _isVerified = userData?['isVerified'] as bool? ?? false;
                    print(
                      '[HomePetugasPage] User data updated via stream: Name=$_userName, Image=$_profileImageUrl, Verified=$_isVerified',
                    );
                  });
                }
              } else {
                if (mounted) {
                  setState(() {
                    _userName = 'Petugas Baru (Doc Not Found)';
                    _profileImageUrl = 'assets/images/default_profile.png';
                    _isVerified = false;
                    print(
                      '[HomePetugasPage] User document not found, setting default data.',
                    );
                  });
                }
              }
            },
            onError: (error) {
              print(
                '[HomePetugasPage] Error listening to user profile stream: $error',
              );
              if (mounted) {
                setState(() {
                  _userName = 'Error Loading';
                  _profileImageUrl = 'assets/images/default_profile.png';
                  _isVerified = false;
                });
              }
            },
          );
    } else {
      if (mounted) {
        setState(() {
          _userName = 'Tamu Petugas (Not Logged In)';
          _profileImageUrl = 'assets/images/default_profile.png';
          _isVerified = false;
          print(
            '[HomePetugasPage] No user logged in, setting default guest data.',
          );
        });
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go('/select-role');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari akun ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _handleLogout(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
      '[HomePetugasPage] Building widget. Current Name: $_userName, Image: $_profileImageUrl',
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.black87),
          onPressed: () => _showLogoutDialog(context),
          tooltip: 'Keluar',
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black54),
          SizedBox(width: 12),
          Icon(Icons.settings, color: Colors.black54),
          SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      (_profileImageUrl.startsWith('http') &&
                              Uri.tryParse(_profileImageUrl)?.hasAbsolutePath ==
                                  true)
                          ? NetworkImage(_profileImageUrl) as ImageProvider
                          : AssetImage(_profileImageUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    print(
                      '[HomePetugasPage] Error loading network image for CircleAvatar: $exception',
                    );
                    if (mounted) {
                      setState(() {
                        _profileImageUrl = 'assets/images/default_profile.png';
                      });
                    }
                  },
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Halo, Selamat Sore',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Row(
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              fontSize: 16,
                            ),
                          ),
                          if (_isVerified)
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Menu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuItem(
                    icon: Icons.group_outlined,
                    label: 'Postingan Edukatif',
                    onTap: () => context.push('/komunitas'),
                  ),
                  _buildMenuItem(
                    icon: Icons.chat_outlined,
                    label: 'Konsultasi Gizi',
                    onTap: () => context.push('/konsultasi-petugas'),
                  ),
                  _buildMenuItem(
                    icon: Icons.calendar_month, // ✅ Icon baru
                    label: 'Daftar Jadwal Bantuan', // ✅ Label baru
                    onTap:
                        () => context.push(
                          '/daftar-jadwal-bantuan',
                        ), // ✅ Rute baru
                  ),
                  _buildMenuItem(label: 'Coming Soon...'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 64),
          decoration: const BoxDecoration(
            color: Color(0xFFEAF7FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const Center(
            child: Icon(Icons.home, color: Colors.blue, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF218BCF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/features/home/view/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'Pengguna';
  String _profileImageUrl = 'assets/images/default_profile.png';
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    print('[HomePage] _loadUserProfile called. Current user: ${user?.uid}');
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
                    _userName = userData?['name'] as String? ?? 'Pengguna';
                    _profileImageUrl =
                        userData?['profileImageUrl'] as String? ??
                        'assets/images/default_profile.png';
                    _isVerified = userData?['isVerified'] as bool? ?? false;
                    print(
                      '[HomePage] User data updated via stream: Name=$_userName, Image=$_profileImageUrl, Verified=$_isVerified',
                    );
                  });
                }
              } else {
                if (mounted) {
                  setState(() {
                    _userName = 'Pengguna Baru (Doc Not Found)';
                    _profileImageUrl = 'assets/images/default_profile.png';
                    _isVerified = false;
                    print(
                      '[HomePage] User document not found, setting default data.',
                    );
                  });
                }
              }
            },
            onError: (error) {
              print(
                '[HomePage] Error listening to user profile stream: $error',
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
          _userName = 'Tamu (Not Logged In)';
          _profileImageUrl = 'assets/images/default_profile.png';
          _isVerified = false;
          print('[HomePage] No user logged in, setting default guest data.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      '[HomePage] Building widget. Current Name: $_userName, Image: $_profileImageUrl',
    );
    final menuItems = [
      _MenuItem('Jadwal Distribusi', Icons.calendar_today, '/jadwal'),
      _MenuItem('Konsultasi Gizi', Icons.chat, '/konsultasi'),
      _MenuItem('Komunitas & Edukasi', Icons.people, '/komunitas'),
      _MenuItem(
        'Riwayat Bantuan Terdistribusi',
        Icons.receipt_long,
        '/riwayat',
      ),
      _MenuItem('GiziSmart', Icons.smart_toy, '/chatbot'),
      _MenuItem('Coming Soon…', Icons.hourglass_empty, ''),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF6FD),
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () => _showLogoutDialog(context),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Halo, Selamat Sore',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      Row(
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundImage:
                      (_profileImageUrl.startsWith('http') &&
                              Uri.tryParse(_profileImageUrl)?.hasAbsolutePath ==
                                  true)
                          ? NetworkImage(_profileImageUrl) as ImageProvider
                          : AssetImage(_profileImageUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    print(
                      '[HomePage] Error loading network image for CircleAvatar: $exception',
                    );
                    if (mounted) {
                      setState(() {
                        _profileImageUrl = 'assets/images/default_profile.png';
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children:
                    menuItems
                        .map(
                          (item) => _MenuCard(
                            // ✅ Tidak ada lagi super.key di sini
                            label: item.label,
                            icon: item.icon,
                            route: item.route,
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEAF6FD),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black45,
        currentIndex: 2,
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
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('user_role');
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    context.go('/select-role');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final String route;

  _MenuItem(this.label, this.icon, this.route);
}

class _MenuCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;

  // ✅ Hapus 'super.key' dari konstruktor
  const _MenuCard({
    required this.label,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: route.isNotEmpty ? () => context.push(route) : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

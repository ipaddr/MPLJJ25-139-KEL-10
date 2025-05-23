import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Tombol Logout
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () => _showLogoutDialog(context),
            ),

            // Nama, notifikasi, dan profil
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
                  onTap:
                      () => context.push(
                        '/profile',
                      ), // ✅ Navigasi ke halaman profil
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        'Halo, Selamat Sore',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      Text(
                        'Wahyu Isnan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage('assets/images/profile.png'),
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
                  Navigator.pop(ctx);
                  context.go('/select-role'); // Arahkan ke halaman awal
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }
}

// ───────────────────────── Menu Data Class ─────────────────────────
class _MenuItem {
  final String label;
  final IconData icon;
  final String route;

  _MenuItem(this.label, this.icon, this.route);
}

// ───────────────────────── Card Widget ─────────────────────────
class _MenuCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;

  const _MenuCard({
    required this.label,
    required this.icon,
    required this.route,
    super.key,
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

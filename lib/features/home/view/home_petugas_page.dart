import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePetugasPage extends StatelessWidget {
  const HomePetugasPage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    context.go('/select-role');
  }

  @override
  Widget build(BuildContext context) {
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
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/dr_annisa.png'),
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
                        children: const [
                          Text(
                            'Dr. Annisa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.verified, color: Colors.blue, size: 16),
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
                    onTap: () => context.push('/komunitas-petugas'),
                  ),
                  _buildMenuItem(
                    icon: Icons.chat_outlined,
                    label: 'Konsultasi Gizi',
                    onTap: () => context.push('/konsultasi-petugas'),
                  ),
                  _buildMenuItem(label: 'Coming Soon...'),
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
                  context.go('/select-role');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }
}

// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('GiziKu Home')),
//       body: const Center(
//         child: Text(
//           'Selamat datang di GiziKu!',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Halo, Selamat Sore',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Wahyu Isnan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
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
          // Arahkan ke halaman sesuai index jika diinginkan
        },
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

  const _MenuCard({
    required this.label,
    required this.icon,
    required this.route,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          route.isNotEmpty ? () => Navigator.pushNamed(context, route) : null,
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
//hazamUpdate123
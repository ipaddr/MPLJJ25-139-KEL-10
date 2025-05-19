import 'package:flutter/material.dart';

class KonsultasiAdminPage extends StatelessWidget {
  const KonsultasiAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> konsultasiList = [
      {'name': 'Wahyu Isnan', 'image': 'assets/images/user_wahyu.png'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9F6FF),
        elevation: 0,
        title: const Text(
          'Konsultasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.filter_list, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4),
            child: Row(
              children: [
                Text('Urutkan', style: TextStyle(fontSize: 14)),
                SizedBox(width: 8),
                Chip(
                  label: Text('A - Z'),
                  backgroundColor: Color(0xFFEAF7FF),
                  labelStyle: TextStyle(color: Color(0xFF218BCF)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: konsultasiList.length,
              itemBuilder: (context, index) {
                final user = konsultasiList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: AssetImage(user['image']!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF218BCF),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildButton('Info', Icons.info, () {
                                  // Aksi Info pengguna
                                }),
                                const SizedBox(width: 8),
                                _buildButton('Chat', Icons.chat, () {
                                  Navigator.pushNamed(
                                    context,
                                    '/chat/${user['name']!.toLowerCase().replaceAll(' ', '-')}',
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
    );
  }
}

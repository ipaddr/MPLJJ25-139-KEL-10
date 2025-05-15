return Scaffold(
  appBar: AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text(
      'Ahli Gizi',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
    actions: const [
      Icon(Icons.search),
      SizedBox(width: 12),
      Icon(Icons.filter_list),
      SizedBox(width: 12),
    ],
  ),
  body: Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4),
        child: Row(
          children: [
            const Text(
              'Urutkan',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'A - Z',
                style: TextStyle(color: Color(0xFF218BCF)),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ahliGiziList.length,
          itemBuilder: (context, index) {
            final dokter = ahliGiziList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FB),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(dokter['image']!),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dokter['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Icon(Icons.verified, size: 16, color: Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dokter['specialist']!,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildSmallButton('Info', Icons.info, () {
                              // Aksi info
                            }),
                            const SizedBox(width: 8),
                            _buildSmallButton('Simpan', Icons.favorite_border, () {
                              // Aksi simpan
                            }),
                            const SizedBox(width: 8),
                            _buildSmallButton('Chat', Icons.chat_bubble_outline, () {
                              // Navigasi ke halaman chat
                              Navigator.pushNamed(context, '/chat/ahli-${index + 1}');
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
    currentIndex: 2,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
    ],
  ),
);

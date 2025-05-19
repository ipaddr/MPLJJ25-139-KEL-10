import 'package:flutter/material.dart';

class KomunitasAdminPage extends StatelessWidget {
const KomunitasAdminPage({super.key});

@override
Widget build(BuildContext context) {
final List<Map<String, dynamic>> posts = [
{
'name': 'Wahyu Isnan',
'time': 'Sekarang',
'text': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
'verified': false,
'likes': 2,
'comments': 0,
},
{
'name': 'Dr. Annisa Irena, Sp.GK.',
'time': '2 menit lalu',
'text':
'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
'verified': true,
'likes': 12,
'comments': 2,
},
];

return Scaffold(
  appBar: AppBar(
    title: const Text(
      'GiziKu Komunitas',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    actions: [
      Stack(
        children: [
          const Icon(Icons.notifications_none),
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '3',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: 12),
    ],
  ),
  body: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Text('Terbaru', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Text(post['name'][0])),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                post['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (post['verified'])
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.verified,
                                      size: 16, color: Colors.blue),
                                ),
                            ],
                          ),
                        ),
                        Text(post['time'],
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(post['text']),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.thumb_up_alt_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(post['likes'].toString()),
                        const SizedBox(width: 16),
                        Icon(Icons.chat_bubble_outline, size: 16),
                        const SizedBox(width: 4),
                        Text(post['comments'].toString()),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      )
    ],
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      // Aksi buat postingan edukatif
    },
    backgroundColor: const Color(0xFF218BCF),
    child: const Icon(Icons.edit),
  ),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: 2,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
    ],
  ),
);
}
}
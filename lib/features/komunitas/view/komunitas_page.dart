import 'package:flutter/material.dart';

class KomunitasPage extends StatefulWidget {
  const KomunitasPage({super.key});

  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage(
              'assets/images/profile.jpg',
            ), // Ganti sesuai asset
          ),
        ),
        title: const Text('GiziKu Komunitas'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
              const CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text(
                  '3',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Terbaru'),
            Tab(text: 'Keseharian'),
            Tab(text: 'Diri Sendiri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildPostList(), // Buat function ini di bawah
          buildPostList(),
          buildPostList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi ketika menulis postingan baru
        },
        child: const Icon(Icons.edit),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
        ],
      ),
    );
  }

  Widget buildPostList() {
    final posts = [
      {
        "name": "Wahyu Isnan",
        "time": "Sekarang",
        "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "likes": 2,
        "comments": 0,
        "verified": false,
      },
      {
        "name": "Fahrezy D.",
        "time": "3 jam lalu",
        "text": "Lorem ipsum dolor sit amet, sed do eiusmod tempor.",
        "likes": 12,
        "comments": 2,
        "verified": false,
      },
      {
        "name": "Dr. Annisa Irena, Sp.GK.",
        "time": "2 menit lalu",
        "text": "Lorem ipsum dolor sit amet, sed do eiusmod tempor incididunt.",
        "likes": 12,
        "comments": 2,
        "verified": true,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            title: Row(
              children: [
                Text(post["name"].toString()),
                if (post["verified"] == true)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.verified, color: Colors.blue, size: 16),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post["name"].toString()),
                const SizedBox(height: 4),
                Text(post["text"].toString()),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(post["likes"].toString()),
                    const SizedBox(width: 16),
                    Icon(Icons.comment_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(post["comments"].toString()),
                    const Spacer(),
                    Icon(Icons.share_outlined, size: 16),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

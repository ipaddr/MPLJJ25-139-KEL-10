import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String role = 'pengguna'; // default

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('user_role') ?? 'pengguna';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPetugas = role == 'petugas';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: const [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                    'assets/images/default_profile.png',
                  ),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.edit, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildField('Nama Lengkap', 'Dr. Annisa Irena, Sp.GK.'),
          _buildField('Telepon', '+62 890 1234 5678'),
          _buildField('Email', 'testing@example.com'),
          _buildField('Tanggal Lahir', 'DD / MM / YYYY'),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildField(
                'Kategori Pengguna',
                isPetugas ? 'Ahli Gizi' : 'Masyarakat',
              ),
              if (isPetugas)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB3DAF4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.push('/verifikasi-petugas');
                  },
                  child: const Text(
                    'Keaslian Data',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF218BCF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Perbarui Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

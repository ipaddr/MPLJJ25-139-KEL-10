import 'package:flutter/material.dart';

class ProfilePetugasPage extends StatelessWidget {
  const ProfilePetugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController namaController = TextEditingController(
      text: 'Dr. Annisa Irena, Sp.GK.',
    );
    final TextEditingController telpController = TextEditingController(
      text: '+62 890 1234 5678',
    );
    final TextEditingController emailController = TextEditingController(
      text: 'testing@example.com',
    );
    final TextEditingController tglController = TextEditingController(text: '');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/dr_annisa.png'),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Nama Lengkap'),
          const SizedBox(height: 4),
          _buildInput(namaController),
          const SizedBox(height: 12),
          const Text('Telepon'),
          const SizedBox(height: 4),
          _buildInput(telpController),
          const SizedBox(height: 12),
          const Text('Email'),
          const SizedBox(height: 4),
          _buildInput(emailController),
          const SizedBox(height: 12),
          const Text('Tanggal Lahir'),
          const SizedBox(height: 4),
          _buildInput(tglController, hint: 'DD / MM / YYYY'),
          const SizedBox(height: 12),
          const Text('Kategori Pengguna'),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Ahli Gizi', style: TextStyle(fontSize: 16)),
                ),
                const Text(
                  'Keaslian Data',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 18, color: Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // aksi simpan/perbarui profile
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF218BCF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Perbarui Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, {String? hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFE9F6FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class VerifikasiPetugasPage extends StatelessWidget {
  const VerifikasiPetugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Ahli Gizi'),
        backgroundColor: const Color(0xFF218BCF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
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
            _buildTextField('Nama Lengkap', 'Dr. Annisa Irena, Sp.GK.'),
            const SizedBox(height: 12),
            _buildUploadField('Surat Tanda Registrasi (STR)'),
            const SizedBox(height: 12),
            _buildUploadField('Surat Izin Praktik (SIP)'),
            const SizedBox(height: 12),
            _buildUploadField('Dokumen Pendukung Lainnya'),
            const SizedBox(height: 24),
            const Row(
              children: [
                Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.verified, color: Colors.blue),
                Text(' Terverifikasi', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFEAF6FD),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Text('Upload File'),
              Spacer(),
              Icon(Icons.upload_file, color: Colors.blue),
            ],
          ),
        ),
      ],
    );
  }
}

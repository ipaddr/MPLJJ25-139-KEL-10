import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class VerifikasiPetugasPage extends StatefulWidget {
  const VerifikasiPetugasPage({super.key});

  @override
  State<VerifikasiPetugasPage> createState() => _VerifikasiPetugasPageState();
}

class _VerifikasiPetugasPageState extends State<VerifikasiPetugasPage> {
  String? fileSTR;
  String? fileSIP;
  String? fileLain;

  Future<void> pickFile(Function(String) onPicked) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      onPicked(result.files.single.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        title: const Text(
          'Verifikasi Ahli Gizi',
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
          _buildTextInfo('Dr. Annisa Irena, Sp.GK.'),
          const SizedBox(height: 20),
          _buildUploadSection('Surat Tanda Registrasi (STR)', fileSTR, () {
            pickFile((fileName) => setState(() => fileSTR = fileName));
          }),
          _buildUploadSection('Surat Izin Praktik (SIP)', fileSIP, () {
            pickFile((fileName) => setState(() => fileSIP = fileName));
          }),
          _buildUploadSection('Dokumen Pendukung Lainnya', fileLain, () {
            pickFile((fileName) => setState(() => fileLain = fileName));
          }),
          const SizedBox(height: 20),
          const Text('Status'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Expanded(child: Text('Terverifikasi')),
                Icon(Icons.verified, color: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInfo(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildUploadSection(
    String label,
    String? fileName,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fileName ?? 'Upload File',
                    style: TextStyle(
                      fontSize: 14,
                      color: fileName != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
                const Icon(Icons.upload_file, color: Colors.blue),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

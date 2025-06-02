// lib/features/profile/view/verifikasi_petugas_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:io'; // ✅ Hapus baris ini
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifikasiPetugasPage extends StatefulWidget {
  const VerifikasiPetugasPage({super.key});

  @override
  State<VerifikasiPetugasPage> createState() => _VerifikasiPetugasPageState();
}

class _VerifikasiPetugasPageState extends State<VerifikasiPetugasPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;

  Map<String, String?> _documentUrls = {
    'strUrl': null,
    'sipUrl': null,
    'otherDocUrl': null,
  };
  bool _isVerified = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Cloudinary Credentials
  final String _cloudinaryCloudName =
      'dpk5a9ule'; // GANTI DENGAN CLOUD NAME ANDA
  final String _cloudinaryUploadPreset =
      'giziku_mbg_upload'; // GANTI DENGAN UPLOAD PRESET NAME ANDA

  // Tambahkan field ini untuk menyimpan data profil dasar
  Map<String, dynamic>? _userData;
  final TextEditingController _nameController =
      TextEditingController(); // Untuk menampilkan nama

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadVerificationStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'Anda harus login untuk melihat status verifikasi.';
        _isLoading = false;
      });
      return;
    }

    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        _userData = data;
        _nameController.text = data?['name'] as String? ?? '';
        _documentUrls['strUrl'] = data?['strUrl'] as String?;
        _documentUrls['sipUrl'] = data?['sipUrl'] as String?;
        _documentUrls['otherDocUrl'] = data?['otherDocUrl'] as String?;
        _isVerified = data?['isVerified'] as bool? ?? false;
      } else {
        _errorMessage = 'Data profil tidak ditemukan.';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat status verifikasi: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadFile(String docType) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
        );
        final request =
            http.MultipartRequest('POST', uri)
              ..fields['upload_preset'] = _cloudinaryUploadPreset
              ..files.add(await http.MultipartFile.fromPath('file', file.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = json.decode(
            await response.stream.bytesToString(),
          );
          final String downloadUrl = responseData['secure_url'];

          await _firestore.collection('users').doc(currentUser!.uid).update({
            docType: downloadUrl,
          });

          setState(() {
            _documentUrls[docType] = downloadUrl;
            _isLoading = false;
          });

          _checkVerificationStatus();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$docType berhasil diupload!')),
            );
          }
        } else {
          final errorBody = await response.stream.bytesToString();
          throw Exception(
            'Failed to upload $docType to Cloudinary: ${response.statusCode} - $errorBody',
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Gagal mengupload $docType: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _checkVerificationStatus() {
    bool allDocsUploaded =
        _documentUrls['strUrl'] != null && _documentUrls['sipUrl'] != null;

    if (allDocsUploaded != _isVerified) {
      setState(() {
        _isVerified = allDocsUploaded;
      });
      _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({'isVerified': _isVerified})
          .catchError((e) {
            print('Error updating isVerified status: $e');
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verifikasi Ahli Gizi'),
          backgroundColor: const Color(0xFF218BCF),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verifikasi Ahli Gizi'),
          backgroundColor: const Color(0xFF218BCF),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Ahli Gizi'),
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        (_userData != null &&
                                _userData!['profileImageUrl'] != null &&
                                _userData!['profileImageUrl'].isNotEmpty)
                            ? NetworkImage(_userData!['profileImageUrl'])
                                as ImageProvider
                            : const AssetImage(
                              'assets/images/default_profile.png',
                            ),
                    onBackgroundImageError: (exception, stackTrace) {
                      print(
                        '[VerifikasiPetugasPage] Error loading network image for avatar: $exception',
                      );
                      setState(() {
                        if (_userData != null) {
                          _userData!['profileImageUrl'] = null;
                        }
                      });
                    },
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Nama Lengkap', _nameController.text),
            const SizedBox(height: 12),
            _buildUploadField(
              'Surat Tanda Registrasi (STR)',
              _documentUrls['strUrl'],
              () => _uploadFile('strUrl'),
            ),
            const SizedBox(height: 12),
            _buildUploadField(
              'Surat Izin Praktik (SIP)',
              _documentUrls['sipUrl'],
              () => _uploadFile('sipUrl'),
            ),
            const SizedBox(height: 12),
            _buildUploadField(
              'Dokumen Pendukung Lainnya',
              _documentUrls['otherDocUrl'],
              () => _uploadFile('otherDocUrl'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isVerified ? Icons.verified : Icons.cancel,
                  color: _isVerified ? Colors.blue : Colors.red,
                ),
                Text(
                  _isVerified ? ' Terverifikasi' : ' Belum Terverifikasi',
                  style: TextStyle(
                    color: _isVerified ? Colors.blue : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
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
          child: Row(children: [Expanded(child: Text(value))]),
        ),
      ],
    );
  }

  Widget _buildUploadField(
    String label,
    String? currentUrl,
    VoidCallback onUpload,
  ) {
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
            children: [
              Expanded(
                child: Text(
                  currentUrl != null && currentUrl.isNotEmpty
                      ? 'File Terupload'
                      : 'Upload File',
                  style: TextStyle(
                    color:
                        currentUrl != null && currentUrl.isNotEmpty
                            ? Colors.green
                            : Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onUpload,
                child: Icon(
                  currentUrl != null && currentUrl.isNotEmpty
                      ? Icons.check_circle
                      : Icons.upload_file,
                  color:
                      currentUrl != null && currentUrl.isNotEmpty
                          ? Colors.green
                          : Colors.blue,
                ),
              ),
              if (currentUrl != null && currentUrl.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    print('View file: $currentUrl');
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.visibility, color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

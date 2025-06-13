// lib/features/profile/view/profile_page.dart
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // ✅ Hapus baris ini
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:io'; // Ini sudah dihapus sebelumnya
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;
  String _role = 'Pengguna Umum';
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  // Cloudinary Credentials
  final String _cloudinaryCloudName =
      'dpk5a9ule'; // GANTI DENGAN CLOUD NAME ANDA
  final String _cloudinaryUploadPreset =
      'giziku_mbg_upload'; // GANTI DENGAN UPLOAD PRESET NAME ANDA

  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _certificationController =
      TextEditingController();
  final TextEditingController _availableHoursController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _specializationController.dispose();
    _certificationController.dispose();
    _availableHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    print('[_loadUserProfile] Starting profile load...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    currentUser = _auth.currentUser;
    print('[_loadUserProfile] Current User UID: ${currentUser?.uid}');
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'Anda harus login untuk melihat profil.';
        _isLoading = false;
      });
      print('[_loadUserProfile] User is null, setting error.');
      return;
    }

    try {
      print(
        '[_loadUserProfile] Attempting to fetch user document for UID: ${currentUser!.uid}',
      );
      final userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (userDoc.exists) {
        _userData = userDoc.data();
        print('[_loadUserProfile] User data fetched: $_userData');
        _role = _userData?['role'] ?? 'Pengguna Umum';

        _nameController.text = _userData?['name'] as String? ?? '';
        _phoneController.text = _userData?['phone'] as String? ?? '';
        _emailController.text = _userData?['email'] as String? ?? '';
        _dobController.text = _userData?['dob'] as String? ?? '';
        if (_role == 'Petugas') {
          _specializationController.text =
              _userData?['specialization'] as String? ?? '';
          _certificationController.text =
              _userData?['certification'] as String? ?? '';
          _availableHoursController.text =
              (_userData?['availableHours'] as List?)
                  ?.map((e) => e.toString())
                  .join(', ') ??
              '';
        }
        print('[_loadUserProfile] Profile data loaded successfully.');
      } else {
        _errorMessage = 'Data profil tidak ditemukan.';
        print(
          '[_loadUserProfile] Error: Data profil tidak ditemukan for UID: ${currentUser!.uid}',
        );
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat profil: $e';
      print('[_loadUserProfile] Caught error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      print(
        '[_loadUserProfile] Loading finished. _isLoading: $_isLoading, _errorMessage: $_errorMessage',
      );
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (currentUser == null) {
      setState(() {
        _errorMessage = 'Anda harus login untuk memperbarui profil.';
        _isLoading = false;
      });
      return;
    }

    try {
      Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
      };

      if (_role == 'Petugas') {
        updatedData.addAll({
          'specialization': _specializationController.text.trim(),
          'certification': _certificationController.text.trim(),
          'availableHours':
              _availableHoursController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        });
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(updatedData);

      setState(() {
        _isLoading = false;
        _userData = {...?_userData, ...updatedData};
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memperbarui profil: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    String? newPassword;
    String? confirmPassword;

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Ganti Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  obscureText: true,
                  onChanged: (value) => newPassword = value,
                  decoration: const InputDecoration(labelText: 'Password Baru'),
                ),
                TextField(
                  obscureText: true,
                  onChanged: (value) => confirmPassword = value,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newPassword != null &&
                      newPassword == confirmPassword &&
                      newPassword!.length >= 6) {
                    try {
                      await currentUser!.updatePassword(newPassword!);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password berhasil diganti!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Gagal mengganti password: $e\n(Mungkin perlu re-login jika sesi terlalu lama)',
                            ),
                          ),
                        );
                      }
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password tidak cocok atau kurang dari 6 karakter.',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Ganti'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickAndUploadProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image != null) {
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
              ..files.add(
                await http.MultipartFile.fromPath('file', image.path),
              );

        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = json.decode(
            await response.stream.bytesToString(),
          );
          final String downloadUrl = responseData['secure_url'];

          await _firestore.collection('users').doc(currentUser!.uid).update({
            'profileImageUrl': downloadUrl,
          });

          setState(() {
            _userData?['profileImageUrl'] = downloadUrl;
            _isLoading = false;
          });
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
            );
          }
        } else {
          final errorBody = await response.stream.bytesToString();
          throw Exception(
            'Failed to upload image to Cloudinary: ${response.statusCode} - $errorBody',
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Gagal mengupload foto: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      '[ProfilePage.build] Building widget. _isLoading: $_isLoading, _errorMessage: $_errorMessage',
    );
    final bool isPetugas = _role == 'Petugas';

    if (_isLoading) {
      print('[ProfilePage.build] Displaying CircularProgressIndicator.');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFF218BCF),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      print('[ProfilePage.build] Displaying error message: $_errorMessage');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
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

    print('[ProfilePage.build] Displaying profile content.');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        title: const Text('Profile'),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
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
                      '[ProfilePage] Error loading network image for CircleAvatar: $exception',
                    );
                    setState(() {
                      if (_userData != null) {
                        _userData!['profileImageUrl'] = null;
                      }
                    });
                  },
                ),
                Positioned(
                  child: GestureDetector(
                    onTap: _pickAndUploadProfileImage,
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 18, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildEditableField('Nama Lengkap', _nameController),
          _buildEditableField(
            'Telepon',
            _phoneController,
            keyboardType: TextInputType.phone,
          ),
          _buildEditableField('Email', _emailController, readOnly: true),
          _buildEditableField(
            'Tanggal Lahir',
            _dobController,
            hintText: 'DD/MM/YYYY',
          ),
          const SizedBox(height: 16),

          if (isPetugas) ...[
            _buildEditableField('Spesialisasi', _specializationController),
            _buildEditableField('No. Sertifikasi', _certificationController),
            _buildEditableField(
              'Jam Tersedia',
              _availableHoursController,
              hintText: 'Senin 09:00-17:00, Rabu 10:00-16:00',
            ),
            const SizedBox(height: 16),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildField(
                  'Kategori Pengguna',
                  isPetugas ? 'Petugas' : 'Pengguna Umum',
                  showVerifiedIcon:
                      isPetugas && (_userData?['isVerified'] == true),
                ),
              ),
              if (isPetugas)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ElevatedButton(
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
                ),
            ],
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF218BCF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Perbarui Profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Ganti Password',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    String value, {
    bool showVerifiedIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: Text(value)),
              if (showVerifiedIcon)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.verified, color: Colors.blue, size: 18),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFEAF6FD),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// lib/features/auth/view/register_page.dart
import 'package:flutter/material.dart';
import 'package:giziku/features/auth/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class RegisterPage extends StatefulWidget {
  final String role;
  const RegisterPage({super.key, required this.role});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // Tambahan untuk petugas
  final specializationCtrl = TextEditingController();
  final certificationCtrl = TextEditingController();
  final availableHoursCtrl = TextEditingController();

  String? error;
  bool _passwordVisible = false; // Untuk toggle visibilitas password
  final authService = AuthService();

  void _register() async {
    setState(() {
      error = null; // Reset error message
    });

    try {
      final roleToStore =
          widget.role == 'petugas' ? 'Petugas' : 'Pengguna Umum';
      final availableList =
          availableHoursCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      await authService.register(
        name: namaCtrl.text,
        email: emailCtrl.text,
        password: passwordCtrl.text,
        role: roleToStore,
        specialization:
            roleToStore == 'Petugas' ? specializationCtrl.text : null,
        certification: roleToStore == 'Petugas' ? certificationCtrl.text : null,
        availableHours: roleToStore == 'Petugas' ? availableList : null,
        profileImageUrl: '', // Default kosong, bisa diubah di halaman profil
      );

      // Setelah register berhasil, langsung login user dan simpan role ke SharedPreferences
      final data = await authService.login(emailCtrl.text, passwordCtrl.text);
      final userRoleFromFirebase = data['role'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', userRoleFromFirebase);

      if (context.mounted) {
        if (userRoleFromFirebase == 'Pengguna Umum') {
          context.go('/home');
        } else if (userRoleFromFirebase == 'Petugas') {
          context.go('/home-petugas');
        }
      }
    } catch (e) {
      setState(() => error = 'Gagal mendaftar: ${e.toString()}');
      print('Register error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPetugas = widget.role == 'petugas';
    final roleText = isPetugas ? 'Petugas' : 'Pengguna Umum';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Biru
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 40,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF218BCF),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Halo!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Daftar Sebagai $roleText.',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Form Register
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  _buildTextField(namaCtrl, 'Nama Lengkap', Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(emailCtrl, 'Email', Icons.email),
                  const SizedBox(height: 16),
                  _buildPasswordField(passwordCtrl, 'Kata Sandi', Icons.lock),
                  const SizedBox(height: 16),

                  if (isPetugas) ...[
                    _buildTextField(
                      specializationCtrl,
                      'Spesialisasi',
                      Icons.medical_services,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      certificationCtrl,
                      'No. Sertifikasi',
                      Icons.badge,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      availableHoursCtrl,
                      'Jam Tersedia (pisahkan dengan koma)',
                      Icons.schedule,
                      hintText: 'contoh: Senin 09:00-17:00, Rabu 10:00-16:00',
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 24),
                  _buildButton('Daftar', _register),
                  const SizedBox(height: 16),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah Punya Akun?'),
                      TextButton(
                        onPressed: () {
                          context.pushNamed('login', extra: widget.role);
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(color: Color(0xFF218BCF)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    IconData icon, {
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF218BCF)),
        filled: true,
        fillColor: const Color(0xFFEAF6FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String labelText,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFF218BCF)),
        filled: true,
        fillColor: const Color(0xFFEAF6FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF218BCF),
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF218BCF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

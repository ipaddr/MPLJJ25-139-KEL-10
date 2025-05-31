// lib/features/auth/view/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:giziku/features/auth/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final String? role;
  const LoginPage({super.key, this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String? error;
  bool _passwordVisible = false; // Untuk toggle visibilitas password

  final authService = AuthService();

  void _login() async {
    setState(() {
      error = null; // Reset error message
    });
    try {
      final data = await authService.login(emailCtrl.text, passwordCtrl.text);
      final userRoleFromFirebase = data['role'];

      String expectedRole;
      if (widget.role == 'pengguna') {
        expectedRole = 'Pengguna Umum';
      } else if (widget.role == 'petugas') {
        expectedRole = 'Petugas';
      } else {
        setState(() {
          error = 'Email atau password salah. Silakan coba lagi.';
        });
        return;
      }

      if (userRoleFromFirebase == expectedRole) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', userRoleFromFirebase);

        if (userRoleFromFirebase == 'Pengguna Umum') {
          context.go('/home');
        } else if (userRoleFromFirebase == 'Petugas') {
          context.go('/home-petugas');
        } else {
          setState(() {
            error = 'Email atau password salah. Silakan coba lagi.';
          });
        }
      } else {
        setState(() {
          error = 'Email atau password salah. Silakan coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Email atau password salah. Silakan coba lagi.';
      });
      print('Login error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayedRole = '';
    if (widget.role == 'pengguna') {
      displayedRole = 'Pengguna Umum';
    } else if (widget.role == 'petugas') {
      displayedRole = 'Petugas';
    }

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
                    'Masuk Sebagai $displayedRole.',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Form Login
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  _buildTextField(emailCtrl, 'Email', Icons.email),
                  const SizedBox(height: 16),
                  _buildPasswordField(passwordCtrl, 'Kata Sandi', Icons.lock),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Aksi lupa kata sandi
                      },
                      child: const Text(
                        'Lupa Kata Sandi',
                        style: TextStyle(color: Color(0xFF218BCF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildButton('Masuk', () => _login()),
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
                      const Text('Belum Punya Akun?'),
                      TextButton(
                        onPressed: () {
                          context.pushNamed('register', extra: widget.role);
                        },
                        child: const Text(
                          'Daftar',
                          style: TextStyle(color: Color(0xFF218BCF)),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/select-role');
                    },
                    child: const Text(
                      'Pilih role lain',
                      style: TextStyle(color: Colors.grey),
                    ),
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
    IconData icon,
  ) {
    return TextField(
      controller: controller,
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

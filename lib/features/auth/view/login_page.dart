import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Dummy akun
const akunPengguna = {'email': 'pengguna@example.com', 'password': '123456'};

const akunPetugas = {'email': 'petugas@example.com', 'password': '654321'};

class LoginPage extends StatefulWidget {
  final String? role;
  const LoginPage({super.key, this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (widget.role == 'pengguna') {
      if (email == akunPengguna['email'] &&
          password == akunPengguna['password']) {
        context.go('/'); // Halaman home pengguna
      } else {
        setState(() => _error = 'Email atau password salah');
      }
    } else if (widget.role == 'petugas') {
      if (email == akunPetugas['email'] &&
          password == akunPetugas['password']) {
        context.go('/petugas'); // Ganti dengan halaman utama petugas
      } else {
        setState(() => _error = 'Email atau password salah');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masuk'),
        backgroundColor: const Color(0xFF218BCF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'contoh@example.com',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF218BCF),
              ),
              child: const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}

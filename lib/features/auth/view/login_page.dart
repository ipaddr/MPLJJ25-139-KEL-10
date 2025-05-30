import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:giziku/features/auth/services/auth_service.dart';
import 'package:giziku/features/home/view/home_page.dart';
import 'package:giziku/features/home/view/home_petugas_page.dart';

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

  final authService = AuthService();

  void _login() async {
    try {
      final data = await authService.login(emailCtrl.text, passwordCtrl.text);
      final role = data['role'];

      if (role == 'pengguna') {
        context.go('/home');
      } else if (role == 'petugas') {
        context.go('/home-petugas');
      } else {
        setState(() {
          error = 'Role tidak valid';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Email atau password salah';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

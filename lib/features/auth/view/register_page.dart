import 'package:flutter/material.dart';
import 'package:giziku/features/auth/services/auth_service.dart';
import 'package:go_router/go_router.dart';

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
  final authService = AuthService();

  void _register() async {
    try {
      final role = widget.role == 'petugas' ? 'Petugas' : 'Pengguna Umum';
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
        role: role,
        specialization: role == 'Petugas' ? specializationCtrl.text : null,
        certification: role == 'Petugas' ? certificationCtrl.text : null,
        availableHours: role == 'Petugas' ? availableList : null,
      );

      context.go('/login');
    } catch (e) {
      setState(() => error = 'Gagal mendaftar: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPetugas = widget.role == 'petugas';
    final roleText = isPetugas ? 'Petugas' : 'Pengguna Umum';

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Daftar Sebagai $roleText',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Kata Sandi'),
            ),
            const SizedBox(height: 12),

            if (isPetugas) ...[
              TextField(
                controller: specializationCtrl,
                decoration: const InputDecoration(labelText: 'Spesialisasi'),
              ),
              TextField(
                controller: certificationCtrl,
                decoration: const InputDecoration(labelText: 'No. Sertifikasi'),
              ),
              TextField(
                controller: availableHoursCtrl,
                decoration: const InputDecoration(
                  labelText: 'Jam Tersedia (pisahkan dengan koma)',
                  hintText: 'contoh: Senin 09:00-17:00, Rabu 10:00-16:00',
                ),
              ),
            ],

            const SizedBox(height: 16),
            ElevatedButton(onPressed: _register, child: const Text('Daftar')),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}

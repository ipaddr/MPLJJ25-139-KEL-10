// login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:giziku/features/auth/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini

class LoginPage extends StatefulWidget {
  final String? role; // Ini adalah role yang dipilih dari RoleSelectionPage
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
    setState(() {
      error = null; // Reset error message
    });
    try {
      final data = await authService.login(emailCtrl.text, passwordCtrl.text);
      final userRoleFromFirebase = data['role']; // Role dari Firebase
      // Debugging: Cetak role yang dipilih dan role dari Firebase (Anda bisa menghapus baris ini di produksi)
      print('Selected Role: ${widget.role}');
      print('User Role from Firebase: $userRoleFromFirebase');

      // Tentukan role yang diharapkan berdasarkan pilihan di RoleSelectionPage
      String expectedRole;
      if (widget.role == 'pengguna') {
        expectedRole =
            'Pengguna Umum'; // Sesuai dengan yang disimpan di Firebase
      } else if (widget.role == 'petugas') {
        expectedRole = 'Petugas'; // Sesuai dengan yang disimpan di Firebase
      } else {
        // Ini seharusnya tidak terjadi jika alur RoleSelectionPage sudah benar
        setState(() {
          error =
              'Email atau password salah. Silakan coba lagi.'; // Pesan generik
        });
        return;
      }

      // Validasi: Periksa apakah role dari Firebase cocok dengan role yang diharapkan
      if (userRoleFromFirebase == expectedRole) {
        // Simpan role ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', userRoleFromFirebase);

        if (userRoleFromFirebase == 'Pengguna Umum') {
          context.go('/home');
        } else if (userRoleFromFirebase == 'Petugas') {
          context.go('/home-petugas');
        } else {
          // Kasus jika role dari Firebase tidak dikenali (seharusnya tidak terjadi)
          setState(() {
            error =
                'Email atau password salah. Silakan coba lagi.'; // Pesan generik
          });
        }
      } else {
        // Jika role tidak cocok, kirim pesan error yang sama dengan error login umum
        setState(() {
          error =
              'Email atau password salah. Silakan coba lagi.'; // Pesan generik
        });
      }
    } catch (e) {
      // Tangani error autentikasi Firebase (misalnya, email/password salah)
      setState(() {
        error =
            'Email atau password salah. Silakan coba lagi.'; // Pesan generik
      });
      // Anda bisa menambahkan logging error 'e.toString()' untuk debugging lebih lanjut
      print('Login error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Teks peran yang dipilih, untuk ditampilkan di UI
    String displayedRole = '';
    if (widget.role == 'pengguna') {
      displayedRole = 'Pengguna Umum';
    } else if (widget.role == 'petugas') {
      displayedRole = 'Petugas';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (displayedRole
                .isNotEmpty) // Tampilkan teks ini hanya jika role terpilih
              Text(
                'Masuk Sebagai: $displayedRole',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
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
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Kembali ke halaman pemilihan role
                context.go('/select-role');
              },
              child: const Text('Pilih Role Lain'),
            ),
          ],
        ),
      ),
    );
  }
}

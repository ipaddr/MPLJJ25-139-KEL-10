import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  final String? role;
  const RegisterPage({super.key, this.role});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isPengguna = widget.role == 'pengguna';
    final roleText = isPengguna ? 'Pengguna' : 'Petugas';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Halo!'),
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daftar sebagai $roleText.',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
              const SizedBox(height: 20),
              _buildField('Nama Lengkap', _nameController, hint: 'nama anda'),
              const SizedBox(height: 12),
              _buildField(
                'Email',
                _emailController,
                hint: 'example@example.com',
              ),
              const SizedBox(height: 12),
              _buildField('Telepon', _phoneController, hint: '08xxxxxxxxxx'),
              const SizedBox(height: 12),
              _buildField('Kata Sandi', _passwordController, obscureText: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF218BCF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Tambahkan validasi & simpan ke database kalau pakai backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pendaftaran berhasil!')),
                    );
                    context.go('/select-role');
                  },
                  child: const Text('Daftar'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    context.go('/login', extra: widget.role);
                  },
                  child: const Text(
                    'Belum Punya Akun? Daftar',
                    style: TextStyle(
                      color: Color(0xFF218BCF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFEAF6FD),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

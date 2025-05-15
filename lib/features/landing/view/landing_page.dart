import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF218BCF), // Warna biru khas GiziKu
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Logo dan teks
            Column(
              children: [
                Image.asset(
                  'assets/images/logo_giziku.png', // Pastikan file ini ada di pubspec.yaml
                  width: 160,
                  height: 160,
                ),
                const SizedBox(height: 20),
                const Text(
                  'GiziKu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Spacer(flex: 3),

            // Tombol Mulai
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Gunakan GoRouter untuk navigasi
                    context.go('/select-role');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7AC6F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Mulai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

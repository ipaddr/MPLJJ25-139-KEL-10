// import 'package:flutter/material.dart';

// class RoleSelectionPage extends StatefulWidget {
//   const RoleSelectionPage({super.key});

//   @override
//   State<RoleSelectionPage> createState() => _RoleSelectionPageState();
// }

// class _RoleSelectionPageState extends State<RoleSelectionPage> {
//   String _selectedRole = 'pengguna';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               // Logo
//               Image.asset('assets/images/logo_giziku_blue.png', width: 140),
//               const SizedBox(height: 12),
//               const Text(
//                 'GiziKu',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF218BCF),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Divider(),
//               const SizedBox(height: 16),

//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Masuk Sebagai:',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               _buildRoleOption('pengguna', 'Pengguna'),
//               const SizedBox(height: 10),
//               _buildRoleOption('petugas', 'Petugas'),

//               const SizedBox(height: 32),
//               const Text(
//                 'Aplikasi mobile untuk mendukung program makan siang dan susu gratis di sekolah dan pesantren serta bantuan gizi untuk balita dan ibu hamil.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 12),
//               ),

//               const SizedBox(height: 40),
//               _buildButton('Masuk', const Color(0xFF218BCF), () {
//                 Navigator.pushNamed(
//                   context,
//                   '/login',
//                   arguments: _selectedRole,
//                 );
//               }),
//               const SizedBox(height: 12),
//               _buildButton('Daftar', const Color(0xFFB3DAF4), () {
//                 Navigator.pushNamed(
//                   context,
//                   '/register',
//                   arguments: _selectedRole,
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRoleOption(String value, String label) {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedRole = value;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF6F6F6),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color:
//                 _selectedRole == value
//                     ? const Color(0xFF218BCF)
//                     : Colors.grey.shade300,
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.account_circle_outlined, size: 28),
//             const SizedBox(width: 12),
//             Text(label, style: const TextStyle(fontSize: 16)),
//             const Spacer(),
//             Radio<String>(
//               value: value,
//               groupValue: _selectedRole,
//               onChanged: (val) {
//                 setState(() {
//                   _selectedRole = val!;
//                 });
//               },
//               activeColor: const Color(0xFF218BCF),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(String label, Color color, VoidCallback onPressed) {
//     return SizedBox(
//       width: double.infinity,
//       height: 48,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Text(
//           label,
//           style: const TextStyle(color: Colors.white, fontSize: 16),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String _selectedRole = 'pengguna';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/logo_giziku_blue.png', width: 140),
              const SizedBox(height: 12),
              const Text(
                'GiziKu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF218BCF),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Masuk Sebagai:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              _buildRoleOption('pengguna', 'Pengguna'),
              const SizedBox(height: 10),
              _buildRoleOption('petugas', 'Petugas'),

              const SizedBox(height: 32),
              const Text(
                'Aplikasi mobile untuk mendukung program makan siang dan susu gratis di sekolah dan pesantren serta bantuan gizi untuk balita dan ibu hamil.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 40),
              _buildButton('Masuk', const Color(0xFF218BCF), () {
                context.pushNamed('login', extra: _selectedRole);
              }),
              const SizedBox(height: 12),
              _buildButton('Daftar', const Color(0xFFB3DAF4), () {
                context.pushNamed('register', extra: _selectedRole);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String value, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _selectedRole == value
                    ? const Color(0xFF218BCF)
                    : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_circle_outlined, size: 28),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Radio<String>(
              value: value,
              groupValue: _selectedRole,
              onChanged: (val) {
                setState(() {
                  _selectedRole = val!;
                });
              },
              activeColor: const Color(0xFF218BCF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

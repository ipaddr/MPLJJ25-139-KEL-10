import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import halaman
import '../../features/landing/view/landing_page.dart';
import '../../features/auth/view/role_selection_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
// import '../../features/jadwal_distribusi/view/jadwal_page.dart';
import '../../features/konsultasi/view/konsultasi_page.dart';
// import '../../features/konsultasi/view/chat_page.dart';
import '../../features/komunitas/view/komunitas_page.dart';
import '../../features/riwayat/view/riwayat_page.dart';
// import '../../features/chatbot/view/chatbot_page.dart';
// import '../../features/home/view/home_petugas_page.dart';
// import '../../features/komunitas/view/komunitas_petugas_page.dart';
// import '../../features/komunitas/view/postingan_form_page.dart';
// import '../../features/komunitas/view/postingan_detail_page.dart';
// import '../../features/konsultasi/view/konsultasi_petugas_page.dart';
// import '../../features/profile/view/profile_petugas_page.dart';
// import '../../features/profile/view/verifikasi_petugas_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/landing',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/select-role',
        name: 'select-role',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      // GoRoute(
      //   path: '/jadwal',
      //   name: 'jadwal',
      //   builder: (context, state) => const JadwalPage(),
      // ),
      GoRoute(
        path: '/konsultasi',
        name: 'konsultasi',
        builder: (context, state) => const KonsultasiPage(),
      ),
      // GoRoute(
      //   path: '/chat/:id',
      //   name: 'chat',
      //   builder: (context, state) {
      //     final id = state.params['id']!;
      //     return ChatPage(chatId: id);
      //   },
      // ),
      GoRoute(
        path: '/komunitas',
        name: 'komunitas',
        builder: (context, state) => const KomunitasPage(),
      ),
      GoRoute(
        path: '/riwayat',
        name: 'riwayat',
        builder: (context, state) => const RiwayatPage(),
      ),
      // GoRoute(
      //   path: '/chatbot',
      //   name: 'chatbot',
      //   builder: (context, state) => const ChatbotPage(),
      // ),
      //  GoRoute(
      //     path: '/home-petugas',
      //     name: 'home-petugas',
      //     builder: (context, state) => const HomePetugasPage(),
      //   ),
      //   GoRoute(
      //     path: '/komunitas-petugas',
      //     name: 'komunitas-petugas',
      //     builder: (context, state) => const KomunitasPetugasPage(),
      //   ),
      //   GoRoute(
      //     path: '/buat-postingan',
      //     name: 'buat-postingan',
      //     builder: (context, state) => const PostinganFormPage(),
      //   ),
      //   GoRoute(
      //     path: '/detail-postingan',
      //     name: 'detail-postingan',
      //     builder: (context, state) => const PostinganDetailPage(),
      //   ),
      //   GoRoute(
      //     path: '/konsultasi-petugas',
      //     name: 'konsultasi-petugas',
      //     builder: (context, state) => const KonsultasiPetugasPage(),
      //   ),
      //   GoRoute(
      //     path: '/profile-petugas',
      //     name: 'profile-petugas',
      //     builder: (context, state) => const ProfilePetugasPage(),
      //   ),
      //   GoRoute(
      //     path: '/verifikasi-petugas',
      //     name: 'verifikasi-petugas',
      //     builder: (context, state) => const VerifikasiPetugasPage(),
      //   ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
        ),
  );
});

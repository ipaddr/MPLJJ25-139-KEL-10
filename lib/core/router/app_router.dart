import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import halaman
import '../../features/landing/view/landing_page.dart';
import '../../features/auth/view/role_selection_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/home/view/home_petugas_page.dart';
import '../../features/jadwal_distribusi/view/jadwal_page.dart';
import '../../features/konsultasi/view/konsultasi_page.dart';
// import '../../features/konsultasi/view/chat_page.dart';
import '../../features/komunitas/view/komunitas_page.dart';
import '../../features/riwayat/view/riwayat_page.dart';
// import '../../features/chatbot/view/chatbot_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/landing',
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
        builder: (context, state) {
          final role = state.extra as String?;
          return LoginPage(role: role);
        },
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/petugas',
        name: 'petugas-home',
        builder:
            (context, state) => const HomeAdminPage(), // Buat halaman ini nanti
      ),
      GoRoute(
        path: '/jadwal',
        name: 'jadwal',
        builder: (context, state) => const JadwalPage(),
      ),
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
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
        ),
  );
});

// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giziku/models/postingan.dart';
import 'package:go_router/go_router.dart';
import 'initial_route_provider.dart';

// Import halaman
import '../../features/landing/view/landing_page.dart';
import '../../features/auth/view/role_selection_page.dart';
import '../../features/auth/view/register_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/jadwal_distribusi/view/jadwal_page.dart';
import '../../features/konsultasi/view/konsultasi_page.dart';
import '../../features/konsultasi/view/chat_page.dart';
import '../../features/komunitas/view/komunitas_page.dart';
import '../../features/riwayat/view/riwayat_page.dart';
import '../../features/chatbot/view/chatbot_page.dart';
import '../../features/home/view/home_petugas_page.dart';
import '../../features/konsultasi/view/konsultasi_petugas_page.dart';
import '../../features/profile/view/profile_page.dart';
import '../../features/profile/view/verifikasi_petugas_page.dart';
import '../../features/komunitas/view/postingan_form_page.dart';
import '../../features/komunitas/view/postingan_detail_page.dart';
import '../../features/jadwal_distribusi/view/jadwal_form_petugas_page.dart'; // ✅ Import halaman baru
import '../../features/jadwal_distribusi/view/jadwal_list_petugas_page.dart'; // ✅ Import halaman baru
import 'package:giziku/models/chat_user.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final initial = ref.watch(initialRouteProvider);
  return GoRouter(
    initialLocation: initial,
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
        path: '/register',
        name: 'register',
        builder: (context, state) {
          final roleKey = state.extra as String? ?? 'pengguna';
          return RegisterPage(role: roleKey);
        },
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
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
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
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) {
          final recipientUser = state.extra as ChatUser;
          return ChatPage(recipientUser: recipientUser);
        },
      ),
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
      GoRoute(
        path: '/chatbot',
        name: 'chatbot',
        builder: (context, state) => const ChatbotPage(),
      ),
      GoRoute(
        path: '/home-petugas',
        name: 'home-petugas',
        builder: (context, state) => const HomePetugasPage(),
      ),
      GoRoute(
        path: '/tambah-jadwal-bantuan', // ✅ Rute baru untuk form jadwal petugas
        name: 'tambah-jadwal-bantuan',
        builder: (context, state) => const JadwalFormPetugasPage(),
      ),
      GoRoute(
        path:
            '/daftar-jadwal-bantuan', // ✅ Rute baru untuk daftar jadwal petugas
        name: 'daftar-jadwal-bantuan',
        builder: (context, state) => const JadwalListPetugasPage(),
      ),
      GoRoute(
        path: '/buat-postingan',
        name: 'buat-postingan',
        builder: (context, state) => const PostinganFormPage(),
      ),
      GoRoute(
        path: '/detail-postingan',
        name: 'detail-postingan',
        builder: (context, state) {
          final postingan = state.extra as Postingan;
          return PostinganDetailPage(postingan: postingan);
        },
      ),
      GoRoute(
        path: '/konsultasi-petugas',
        name: 'konsultasi-petugas',
        builder: (context, state) => const KonsultasiPetugasPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/verifikasi-petugas',
        name: 'verifikasi-petugas',
        builder: (context, state) => VerifikasiPetugasPage(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
        ),
  );
});

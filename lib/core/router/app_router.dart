// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/view/home_page.dart'; // ganti dengan halaman awalmu

// final routerProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: '/',
//     routes: [
//       GoRoute(path: '/', builder: (context, state) => const HomePage()),
//       // Tambahkan route lain di sini
//     ],
//   );
// });
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (context, state) => const HomePage())],
  );
});

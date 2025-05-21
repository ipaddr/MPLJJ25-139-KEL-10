// import 'core/themes/app_theme.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const ProviderScope(child: GiziKuApp()));
// }

// class GiziKuApp extends ConsumerWidget {
//   const GiziKuApp({super.key});

// @override
// Widget build(BuildContext context, WidgetRef ref) {
//   final router = ref.watch(routerProvider);
//   return MaterialApp.router(
//     title: 'GiziKu',
//     theme: AppTheme.lightTheme,
//     routerConfig: router,

//       // @override
//       // Widget build(BuildContext context) {
//       //   return MaterialApp.router(
//       //     debugShowCheckedModeBanner: false,
//       //     title: 'GiziKu',
//       //     theme: AppTheme.lightTheme,
//       //     routerConfig: appRouter,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'core/router/initial_route_provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final prefs = await SharedPreferences.getInstance();
//   final role = prefs.getString('user_role');

//   // Tentukan initial location sesuai role
//   final initialRoute =
//       role == 'pengguna'
//           ? '/'
//           : role == 'petugas'
//           ? '/petugas'
//           : '/landing';

//   runApp(ProviderScope(child: GiziKuApp(initialRoute: initialRoute)));
// }

// class GiziKuApp extends StatelessWidget {
//   final String initialRoute;
//   const GiziKuApp({super.key, required this.initialRoute});

//   // @override
//   // Widget build(BuildContext context, WidgetRef ref) {
//   //   final router = ref.watch(routerProvider);
//   //   return MaterialApp.router(
//   //     title: 'GiziKu',
//   //     theme: AppTheme.lightTheme,
//   //     routerConfig: router,

//   @override
//   Widget build(BuildContext context) {
//     final router = GoRouter(
//       initialLocation: initialRoute,
//       routes: appRoutes, // routes didefinisikan di app_router.dart
//       errorBuilder:
//           (context, state) => const Scaffold(
//             body: Center(child: Text('Halaman tidak ditemukan')),
//           ),
//     );

//     return MaterialApp.router(
//       routerConfig: router,
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('user_role');

  final initialRoute =
      role == 'pengguna'
          ? '/home'
          : role == 'petugas'
          ? '/petugas'
          : '/landing';

  runApp(
    ProviderScope(
      overrides: [initialRouteProvider.overrideWithValue(initialRoute)],
      child: const GiziKuApp(),
    ),
  );
}

class GiziKuApp extends ConsumerWidget {
  const GiziKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

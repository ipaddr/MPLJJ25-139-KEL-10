import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giziku/core/router/app_router.dart';
import 'package:giziku/core/router/initial_route_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ambil sesi role
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('user_role');

  // Tentukan initial route berdasarkan role
  final initialRoute = switch (role) {
    'pengguna' => '/home',
    'Petugas' => '/home-petugas',
    _ => '/landing',
  };

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
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

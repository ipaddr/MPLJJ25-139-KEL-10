import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/themes/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: GiziKuApp()));
}

class GiziKuApp extends ConsumerWidget {
  const GiziKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'GiziKu',
      theme: AppTheme.lightTheme,
      routerConfig: router,

      // @override
      // Widget build(BuildContext context) {
      //   return MaterialApp.router(
      //     debugShowCheckedModeBanner: false,
      //     title: 'GiziKu',
      //     theme: AppTheme.lightTheme,
      //     routerConfig: appRouter,
    );
  }
}

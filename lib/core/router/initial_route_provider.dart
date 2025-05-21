import 'package:flutter_riverpod/flutter_riverpod.dart';

final initialRouteProvider = Provider<String>((ref) {
  // Default jika belum login
  return '/landing';
});

// lib/features/auth/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) throw Exception('User not found in Firestore');

      final data = doc.data()!;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? specialization,
    String? certification,
    List<String>? availableHours,
    String? profileImageUrl, // Tambahkan ini
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;
    final now = DateTime.now().toUtc().toIso8601String();

    final Map<String, dynamic> data = {
      'email': email,
      'name': name,
      'role': role,
      'registrationDate': now,
      'profileImageUrl':
          profileImageUrl ??
          '', // Simpan URL gambar profil, default string kosong
      'isVerified': false, // Default false saat register petugas
    };

    if (role == 'Petugas') {
      data.addAll({
        'specialization': specialization ?? '',
        'certification': certification ?? '',
        'availableHours': availableHours ?? [],
        'strUrl': null, // URL dokumen STR
        'sipUrl': null, // URL dokumen SIP
        'otherDocUrl': null, // URL dokumen lainnya
      });
    }

    await _firestore.collection('users').doc(uid).set(data);
  }
}

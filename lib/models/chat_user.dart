// lib/models/chat_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String uid; // User ID dari Firebase Auth
  final String name;
  final String email;
  final String role; // 'Pengguna Umum' atau 'Petugas'
  final String? specialization; // Hanya untuk Petugas
  final String? certification; // Hanya untuk Petugas
  final List<String>? availableHours; // Hanya untuk Petugas
  final String profileImageUrl; // URL gambar profil

  ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.specialization,
    this.certification,
    this.availableHours,
    this.profileImageUrl =
        'assets/images/default_profile.png', // Default placeholder
  });

  // Factory constructor untuk membuat ChatUser dari DocumentSnapshot Firestore
  factory ChatUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatUser(
      uid: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
      specialization: data['specialization'] as String?,
      certification: data['certification'] as String?,
      availableHours:
          (data['availableHours'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      profileImageUrl:
          data['profileImageUrl'] as String? ??
          'assets/images/default_profile.png', // Ambil dari Firestore atau default
    );
  }

  // Method untuk mengubah ChatUser menjadi Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'specialization': specialization,
      'certification': certification,
      'availableHours': availableHours,
      'profileImageUrl': profileImageUrl,
    };
  }
}

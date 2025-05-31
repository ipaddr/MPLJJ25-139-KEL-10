// lib/models/postingan.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Postingan {
  final String id;
  final String userId; // ID pengguna yang membuat postingan
  final String userName; // Nama pengguna yang membuat postingan
  final String
  userRole; // Role pengguna yang membuat postingan (Pengguna Umum / Petugas)
  final String subject; // Subjek/Judul postingan
  final String content; // Isi lengkap postingan
  final DateTime createdAt; // Waktu pembuatan postingan
  final bool
  isVerified; // Menandakan apakah postingan terverifikasi (dari Petugas)

  Postingan({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.subject,
    required this.content,
    required this.createdAt,
    this.isVerified = false,
  });

  factory Postingan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Postingan(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      userRole: data['userRole'] as String,
      subject: data['subject'] as String,
      content: data['content'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isVerified: data['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'subject': subject,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
    };
  }
}

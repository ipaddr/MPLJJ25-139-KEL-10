// lib/models/jadwal_detail_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JadwalDetailItem {
  final String id;
  final DateTime tanggal;
  final String lokasi;
  final String
  jenisBantuan; // Ini akan menjadi "Subject Bantuan" (misal: Karbohidrat)
  final String
  deskripsiBantuan; // Ini akan menjadi "Deskripsi Bantuan" (misal: Beras, susu)
  final String status; // Misal: "Dijadwalkan", "Disalurkan"
  final List<String> recipientUserIds; // List UID pengguna yang akan menerima
  final String? addedByUserId; // UID petugas yang menambahkan jadwal
  final String?
  addedByUserName; // ✅ Tambahkan ini: Nama petugas yang menambahkan jadwal
  final DateTime createdAt;

  JadwalDetailItem({
    required this.id,
    required this.tanggal,
    required this.lokasi,
    required this.jenisBantuan,
    required this.deskripsiBantuan,
    this.status = 'Dijadwalkan', // Default status saat pembuatan
    this.recipientUserIds = const [],
    this.addedByUserId,
    this.addedByUserName, // ✅ Tambahkan ini
    required this.createdAt,
  });

  factory JadwalDetailItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JadwalDetailItem(
      id: doc.id,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      lokasi: data['lokasi'] as String? ?? 'Tidak Diketahui',
      jenisBantuan: data['jenisBantuan'] as String? ?? 'Tidak Diketahui',
      deskripsiBantuan:
          data['deskripsiBantuan'] as String? ?? '', // Baca field baru
      status: data['status'] as String? ?? 'Dijadwalkan', // Baca status
      recipientUserIds: List<String>.from(data['recipientUserIds'] ?? []),
      addedByUserId: data['addedByUserId'] as String?,
      addedByUserName: data['addedByUserName'] as String?, // ✅ Baca field baru
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tanggal': Timestamp.fromDate(tanggal),
      'lokasi': lokasi,
      'jenisBantuan': jenisBantuan,
      'deskripsiBantuan': deskripsiBantuan, // Simpan field baru
      'status': status,
      'recipientUserIds': recipientUserIds,
      'addedByUserId': addedByUserId,
      'addedByUserName': addedByUserName, // ✅ Simpan field baru
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

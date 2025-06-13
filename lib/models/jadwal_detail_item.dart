// lib/models/jadwal_detail_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JadwalDetailItem {
  final String id;
  final DateTime tanggal;
  final String lokasi;
  final String jenisBantuan; // Misal: "Makanan Pokok", "Susu Balita"
  final String status; // Misal: "Dijadwalkan", "Disalurkan"
  final List<String> recipientUserIds; // List UID pengguna yang akan menerima
  final String? addedByUserId; // UID petugas yang menambahkan jadwal
  final DateTime createdAt;

  JadwalDetailItem({
    required this.id,
    required this.tanggal,
    required this.lokasi,
    required this.jenisBantuan,
    this.status = 'Dijadwalkan',
    this.recipientUserIds = const [],
    this.addedByUserId,
    required this.createdAt,
  });

  factory JadwalDetailItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JadwalDetailItem(
      id: doc.id,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      lokasi: data['lokasi'] as String? ?? 'Tidak Diketahui',
      jenisBantuan: data['jenisBantuan'] as String? ?? 'Tidak Diketahui',
      status: data['status'] as String? ?? 'Dijadwalkan',
      recipientUserIds: List<String>.from(data['recipientUserIds'] ?? []),
      addedByUserId: data['addedByUserId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tanggal': Timestamp.fromDate(tanggal),
      'lokasi': lokasi,
      'jenisBantuan': jenisBantuan,
      'status': status,
      'recipientUserIds': recipientUserIds,
      'addedByUserId': addedByUserId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

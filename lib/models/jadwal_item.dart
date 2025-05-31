// lib/models/jadwal_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JadwalItem {
  final String id;
  final DateTime tanggal;
  final String lokasi;
  final String jenisBantuan;

  JadwalItem({
    required this.id,
    required this.tanggal,
    required this.lokasi,
    required this.jenisBantuan,
  });

  factory JadwalItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JadwalItem(
      id: doc.id,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      lokasi: data['lokasi'] as String? ?? 'Tidak Diketahui',
      jenisBantuan: data['jenisBantuan'] as String? ?? 'Tidak Diketahui',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tanggal': Timestamp.fromDate(tanggal),
      'lokasi': lokasi,
      'jenisBantuan': jenisBantuan,
    };
  }
}

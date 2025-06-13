// lib/models/riwayat_detail_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RiwayatDetailItem {
  final String id;
  final String userId; // UID pengguna yang menerima bantuan
  final String userName; // Nama pengguna yang menerima bantuan (untuk display)
  final String jenisBantuan; // Misal: "Makanan Pokok", "Susu Balita"
  final String deskripsi; // Detail jenis bantuan: "Beras, roti, jagung, dll."
  final DateTime tanggalDisalurkan; // Tanggal bantuan disalurkan
  final String lokasiDisalurkan; // Lokasi penyaluran
  final String disalurkanOlehUserId; // UID petugas yang menyalurkan
  final String disalurkanOlehUserName; // Nama petugas yang menyalurkan
  final DateTime createdAt;

  RiwayatDetailItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.jenisBantuan,
    required this.deskripsi,
    required this.tanggalDisalurkan,
    required this.lokasiDisalurkan,
    required this.disalurkanOlehUserId,
    required this.disalurkanOlehUserName,
    required this.createdAt,
  });

  factory RiwayatDetailItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RiwayatDetailItem(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String? ?? 'Pengguna',
      jenisBantuan: data['jenisBantuan'] as String? ?? 'Tidak Diketahui',
      deskripsi: data['deskripsi'] as String? ?? '',
      tanggalDisalurkan: (data['tanggalDisalurkan'] as Timestamp).toDate(),
      lokasiDisalurkan:
          data['lokasiDisalurkan'] as String? ?? 'Tidak Diketahui',
      disalurkanOlehUserId: data['disalurkanOlehUserId'] as String,
      disalurkanOlehUserName:
          data['disalurkanOlehUserName'] as String? ?? 'Petugas',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'jenisBantuan': jenisBantuan,
      'deskripsi': deskripsi,
      'tanggalDisalurkan': Timestamp.fromDate(tanggalDisalurkan),
      'lokasiDisalurkan': lokasiDisalurkan,
      'disalurkanOlehUserId': disalurkanOlehUserId,
      'disalurkanOlehUserName': disalurkanOlehUserName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

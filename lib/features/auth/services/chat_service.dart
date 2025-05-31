// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giziku/models/message.dart'; // Import model Message

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Fungsi untuk mendapatkan ID chat antara dua pengguna
  // ID chat akan selalu sama tidak peduli siapa yang memulai chat
  String getChatRoomId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id];
    ids.sort(); // Urutkan ID untuk memastikan ID chat unik dan konsisten
    return ids.join('_');
  }

  // Mengirim pesan
  Future<void> sendMessage(String receiverId, String messageContent) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in.");
    }

    final String currentUserId = currentUser.uid;
    final String chatRoomId = getChatRoomId(currentUserId, receiverId);

    // Buat dokumen chat room jika belum ada
    await _firestore.collection('chats').doc(chatRoomId).set(
      {
        'participants': [currentUserId, receiverId],
        'lastMessage': messageContent,
        'lastMessageTimestamp': Timestamp.now(),
        'createdAt': FieldValue.arrayUnion([
          Timestamp.now(),
        ]), // Hanya tambahkan jika belum ada
      },
      SetOptions(merge: true),
    ); // Gunakan merge untuk tidak menimpa jika sudah ada

    // Tambahkan pesan ke sub-koleksi messages
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(
          Message(
            senderId: currentUserId,
            content: messageContent,
            timestamp: DateTime.now(),
          ).toFirestore(),
        );
  }

  // Mendapatkan stream pesan untuk chat room tertentu
  Stream<List<Message>> getMessages(String user1Id, String user2Id) {
    final chatRoomId = getChatRoomId(user1Id, user2Id);
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: true,
        ) // Urutkan dari terbaru ke terlama
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromFirestore(doc))
              .toList();
        });
  }
}

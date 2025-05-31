// lib/models/message.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor untuk membuat Message dari DocumentSnapshot Firestore
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Method untuk mengubah Message menjadi Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

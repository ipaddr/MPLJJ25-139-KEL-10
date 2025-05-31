// lib/models/chatbot_message.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotMessage {
  final String sender; // 'user' or 'bot'
  final String text;
  final DateTime timestamp;

  ChatbotMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  factory ChatbotMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatbotMessage(
      sender: data['sender'] as String,
      text: data['text'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

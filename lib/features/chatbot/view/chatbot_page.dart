// lib/features/chatbot/view/chatbot_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giziku/models/chatbot_message.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // ✅ Hapus import ini jika tidak ada SVG lain yang digunakan

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  // GANTI DENGAN API KEY GOOGLE GEMINI ANDA
  final String _geminiApiKey =
      'AIzaSyANq7R-ePC643RHC5LpkFh31_svdcoAVZo'; // Pastikan API key Anda yang benar

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login untuk menggunakan chatbot.'),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUser == null) return;

    final userMessage = ChatbotMessage(
      sender: 'user',
      text: text,
      timestamp: DateTime.now(),
    );
    await _firestore
        .collection('chatbot_history')
        .doc(_currentUser!.uid)
        .collection('messages')
        .add(userMessage.toFirestore());

    _messageController.clear();
    _scrollToBottom();

    try {
      final botResponseText = await _getGeminiResponse(text);

      final botMessage = ChatbotMessage(
        sender: 'bot',
        text: botResponseText,
        timestamp: DateTime.now(),
      );
      await _firestore
          .collection('chatbot_history')
          .doc(_currentUser!.uid)
          .collection('messages')
          .add(botMessage.toFirestore());

      _scrollToBottom();
    } catch (e) {
      final errorMessage = ChatbotMessage(
        sender: 'bot',
        text: 'Error: Gagal mendapatkan respons dari chatbot. ${e.toString()}',
        timestamp: DateTime.now(),
      );
      await _firestore
          .collection('chatbot_history')
          .doc(_currentUser!.uid)
          .collection('messages')
          .add(errorMessage.toFirestore());
      _scrollToBottom();
    }
  }

  Future<String> _getGeminiResponse(String prompt) async {
    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_geminiApiKey';
    // 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiApiKey';
    // 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_geminiApiKey';

    final chatHistorySnapshot =
        await _firestore
            .collection('chatbot_history')
            .doc(_currentUser!.uid)
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .limitToLast(10)
            .get();

    // Tipe eksplisit: List<Map<String, Object>>
    List<Map<String, Object>> contextMessages =
        chatHistorySnapshot.docs.map((doc) {
          final data = doc.data();
          final String senderRole = data['sender'] == 'user' ? "user" : "model";
          final String messageText = data['text'] as String;

          return {
            "role": senderRole,
            "parts": <Map<String, String>>[
              {"text": messageText},
            ],
          };
        }).toList();

    // Tambahkan prompt terakhir
    contextMessages.add({
      "role": "user",
      "parts": <Map<String, String>>[
        {"text": prompt},
      ],
    });

    // Payload dengan tipe benar
    final Map<String, Object> payload = {"contents": contextMessages};

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          json.decode(response.body) as Map<String, dynamic>;

      if (jsonResponse.containsKey('candidates') &&
          jsonResponse['candidates'] is List &&
          jsonResponse['candidates'].isNotEmpty) {
        final candidates = jsonResponse['candidates'] as List<dynamic>;
        final firstCandidate = candidates.first as Map<String, dynamic>;
        final content = firstCandidate['content'];
        if (content != null &&
            content['parts'] is List &&
            content['parts'].isNotEmpty &&
            content['parts'][0]['text'] != null) {
          return content['parts'][0]['text'];
        }
      }
      return 'Maaf, saya tidak bisa memahami pertanyaan Anda.';
    } else {
      throw Exception(
        'Gagal memuat respon dari Gemini: ${response.statusCode} - ${response.body}',
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('GiziSmart'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Anda harus login untuk menggunakan chatbot.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
        // ✅ Hapus Row yang menampilkan ikon chatbot di AppBar
        title: const Text('GiziSmart'), // Cukup tampilkan teks judul
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('chatbot_history')
                      .doc(_currentUser!.uid)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error memuat pesan: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Mulai percakapan dengan GiziSmart!'),
                  );
                }

                final messages =
                    snapshot.data!.docs
                        .map((doc) {
                          return ChatbotMessage.fromFirestore(doc);
                        })
                        .toList()
                        .reversed
                        .toList();

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message.sender == 'user';
                    return ChatMessageBubble(
                      text: message.text,
                      time: DateFormat('HH:mm').format(message.timestamp),
                      isUser: isUser,
                      showBotIcon:
                          false, // ✅ Selalu false agar ikon bot tidak tampil
                    );
                  },
                );
              },
            ),
          ),
          _ChatInputBar(
            messageController: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan bubble pesan chat
class ChatMessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isUser;
  final bool showBotIcon;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isUser,
    this.showBotIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser ? const Color(0xFFDDF2FF) : Colors.white;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
      bottomRight:
          isUser ? const Radius.circular(0) : const Radius.circular(16),
    );

    return Align(
      alignment: alignment,
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Hapus bagian ini yang menampilkan ikon bot
          // if (showBotIcon)
          //   Padding(
          //     padding: const EdgeInsets.only(right: 8.0, top: 4.0),
          //     child: Image.asset(
          //       'assets/images/bot_icon.png',
          //       height: 24,
          //       width: 24,
          //     ),
          //   ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius,
                border:
                    isUser ? Border.all(color: const Color(0xFF218BCF)) : null,
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk input bar chat
class _ChatInputBar extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSend;

  const _ChatInputBar({required this.messageController, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
        color: const Color(0xFF218BCF),
        child: Row(
          children: [
            const Icon(Icons.photo, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Tulis pesan...",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.mic, color: Colors.white),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}

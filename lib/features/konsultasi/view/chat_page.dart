// lib/features/konsultasi/view/chat_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giziku/models/chat_user.dart';
import 'package:giziku/models/message.dart';
import 'package:giziku/features/auth/services/chat_service.dart'; // Import ChatService
import 'package:intl/intl.dart'; // Untuk format waktu

class ChatPage extends StatefulWidget {
  final ChatUser recipientUser;

  const ChatPage({super.key, required this.recipientUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  User? _currentUser; // Untuk menyimpan data pengguna yang sedang login

  @override
  void initState() {
    super.initState();
    _currentUser = _chatService.getCurrentUser();
    // Scroll ke bawah saat keyboard muncul atau pesan baru datang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.recipientUser.uid,
        _messageController.text,
      );
      _messageController.clear();
      _scrollToBottom(); // Scroll ke pesan terbaru setelah mengirim
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Anda harus login untuk mengakses chat.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientUser.name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.call),
          SizedBox(width: 12),
          Icon(Icons.video_call),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(
                _currentUser!.uid,
                widget.recipientUser.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Mulai percakapan baru.'));
                }

                final messages =
                    snapshot.data!.reversed
                        .toList(); // Tampilkan pesan dari bawah ke atas

                // Scroll ke bawah setelah pesan baru diterima
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUser!.uid;
                    return ChatBubble(
                      text: message.content,
                      time: DateFormat('HH:mm').format(message.timestamp),
                      isMe: isMe,
                      // showBorder: isMe, // Anda bisa aktifkan ini jika ingin border hanya untuk pesan Anda
                    );
                  },
                );
              },
            ),
          ),
          // TypingIndicator (opsional, bisa diimplementasikan nanti dengan Firestore)
          // const TypingIndicator(),
          ChatInputBar(
            messageController: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool
  showBorder; // Properti ini tidak digunakan di sini, tapi bisa dipertahankan

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    this.isMe = false,
    this.showBorder = false, // Properti ini tidak digunakan di sini
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isMe ? const Color(0xFFDDF2FF) : Colors.white; // Warna bubble
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ), // Batasi lebar bubble
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border:
              isMe
                  ? Border.all(color: const Color(0xFF218BCF))
                  : null, // Border untuk pesan saya
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
    );
  }
}

// VoiceMessageBubble dan TypingIndicator tetap seperti sebelumnya atau bisa dihilangkan jika tidak digunakan
class VoiceMessageBubble extends StatelessWidget {
  final String time;

  const VoiceMessageBubble({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/dr_annisa.png'),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.play_arrow),
            Expanded(
              child: LinearProgressIndicator(
                value: 0.3,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            const Text("02:50", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Dr. Annisa mengetik...",
          style: TextStyle(fontSize: 12, color: Colors.blue),
        ),
      ),
    );
  }
}

class ChatInputBar extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.messageController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
        color: const Color(0xFF218BCF), // Warna latar belakang input bar
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
                onSubmitted: (_) => onSend(), // Kirim pesan saat Enter ditekan
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.mic, color: Colors.white),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: onSend, // Kirim pesan saat tombol send ditekan
            ),
          ],
        ),
      ),
    );
  }
}

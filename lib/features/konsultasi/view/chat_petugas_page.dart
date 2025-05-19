import 'package:flutter/material.dart';

class ChatAdminPage extends StatelessWidget {
  final String userName;

  const ChatAdminPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF218BCF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.call, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.videocam, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _chatBubble(
                  text:
                      'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  isSender: false,
                  time: '09:00',
                ),
                _chatBubble(
                  text:
                      'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  isSender: true,
                  time: '09:30',
                ),
                _chatBubble(
                  text:
                      'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  isSender: false,
                  time: '09:43',
                ),
                _voiceBubble(isSender: true, time: '09:50'),
                _chatBubble(
                  text:
                      'lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  isSender: false,
                  time: '09:55',
                ),
              ],
            ),
          ),
          _chatInput(),
        ],
      ),
    );
  }

  Widget _chatBubble({
    required String text,
    required bool isSender,
    required String time,
  }) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isSender ? const Color(0xFFD5ECFF) : Colors.transparent,
              border: Border.all(
                color: isSender ? Colors.transparent : const Color(0xFF218BCF),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _voiceBubble({required bool isSender, required String time}) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSender)
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage('assets/images/dr_annisa.png'),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSender ? const Color(0xFFD5ECFF) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.play_arrow),
                    SizedBox(width: 4),
                    SizedBox(
                      width: 80,
                      child: LinearProgressIndicator(
                        value: 0.4,
                        backgroundColor: Colors.white,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text('02:50'),
                  ],
                ),
              ),
            ],
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF218BCF),
      child: Row(
        children: [
          const Icon(Icons.edit, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Write Here...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

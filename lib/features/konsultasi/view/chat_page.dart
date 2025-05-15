import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dr. Annisa Irena, Sp.GK.'),
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
          const Expanded(
            child: Padding(padding: EdgeInsets.all(12), child: ChatBody()),
          ),
          const TypingIndicator(),
          const ChatInputBar(),
        ],
      ),
    );
  }
}

class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ChatBubble(
          text:
              "lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          time: "09:00",
          isMe: false,
        ),
        ChatBubble(
          text:
              "lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          time: "09:30",
          isMe: true,
          showBorder: true,
        ),
        ChatBubble(
          text:
              "lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          time: "09:43",
          isMe: false,
        ),
        VoiceMessageBubble(time: "09:50"),
        ChatBubble(
          text: "lorem ipsum dolor sit amet, consectetur adipiscing elit.",
          time: "09:55",
          isMe: false,
        ),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool showBorder;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    this.isMe = false,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isMe ? Colors.white : const Color(0xFFDDF2FF);
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
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bgColor,
          border: showBorder ? Border.all(color: Colors.blue) : null,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontSize: 14)),
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
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
        color: Colors.blue,
        child: Row(
          children: [
            const Icon(Icons.photo, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Write Here...",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.mic, color: Colors.white),
            const SizedBox(width: 8),
            const Icon(Icons.send, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

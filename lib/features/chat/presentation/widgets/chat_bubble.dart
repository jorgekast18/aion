import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageEntity message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF4C4DDC) : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: MarkdownBody(
          data: message.text,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: Colors.white, fontSize: 15),
            code: const TextStyle(
              backgroundColor: Colors.black38,
              fontFamily: 'monospace',
              fontSize: 13,
              color: Colors.orangeAccent,
            ),
            codeblockDecoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatHistoryLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
      builder: (context, state) {
        return Column(
          children: [
            if (state.isTyping)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Colors.deepPurpleAccent,
                minHeight: 2,
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.messages.length,
                itemBuilder: (context, index) => ChatBubble(message: state.messages[index]),
              ),
            ),
            _buildInput(),
          ],
        );
      },
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Pregunta a AION...",
                filled: true,
                fillColor: const Color(0xFF1E1E2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            backgroundColor: Colors.deepPurpleAccent,
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                context.read<ChatBloc>().add(ChatMessageSent(_controller.text));
                _controller.clear();
              }
            },
            child: const Icon(Icons.send, color: Colors.white),
          )
        ],
      ),
    );
  }
}
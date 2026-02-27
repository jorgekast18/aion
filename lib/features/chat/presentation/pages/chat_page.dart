// lib/features/chat/presentation/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Cargamos el historial al iniciar
    context.read<ChatBloc>().add(ChatHistoryLoaded());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        // Cada vez que llega un nuevo chunk del stream, bajamos el scroll
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
      builder: (context, state) {
        return Column(
          children: [
            // Lista de Mensajes
            Expanded(
              child: state.messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(message: state.messages[index]);
                },
              ),
            ),

            // Indicador de que la IA está pensando/escribiendo
            if (state.isTyping)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("AION está escribiendo...",
                    style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 12,
                        fontStyle: FontStyle.italic
                    )),
              ),

            // Barra de entrada de texto
            _buildInputArea(context, state.isTyping),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.deepPurpleAccent.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text("¿En qué puedo ayudarte hoy?",
              style: TextStyle(color: Colors.white54, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, bool isTyping) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121F),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Escribe un mensaje...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: isTyping ? null : (val) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: isTyping ? Colors.grey : Colors.deepPurpleAccent,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: isTyping ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    context.read<ChatBloc>().add(ChatMessageSent(_messageController.text.trim()));
    _messageController.clear();
  }
}
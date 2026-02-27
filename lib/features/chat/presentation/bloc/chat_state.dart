import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatState extends Equatable {
  final List<ChatMessageEntity> messages;
  final bool isTyping;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isTyping,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping, error];
}
part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<ChatMessageEntity> messages;
  final bool isTyping;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isTyping,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping, errorMessage];
}
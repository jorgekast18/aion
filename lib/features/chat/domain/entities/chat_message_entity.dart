import 'package:equatable/equatable.dart';

enum MessageRole { user, ai }

class ChatMessageEntity extends Equatable {
  final String id;
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
  });

  ChatMessageEntity copyWith({String? text}) {
    return ChatMessageEntity(
      id: id,
      text: text ?? this.text,
      role: role,
      timestamp: timestamp,
    );
  }

  @override
  List<Object?> get props => [id, text, role, timestamp];
}
import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  // Receive response from IA in real time
  Stream<String> getChatResponseStream(List<ChatMessageEntity> history);

  // Persistence
  Future<void> saveMessage(String userId, ChatMessageEntity message);
  Future<List<ChatMessageEntity>> getChatHistory(String userId);
}
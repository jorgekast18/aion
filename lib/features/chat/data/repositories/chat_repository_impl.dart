import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GenerativeModel _model;
  final FirebaseFirestore _firestore;

  ChatRepositoryImpl(this._model, this._firestore);

  @override
  Stream<String> getChatResponseStream(List<ChatMessageEntity> history) async* {
    // Convertimos nuestro historial al formato que entiende Gemini
    final contentHistory = history.map((m) {
      return m.role == MessageRole.user
          ? Content.text(m.text)
          : Content.model([TextPart(m.text)]);
    }).toList();

    // El último mensaje es el que dispara la respuesta
    final prompt = contentHistory.removeLast().parts.first as TextPart;

    final chat = _model.startChat(history: contentHistory);
    final responseStream = chat.sendMessageStream(Content.text(prompt.text));

    await for (final chunk in responseStream) {
      if (chunk.text != null) {
        yield chunk.text!;
      }
    }
  }

  @override
  Future<void> saveMessage(String userId, ChatMessageEntity message) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('messages')
        .doc(message.id)
        .set({
      'text': message.text,
      'role': message.role.name,
      'timestamp': message.timestamp.toIso8601String(),
    });
  }

  @override
  Future<List<ChatMessageEntity>> getChatHistory(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatMessageEntity(
        id: doc.id,
        text: data['text'],
        role: MessageRole.values.byName(data['role']),
        timestamp: DateTime.parse(data['timestamp']),
      );
    }).toList();
  }
}